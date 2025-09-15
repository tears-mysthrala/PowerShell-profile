# Apply up to 20 conservative fixes for single-line empty catch blocks
$root = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
Set-Location $root
$jsonPath = Join-Path $root 'pssa_empty_catches.json'
if (-not (Test-Path $jsonPath)) { Write-Error "Missing $jsonPath"; exit 1 }
$entries = Get-Content $jsonPath -Raw | ConvertFrom-Json
# Collect files flagged for empty-catch, exclude Modules/ and common vendor patterns
$files = $entries | Where-Object { $_.Rule -eq 'PSAvoidUsingEmptyCatchBlock' } | ForEach-Object { $_.File } | Where-Object { $_ } | Select-Object -Unique
$files = $files | Where-Object { ($_ -notmatch '^Modules[\\/]') -and ($_ -notmatch 'Microsoft\.PowerToys') -and ($_ -notmatch 'posh-wakatime') }
# Prefer Core/ and Scripts/ files first
$preferred = $files | Where-Object { $_ -match '^(Core|Scripts)[\\/]' }
$ordered = @()
if ($preferred) { $ordered += $preferred }
$ordered += ($files | Where-Object { $ordered -notcontains $_ })
$selected = $ordered | Select-Object -First 20
Write-Output "Selected $($selected.Count) files for editing"
$edited = @()
foreach ($f in $selected) {
    $path = Join-Path $root $f
    if (-not (Test-Path $path)) { Write-Output "Skipping missing: $f"; continue }
    try {
        $content = Get-Content -Raw -Encoding UTF8 -Path $path
    } catch {
        Write-Output "Failed reading $($f): $($_)"; continue
    }
    # replacement: single-line empty catch blocks like: catch { }  (allow whitespace)
    $pattern = 'catch\s*\{\s*\}'
    $replacement = 'catch { Write-Verbose ''Ignored exception: $_'' }'
    $new = [regex]::Replace($content, $pattern, $replacement)
    if ($new -ne $content) {
        Copy-Item -Path $path -Destination "$path.bak" -Force
        Set-Content -Path $path -Value $new -Encoding UTF8
        Write-Output "Edited: $f"
        $edited += $f
    } else {
        Write-Output "No single-line empty catch in: $f"
    }
}
# Run analyzer on edited files and save JSON
if ($edited.Count -gt 0) {
    $analyzerResults = @()
    Import-Module PSScriptAnalyzer -ErrorAction Stop
    foreach ($ef in $edited) {
        $p = Join-Path $root $ef
        $res = Invoke-ScriptAnalyzer -Path $p -Settings (Join-Path $root '.psscriptanalyzersettings.psd1') -Recurse -Severity Warning -ErrorAction SilentlyContinue
        $analyzerResults += $res
    }
    $outJson = Join-Path $root 'pssa_triage_after.json'
    $analyzerResults | Select-Object @{Name='File';Expression={$_.ScriptPath}},RuleName,Message,Line,Column,Severity | ConvertTo-Json -Depth 5 | Out-File -FilePath $outJson -Encoding UTF8
    Write-Output "Wrote analyzer results to $outJson"
    # git commit & push
    git add -A
    $status = git status --porcelain
    if ($status) {
        git commit -m "chore: triage: replace single-line empty catch blocks with Write-Verbose (conservative)"
        git push origin main
    } else {
        Write-Output 'No changes to commit'
    }
} else {
    Write-Output 'No files edited'
}
Write-Output 'Done'
