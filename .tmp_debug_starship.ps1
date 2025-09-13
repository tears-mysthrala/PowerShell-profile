. 'C:\Users\unaiu\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1'
Write-Host "After dot-source: script:StarshipInitialized = $script:StarshipInitialized"
Write-Host "Prompt function exists? "
if (Get-Command prompt -ErrorAction SilentlyContinue) { Get-Command prompt -CommandType Function | ForEach-Object { Write-Host "Prompt ScriptBlock length: $($_.ScriptBlock.ToString().Length)" } } else { Write-Host "No prompt function" }
Write-Host "Invoking prompt to force initialization..."
try { & prompt } catch { Write-Host "prompt invocation error: $_" }
Write-Host "After prompt call: script:StarshipInitialized = $script:StarshipInitialized" 
Get-Variable -Scope Script -Name StarshipInitialized -ErrorAction SilentlyContinue | Format-List -Force
