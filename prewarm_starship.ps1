$ProfileDir = Split-Path -Parent $PROFILE
$env:STARSHIP_CONFIG = '#file:starship.toml'
$env:STARSHIP_CACHE = Join-Path $ProfileDir '.starship\cache'
$cacheDir = Join-Path $ProfileDir '.starship'
if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null }
$cacheFile = Join-Path $cacheDir 'starship-init.ps1'
$init = & starship init powershell --print-full-init 2>$null
if ($init) {
    if ($init -is [System.Array]) { $initText = $init -join "`n" } else { $initText = $init.ToString() }
    Set-Content -Path $cacheFile -Value $initText -Encoding UTF8 -Force
    Write-Output "Wrote cache: $cacheFile"
} else {
    Write-Output 'starship init returned nothing'
}
