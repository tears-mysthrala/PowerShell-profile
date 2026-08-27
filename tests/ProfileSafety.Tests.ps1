BeforeAll {
    $script:profileText = Get-Content "$PSScriptRoot\..\Microsoft.PowerShell_profile.ps1" -Raw
    $script:aliasesText = Get-Content "$PSScriptRoot\..\Core\Utils\unified_aliases.ps1" -Raw
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

    It 'loads documented lightweight system helpers' {
        foreach ($helper in @('linuxLike.ps1', 'clean.ps1', 'chezmoi.ps1')) {
            $pattern = [regex]::Escape($helper)
            $script:profileText | Should -Match $pattern
        }
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
