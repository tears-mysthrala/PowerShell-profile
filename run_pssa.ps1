Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser -AllowClobber
Import-Module PSScriptAnalyzer
$results = Invoke-ScriptAnalyzer -Path . -Recurse -Severity Warning
$results | Select-Object Severity,RuleName,ScriptName,Line,Message | Out-File -FilePath .\pssa_report.txt -Encoding utf8
Write-Host 'Saved report to pssa_report.txt'
if ($results.Count -gt 0) { $results | Format-Table -AutoSize } else { Write-Host 'No issues found by PSScriptAnalyzer' }
