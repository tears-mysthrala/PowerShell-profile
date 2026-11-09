BeforeAll {
    . "$PSScriptRoot\..\Core\Apps\UpdateAppsHelper.ps1"
}

Describe 'UpdateAppsHelper upgrade noise handling' {
    It 'captures stderr and a nonzero native exit code without reporting success' {
        $result = Invoke-UpdateCommand -Command (Get-Process -Id $PID).Path -Arguments @(
            '-NoProfile', '-Command', 'Write-Output "native-output"; [Console]::Error.WriteLine("native-error"); exit 7'
        )
        $result.ExitCode | Should -Be 7
        ($result.Output -join "`n") | Should -Match 'native-output'
        ($result.Output -join "`n") | Should -Match 'native-error'
    }

    It 'uses the publisher checksum for the exact Apache archive' {
        $manifest = [pscustomobject]@{ version = '2.4.69'; architecture = @{ '64bit' = @{
            url = 'https://fossies.org/windows/www/httpd-2.4.69-261002-Win64-VS18.zip'; hash = 'upstream-hash'
        } } }
        $hash = 'a' * 64
        $checksums = "SHA256-Checksum for: httpd-2.4.69-261002-Win64-VS18.zip:`r`n$hash`r`n"
        $result = Get-ApacheLoungeManifest -Manifest $manifest -Checksums $checksums
        $result.architecture.'64bit'.url | Should -Be 'https://www.apachelounge.com/download/VS18/binaries/httpd-2.4.69-261002-Win64-VS18.zip'
        $result.architecture.'64bit'.hash | Should -Be $hash
        $manifest.architecture.'64bit'.hash | Should -Be 'upstream-hash'
        { Get-ApacheLoungeManifest -Manifest $manifest -Checksums 'unrelated archive checksum' } | Should -Throw
    }

    It 'does not accept an arbitrary host as an Apache fallback source' {
        $manifest = [pscustomobject]@{ version = '2.4.69'; architecture = @{ '64bit' = @{
            url = 'https://example.com/httpd-2.4.69-261002-Win64-VS18.zip'
        } } }
        { Get-ApacheLoungeManifest -Manifest $manifest -Checksums '' } | Should -Throw
    }

    It 'restores the current Scoop metadata file after a legacy installation is upgraded' {
        $directory = New-Item -ItemType Directory -Path (Join-Path $TestDrive 'scoop-metadata') -Force
        '{}' | Set-Content -LiteralPath (Join-Path $directory 'install.json')
        Get-ScoopInstallInfoPath -Directory $directory | Should -Be (Join-Path $directory 'install.json')
        '{}' | Set-Content -LiteralPath (Join-Path $directory 'scoop-install.json')
        Get-ScoopInstallInfoPath -Directory $directory | Should -Be (Join-Path $directory 'scoop-install.json')
    }

    It 'restores Apache upstream tracking after mirror exit <Code>' -TestCases @(@{Code=0}, @{Code=1}) {
        param($Code)
        $fixtureRoot = Join-Path $TestDrive "mirror-$Code"
        $current = New-Item -ItemType Directory -Path "$fixtureRoot\apps\apache\current" -Force
        $bucket = New-Item -ItemType Directory -Path "$fixtureRoot\buckets\main\bucket" -Force
        @{bucket='main';architecture='64bit'} | ConvertTo-Json | Set-Content "$current\install.json"
        @{version='2.4.69';architecture=@{'64bit'=@{url='https://fossies.org/windows/www/httpd-2.4.69-261002-Win64-VS18.zip';hash=('b'*64)}}} |
            ConvertTo-Json -Depth 10 | Set-Content "$bucket\apache.json"
        $cacheFile = Join-Path $fixtureRoot 'cache\apache.zip'
        Mock Invoke-WebRequest {
            if ($OutFile) { 'archive' | Set-Content -LiteralPath $OutFile; return }
            return [pscustomobject]@{Content=("SHA256-Checksum for: httpd-2.4.69-261002-Win64-VS18.zip:`n" + ('a'*64) + "`n")}
        }
        Mock Get-FileHash { [pscustomobject]@{Hash=('a'*64)} }
        Mock Write-UpdateStatus {}
        Mock Invoke-UpdateCommand {
            if ($Arguments[-1] -like '*cache_path*') { return [pscustomobject]@{ExitCode=0;Output=@($cacheFile)} }
            @{architecture='64bit';url='temporary-mirror'} | ConvertTo-Json | Set-Content "$current\scoop-install.json"
            return [pscustomobject]@{ExitCode=$Code;Output=@()}
        }
        $previousScoop = $env:SCOOP
        $previousLocal = $env:LOCALAPPDATA
        try {
            $env:SCOOP = $fixtureRoot
            $env:LOCALAPPDATA = Join-Path $fixtureRoot 'local'
            $result = Update-ScoopApacheMirror
            $result.ExitCode | Should -Be $Code
            $restored = Get-Content "$current\scoop-install.json" -Raw | ConvertFrom-Json
            $restored.bucket | Should -Be 'main'
            $restored.PSObject.Properties.Name | Should -Not -Contain 'url'
        } finally {
            $env:SCOOP = $previousScoop
            $env:LOCALAPPDATA = $previousLocal
        }
    }

    It 'continues upgrading uv tools after one tool fails' {
        Mock Test-UpdateCommandExist { $true }
        Mock Get-UvSelfUpdateCommandPath { $null }
        Mock Write-UpdateStatus {}
        Mock Invoke-UpdateCommand {
            if ($Arguments[1] -eq 'list') {
                return [pscustomobject]@{ExitCode=0;Output=@('broken v1.0', '- broken-cli', 'working v2.0', '- working-cli')}
            }
            if ($Arguments[2] -eq 'broken') { return [pscustomobject]@{ExitCode=1;Output=@('source missing')} }
            return [pscustomobject]@{ExitCode=0;Output=@('up to date')}
        }
        Update-Uv
        Should -Invoke Invoke-UpdateCommand -Times 1 -ParameterFilter { $Arguments[2] -eq 'working' }
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' -and $Message -match 'broken' }
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter { $Status -eq 'Success' }
    }

    It 'treats absent Ruby and Conda as optional, but incomplete Ruby as an error' {
        Mock Get-CondaUpdateExecutable { $null }
        Mock Test-UpdateCommandExist { $false }
        Mock Write-UpdateStatus {}
        Update-Gem
        Update-Conda
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter { $Status -in @('Warning','Error') }
        Mock Test-UpdateCommandExist { $Command -eq 'ruby' }
        Update-Gem
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' -and $Message -match 'incomplete' }
    }

    It 'selects only old recognized npm staging folders and preserves other dot directories' {
        $root = Join-Path $TestDrive 'node_modules'
        $old = New-Item -ItemType Directory -Path "$root\@openai\.codex-1234abcd" -Force
        $old.LastWriteTime = (Get-Date).AddDays(-2)
        New-Item -ItemType Directory -Path "$root\.bin", "$root\.private-data", "$root\.recent-abcd1234" -Force | Out-Null
        $result = @(Get-NpmStagingDirectory -Root $root)
        $result.Count | Should -Be 1
        $result[0].Name | Should -Be '.codex-1234abcd'
    }

    It 'does not report npm success when a global update failed' {
        $root = New-Item -ItemType Directory -Path (Join-Path $TestDrive 'npm-failure') -Force
        $package = New-Item -ItemType Directory -Path (Join-Path $root 'example') -Force
        '{"name":"example"}' | Set-Content (Join-Path $package 'package.json')
        Mock Test-UpdateCommandExist { $true }
        Mock Get-CimInstance { @() }
        Mock Write-UpdateStatus {}
        Mock Invoke-UpdateCommand {
            if ($Arguments[0] -eq 'root') { return [pscustomobject]@{ExitCode=0;Output=@($root.FullName)} }
            if ($Arguments[0] -eq 'outdated') { return [pscustomobject]@{ExitCode=0;Output=@('{}')} }
            if ($Arguments[0] -eq 'update') { return [pscustomobject]@{ExitCode=1;Output=@('package locked')} }
            return [pscustomobject]@{ExitCode=0;Output=@()}
        }
        Update-Npm
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' -and $Message -match 'npm update' }
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter { $Status -eq 'Success' }
        Should -Invoke Invoke-UpdateCommand -Times 0 -ParameterFilter { $Arguments[2] -eq '@latest' }
    }

    It 'parses only the primary Winget upgrade table' {
        $output = @(
            'Name             Id                  Version Available Source',
            '--------------------------------------------------------------',
            'Google Chrome    Google.Chrome       1.0     2.0       winget',
            'CMake            Kitware.CMake       4.4.1   4.4.2     winget',
            '',
            'Packages requiring an explicit location:',
            'Battle.net       Blizzard.BattleNet  Unknown 1.2       winget'
        )

        $packages = @(ConvertFrom-WingetUpgradeOutput -Output $output)

        $packages.Id | Should -Be @('Google.Chrome', 'Kitware.CMake')
    }

    It 'parses a Winget id when the package name contains spaces and a version-like suffix' {
        $output = @(
            'Nombre                        Id                        Versión   Disponible Origen',
            '--------------------------------------------------------------------------------',
            'Logitech Gaming Software 5.10 Logitech.LGS              5.10.127  9.04.49    winget',
            ''
        )

        $result = @(ConvertFrom-WingetUpgradeOutput -Output $output)

        $result.Count | Should -Be 1
        $result[0].Name | Should -Be 'Logitech Gaming Software 5.10'
        $result[0].Id | Should -Be 'Logitech.LGS'
    }

    It 'parses only real Scoop update candidates from status output' {
        $statusOutput = @(
            'WARN  Scoop bucket(s) out of date. Run ''scoop update'' to get the latest changes.',
            '',
            'Name      Installed Version Latest Version Missing Dependencies Info',
            '----      ----------------- -------------- -------------------- ----',
            'erlang     28.5              29.0.3',
            'opencode   1.1.29                                                Deprecated, Manifest removed',
            'postgresql 18.4              18.4-2'
        )

        $candidates = ConvertFrom-ScoopStatusOutput -Output $statusOutput

        $candidates.Name | Should -Be @('erlang', 'postgresql')
        $candidates[0].InstalledVersion | Should -Be '28.5'
        $candidates[0].LatestVersion | Should -Be '29.0.3'
        $candidates[1].InstalledVersion | Should -Be '18.4'
        $candidates[1].LatestVersion | Should -Be '18.4-2'
    }

    It 'parses Scoop status objects returned by the PowerShell scoop script' {
        $statusOutput = @(
            [pscustomobject]@{ Name = 'erlang'; 'Installed Version' = '28.5'; 'Latest Version' = '29.0.3'; Info = '' },
            [pscustomobject]@{ Name = 'opencode'; 'Installed Version' = '1.1.29'; 'Latest Version' = ''; Info = 'Deprecated, Manifest removed' },
            [pscustomobject]@{ Name = 'postgresql'; 'Installed Version' = '18.4'; 'Latest Version' = '18.4-2'; Info = '' }
        )

        $candidates = ConvertFrom-ScoopStatusOutput -Output $statusOutput

        $candidates.Name | Should -Be @('erlang', 'postgresql')
    }

    It 'detects known Scoop packages that are blocked by running processes' {
        $processes = @(
            [pscustomobject]@{ ProcessName = 'erl' },
            [pscustomobject]@{ ProcessName = 'inet_gethost' },
            [pscustomobject]@{ ProcessName = 'postgres' }
        )

        (Get-ScoopPackageBlockers -Name 'erlang' -Process $processes) | Should -Be @('erl', 'inet_gethost')
        (Get-ScoopPackageBlockers -Name 'postgresql' -Process $processes) | Should -Be @('postgres')
        (Get-ScoopPackageBlockers -Name 'vscode' -Process $processes) | Should -BeNullOrEmpty
    }

    It 'recognizes WinGet-managed command shims' {
        Test-WingetManagedCommandPath 'C:\Users\unaiu\AppData\Local\Microsoft\WinGet\Links\chezmoi.exe' | Should -BeTrue
        Test-WingetManagedCommandPath 'C:\Users\unaiu\scoop\shims\chezmoi.exe' | Should -BeFalse
    }

    It 'prefers the active uv command over a stale legacy copy for self-update' {
        $active = 'C:\Users\unaiu\AppData\Local\hermes\bin\uv.exe'
        $legacy = 'C:\Users\unaiu\.local\bin\uv.exe'

        Get-UvSelfUpdateCommandPath -ActiveCommandPath $active -LegacyStandalonePath $legacy | Should -Be $active
    }

    It 'keeps Winget community and Microsoft Store updates in separate layers' {
        Mock Get-WingetExecutable { 'test-winget' }
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=-1978335189;Output=@()} }
        Mock Write-UpdateStatus {}
        Update-Winget
        Should -Invoke Invoke-UpdateCommand -Times 1 -ParameterFilter { $Arguments[0] -eq 'upgrade' -and $Arguments[1] -eq '--source' -and $Arguments[2] -eq 'winget' }
        ${function:Update-StoreApp}.ToString() | Should -Match 'upgrade --all --source msstore'
    }

    It 'does not expose an implicit repository submodule updater' {
        Get-Command Update-GitSubmodule -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
    }
}
