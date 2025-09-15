Import-Module 'C:\Users\unaiu\OneDrive\Documents\PowerShell\Modules\PSScriptAnalyzer\1.24.0\PSScriptAnalyzer.psd1' -Force
$results = Invoke-ScriptAnalyzer -Path . -Recurse -ErrorAction SilentlyContinue
if ($null -eq $results -or $results.Count -eq 0) {
    Write-Output 'No diagnostics found.'
    exit 0
}
$results | ConvertTo-Json -Depth 5 | Out-File -FilePath pssa_full_report.json -Encoding utf8
$results | Group-Object RuleName | Sort-Object Count -Descending | ForEach-Object { "$($_.Name): $($_.Count)" } | Out-File pssa_summary.txt -Encoding utf8
Write-Output 'Analyzer run completed. Summary (top 40):'
Get-Content pssa_summary.txt | Select-Object -First 40 | ForEach-Object { Write-Output $_ }
