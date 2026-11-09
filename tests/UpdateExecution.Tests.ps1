BeforeAll {
    . "$PSScriptRoot\..\Core\Apps\UpdateAppsHelper.ps1"
}

Describe 'Native update execution' {
    It 'bounds a stalled native process without waiting for its output to close' {
        $clock = [Diagnostics.Stopwatch]::StartNew()
        $result = Invoke-UpdateCommand -Command (Get-Process -Id $PID).Path -Arguments @('-NoProfile','-Command','Start-Sleep 30') -TimeoutSeconds 1
        $result.ExitCode | Should -Be 124
        $clock.Elapsed.TotalSeconds | Should -BeLessThan 15
    }
}

Describe 'WSL runtime and distribution results' {
    BeforeEach {
        Mock Test-UpdateCommandExist { $true }
        Mock Get-WslPublishedVersion { [version]'3.0.3' }
        Mock Write-UpdateStatus {}
        Mock Invoke-UpdateCommand {
            if ($Arguments -contains '--version') { return [pscustomobject]@{ExitCode=0;Output=@('WSL version: 3.0.4.0')} }
            [pscustomobject]@{ExitCode=0;Output=@()}
        }
    }
    It 'verifies a current runtime without invoking a redundant update' {
        Update-WSL -Distribution FedoraLinux-43
        Should -Invoke Invoke-UpdateCommand -Times 0 -ParameterFilter { $Arguments -contains '--update' }
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Success' -and $Message -match 'runtime' }
    }
    It 'retains a failed runtime update even when the distribution succeeds' {
        Mock Get-WslPublishedVersion { [version]'3.1.0' }
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=1;Output=@('Forbidden (403)')} } -ParameterFilter { $Arguments -contains '--update' }
        Update-WSL
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' -and $Message -match 'runtime update failed' }
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Success' -and $Message -match 'distribution' }
    }
    It 'does not convert an unverified release into success' {
        Mock Get-WslPublishedVersion { throw 'network unavailable' }
        Update-WSL
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' -and $Message -match 'runtime check failed' }
    }
}

Describe 'Homebrew failure propagation' {
    BeforeEach {
        Mock Test-UpdateCommandExist { $true }
        Mock Write-UpdateStatus {}
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=0;Output=@()} }
    }
    It 'stops after a failed upgrade rather than overwriting its status with cleanup' {
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=3;Output=@('upgrade failed')} } -ParameterFilter { $Arguments -contains 'upgrade' }
        Update-Homebrew
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' }
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter { $Status -eq 'Success' }
        Should -Invoke Invoke-UpdateCommand -Times 0 -ParameterFilter { $Arguments -contains 'cleanup' }
    }
    It 'runs with explicit distribution, no prompt and portable Ruby for sandbox support' {
        Update-Homebrew
        Should -Invoke Invoke-UpdateCommand -Times 1 -ParameterFilter {
            $Arguments -contains 'upgrade' -and $Arguments -contains '--no-ask' -and
            $Arguments -contains 'fedora' -and $Arguments -contains 'HOMEBREW_FORCE_VENDOR_RUBY=1'
        }
    }
}

Describe 'Node project verification' {
    BeforeEach {
        $script:projectRoot = Join-Path $TestDrive 'project'
        New-Item -ItemType Directory -Path $script:projectRoot -Force | Out-Null
        '{}' | Set-Content (Join-Path $script:projectRoot 'package.json')
        Mock Test-UpdateCommandExist { $true }
        Mock Write-UpdateStatus {}
        Mock Invoke-UpdateCommand {
            $json = if ($Arguments[0] -eq 'audit') { '{"metadata":{"vulnerabilities":{"total":0}}}' } else { '{}' }
            [pscustomobject]@{ExitCode=0;Output=@($json)}
        }
    }
    It 'does not update packages for an empty outdated object' {
        Update-NodeEnvironment -ProjectPath $script:projectRoot
        Should -Invoke Invoke-UpdateCommand -Times 0 -ParameterFilter { $Arguments[0] -eq 'update' }
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Success' }
    }
    It 'counts audit findings as an error even after a successful update' {
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=1;Output=@('{"metadata":{"vulnerabilities":{"total":2}}}')} } -ParameterFilter { $Arguments[0] -eq 'audit' }
        Update-NodeEnvironment -ProjectPath $script:projectRoot
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' -and $Message -match '2 vulnerable' }
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter { $Status -eq 'Success' }
    }
    It 'reports dependencies that remain behind the declared version range' {
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=1;Output=@('{"example":{"current":"1","wanted":"2","latest":"3"}}')} } -ParameterFilter { $Arguments[0] -eq 'outdated' }
        Update-NodeEnvironment -ProjectPath $script:projectRoot
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Warning' -and $Message -match 'pending dependencies' }
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter { $Status -eq 'Success' }
    }
    It 'distinguishes newer major releases from pending compatible updates' {
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=1;Output=@('{"example":{"current":"1","wanted":"1","latest":"2"}}')} } -ParameterFilter { $Arguments[0] -eq 'outdated' }
        Update-NodeEnvironment -ProjectPath $script:projectRoot
        Should -Invoke Invoke-UpdateCommand -Times 0 -ParameterFilter { $Arguments[0] -eq 'update' }
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Info' -and $Message -match 'outside its declared ranges' }
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter { $Status -eq 'Warning' -or $Status -eq 'Error' }
    }
    It 'rejects malformed discovery instead of treating it as no updates' {
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=1;Output=@('not json')} }
        Update-NodeEnvironment -ProjectPath $script:projectRoot
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' }
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter { $Status -eq 'Success' }
    }
    It 'does not recurse into hidden application projects' {
        $hidden = New-Item -ItemType Directory -Path (Join-Path $script:projectRoot '.config\app') -Force
        '{}' | Set-Content (Join-Path $hidden 'package.json')
        Update-NodeEnvironment -ProjectPath $script:projectRoot
        Should -Invoke Invoke-UpdateCommand -Times 1 -ParameterFilter { $Arguments[0] -eq 'audit' }
    }
    It 'does not mutate or query projects under WhatIf' {
        Update-NodeEnvironment -ProjectPath $script:projectRoot -WhatIf
        Should -Invoke Invoke-UpdateCommand -Times 0
    }
}

Describe 'Active npm applications' {
    It 'excludes a running scoped CLI while allowing unrelated packages' {
        $root = New-Item -ItemType Directory -Path "$TestDrive\global\@openai\codex" -Force
        '{"name":"@openai/codex"}' | Set-Content (Join-Path $root 'package.json')
        $other = New-Item -ItemType Directory -Path "$TestDrive\global\example" -Force
        '{"name":"example"}' | Set-Content (Join-Path $other 'package.json')
        $packages = @(Get-NpmGlobalUpdatePackage -Root "$TestDrive\global" -Process @(
            [pscustomobject]@{ExecutablePath="$root\vendor\codex.exe";CommandLine='codex'}
        ))
        ($packages | Where-Object Name -eq '@openai/codex').Busy | Should -BeTrue
        ($packages | Where-Object Name -eq 'example').Busy | Should -BeFalse
    }
}

Describe 'Official VS Code recovery' {
    It 'does not download or install under WhatIf' {
        Mock Invoke-RestMethod { throw 'must not query' }
        Mock Start-Process { throw 'must not install' }
        Update-VSCodeUserPackage -AvailableVersion 1.142.0 -WhatIf
        Should -Invoke Invoke-RestMethod -Times 0
        Should -Invoke Start-Process -Times 0
    }

    It 'rejects a publisher metadata version mismatch' {
        $oldLocal = $env:LOCALAPPDATA
        try {
            $env:LOCALAPPDATA = $TestDrive
            $directory = New-Item -ItemType Directory -Path "$TestDrive\Programs\Microsoft VS Code" -Force
            'fixture' | Set-Content (Join-Path $directory 'Code.exe')
            Mock Get-Process { @() }
            Mock Invoke-RestMethod { [pscustomobject]@{name='1.0.0';sha256hash=('a'*64);url='https://example.com/installer.exe'} }
            Mock Start-Process {}
            { Update-VSCodeUserPackage -AvailableVersion 1.142.0 } | Should -Throw '*metadata does not match*'
            Should -Invoke Start-Process -Times 0
        } finally { $env:LOCALAPPDATA = $oldLocal }
    }
    It 'rejects an older installer URL even if metadata advertises the new version' {
        $oldLocal = $env:LOCALAPPDATA
        try {
            $env:LOCALAPPDATA = $TestDrive
            $directory = New-Item -ItemType Directory -Path "$TestDrive\Programs\Microsoft VS Code" -Force
            'fixture' | Set-Content (Join-Path $directory 'Code.exe')
            Mock Get-Process { @() }
            Mock Invoke-RestMethod { [pscustomobject]@{name='1.142.0';sha256hash=('a'*64);url='https://vscode.download.prss.microsoft.com/dbazure/download/stable/test/VSCodeUserSetup-x64-1.141.2.exe'} }
            Mock Invoke-WebRequest { throw 'must not download' }
            { Update-VSCodeUserPackage -AvailableVersion 1.142.0 } | Should -Throw '*metadata does not match*'
            Should -Invoke Invoke-WebRequest -Times 0
        } finally { $env:LOCALAPPDATA = $oldLocal }
    }
}
