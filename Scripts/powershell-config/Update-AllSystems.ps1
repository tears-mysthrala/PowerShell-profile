using namespace System.Threading
using namespace System.Collections.Concurrent

# Script to update all installed applications with TUI
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'Continue'

# Initialize logging
$logFile = Join-Path $env:TEMP "UpdateAll_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
function Write-Log {
    param($Message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

# Create a thread-safe queue for progress updates
$progressQueue = [ConcurrentQueue[hashtable]]::new()

# Function to update TUI
function Update-TUI {
    param(
        [hashtable]$Status
    )
    $progressQueue.Enqueue($Status)
}

# Function to display TUI
function Show-TUI {
    $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates(0, $host.UI.RawUI.CursorPosition.Y)
    Write-Host "\r" -NoNewline
    $status = New-Object hashtable
    while ($progressQueue.TryDequeue([ref]$status)) {
        Write-Host "[$($status.Source)] $($status.Status)" -ForegroundColor $status.Color
    }
}

# Function to handle errors
function Handle-Error {
    param($ErrorMessage, $Source)
    Update-TUI @{
        Source = $Source
        Status = "ERROR: $ErrorMessage"
        Color = 'Red'
    }
    Write-Log "ERROR [$Source]: $ErrorMessage"
    Write-Log "Details: $($Error[0].Exception.Message)"
}

# Function to check if a command exists
function Test-CommandExists {
    param($Command)
    $null -ne (Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

# Main update function
function Update-AllSystems {
    [CmdletBinding()]
    param()

    $jobs = @()
    $timer = [System.Diagnostics.Stopwatch]::StartNew()

    # Clear screen and set initial display
    Clear-Host
    Write-Host "Starting system-wide update..." -ForegroundColor Cyan
    Write-Host "Progress will be shown below:" -ForegroundColor Cyan
    Write-Host "--------------------------" -ForegroundColor Cyan

    # Windows Update job
    $jobs += Start-Job -ScriptBlock {
        try {
            $ProgressPreference = 'SilentlyContinue'
            if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
                Install-Module PSWindowsUpdate -Force -AllowClobber
            }
            Import-Module PSWindowsUpdate
            Get-WindowsUpdate -AcceptAll -Install -AutoReboot:$false
            "Windows updates completed successfully"
        } catch {
            throw "Windows Update failed: $($_.Exception.Message)"
        }
    }

    # Winget updates job
    if (Test-CommandExists 'winget') {
        $jobs += Start-Job -ScriptBlock {
            try {
                $ProgressPreference = 'SilentlyContinue'
                winget upgrade --all --accept-source-agreements --accept-package-agreements
                "Winget updates completed successfully"
            } catch {
                throw "Winget update failed: $($_.Exception.Message)"
            }
        }
    }

    # Scoop updates job
    if (Test-CommandExists 'scoop') {
        $jobs += Start-Job -ScriptBlock {
            try {
                $ProgressPreference = 'SilentlyContinue'
                scoop update
                scoop update *
                "Scoop updates completed successfully"
            } catch {
                throw "Scoop update failed: $($_.Exception.Message)"
            }
        }
    }

    # Chocolatey updates job
    if (Test-CommandExists 'choco') {
        $jobs += Start-Job -ScriptBlock {
            try {
                $ProgressPreference = 'SilentlyContinue'
                choco upgrade all -y
                "Chocolatey updates completed successfully"
            } catch {
                throw "Chocolatey update failed: $($_.Exception.Message)"
            }
        }
    }

    # NPM global updates job
    if (Test-CommandExists 'npm') {
        $jobs += Start-Job -ScriptBlock {
            try {
                $ProgressPreference = 'SilentlyContinue'
                npm update -g
                "NPM global updates completed successfully"
            } catch {
                throw "NPM update failed: $($_.Exception.Message)"
            }
        }
    }

    # Microsoft Store updates job
    $jobs += Start-Job -ScriptBlock {
        try {
            $ProgressPreference = 'SilentlyContinue'
            Get-CimInstance -Namespace 'Root\cimv2' -ClassName 'Win32_AppxUpdateInfo' | 
                Where-Object { $_.UpdateAvailable -eq $true } | 
                ForEach-Object { Add-AppxPackage -Path $_.PackageLocation }
            "Microsoft Store updates completed successfully"
        } catch {
            throw "Microsoft Store update failed: $($_.Exception.Message)"
        }
    }

    # Monitor jobs and update TUI
    $completed = 0
    $total = $jobs.Count

    while ($completed -lt $total) {
        foreach ($job in $jobs) {
            if ($job.State -eq 'Completed' -and !$job.HasMoreData) {
                continue
            }

            $output = Receive-Job -Job $job
            if ($output) {
                Update-TUI @{
                    Source = $job.Name
                    Status = $output
                    Color = 'Green'
                }
            }

            if ($job.State -eq 'Failed') {
                Update-TUI @{
                    Source = $job.Name
                    Status = "Failed: $($job.ChildJobs[0].JobStateInfo.Reason.Message)"
                    Color = 'Red'
                }
                $completed++
            } elseif ($job.State -eq 'Completed' -and !$job.HasMoreData) {
                $completed++
            }
        }

        Show-TUI
        Start-Sleep -Milliseconds 100
    }

    $timer.Stop()
    Write-Host "--------------------------" -ForegroundColor Cyan
    Write-Host "Update process completed in $([math]::Round($timer.Elapsed.TotalMinutes, 2)) minutes" -ForegroundColor Cyan

    # Cleanup jobs
    $jobs | Remove-Job -Force
}

# Create alias for the update function
Set-Alias -Name upgrade -Value Update-AllSystems -Description "Updates all system components and applications"

# Export the function and alias
Export-ModuleMember -Function Update-AllSystems -Alias upgrade