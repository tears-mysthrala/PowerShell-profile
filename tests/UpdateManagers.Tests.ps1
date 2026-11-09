BeforeAll {
    . "$PSScriptRoot\..\Core\Apps\UpdateAppsHelper.ps1"
}

Describe 'Package manager failure handling' {
    It 'parses compact WinGet tables without dropping Copilot or TeamSpeak' {
        $packages = @(ConvertFrom-WingetUpgradeOutput -Output @(
            'Nombre      Id                                      Versión Disponible',
            '-------------------------------------------------------------------------',
            'Copilot CLI GitHub.Copilot                          v1.0.95 v1.0.96',
            'TeamSpeak   TeamSpeakSystems.TeamSpeakClient.Beta.6 5.0.0   6.0.0-beta4.1',
            'Zed         ZedIndustries.Zed                       1.14.2  1.23.3',
            ''
        ))
        $packages.Id | Should -Be @('GitHub.Copilot','TeamSpeakSystems.TeamSpeakClient.Beta.6','ZedIndustries.Zed')
        $packages[1].AvailableVersion | Should -Be '6.0.0-beta4.1'
    }

    It 'does not call an advertised but inapplicable WinGet upgrade a success' {
        Mock Get-WingetExecutable { 'test-winget' }
        Mock ConvertFrom-WingetUpgradeOutput { [pscustomobject]@{Name='Example';Id='Example.App';AvailableVersion='2.0'} }
        Mock Invoke-UpdateCommand {
            if ($Arguments -contains '--id') { return [pscustomobject]@{ExitCode=-1978335189;Output=@('No applicable upgrade')} }
            [pscustomobject]@{ExitCode=0;Output=@('upgrade table')}
        }
        Mock Write-UpdateStatus {}
        Update-Winget
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter {$Status -eq 'Error' -and $Message -match 'Example.App'}
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter {$Status -eq 'Success'}
    }

    It 'checks the upgrade list again after a successful installer exit' {
        Mock Get-WingetExecutable { 'test-winget' }
        Mock ConvertFrom-WingetUpgradeOutput { [pscustomobject]@{Name='Example';Id='Example.App';AvailableVersion='2.0'} }
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=0;Output=@('upgrade table')} }
        Mock Write-UpdateStatus {}
        Update-Winget
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter {$Status -eq 'Error' -and $Message -match 'still reports'}
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter {$Status -eq 'Success'}
    }

    It 'does not suppress a newer TeamSpeak release using a previous verification record' {
        $priorLocal = $env:LOCALAPPDATA
        try {
            $env:LOCALAPPDATA = $TestDrive
            $root = New-Item -ItemType Directory -Path "$TestDrive\SystemUpgrade\winget\TeamSpeakSystems.TeamSpeakClient.Beta.6" -Force
            @{Id='TeamSpeakSystems.TeamSpeakClient.Beta.6';PublishedVersion='6.0.0-beta4.1';BinaryHash=('a'*64)} |
                ConvertTo-Json | Set-Content "$root\verified-current.json"
            Test-WingetVerifiedCurrentPackage -Id 'TeamSpeakSystems.TeamSpeakClient.Beta.6' -AvailableVersion '6.0.0-beta5' | Should -BeFalse
        } finally { $env:LOCALAPPDATA = $priorLocal }
    }

    It 'limits scope recovery to the inspected applications' {
        Get-WingetScopeRecoveryPolicy -Id 'Unknown.Application' | Should -BeNullOrEmpty
        (Get-WingetScopeRecoveryPolicy -Id 'ZedIndustries.Zed').Scope | Should -Be 'User'
        (Get-WingetScopeRecoveryPolicy -Id 'Comfy.ComfyUI-Desktop').Scope | Should -Be 'Machine'
    }

    It 'rejects a changed installer before invoking it' {
        $priorLocal = $env:LOCALAPPDATA
        try {
            $env:LOCALAPPDATA = $TestDrive
            $download = New-Item -ItemType Directory -Path "$TestDrive\bad-download" -Force
            'bad installer' | Set-Content "$download\installer.exe"
            "PackageIdentifier: ZedIndustries.Zed`n  InstallerSha256: $('a'*64)`n" | Set-Content "$download\manifest.yaml"
            Mock Get-WingetScopeRecoveryInstallation { [pscustomobject]@{DisplayVersion='1.0';InstallLocation='C:\Existing'} }
            Mock Invoke-UpdateCommand {}
            { Update-WingetScopeMismatch -Id 'ZedIndustries.Zed' -Winget 'test-winget' -DownloadedDirectory $download } | Should -Throw '*checksum mismatch*'
            Should -Invoke Invoke-UpdateCommand -Times 0
        } finally { $env:LOCALAPPDATA = $priorLocal }
    }

    It 'parses Chocolatey remote versions and pin state without treating banners as packages' {
        $packages = @(ConvertFrom-ChocoOutdatedOutput -Output @('Chocolatey v2.6.0', 'nodejs.install|26.11.0|26.11.1|false', 'pinned|1.0|2.0|true'))
        $packages.Count | Should -Be 2
        $packages[0].Available | Should -Be '26.11.1'
        $packages[1].Pinned | Should -BeTrue
    }

    It 'continues Chocolatey updates after one failed package' {
        Mock Test-UpdateCommandExist { $Command -eq 'choco' }
        Mock Get-Command { [pscustomobject]@{Source='test-choco'} } -ParameterFilter {$Name -eq 'choco'}
        Mock Invoke-UpdateCommand {
            if ($Arguments[0] -eq 'outdated') { return [pscustomobject]@{ExitCode=0;Output=@('broken|1|2|false','working|1|2|false')} }
            if ($Arguments[1] -eq 'broken') { return [pscustomobject]@{ExitCode=1;Output=@('dependency failure')} }
            [pscustomobject]@{ExitCode=0;Output=@()}
        }
        Mock Write-UpdateStatus {}
        Update-Choco
        Should -Invoke Invoke-UpdateCommand -Times 1 -ParameterFilter {$Arguments[1] -eq 'working'}
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter {$Status -eq 'Error' -and $Message -match 'broken'}
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter {$Status -eq 'Success'}
    }
}
