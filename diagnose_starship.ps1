# Diagnostic script — dot-source the interactive profile and report Starship state
. $PROFILE
Write-Output '--- PROFILE SOURCED ---'
Get-Command Initialize-Starship -ErrorAction SilentlyContinue | Format-List
Write-Output "StarshipInitialized=$($script:StarshipInitialized -as [string])"
Write-Output "ENV_STARSHIP_CONFIG=$env:STARSHIP_CONFIG"
Write-Output "ENV_STARSHIP_CACHE=$env:STARSHIP_CACHE"
$profileDir = Split-Path -Parent $PROFILE
$cfg = Join-Path $profileDir 'Config\starship.toml'
Write-Output "ConfigPath=$cfg"
Write-Output "ConfigExists=$(Test-Path $cfg)"
$cacheFile = Join-Path $profileDir '.starship\starship-init.ps1'
Write-Output "CachePath=$cacheFile"
Write-Output "CacheExists=$(Test-Path $cacheFile)"
if (Test-Path $cacheFile) {
    Write-Output 'Cache head:'
    Get-Content -Path $cacheFile -TotalCount 20
}
# Show prompt function source
$promptFn = Get-Command prompt -CommandType Function -ErrorAction SilentlyContinue
if ($promptFn) {
    Write-Output 'Prompt function scriptblock (first 200 chars):'
    $s = $promptFn.ScriptBlock.ToString()
    Write-Output ($s.Substring(0, [Math]::Min(200, $s.Length)))
}
# Try to call Initialize-Starship and report result (do not fail silently)
try {
    Write-Output 'Invoking Initialize-Starship now...'
    Initialize-Starship
    Write-Output "AfterInit_StarshipInitialized=$($script:StarshipInitialized -as [string])"
} catch {
    Write-Output "Initialize-Starship threw: $_"
}
