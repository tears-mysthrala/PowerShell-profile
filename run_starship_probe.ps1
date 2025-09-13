$ProfileDir = Split-Path -Parent $PROFILE
$starshipConfigPath = Join-Path $ProfileDir 'Config\starship.toml'
$env:STARSHIP_CONFIG = $starshipConfigPath
$outFile = Join-Path $env:TEMP 'starship_probe_out.txt'
try {
    $out = & 'C:\Program Files\starship\bin\starship.exe' prompt --path $ProfileDir --logical-path $ProfileDir --terminal-width 120 --jobs 0 --status 0 2>&1
    Set-Content -Path $outFile -Value ($out -join "`n") -Encoding UTF8 -Force
    Write-Output "Wrote: $outFile"
    Write-Output "ExitCode: $LASTEXITCODE"
} catch {
    Write-Output "Exception: $_"
}
Get-Content -Path $outFile -Raw
