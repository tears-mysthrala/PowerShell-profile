$profilePath = 'C:\Users\unaiu\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1'
$runs = 6
$results = @()

for ($i = 1; $i -le $runs; $i++) {
    try {
        $outFile = Join-Path $env:TEMP ("pw_profile_run_{0}.json" -f $i)
        # Run the profile in a child pwsh which writes a pure JSON file to avoid mixed host output
        & pwsh -NoProfile -Command {
            param($p, $out)
            . $p
            $report = @{ total = $totalTime; timings = $script:profileTiming }
            $report | ConvertTo-Json -Depth 5 -Compress | Out-File -FilePath $out -Encoding utf8
        } -Arg $profilePath, $outFile

        Start-Sleep -Milliseconds 20
        $json = Get-Content -Raw -Path $outFile -ErrorAction Stop
        $obj = $json | ConvertFrom-Json
        $results += $obj
        Write-Host ("Run {0}: {1}ms" -f $i, $obj.total)
    } catch {
        Write-Warning "Run $i failed: $_"
    }
    Start-Sleep -Milliseconds 150
}

if ($results.Count -eq 0) {
    Write-Error "No successful runs."
    exit 1
}

$avgTotal = [math]::Round(($results | Measure-Object -Property total -Average).Average, 2)

# collect all timing keys
$allKeys = $results | ForEach-Object { $_.timings.PSObject.Properties.Name } | Select-Object -Unique
$avgTimings = @{}
foreach ($k in $allKeys) {
    $vals = $results | ForEach-Object { if ($_.timings.$k) { [double]$_.timings.$k } else { 0 } }
    $avg = [math]::Round(($vals | Measure-Object -Average).Average, 2)
    $avgTimings[$k] = $avg
}

Write-Host "`nBenchmark results (average over $runs runs):" -ForegroundColor Cyan
Write-Host "Average total: $avgTotal ms`n" -ForegroundColor Cyan
foreach ($k in $avgTimings.GetEnumerator() | Sort-Object -Property Value -Descending) {
    Write-Host ("{0}: {1}ms" -f $k.Name, $k.Value) -ForegroundColor Green
}

$summary = @{ runs = $runs; avgTotal = $avgTotal; avgTimings = $avgTimings }
$outPath = Join-Path $env:TEMP 'pw_profile_benchmark.json'
$summary | ConvertTo-Json -Depth 5 | Out-File -FilePath $outPath -Encoding utf8
Write-Host "\nDetailed JSON saved to $outPath" -ForegroundColor Yellow
Write-Host "Done." -ForegroundColor Cyan
