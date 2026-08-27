BeforeDiscovery {
    function global:Test-IsAdmin { $true }
    . "$PSScriptRoot\..\Core\Apps\appsManage.ps1"
}

Describe 'AppsManage package discovery' {
    InModuleScope AppsManage {
        It 'extracts every Chocolatey package from limit output' {
            $output = @(
                'git|2.51.0'
                'ripgrep|14.1.1'
                '2 packages installed.'
            )

            @(ConvertFrom-ChocoListOutput -Output $output) | Should -Be @('git', 'ripgrep')
        }

        It 'extracts Scoop package names from objects' {
            $output = @(
                [pscustomobject]@{ Name = 'bat'; Version = '0.25.0' }
                [pscustomobject]@{ Name = 'fzf'; Version = '0.60.0' }
            )

            @(ConvertFrom-ScoopListOutput -Output $output) | Should -Be @('bat', 'fzf')
        }

        It 'ignores Scoop headings and accepts plain package names' {
            $output = @('Name', '----', 'bat', 'fzf')

            @(ConvertFrom-ScoopListOutput -Output $output) | Should -Be @('bat', 'fzf')
        }
    }
}

AfterAll {
    Remove-Item Function:\Test-IsAdmin -ErrorAction SilentlyContinue
}
