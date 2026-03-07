# Disk cleanup utilities
# Source: https://www.geeksforgeeks.org/disk-cleanup-using-powershell-scripts/

function Clear-RecycleBin {
    $Path = "$env:SystemDrive\`$Recycle.Bin"
    Write-Host "[INFO] Cleaning recycle bin..." -ForegroundColor Yellow
    Get-ChildItem $Path -Force -Recurse -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Exclude *.ini -ErrorAction SilentlyContinue
    Write-Host "Recycle bin cleaned successfully" -ForegroundColor Green
}

function Clear-TempData {
    Write-Host "Erasing temporary files..." -ForegroundColor Yellow

    $tempPaths = @(
        "$env:WinDir\Temp",
        "$env:WinDir\Prefetch",
        "$env:SystemDrive\Users\*\AppData\Local\Temp"
    )

    foreach ($path in $tempPaths) {
        Write-Host "  Cleaning $path" -ForegroundColor Yellow
        Get-ChildItem $path -Force -Recurse -ErrorAction SilentlyContinue |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Temp files cleaned successfully" -ForegroundColor Green
}

function Clear-Disk {
    Write-Host "Running Disk Cleanup tool..." -ForegroundColor Yellow
    cleanmgr /sagerun:1 | Out-Null
    Write-Host "$([char]7)"
    Write-Host "Disk Cleanup completed" -ForegroundColor Green
}

function Clear-All {
    Clear-RecycleBin
    Clear-TempData
    Clear-Disk
}
