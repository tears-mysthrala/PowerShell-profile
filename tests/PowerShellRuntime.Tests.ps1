BeforeAll {
    . "$PSScriptRoot\..\Core\Apps\UpdateAppsHelper.ps1"
}

Describe 'PowerShell stable release discovery' {
    It 'uses the bounded official redirect without the REST API' {
        Mock Invoke-WebRequest {
            [pscustomobject]@{ BaseResponse = @{ RequestMessage = @{ RequestUri = [uri]'https://github.com/PowerShell/PowerShell/releases/tag/v7.6.8' } } }
        }
        Get-PowerShellPublishedVersion | Should -Be ([version]'7.6.8')
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
            $Uri -eq 'https://github.com/PowerShell/PowerShell/releases/latest' -and $Method -eq 'Head' -and $TimeoutSec -eq 30
        }
    }

    It 'rejects unexpected or prerelease redirect <Redirect>' -ForEach @(
        @{ Redirect = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.7.0-preview.1' }
        @{ Redirect = 'https://example.com/PowerShell/PowerShell/releases/tag/v7.6.8' }
        @{ Redirect = 'https://github.com/PowerShell/PowerShell/releases/latest' }
    ) {
        Mock Invoke-WebRequest {
            [pscustomobject]@{ BaseResponse = @{ RequestMessage = @{ RequestUri = [uri]$Redirect } } }
        }
        { Get-PowerShellPublishedVersion } | Should -Throw '*Cannot determine*'
    }
}

Describe 'PowerShell runtime update failures and no-op' {
    BeforeEach {
        Mock Write-UpdateStatus {}
        Mock Invoke-WebRequest {}
    }

    It 'does not download anything when already current' {
        Mock Get-PowerShellPublishedVersion { [version]'1.0.0' }
        Update-PowerShellRuntime
        Should -Invoke Invoke-WebRequest -Times 0
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Success' -and $Message -match 'already current' }
    }

    It 'reports discovery failures without claiming success' {
        Mock Get-PowerShellPublishedVersion { throw 'network failure' }
        Update-PowerShellRuntime
        Should -Invoke Invoke-WebRequest -Times 0
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' -and $Message -match 'network failure' }
        Should -Invoke Write-UpdateStatus -Times 0 -ParameterFilter { $Status -eq 'Success' }
    }

    It 'downloads the official versioned MSI and refuses an invalid signature' {
        Mock Get-PowerShellPublishedVersion { [version]'99.1.0' }
        Mock Get-AuthenticodeSignature { [pscustomobject]@{ Status = 'NotSigned' } }
        Mock sudo {}
        Update-PowerShellRuntime
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
            $Uri -eq 'https://github.com/PowerShell/PowerShell/releases/download/v99.1.0/PowerShell-99.1.0-win-x64.msi' -and $TimeoutSec -eq 300
        }
        Should -Invoke sudo -Times 0
        Should -Invoke Write-UpdateStatus -Times 1 -ParameterFilter { $Status -eq 'Error' -and $Message -match 'refusing install' }
    }

    It 'does not perform discovery or downloads under WhatIf' {
        Mock Get-PowerShellPublishedVersion { throw 'must not run' }
        Update-PowerShellRuntime -WhatIf
        Should -Invoke Get-PowerShellPublishedVersion -Times 0
        Should -Invoke Invoke-WebRequest -Times 0
    }
}
