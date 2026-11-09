BeforeAll {
    . "$PSScriptRoot\..\Core\Apps\UpdateAppsHelper.ps1"
}

Describe 'Upgrade recovery boundaries' {
    It 'retries only the package requiring packaged-service elevation' {
        Mock Get-WingetExecutable { 'test-winget' }
        Mock Test-UpdateCommandExist { $true }
        Mock Test-WingetVerifiedCurrentPackage { $false }
        Mock ConvertFrom-WingetUpgradeOutput {
            if ($Output -contains 'initial') { [pscustomobject]@{Id='OpenAI.ChatGPT';Name='ChatGPT';AvailableVersion='2.0'} }
        }
        Mock Invoke-UpdateCommand {
            if ($Command -eq 'sudo') { return [pscustomobject]@{ExitCode=0;Output=@()} }
            if ($Arguments -contains '--id') { return [pscustomobject]@{ExitCode=-2147009240;Output=@()} }
            [pscustomobject]@{ExitCode=0;Output=@('initial')}
        }
        Mock Write-UpdateStatus {}
        Update-Winget
        Should -Invoke Invoke-UpdateCommand -Times 1 -Exactly -ParameterFilter {
            $Command -eq 'sudo' -and $Arguments[0] -eq '--inline' -and $Arguments -contains 'OpenAI.ChatGPT'
        }
    }

    It 'does not retry a cancelled installer with elevation' {
        Mock Get-WingetExecutable { 'test-winget' }
        Mock Test-WingetVerifiedCurrentPackage { $false }
        Mock ConvertFrom-WingetUpgradeOutput { [pscustomobject]@{Id='Example.App';Name='Example';AvailableVersion='2.0'} }
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=-2147023673;Output=@()} }
        Mock Write-UpdateStatus {}
        Update-Winget
        Should -Invoke Invoke-UpdateCommand -Times 0 -ParameterFilter { $Command -eq 'sudo' }
    }

    It 'leaves Chocolatey pending on reboot-required exit 350' {
        Mock Test-UpdateCommandExist { $true }
        Mock Get-Command { [pscustomobject]@{Source='test-choco'} } -ParameterFilter { $Name -eq 'choco' }
        Mock Invoke-ChocoUpdateCommand {
            if ($Arguments[0] -eq 'outdated') { return [pscustomobject]@{ExitCode=0;Output=@('first|1|2|false','second|1|2|false')} }
            [pscustomobject]@{ExitCode=350;Output=@()}
        }
        Mock Write-UpdateStatus {}
        Update-Choco
        Should -Invoke Invoke-ChocoUpdateCommand -Times 1 -Exactly -ParameterFilter { $Arguments[0] -eq 'upgrade' }
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Warning' -and $Message -match 'remain pending' }
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter { $Status -in @('Error','Success') }
    }

    It 'reports Windows Update exit <ExitCode> as <ExpectedStatus>' -ForEach @(
        @{ExitCode=1;ExpectedStatus='Error'}
        @{ExitCode=3010;ExpectedStatus='Warning'}
    ) {
        Mock Get-Module { $true }
        Mock Get-Command { $true }
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=$ExitCode;Output=@('Fixture')} }
        Mock Write-UpdateStatus {}
        Update-WindowsSystem
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq $ExpectedStatus }
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter { $Status -eq 'Success' }
    }

    It 'uses the binary version independently of the running session' {
        Mock Get-Item { [pscustomobject]@{VersionInfo=@{ProductVersion='7.6.9 SHA: abcdef'}} }
        Get-InstalledPowerShellVersion | Should -Be ([version]'7.6.9')
    }

    It 'does not trust a zero MSI exit without the installed version changing' {
        Mock Get-InstalledPowerShellVersion { [version]'1.0.0' }
        Mock Get-PowerShellPublishedVersion { [version]'99.0.0' }
        Mock Invoke-WebRequest {}
        Mock Get-AuthenticodeSignature { [pscustomobject]@{Status='Valid';SignerCertificate=@{Subject='Microsoft Corporation'}} }
        Mock Test-UpdateCommandExist { $true }
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=0;Output=@()} }
        Mock Write-UpdateStatus {}
        Update-PowerShellRuntime
        Should -Invoke Invoke-UpdateCommand -Times 1 -ParameterFilter { $Arguments[0] -eq '--inline' }
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' -and $Message -match 'not verified' }
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter { $Status -eq 'Success' -and $Message -match 'update completed' }
    }
}

Describe 'Elevated Windows Update worker exit status' {
    It 'returns <Expected> for simulated <Mode> results' -ForEach @(
        @{Mode='Failed';Expected=1}
        @{Mode='Installed';Expected=0}
        @{Mode='Downloaded';Expected=1}
        @{Mode='Reboot';Expected=3010}
    ) {
        $moduleDirectory = New-Item -ItemType Directory -Path "$TestDrive\modules\PSWindowsUpdate" -Force
        $fixtureModule = @'
function Get-WindowsUpdate { [pscustomobject]@{Title='Fixture'} }
function Install-WindowsUpdate {
    param([switch]$AcceptAll,[switch]$IgnoreReboot)
    [pscustomobject]@{ComputerName='Fixture';Result='FIXTURE_RESULT';KB='KBTEST';Size='1MB';Title='Fixture'}
}
function Get-WURebootStatus { param([switch]$Silent) 'FIXTURE_RESULT' -eq 'Reboot' }
'@
        $fixtureModule.Replace('FIXTURE_RESULT', $Mode) | Set-Content -LiteralPath (Join-Path $moduleDirectory 'PSWindowsUpdate.psm1')
        $previousPath = $env:PSModulePath
        try {
            $env:PSModulePath = "$TestDrive\modules"
            $env:UPGRADE_TEST_RESULT = $Mode
            $worker = [IO.Path]::GetFullPath("$PSScriptRoot\..\Core\Apps\Updates\InstallWindowsUpdates.ps1")
            $fixturePath = (Join-Path $moduleDirectory 'PSWindowsUpdate.psm1').Replace("'", "''")
            $wrapper = Join-Path $TestDrive 'worker-fixture.ps1'
            (Get-Content -LiteralPath $worker -Raw).Replace('Import-Module PSWindowsUpdate -ErrorAction Stop', "Import-Module '$fixturePath' -Force -ErrorAction Stop") | Set-Content -LiteralPath $wrapper
            $result = Invoke-UpdateCommand -Command (Get-Process -Id $PID).Path -Arguments @('-NoProfile','-File',$wrapper) -TimeoutSeconds 15
            $result.ExitCode | Should -Be $Expected
        } finally {
            $env:PSModulePath = $previousPath
            Remove-Item Env:\UPGRADE_TEST_RESULT
        }
    }
}
