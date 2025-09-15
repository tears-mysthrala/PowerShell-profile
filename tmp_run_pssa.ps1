$modulePath = 'C:\Users\unaiu\OneDrive\Documents\PowerShell\Modules\PSScriptAnalyzer\1.24.0\PSScriptAnalyzer.psd1'
if (Test-Path $modulePath) {
    Import-Module $modulePath -Force
} else {
    Write-Output "Module path not found: $modulePath"
    exit 0
}

$rules = @('PSUseBOMForUnicodeEncodedFile','PSAvoidUsingCmdletAliases')
$results = Invoke-ScriptAnalyzer -Path (Get-Location) -Recurse -IncludeRule $rules -ErrorAction SilentlyContinue
if ($null -eq $results -or $results.Count -eq 0) {
    Write-Output 'No results for selected rules.'
} else {
    $results | Group-Object RuleName | Sort-Object Count -Descending | ForEach-Object { "$($_.Name): $($_.Count)" } | Out-File -FilePath pssa_after_fix_summary.txt -Encoding utf8
    Get-Content pssa_after_fix_summary.txt | ForEach-Object { Write-Output $_ }
}
