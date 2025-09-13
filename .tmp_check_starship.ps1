# Check starship availability and configuration
Write-Host "=== Starship availability check ==="
$cmd = Get-Command starship -ErrorAction SilentlyContinue
if ($cmd) {
    Write-Host "starship command found at: $($cmd.Path)"
    try {
        $ver = & starship --version 2>&1
        Write-Host "starship --version: $ver"
    } catch { Write-Host "Failed to get starship version: $_" }
    Write-Host "\n--- starship init output (powershell) ---"
    try {
        $init = & starship init powershell --print-full-init 2>&1
        if ($init) { $init | Out-String | Write-Host } else { Write-Host "(empty init output)" }
    } catch { Write-Host "starship init failed: $_" }
} else {
    Write-Host "starship not found via Get-Command"
}

# Check profile-config paths from our profile
$profileDir = Split-Path -Parent $PROFILE
$cfg = Join-Path $profileDir 'Config\starship.toml'
$cache = Join-Path $profileDir '.starship\cache'
Write-Host "\nProfileDir: $profileDir"
Write-Host "STARSHIP_CONFIG expected at: $cfg"
Write-Host "STARSHIP_CACHE expected at: $cache"
if (Test-Path $cfg) { Write-Host "starship config exists"; Get-Content $cfg -TotalCount 20 | ForEach-Object { Write-Host "   $_" } } else { Write-Host "starship config missing" }
if (Test-Path $cache) { Write-Host "starship cache dir exists" } else { Write-Host "starship cache dir missing" }
