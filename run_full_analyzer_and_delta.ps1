param()
$repo = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
Set-Location $repo
Import-Module PSScriptAnalyzer -ErrorAction Stop
Write-Output "Running Invoke-ScriptAnalyzer on Core/, Scripts/, and root .ps1 files (faster run)..."
$paths = @((Join-Path $repo 'Core'), (Join-Path $repo 'Scripts'))
$rootPs1 = Get-ChildItem -Path $repo -Filter *.ps1 -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
if ($rootPs1) { $paths += $rootPs1 }
$after = Invoke-ScriptAnalyzer -Path $paths -Recurse -Settings (Join-Path $repo '.psscriptanalyzersettings.psd1') -Severity Warning -ErrorAction SilentlyContinue
$outAfter = Join-Path $repo 'pssa_full_report_post.json'
$after | ConvertTo-Json -Depth 6 | Out-File -FilePath $outAfter -Encoding UTF8
Write-Output "Wrote post run JSON to $outAfter"

$beforePath = Join-Path $repo 'pssa_full_report.json'
if (Test-Path $beforePath) { $before = Get-Content $beforePath -Raw | ConvertFrom-Json } else { $before = @() }

function GroupCounts($arr){
    if (-not $arr) { return @{} }
    return ($arr | Group-Object -Property RuleName | ForEach-Object { @{ RuleName = $_.Name; Count = $_.Count } })
}
$beforeGroups = GroupCounts $before
$afterGroups = GroupCounts $after
$map = @{}
foreach ($g in $beforeGroups) { $map[$g.RuleName] = @{Before = $g.Count; After = 0} }
foreach ($g in $afterGroups) {
    if (-not $map.ContainsKey($g.RuleName)) { $map[$g.RuleName] = @{Before = 0; After = $g.Count} } else { $map[$g.RuleName].After = $g.Count }
}
# Create array of deltas
$arr = $map.GetEnumerator() | ForEach-Object { [PSCustomObject]@{ RuleName = $_.Key; Before = $_.Value.Before; After = $_.Value.After; Delta = ($_.Value.After - $_.Value.Before) } }
# Sort by absolute delta desc
$arr = $arr | Sort-Object -Property @{ Expression = { [math]::Abs($_.Delta) } } -Descending
$outJson = Join-Path $repo 'pssa_summary_delta.json'
$outTxt = Join-Path $repo 'pssa_summary_delta.txt'
$arr | ConvertTo-Json -Depth 4 | Out-File -FilePath $outJson -Encoding UTF8
$arr | Format-Table -AutoSize | Out-String | Out-File -FilePath $outTxt -Encoding UTF8
Write-Output "Wrote delta JSON to $outJson and text summary to $outTxt"
Write-Output 'Done'