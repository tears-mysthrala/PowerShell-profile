BeforeAll {
    $script:profileText = Get-Content "$PSScriptRoot\..\Microsoft.PowerShell_profile.ps1" -Raw
    $script:aliasesText = Get-Content "$PSScriptRoot\..\Core\Utils\unified_aliases.ps1" -Raw
    $script:commandsManifest = Import-PowerShellDataFile "$PSScriptRoot\..\Modules\Profile.Commands\Profile.Commands.psd1"
    $script:chezmoiManifest = Import-PowerShellDataFile "$PSScriptRoot\..\Modules\Profile.Chezmoi\Profile.Chezmoi.psd1"
    $script:updateManifest = Import-PowerShellDataFile "$PSScriptRoot\..\Modules\Profile.Update\Profile.Update.psd1"
}

Describe 'Profile safety defaults' {
    It 'does not globally suppress diagnostic streams' {
        $script:profileText | Should -Not -Match '\$global:(Warning|Verbose|Information)Preference\s*='
    }

    It 'does not force unsafe Codex execution flags' {
        $script:profileText | Should -Not -Match 'dangerously-bypass-approvals-and-sandbox'
        $script:profileText | Should -Not -Match 'function\s+codex-safe'
    }

    It 'does not initialize rich terminal features on unsupported terminals' {
        $script:profileText | Should -Match '\$supportsVirtualTerminal'
        $script:profileText | Should -Match '\$env:TERM -ne ''dumb'''
    }

    It 'autoloads interactive commands instead of dot-sourcing their implementation' {
        $script:commandsManifest.FunctionsToExport | Should -Contain 'Clear-All'
        $script:commandsManifest.AliasesToExport | Should -Contain 'ff'
        $script:profileText | Should -Not -Match 'Core[\\/]Utils[\\/]unified_aliases\.ps1'
    }

    It 'keeps Chezmoi completion out of the general command module' {
        $script:chezmoiManifest.FunctionsToExport | Should -Contain 'cmc'
        $script:chezmoiManifest.AliasesToExport | Should -Contain 'cm'
        $script:commandsManifest.FunctionsToExport | Should -Not -Contain 'cmc'
    }

    It 'autoloads upgrade from its own module' {
        $script:updateManifest.FunctionsToExport | Should -Contain 'Update-System'
        $script:updateManifest.AliasesToExport | Should -Contain 'upgrade'
        $script:profileText | Should -Not -Match 'SystemUpdater\.ps1'
    }

    It 'loads function-defining helpers in profile scope' {
        $script:profileText | Should -Not -Match "Measure-Block 'Core Setup'"
        $script:profileText | Should -Match '\$coreSetupTimer'
    }

    It 'creates gst only after its lazy posh-git proxy exists' {
        $proxyIndex = $script:profileText.IndexOf('Set-Item "Function:\$command"')
        $aliasIndex = $script:profileText.IndexOf('Set-Alias -Name gst -Value Get-GitStatus')

        $proxyIndex | Should -BeGreaterThan -1
        $aliasIndex | Should -BeGreaterThan $proxyIndex
        $script:aliasesText | Should -Not -Match 'Set-Alias -Name gst'
    }
}

Describe 'Alias safety' {
    It 'does not replace PowerShell cat or ls semantics' {
        $script:aliasesText | Should -Not -Match 'Set-Alias -Name cat'
        $script:aliasesText | Should -Not -Match 'Set-Alias -Name ls'
    }

    It 'does not contain implicit third-party upload helpers' {
        $script:aliasesText | Should -Not -Match 'bin\.christitus\.com|ix\.io'
    }

    It 'does not publish a fixed SSH target' {
        $script:aliasesText | Should -Match 'PROXMOX_SSH_TARGET'
        $script:aliasesText | Should -Not -Match '(?m)^\s*ssh\s+-p\s+\d+\s+\S+@\S+'
    }
}
