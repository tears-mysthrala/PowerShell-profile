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

# Main update function with visual progress
function Update-System {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    $logFile = Initialize-UpdateLog
    $script:CurrentUpdateLogFile = $logFile
    $script:UpdateWarningCount = 0
    $script:UpdateErrorCount = 0
    
    # Import helper functions
    . "$PSScriptRoot\..\UpdateAppsHelper.ps1"
    
    # Header
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "               STARTING SYSTEM UPGRADE                       " -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-UpdateStatus "Log file: $logFile" -Status Info
    Write-UpdateStatus "Starting system update at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')..." -Status Info
    Write-UpdateLog "Starting system update..." $logFile

    $startTime = Get-Date

    try {
        # ============================================================
        # LAYER 0: WINDOWS SYSTEM
        # ============================================================
        Update-WindowsSystem
        Update-WSL

        # ============================================================
        # LAYER 1: PACKAGE MANAGERS
        # ============================================================
        Update-Winget
        Update-Scoop
        Update-Choco
        Update-Homebrew

        # ============================================================
        # LAYER 2: DEVELOPMENT TOOLS
        # ============================================================
        Update-Npm
        Update-Pipx
        Update-Cargo
        Update-Uv
        Update-Vcpkg
        Update-Conda
        Update-DotnetTool
        Update-Gem
        Update-GoTools
        Update-Composer
        Update-Gcloud

        # ============================================================
        # LAYER 3: APP STORES & FRAMEWORKS
        # ============================================================
        Update-StoreApp
        Update-PowerShellModule
        Update-PythonEnvironment
        Update-NodeEnvironment

        # ============================================================
        # LAYER 4: DOTFILES & SHELL TOOLS
        # ============================================================
        Update-Chezmoi
        Update-Starship
        Update-Fzf
        Update-VSCodeExtension

        # Keep this last: updating pwsh can interrupt the current host process.
        Update-PowerShellRuntime
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
    Write-Host "============================================================" -ForegroundColor Green
    if ($script:UpdateErrorCount -gt 0 -or $script:UpdateWarningCount -gt 0) {
        Write-Host "       SYSTEM UPGRADE COMPLETED WITH WARNINGS               " -ForegroundColor Yellow
    } else {
        Write-Host "            SYSTEM UPGRADE COMPLETED                        " -ForegroundColor Green
    }
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host ""
    Write-UpdateStatus "Total duration: $($duration.ToString('hh\:mm\:ss'))" -Status Success
    Write-UpdateStatus "Warnings: $script:UpdateWarningCount; errors: $script:UpdateErrorCount" -Status Info
    Write-UpdateStatus "Log saved to: $logFile" -Status Info
    Write-Host ""
    
    Write-UpdateLog "System update completed" $logFile
    $script:CurrentUpdateLogFile = $null
}

# Create aliases
Set-Alias -Name upgrade -Value Update-System
