Describe 'CI quality policy' {
    BeforeAll {
        $script:workflow = Get-Content "$PSScriptRoot\..\.github\workflows\ci.yml" -Raw
    }

    It 'fails on every PSScriptAnalyzer finding regardless of severity' {
        $script:workflow | Should -Match 'if \(\$results\.Count -gt 0\) \{ exit 1 \}'
        $script:workflow | Should -Not -Match 'Where-Object Severity -eq ''Error'''
    }

    It 'runs the complete Pester suite' {
        $script:workflow | Should -Match 'Run Pester tests'
        $script:workflow | Should -Match "Run\.Path = @\('tests'\)"
    }
}
