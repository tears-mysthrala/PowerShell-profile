BeforeAll {
    $fzfScript = Get-Content "$PSScriptRoot\..\Core\System\fzf.ps1" -Raw
    $functionAst = [scriptblock]::Create($fzfScript).Ast.Find(
        { param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Remove-FzfSelectedPath' },
        $true
    )
    . ([scriptblock]::Create($functionAst.Extent.Text))
}

Describe 'Destructive helper safety' {
    It 'does not remove an fzf-selected path under WhatIf' {
        $target = Join-Path $TestDrive 'keep-me'
        New-Item -Path $target -ItemType Directory | Out-Null
        Set-Content -Path (Join-Path $target 'data.txt') -Value 'test'

        Remove-FzfSelectedPath -Path $target -WhatIf

        $target | Should -Exist
        (Join-Path $target 'data.txt') | Should -Exist
    }

    It 'refuses to remove a filesystem root' {
        $root = [System.IO.Path]::GetPathRoot($TestDrive)

        { Remove-FzfSelectedPath -Path $root -Confirm:$false } | Should -Throw '*filesystem root*'
    }
}
