Describe 'Documentation generator' {
    BeforeAll {
        $script:fixtureRoot = Join-Path $TestDrive 'repo'
        $script:outputDir = Join-Path $script:fixtureRoot 'docs'
        New-Item -Path (Join-Path $script:fixtureRoot 'Core') -ItemType Directory -Force | Out-Null
        New-Item -Path (Join-Path $script:fixtureRoot 'tools') -ItemType Directory -Force | Out-Null
        New-Item -Path (Join-Path $script:fixtureRoot 'tests') -ItemType Directory -Force | Out-Null

        @'
function Get-PublicThing {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )
}

function Get-SecondThing { 'ok' }
'@ | Set-Content (Join-Path $script:fixtureRoot 'Core\Sample.ps1')

        "function Test-OnlyThing {}`n" |
            Set-Content (Join-Path $script:fixtureRoot 'tests\Sample.Tests.ps1')
        "# Fixture`n" | Set-Content (Join-Path $script:fixtureRoot 'README.md')

        & "$PSScriptRoot\..\tools\generate_function_docs.ps1" `
            -RepoRoot $script:fixtureRoot `
            -OutputDir $script:outputDir

        $script:reference = Get-Content (Join-Path $script:outputDir 'FunctionReference.md') -Raw
    }

    It 'uses AST extents for multiline function signatures' {
        $script:reference | Should -Match '(?s)function Get-PublicThing \{\s*\[CmdletBinding\(\)\].*\[string\]\$Name.*\}'
    }

    It 'documents parameterless functions without leaking their bodies' {
        $script:reference | Should -Match 'function Get-SecondThing\s*```'
        $script:reference | Should -Not -Match "'ok'"
    }

    It 'excludes tests from the public function inventory' {
        $script:reference | Should -Not -Match 'Test-OnlyThing'
    }
}
