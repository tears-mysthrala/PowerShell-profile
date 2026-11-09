BeforeAll {
    . "$PSScriptRoot\..\Core\Apps\UpdateAppsHelper.ps1"
}

Describe 'Conda discovery and failure reporting' {
    It 'finds Miniforge without a PATH entry' {
        Mock Get-Command { $null }
        Mock Test-Path { $LiteralPath -eq "$env:USERPROFILE\miniforge3\Scripts\conda.exe" }
        Get-CondaUpdateExecutable | Should -Be "$env:USERPROFILE\miniforge3\Scripts\conda.exe"
    }
    BeforeEach {
        Mock Write-UpdateStatus {}
    }
    It 'stops when the installed Conda cannot start' {
        Mock Get-CondaUpdateExecutable { 'conda.exe' }
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=1;Output=@('broken dependency')} }
        Update-Conda
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' }
        Should -Invoke Invoke-UpdateCommand -Times 1 -Exactly
    }
    It 'does not claim success after a native update failure' {
        Mock Get-CondaUpdateExecutable { 'conda.exe' }
        Mock Invoke-UpdateCommand {
            if ($Arguments[0] -eq 'info') { return [pscustomobject]@{ExitCode=0;Output=@('{"root_prefix":"C:/base"}')} }
            [pscustomobject]@{ExitCode=1;Output=@()}
        }
        Update-Conda
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter { $Status -eq 'Success' }
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' }
    }
    It 'reports remaining package changes after an apparently successful update' {
        Mock Get-CondaUpdateExecutable { 'conda.exe' }
        Mock Invoke-UpdateCommand {
            if ($Arguments[0] -eq 'info') { return [pscustomobject]@{ExitCode=0;Output=@('{"root_prefix":"C:/base"}')} }
            [pscustomobject]@{ExitCode=0;Output=@('{"success":true,"actions":{"LINK":[{"name":"pending"}]}}')}
        }
        Update-Conda
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter { $Status -eq 'Success' }
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' }
    }
}

Describe 'MSYS2 native update safety' {
    BeforeEach {
        Mock Write-UpdateStatus {}
        Mock Test-Path { $LiteralPath -like '*bash.exe' }
        Mock Get-Process { @() }
    }
    It 'leaves an active installation alone' {
        Mock Get-Process { [pscustomobject]@{Path='C:\msys64\usr\bin\bash.exe'} }
        Mock Invoke-UpdateCommand { throw 'must not run' }
        Update-Msys2
        Should -Invoke Invoke-UpdateCommand -Times 0
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Warning' }
    }
    It 'uses a fresh shell after core updates and checks pending packages' {
        Mock Invoke-UpdateCommand {
            if ($Arguments[-1] -match 'pacman -Qu') { return [pscustomobject]@{ExitCode=1;Output=@()} }
            [pscustomobject]@{ExitCode=0;Output=@()}
        }
        Update-Msys2
        Should -Invoke Invoke-UpdateCommand -Times 2 -Exactly -ParameterFilter { $Arguments[-1] -match 'pacman -Syu' }
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Success' }
    }
    It 'stops after a failed transaction' {
        Mock Invoke-UpdateCommand { [pscustomobject]@{ExitCode=1;Output=@('failed')} }
        Update-Msys2
        Should -Invoke Invoke-UpdateCommand -Times 1 -Exactly
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' }
    }
}
