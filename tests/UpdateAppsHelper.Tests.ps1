BeforeAll {
    . "$PSScriptRoot\..\Core\Apps\UpdateAppsHelper.ps1"
}

Describe 'UpdateAppsHelper upgrade noise handling' {
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
}
