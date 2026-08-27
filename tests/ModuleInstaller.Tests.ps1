BeforeAll {
    Import-Module "$PSScriptRoot\..\Core\ModuleInstaller.ps1" -Force
    $script:moduleInstallerText = Get-Content "$PSScriptRoot\..\Core\ModuleInstaller.ps1" -Raw
}

Describe 'Targeted module installation' {
    It 'iterates only over explicitly requested names' {
        $script:moduleInstallerText | Should -Match 'foreach \(\$moduleName in \$Name\)'
        $script:moduleInstallerText | Should -Not -Match 'foreach \(\$module in \$requiredModules\.GetEnumerator\(\)\)'
    }

    It 'rejects modules outside the required-module allowlist before installation' {
        { Install-RequiredModule -Name ArbitraryModule } |
            Should -Throw '*Unknown required module*'
    }
}

Describe 'Profile lazy loading' {
    It 'passes the requested module name to the installer' {
        $profileText = Get-Content "$PSScriptRoot\..\Microsoft.PowerShell_profile.ps1" -Raw

        $profileText | Should -Match 'Install-RequiredModule -Name \$Name'
        $profileText | Should -Match '& \$script:LazyLoadModule -Name \$moduleName'
    }
}
