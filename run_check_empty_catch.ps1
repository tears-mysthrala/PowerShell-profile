Import-Module 'C:\Users\unaiu\OneDrive\Documents\PowerShell\Modules\PSScriptAnalyzer\1.24.0\PSScriptAnalyzer.psd1' -Force
$res = Invoke-ScriptAnalyzer -Path 'Microsoft.PowerShell_profile.ps1' -IncludeRule 'PSAvoidUsingEmptyCatchBlock' -ErrorAction SilentlyContinue
if ($null -eq $res -or $res.Count -eq 0) { Write-Output 'No findings for PSAvoidUsingEmptyCatchBlock in Microsoft.PowerShell_profile.ps1' } else { $res | Group-Object RuleName | ForEach-Object { "$($_.Name): $($_.Count)" } }
