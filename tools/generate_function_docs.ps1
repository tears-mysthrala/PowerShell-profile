<#
.SYNOPSIS
    Professional documentation generator for PowerShell Profile project.

.DESCRIPTION
    Scans all PowerShell source files in the repository and generates comprehensive
    documentation including:
    - Function reference with signatures and descriptions
    - Module documentation
    - Performance metrics
    - Cross-references and examples

.PARAMETER RepoRoot
    Root directory of the repository. Defaults to parent of script location.

.PARAMETER OutputDir
    Directory where documentation will be generated. Defaults to 'docs' folder.

.PARAMETER Verbose
    Show detailed progress information.

.EXAMPLE
    .\generate_function_docs.ps1
    Generates all documentation with default settings.

.EXAMPLE
    .\generate_function_docs.ps1 -Verbose
    Generates documentation with detailed progress output.
#>

[CmdletBinding()]
Param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$OutputDir = "$RepoRoot\docs"
)

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Performance tracking
$sw = [System.Diagnostics.Stopwatch]::StartNew()

Write-Verbose "=== PowerShell Profile Documentation Generator ==="
Write-Verbose "Repository Root: $RepoRoot"
Write-Verbose "Output Directory: $OutputDir"
Write-Verbose ""

#region Helper Functions

function Get-PrecedingCommentBlock {
    <#
    .SYNOPSIS
        Extract comment block immediately above a function declaration.
    #>
    param(
        [string]$Text,
        [int]$StartIndex
    )

    $before = $Text.Substring(0, $StartIndex)

    # Try block comment first (<# ... #>)
    $blockPattern = '(?s)<#(.*?)#>\s*$'
    $match = [regex]::Match($before, $blockPattern)
    
    if ($match.Success) {
        $comment = $match.Groups[1].Value.Trim()
        
        # Parse structured comment
        $structured = @{
            Synopsis    = ''
            Description = ''
            Examples    = @()
            Parameters  = @{}
            Notes       = ''
        }
        
        $currentSection = 'Description'
        $lines = $comment -split "\r?\n"
        
        foreach ($line in $lines) {
            $cleanLine = $line.Trim()
            
            if ($cleanLine -match '^\.(SYNOPSIS|DESCRIPTION|EXAMPLE|PARAMETER|NOTES)') {
                $currentSection = $matches[1]
                continue
            }
            
            if ($cleanLine) {
                switch ($currentSection) {
                    'SYNOPSIS' { $structured.Synopsis += " $cleanLine" }
                    'DESCRIPTION' { $structured.Description += " $cleanLine" }
                    'EXAMPLE' { $structured.Examples += $cleanLine }
                    'NOTES' { $structured.Notes += " $cleanLine" }
                }
            }
        }
        
        return $structured
    }

    # Fallback: single-line comments
    $lines = $before -split "\r?\n"
    $commentLines = @()
    
    for ($i = $lines.Length - 1; $i -ge 0; $i--) {
        if ($lines[$i] -match '^[ \t]*#\s*(.+)$') {
            $commentLines = , $matches[1] + $commentLines
        }
        elseif ($lines[$i] -match '^[ \t]*$') {
            if ($commentLines.Count -gt 0) { break }
        }
        else { break }
    }
    
    if ($commentLines.Count -gt 0) {
        return @{ Description = ($commentLines -join ' ').Trim() }
    }
    
    return @{ Description = '' }
}

function Get-FunctionSignature {
    <#
    .SYNOPSIS
        Extract complete function signature including parameters.
    #>
    param([System.Management.Automation.Language.FunctionDefinitionAst]$FunctionAst)

    $declaration = "function $($FunctionAst.Name)"
    if (-not $FunctionAst.Body.ParamBlock) {
        return $declaration
    }

    $paramAst = $FunctionAst.Body.ParamBlock
    $attributes = @($paramAst.Attributes | ForEach-Object { $_.Extent.Text.Trim() })
    $paramBlock = (($paramAst.Extent.Text.Trim() -split "\r?\n") |
        ForEach-Object { $_.TrimEnd() }) -join "`n"
    $signatureParts = @($declaration + ' {') + $attributes + $paramBlock + '}'
    return ($signatureParts -join "`n")
}

function Write-Utf8File {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Content
    )

    $normalized = ($Content -replace "`r`n", "`n").TrimEnd() + "`n"
    [System.IO.File]::WriteAllText(
        $Path,
        $normalized,
        [System.Text.UTF8Encoding]::new($false)
    )
}

function Get-SourceCategory {
    <#
    .SYNOPSIS
        Categorize source file based on path.
    #>
    param([string]$Path)
    
    $relativePath = $Path.Replace($RepoRoot, '').TrimStart('\', '/')
    
    if ($relativePath -match '^Core\\Utils') { return 'Utilities' }
    if ($relativePath -match '^Core\\Apps') { return 'Applications' }
    if ($relativePath -match '^Core\\System') { return 'System' }
    if ($relativePath -match '^Core') { return 'Core' }
    if ($relativePath -match '^tools') { return 'Tools' }
    if ($relativePath -eq 'Microsoft.PowerShell_profile.ps1') { return 'Profile' }
    
    return 'Other'
}

#endregion

#region Scan Functions

Write-Verbose "Scanning for PowerShell files..."

$sourcePaths = @(
    (Join-Path $RepoRoot 'Core'),
    (Join-Path $RepoRoot 'tools'),
    (Join-Path $RepoRoot 'Microsoft.PowerShell_profile.ps1')
)
$files = @(
    Get-ChildItem -Path $sourcePaths -Recurse -Include *.ps1, *.psm1 -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -ne $PSCommandPath } |
        Sort-Object FullName
)

Write-Verbose "Found $($files.Count) PowerShell files to scan"

$functions = @{}
$aliases = @{}
$categories = @{}

$aliasPattern = '(?m)Set-Alias\s+-Name\s+([A-Za-z0-9_\-]+)\s+-Value\s+([A-Za-z0-9_\-]+)'

foreach ($file in $files) {
    Write-Verbose "  Processing: $($file.Name)"
    
    try {
        $content = Get-Content -Raw -LiteralPath $file.FullName -ErrorAction Stop
        if (-not $content) { continue }
        
        $category = Get-SourceCategory $file.FullName

        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile(
            $file.FullName,
            [ref]$tokens,
            [ref]$parseErrors
        )
        if ($parseErrors.Count -gt 0) {
            throw "Cannot document a file with syntax errors: $($parseErrors.Message -join '; ')"
        }

        # Extract functions from the parsed syntax tree so multiline parameter
        # blocks and line endings cannot corrupt signatures.
        $functionAsts = $ast.FindAll({
            param($node)
            $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
        }, $true)
        foreach ($functionAst in $functionAsts) {
            $name = $functionAst.Name

            if (-not $functions.ContainsKey($name)) {
                $sig = Get-FunctionSignature -FunctionAst $functionAst
                $doc = Get-PrecedingCommentBlock $content $functionAst.Extent.StartOffset
                
                $functions[$name] = @{
                    Name          = $name
                    Signature     = $sig
                    Documentation = $doc
                    Source        = $file.FullName.Replace($RepoRoot, '').TrimStart('\', '/')
                    Category      = $category
                }
                
                if (-not $categories.ContainsKey($category)) {
                    $categories[$category] = @()
                }
                $categories[$category] += $name
            }
        }
        
        # Extract aliases
        $aliasMatches = [regex]::Matches($content, $aliasPattern)
        foreach ($match in $aliasMatches) {
            $aliasName = $match.Groups[1].Value
            $targetName = $match.Groups[2].Value
            
            if (-not $aliases.ContainsKey($aliasName)) {
                $aliases[$aliasName] = @{
                    Alias  = $aliasName
                    Target = $targetName
                    Source = $file.FullName.Replace($RepoRoot, '').TrimStart('\', '/')
                }
            }
        }
    }
    catch {
        Write-Warning "Error processing $($file.Name): $_"
    }
}

Write-Verbose ""
Write-Verbose "Scan complete:"
Write-Verbose "  Functions: $($functions.Count)"
Write-Verbose "  Aliases: $($aliases.Count)"
Write-Verbose "  Categories: $($categories.Count)"
Write-Verbose ""

#endregion

#region Generate Documentation

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

# 1. Function Reference (detailed)
Write-Verbose "Generating FunctionReference.md..."
$output = @()
$output += "# Function Reference"
$output += ""
$output += "> **Auto-generated documentation**"
$output += "> Last updated: $timestamp"
$output += "> Total functions: $($functions.Count)"
$output += ""
$output += "## Table of Contents"
$output += ""

foreach ($cat in ($categories.Keys | Sort-Object)) {
    $output += "- [$cat](#$($cat.ToLower()))"
}

$output += ""

foreach ($cat in ($categories.Keys | Sort-Object)) {
    $output += "## $cat"
    $output += ""
    
    $categoryFunctions = $categories[$cat] | Sort-Object
    foreach ($funcName in $categoryFunctions) {
        $func = $functions[$funcName]
        $output += "### ``$($func.Name)``"
        $output += ""
        
        if ($func.Documentation.Synopsis) {
            $output += $func.Documentation.Synopsis.Trim()
            $output += ""
        }
        
        if ($func.Signature) {
            $output += "**Signature:**"
            $output += "``````powershell"
            $output += $func.Signature
            $output += "``````"
            $output += ""
        }
        
        if ($func.Documentation.Description) {
            $output += "**Description:**"
            $output += ""
            $output += $func.Documentation.Description.Trim()
            $output += ""
        }
        
        if ($func.Documentation.Examples -and $func.Documentation.Examples.Count -gt 0) {
            $output += "**Examples:**"
            $output += ""
            foreach ($example in $func.Documentation.Examples) {
                $output += "``````powershell"
                $output += $example
                $output += "``````"
                $output += ""
            }
        }
        
        $output += "<sub>**Source:** ``$($func.Source)``</sub>"
        $output += ""
    }
}

Write-Utf8File -Path "$OutputDir\FunctionReference.md" -Content ($output -join "`n")

# 2. Quick Reference (aliases and functions list)
Write-Verbose "Generating QuickReference.md..."
$output = @()
$output += "# Quick Reference"
$output += ""
$output += "> **Auto-generated documentation**"
$output += "> Last updated: $timestamp"
$output += ""
$output += "## Functions"
$output += ""
$output += "| Function | Category | Description |"
$output += "|----------|----------|-------------|"

foreach ($funcName in ($functions.Keys | Sort-Object)) {
    $func = $functions[$funcName]
    $desc = if ($func.Documentation.Synopsis) { 
        $func.Documentation.Synopsis.Trim() -replace '\r?\n', ' ' 
    }
    else { 
        $func.Documentation.Description.Trim() -replace '\r?\n', ' ' 
    }
    if ($desc.Length -gt 80) { $desc = $desc.Substring(0, 77) + "..." }
    $output += "| ``$($func.Name)`` | $($func.Category) | $desc |"
}

$output += ""
$output += "## Aliases"
$output += ""
$output += "| Alias | Target | Source |"
$output += "|-------|--------|--------|"

foreach ($aliasName in ($aliases.Keys | Sort-Object)) {
    $alias = $aliases[$aliasName]
    $output += "| ``$($alias.Alias)`` | ``$($alias.Target)`` | ``$($alias.Source)`` |"
}

Write-Utf8File -Path "$OutputDir\QuickReference.md" -Content ($output -join "`n")

# 3. Generate/Update README sections
Write-Verbose "Updating README.md sections..."

$readmePath = "$RepoRoot\README.md"
if (Test-Path $readmePath) {
    $readmeContent = Get-Content -Raw $readmePath
    
    # Update stats
    $statsBlock = @"
## 📊 Statistics

- **Functions:** $($functions.Count) across Core/, tools/install-dependencies.ps1, and the main profile
- **Aliases:** $($aliases.Count)
- **Categories:** $($categories.Count)
- **Last Updated:** $timestamp

"@
    
    # Update or add stats section
    if ($readmeContent -match '(?s)## 📊 Statistics.*?(?=\n## |\z)') {
        $readmeContent = $readmeContent -replace '(?s)## 📊 Statistics.*?(?=\n## |\z)', $statsBlock
    } else {
        $readmeContent += "`n`n$statsBlock"
    }
    Write-Utf8File -Path $readmePath -Content $readmeContent
}

#endregion

$sw.Stop()
Write-Verbose ""
Write-Verbose "=== Documentation Generation Complete ==="
Write-Verbose "Time elapsed: $($sw.ElapsedMilliseconds)ms"
Write-Verbose "Files generated:"
Write-Verbose "  - FunctionReference.md"
Write-Verbose "  - QuickReference.md"
Write-Verbose ""
