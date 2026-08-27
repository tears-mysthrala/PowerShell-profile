# Disk cleanup utilities
# Source: https://www.geeksforgeeks.org/disk-cleanup-using-powershell-scripts/

function Clear-RecycleBin {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param()

    $Path = "$env:SystemDrive\`$Recycle.Bin"
    if ($PSCmdlet.ShouldProcess($Path, 'Empty recycle bin')) {
        Microsoft.PowerShell.Management\Clear-RecycleBin -DriveLetter $env:SystemDrive.TrimEnd(':') -Force -ErrorAction Stop
    }
}

function Clear-TempData {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param()

    $tempPaths = @(
        "$env:WinDir\Temp",
        "$env:SystemDrive\Users\*\AppData\Local\Temp"
    )

    foreach ($path in $tempPaths) {
        if ($PSCmdlet.ShouldProcess($path, 'Delete temporary contents')) {
            Get-ChildItem -Path $path -Force -ErrorAction SilentlyContinue |
                Remove-Item -Recurse -Force -ErrorAction Stop
        }
    }
}

function Clear-Disk {
    Write-Host "Running Disk Cleanup tool..." -ForegroundColor Yellow
    cleanmgr /sagerun:1 | Out-Null
    Write-Host "$([char]7)"
    Write-Host "Disk Cleanup completed" -ForegroundColor Green
}

function Clear-All {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param()

    if (-not $PSCmdlet.ShouldProcess('Recycle bin, temporary files, and Disk Cleanup', 'Run all cleanup operations')) {
        return
    }

    Clear-RecycleBin -Confirm:$false
    Clear-TempData -Confirm:$false
    Clear-Disk
}
