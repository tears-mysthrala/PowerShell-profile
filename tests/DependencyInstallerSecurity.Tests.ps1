Describe 'Dependency installer supply-chain policy' {
    BeforeAll {
        $scriptText = Get-Content "$PSScriptRoot\..\tools\install-dependencies.ps1" -Raw
    }

    It 'does not pipe downloaded content into Invoke-Expression' {
        $scriptText | Should -Not -Match 'Invoke-RestMethod[^\r\n]*\|\s*Invoke-Expression'
    }

    It 'does not download and execute the Chocolatey bootstrap script' {
        $scriptText | Should -Not -Match 'DownloadString\s*\('
        $scriptText | Should -Not -Match 'chocolatey\.org/install\.ps1'
    }

    It 'installs Chocolatey by exact WinGet id' {
        $scriptText | Should -Match 'winget install --id Chocolatey\.Chocolatey --exact --source winget'
    }
}
