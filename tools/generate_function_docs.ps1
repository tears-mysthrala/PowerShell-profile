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
    param(
        [string]$Text,
        [int]$MatchIndex
    )

    $lines = $Text -split "\r?\n"
    $currentPos = 0
    $startLine = 0

    # Find starting line
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($currentPos + $lines[$i].Length -ge $MatchIndex) {
            $startLine = $i
            break
        }
        $currentPos += $lines[$i].Length + 2
    }

    $signatureLines = @($lines[$startLine].Trim())
    $braceCount = 0
    $parenCount = 0
    $inParam = $false

    for ($i = $startLine + 1; $i -lt [Math]::Min($startLine + 100, $lines.Length); $i++) {
        $line = $lines[$i]
        
        if ($line -match 'param\s*\(') {
            $inParam = $true
        }
        
        $parenCount += ($line.ToCharArray() | Where-Object { $_ -eq '(' }).Count
        $parenCount -= ($line.ToCharArray() | Where-Object { $_ -eq ')' }).Count
        $braceCount += ($line.ToCharArray() | Where-Object { $_ -eq '{' }).Count

        $signatureLines += $line.TrimEnd()

        if ($inParam -and $parenCount -eq 0) {
            break
        }
        
        if (-not $inParam -and $braceCount -gt 0) {
            break
        }
    }

    return ($signatureLines -join "`n").Trim()
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
    if ($relativePath -match '^Modules') { return 'Modules' }
    if ($relativePath -match '^Scripts') { return 'Scripts' }
    
    return 'Other'
}

#endregion

#region Scan Functions

Write-Verbose "Scanning for PowerShell files..."

$files = Get-ChildItem -Path $RepoRoot -Recurse -Include *.ps1, *.psm1 -File -ErrorAction SilentlyContinue |
Where-Object { 
    $_.FullName -notmatch '[\\/]\.(git|vscode)[\\/]' -and
    $_.FullName -notmatch '[\\/]docs[\\/]' -and
    $_.FullName -notmatch '[\\/]tools[\\/]generate_' -and
    $_.FullName -notmatch '[\\/]node_modules[\\/]'
}

Write-Verbose "Found $($files.Count) PowerShell files to scan"

$functions = @{}
$aliases = @{}
$categories = @{}

$functionPattern = '(?m)^[ \t]*function[ \t]+([A-Za-z0-9_\-]+)\b'
$aliasPattern = '(?m)Set-Alias\s+-Name\s+([A-Za-z0-9_\-]+)\s+-Value\s+([A-Za-z0-9_\-]+)'

foreach ($file in $files) {
    Write-Verbose "  Processing: $($file.Name)"
    
    try {
        $content = Get-Content -Raw -LiteralPath $file.FullName -ErrorAction Stop
        if (-not $content) { continue }
        
        $category = Get-SourceCategory $file.FullName
        
        # Extract functions
        $functionMatches = [regex]::Matches($content, $functionPattern)
        foreach ($match in $functionMatches) {
            $name = $match.Groups[1].Value
            
            if (-not $functions.ContainsKey($name)) {
                $sig = Get-FunctionSignature $content $match.Index
                $doc = Get-PrecedingCommentBlock $content $match.Index
                
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

Set-Content -LiteralPath "$OutputDir\FunctionReference.md" -Value ($output -join "`n") -Encoding UTF8

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

Set-Content -LiteralPath "$OutputDir\QuickReference.md" -Value ($output -join "`n") -Encoding UTF8

# 3. Generate/Update README sections
Write-Verbose "Updating README.md sections..."

$readmePath = "$RepoRoot\README.md"
if (Test-Path $readmePath) {
    $readmeContent = Get-Content -Raw $readmePath
    
    # Update stats
    $statsBlock = @"
## 📊 Statistics

- **Functions:** $($functions.Count)
- **Aliases:** $($aliases.Count)
- **Categories:** $($categories.Count)
- **Last Updated:** $timestamp

"@
    
    # Add stats if not present
    if ($readmeContent -notmatch '## 📊 Statistics') {
        $readmeContent += "`n`n$statsBlock"
        Set-Content -LiteralPath $readmePath -Value $readmeContent -Encoding UTF8
    }
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
