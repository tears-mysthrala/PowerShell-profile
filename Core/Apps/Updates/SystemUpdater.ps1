using namespace System.Threading
using namespace System.Collections.Concurrent

# Unified system update module
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

# Initialize logging
function Initialize-UpdateLog {
    $logFile = Join-Path $env:TEMP "SystemUpdate_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    return $logFile
}

# Logging function
function Write-UpdateLog {
    param($Message, $LogFile)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
    Write-Verbose $logMessage
    Add-Content -Path $LogFile -Value $logMessage
}

# Error handling function
function Write-UpdateErrorLog {
    param($ErrorMessage, $Source, $LogFile)
    Write-UpdateLog "ERROR [$Source]: $ErrorMessage" $logFile
    Write-UpdateLog "Details: $($Error[0].Exception.Message)" $LogFile
}

# Helper function to write section headers
function Write-UpdateHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Magenta
    Write-Host $Title -ForegroundColor Magenta
    Write-Host "============================================================" -ForegroundColor Magenta
}

# Helper function to write status messages
function Write-UpdateStatus {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Status = 'Info'
    )
    $colors = @{ Info = 'White'; Success = 'Green'; Warning = 'Yellow'; Error = 'Red' }
    $prefixes = @{ Info = '>'; Success = 'OK'; Warning = '!!'; Error = 'XX' }
    Write-Host "[$($prefixes[$Status])] $Message" -ForegroundColor $colors[$Status]
}

# Main update function with visual progress
function Update-System {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    $logFile = Initialize-UpdateLog
    
    # Import helper functions
    . "$PSScriptRoot\..\UpdateAppsHelper.ps1"
    
    # Header
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                          ║" -ForegroundColor Cyan
    Write-Host "║               🔄  STARTING SYSTEM UPGRADE                 ║" -ForegroundColor Cyan
    Write-Host "║                                                          ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-UpdateStatus "Log file: $logFile" -Status Info
    Write-UpdateStatus "Starting system update at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')..." -Status Info
    Write-UpdateLog "Starting system update..." $logFile

    $startTime = Get-Date

    try {
        # Windows Update (Layer 0)
        Update-WindowsSystem

        # Winget updates (Layer 1)
        Update-Winget

        # Scoop updates (Layer 1)
        Update-Scoop

        # Chocolatey updates (Layer 1)
        Update-Choco

        # NPM global updates (Layer 2)
        Update-Npm

        # Pipx updates (Layer 2)
        Update-Pipx

        # Cargo updates (Layer 2)
        Update-Cargo

        # Uv tool updates (Layer 2)
        Update-Uv

        # Microsoft Store updates (Layer 3)
        Update-StoreApp

        # PowerShell module updates (Layer 3)
        Update-PowerShellModule
    }
    catch {
        Write-UpdateErrorLog $_.Exception.Message "System Update" $logFile
        Write-UpdateStatus "Update failed: $_" -Status Error
        $PSCmdlet.ThrowTerminatingError($_)
    }

    $endTime = Get-Date
    $duration = $endTime - $startTime

    # Footer
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                                                          ║" -ForegroundColor Green
    Write-Host "║            ✅  SYSTEM UPGRADE COMPLETED                  ║" -ForegroundColor Green
    Write-Host "║                                                          ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-UpdateStatus "Total duration: $($duration.ToString('hh\:mm\:ss'))" -Status Success
    Write-UpdateStatus "Log saved to: $logFile" -Status Info
    Write-Host ""
    
    Write-UpdateLog "System update completed" $logFile
}

# Create aliases
Set-Alias -Name upgrade -Value Update-System
