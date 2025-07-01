# Profile management module

$script:moduleRoot = Split-Path -Parent $PSCommandPath

function Reset-ProfileState {
    [CmdletBinding()]
    param(
        [switch]$Quiet
    )
    
    try {
        # Clear any existing background jobs
        $script:backgroundJobs = @()
        
        # Clear profile timing information
        $script:profileTiming = @{}
        
        # Reset preference variables to their defaults
        # Reset preference variables to their defaults (log this action)
        Write-Host "[INFO] Resetting global preference variables to defaults..." -ForegroundColor Yellow
        $global:WarningPreference = 'Continue'
        $global:VerbosePreference = 'SilentlyContinue'
        $global:InformationPreference = 'Continue'
        $global:DebugPreference = 'SilentlyContinue'
        
        # Force garbage collection
        [System.GC]::Collect()
        
        if (-not $Quiet) {
            Write-Host "Profile state reset successfully" -ForegroundColor Green
        }
    } catch {
        Write-Error "Failed to reset profile state: $_"
        throw
    }
}

# Create module manifest if it doesn't exist
if (-not (Test-Path "$moduleRoot\profile_management.psd1")) {
    New-ModuleManifest -Path "$moduleRoot\profile_management.psd1" `
        -RootModule 'profile_management.psm1' `
        -ModuleVersion '1.0.0' `
        -Author 'unaiu' `
        -Description 'Profile management functions' `
        -FunctionsToExport @('Reset-ProfileState')
}

# Export module members
Export-ModuleMember -Function Reset-ProfileState
