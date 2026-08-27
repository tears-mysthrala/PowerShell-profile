Describe 'Dependency installer supply-chain policy' {
    BeforeAll {
        $script:scriptText = Get-Content "$PSScriptRoot\..\tools\install-dependencies.ps1" -Raw
        $runtimeFiles = @(
            Get-ChildItem "$PSScriptRoot\..\Core" -Recurse -File -Include *.ps1, *.psm1
            Get-Item "$PSScriptRoot\..\Microsoft.PowerShell_profile.ps1"
            Get-Item "$PSScriptRoot\..\tools\install-dependencies.ps1"
        )
        $script:runtimeText = ($runtimeFiles | ForEach-Object {
            Get-Content $_.FullName -Raw
        }) -join "`n"
    }

    It 'does not pipe downloaded content into Invoke-Expression' {
        $script:scriptText | Should -Not -Match 'Invoke-RestMethod[^\r\n]*\|\s*Invoke-Expression'
    }

    It 'does not download and execute the Chocolatey bootstrap script' {
        $script:scriptText | Should -Not -Match 'DownloadString\s*\('
        $script:scriptText | Should -Not -Match 'chocolatey\.org/install\.ps1'
    }

    It 'installs Chocolatey by exact WinGet id' {
        $script:scriptText | Should -Match 'winget install --id Chocolatey\.Chocolatey --exact --source winget'
    }

    It 'does not persistently trust PSGallery from profile runtime code' {
        $script:runtimeText | Should -Not -Match 'Set-PSRepository[^\r\n]+InstallationPolicy\s+Trusted'
    }
}
