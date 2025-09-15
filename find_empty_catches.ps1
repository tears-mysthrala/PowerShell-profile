Import-Module 'C:\Users\unaiu\OneDrive\Documents\PowerShell\Modules\PSScriptAnalyzer\1.24.0\PSScriptAnalyzer.psd1' -Force
$results = Invoke-ScriptAnalyzer -Path . -Recurse -IncludeRule 'PSAvoidUsingEmptyCatchBlock' -ErrorAction SilentlyContinue
if ($null -eq $results -or $results.Count -eq 0) { Write-Output 'No empty catches found.'; exit 0 }
$results | Select-Object @{Name='File';Expression={$_.ScriptName}}, @{Name='Rule';Expression={$_.RuleName}}, @{Name='StartLine';Expression={$_.ScriptExtent.StartLineNumber}}, @{Name='EndLine';Expression={$_.ScriptExtent.EndLineNumber}}, @{Name='Message';Expression={$_.Message}} | ConvertTo-Json -Depth 5 | Out-File pssa_empty_catches.json -Encoding utf8
Write-Output "Wrote pssa_empty_catches.json with $($results.Count) entries"
