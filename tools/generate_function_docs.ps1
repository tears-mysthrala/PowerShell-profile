<#
Generate FunctionReference.md by scanning PowerShell source files for function declarations
and extracting nearby comment blocks as short descriptions.

Usage:
  pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\generate_function_docs.ps1

#>
Param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$OutFile = "$PSScriptRoot\..\docs\FunctionReference.md"
)

Write-Host "Scanning repository: $RepoRoot"

function Get-PrecedingCommentBlock($text, $startIndex) {
    # Return nearest contiguous comment block (<# ... #> or lines starting with #) immediately above the function
    $before = $text.Substring(0, $startIndex)

    # Try block comment first
    $blockPattern = '(?s)<#(.*?)#>\s*$'
    $m = [regex]::Match($before, $blockPattern)
    if ($m.Success) {
        $comment = $m.Groups[1].Value.Trim()
        # Extract first line as description
        $lines = $comment -split "\r?\n" | Where-Object { $_.Trim() -and -not $_.Trim().StartsWith('.') }
        if ($lines) {
            return ($lines | Select-Object -First 1).Trim()
        }
        return $comment
    }

    # Fallback: collect contiguous '#' lines from the end
    $lines = $before -split "\r?\n"
    $descLines = @()
    for ($i = $lines.Length - 1; $i -ge 0; $i--) {
        $line = $lines[$i]
        if ($line -match '^[ \t]*#') {
            $cleanLine = ($line -replace '^[ \t]*#\s?', '').Trim()
            if ($cleanLine -and -not $cleanLine.StartsWith('.') -and $cleanLine -notmatch '^function\s+') {
                $descLines += $cleanLine
            }
        } elseif ($line -match '^[ \t]*$') {
            # stop on blank line between comments and function
            if ($descLines.Count -gt 0) { break }
            else { continue }
        } else { break }
    }
    if ($descLines.Count -gt 0) {
        # We collected lines from bottom-to-top; reverse them back to original order
        [array]::Reverse($descLines)
        return ($descLines -join ' ')
    }
    return ''
}

function Get-FunctionSignature($text, $matchIndex) {
    # Extract the complete function signature including parameters
    $lines = $text -split "\r?\n"
    $startLine = 0

    # Find which line the match starts on
    $currentPos = 0
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($currentPos + $lines[$i].Length -ge $matchIndex) {
            $startLine = $i
            break
        }
        $currentPos += $lines[$i].Length + 2  # +2 for \r\n
    }

    $signatureLines = @()
    $signatureLines += $lines[$startLine].Trim()

    $inParamBlock = $false
    $paramParenCount = 0

    for ($i = $startLine + 1; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]

        # Check if we're entering a param block
        if ($line -match 'param\s*\(') {
            $inParamBlock = $true
            $paramParenCount = ($line -split '\(').Count - ($line -split '\)').Count
        }

        # If we're in a param block, count parentheses
        if ($inParamBlock) {
            $paramParenCount += ($line -split '\(').Count - 1
            $paramParenCount -= ($line -split '\)').Count - 1
        }

        # Stop if this line closes the param block (contains only closing paren and whitespace)
        if ($inParamBlock -and $line.Trim() -match '^\s*\)\s*$') {
            $signatureLines += $line.TrimEnd()
            break
        }

        # Stop at the opening brace of the function body if no param block
        if (-not $inParamBlock -and $line.Trim() -match '^\{') {
            $signatureLines += $line.TrimEnd()
            break
        }

        # Add the line to signature
        $signatureLines += $line.TrimEnd()

        # Safety break if we have too many lines
        if ($signatureLines.Count -gt 50) {
            break
        }
    }

    return ($signatureLines -join "`n").Trim()
}

$files = Get-ChildItem -Path $RepoRoot -Recurse -Include *.ps1,*.psm1 -File -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' -and $_.FullName -notmatch '\\docs\\' -and $_.FullName -notmatch '\\tools\\' }

$entries = @()
foreach ($f in $files) {
    try {
        $text = Get-Content -Raw -LiteralPath $f.FullName -ErrorAction Stop
    } catch { continue }
    # Skip files where reading returned nothing (avoid null-valued calls later)
    if (-not $text) { continue }

    $pattern = '(?m)^[ \t]*function[ \t]+([A-Za-z0-9_\-]+)\b.*'
    $matches = [regex]::Matches($text, $pattern)
    foreach ($m in $matches) {
        $name = $m.Groups[1].Value
        $sig = Get-FunctionSignature $text $m.Index
        $desc = Get-PrecedingCommentBlock $text $m.Index
        $entry = [PSCustomObject]@{
            Name = $name
            Signature = $sig
            Description = if ($desc) { $desc } else { '' }
            Source = $f.FullName
        }
        $entries += $entry
    }
}

# Deduplicate by name (keep first)
$byName = @{}
foreach ($e in $entries) {
    if (-not $byName.ContainsKey($e.Name)) { $byName[$e.Name] = $e }
}

# Generate output
$out = @()
$out += "# Function Reference (auto-generated)"
$out += ''
$out += "This file was generated by tools/generate_function_docs.ps1. Run the script to refresh the contents."
$out += ''
$out += "Generated on: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$out += ''
$out += "Total functions found: $($byName.Count)"
$out += ''

foreach ($name in ($byName.Keys | Sort-Object)) {
    $e = $byName[$name]
    $out += "## $($e.Name)"
    $out += ''
    if ($e.Signature) {
        $out += "**Signature:**"
        $out += ''
        $out += '```powershell'
        $out += $e.Signature
        $out += '```'
        $out += ''
    }
    if ($e.Description) {
        $out += "**Description:**"
        $out += ''
        $out += $e.Description
        $out += ''
    }
    $out += "**Source:** $($e.Source.Replace($RepoRoot, '').TrimStart('\'))"
    $out += ''
}

Write-Host "Writing output to $OutFile"
Set-Content -LiteralPath $OutFile -Value ($out -join "`n") -Encoding UTF8
Write-Host "Done. Found $($byName.Count) unique functions."

# Update FUNCTIONS.md with current scan date
$functionsFile = "$RepoRoot\docs\FUNCTIONS.md"
if (Test-Path $functionsFile) {
    $currentDate = Get-Date -Format 'yyyy-MM-dd'
    $functionsContent = Get-Content -Raw -LiteralPath $functionsFile
    $updatedContent = $functionsContent -replace '<!-- AUTOGEN_SCAN_DATE -->', $currentDate
    Set-Content -LiteralPath $functionsFile -Value $updatedContent -Encoding UTF8
    Write-Host "Updated scan date in FUNCTIONS.md to $currentDate"
}
