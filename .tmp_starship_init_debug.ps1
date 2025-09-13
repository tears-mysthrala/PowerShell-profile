. 'C:\Users\unaiu\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1'
Write-Host "starship command available: "
Get-Command starship -ErrorAction SilentlyContinue | Format-List -Force

# Show the init output captured by the Initialize-Starship function
$init = & starship init powershell --print-full-init 2>&1
Write-Host "--- raw init (first 1200 chars) ---"
if ($init) { $init.ToString().Substring(0,[math]::Min(1200,$init.ToString().Length)) | Write-Host } else { Write-Host "(empty)" }

# Call Initialize-Starship and capture errors
$errBefore = $error.Count
try {
    Initialize-Starship
    Write-Host "Initialize-Starship completed without throwing"
} catch {
    Write-Host "Initialize-Starship threw: $_"
}
$errAfter = $error.Count
if ($errAfter -gt $errBefore) {
    Write-Host "Errors added during Initialize-Starship:"; $error[$errBefore..($errAfter-1)] | ForEach-Object { Write-Host "  $_" }
}
Write-Host "script:StarshipInitialized = $script:StarshipInitialized"
