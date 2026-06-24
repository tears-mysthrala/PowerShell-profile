$ErrorActionPreference = 'SilentlyContinue'
$log = "C:\temp\CleanTemp_$(Get-Date -Format 'yyyyMMdd').log"
$freed = 0

function Remove-TempFolder {
    param($Path)
    if (-not (Test-Path $Path)) { return 0 }
    $before = (Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { -not $_.PSIsContainer } | Measure-Object Length -Sum).Sum
    Get-ChildItem $Path -Force -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    $after = (Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { -not $_.PSIsContainer } | Measure-Object Length -Sum).Sum
    return ($before - $after)
}

$targets = @(
    "$env:LOCALAPPDATA\Temp",
    "$env:WINDIR\Temp",
    "$env:WINDIR\SoftwareDistribution\Download",
    "C:\temp\*.log",
    "C:\temp\*.ps1"
)

Add-Content $log "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - CleanTemp started"

foreach ($target in $targets) {
    if ($target -match '\*') {
        # Glob pattern - borrar archivos directamente
        $before = (Get-Item $target -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        Remove-Item $target -Force -ErrorAction SilentlyContinue
        $freed += $before
        Add-Content $log "  Cleaned: $target"
    } else {
        $delta = Remove-TempFolder $target
        $freed += $delta
        Add-Content $log "  Cleaned: $target (+$([math]::Round($delta/1MB,1)) MB)"
    }
}

$freedMB = [math]::Round($freed/1MB,1)
Add-Content $log "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Done. Freed: $freedMB MB"
