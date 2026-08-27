[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param()

$logDirectory = Join-Path $env:TEMP 'PowerShellProfile'
New-Item -Path $logDirectory -ItemType Directory -Force -ErrorAction Stop | Out-Null
$log = Join-Path $logDirectory "CleanTemp_$(Get-Date -Format 'yyyyMMdd').log"
$freed = 0

function Remove-TempFolder {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([int64])]
    param([Parameter(Mandatory)][string]$Path)

    $resolvedPath = Resolve-Path -LiteralPath $Path -ErrorAction SilentlyContinue
    if (-not $resolvedPath) { return 0 }

    $root = [System.IO.Path]::GetPathRoot($resolvedPath.ProviderPath)
    if ($resolvedPath.ProviderPath.TrimEnd('\') -eq $root.TrimEnd('\')) {
        throw "Refusing to clean filesystem root: $resolvedPath"
    }

    $before = (Get-ChildItem -LiteralPath $resolvedPath.ProviderPath -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { -not $_.PSIsContainer } | Measure-Object Length -Sum).Sum

    if ($PSCmdlet.ShouldProcess($resolvedPath.ProviderPath, 'Delete temporary contents')) {
        Get-ChildItem -LiteralPath $resolvedPath.ProviderPath -Force -ErrorAction SilentlyContinue |
            Remove-Item -Recurse -Force -ErrorAction Stop
    }

    $after = (Get-ChildItem -LiteralPath $resolvedPath.ProviderPath -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { -not $_.PSIsContainer } | Measure-Object Length -Sum).Sum
    return ($before - $after)
}

$targets = @(
    "$env:LOCALAPPDATA\Temp",
    "$env:WINDIR\Temp",
    "$env:WINDIR\SoftwareDistribution\Download"
)

Add-Content $log "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - CleanTemp started"

foreach ($target in $targets) {
    try {
        $delta = Remove-TempFolder -Path $target
        $freed += $delta
        Add-Content $log "  Cleaned: $target (+$([math]::Round($delta/1MB,1)) MB)"
    } catch {
        Add-Content $log "  Failed: $target ($($_.Exception.Message))"
        Write-Error "Failed to clean '$target': $_"
    }
}

$freedMB = [math]::Round($freed/1MB,1)
Add-Content $log "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Done. Freed: $freedMB MB"
