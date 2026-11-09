BeforeAll { . "$PSScriptRoot\..\Core\Apps\UpdateAppsHelper.ps1" }
Describe 'WSL mise dotnet updates' {
    BeforeEach {
        Mock Test-UpdateCommandExist { $true }
        Mock Write-UpdateStatus {}
    }
    It 'propagates failed updates' {
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=1;Output=@('failed')} }
        Update-WslDotnet
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' }
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter { $Status -eq 'Success' }
    }
    It 'targets global requests in the configured distribution from HOME' {
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=0;Output=@()} }
        Update-WslDotnet -Distribution fedora
        Should -Invoke Invoke-UpdateCommand -Times 1 -ParameterFilter {
            $Arguments -contains 'fedora' -and $Arguments -contains '~' -and
            $Arguments[-1] -match 'upgrade --global dotnet --yes' -and $TimeoutSeconds -eq 1800
        }
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Success' }
    }
    It 'does not execute during WhatIf' {
        Mock Invoke-UpdateCommand { throw 'must not run' }
        Update-WslDotnet -WhatIf
        Should -Invoke Invoke-UpdateCommand -Times 0
    }
}
