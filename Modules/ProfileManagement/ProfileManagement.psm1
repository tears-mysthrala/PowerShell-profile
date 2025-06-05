# Module to manage PowerShell profile updates and reloading
# Initialize variables
$script:profileTiming = @{}
$script:backgroundJobs = @()

# Ensure these variables are also initialized in the global scope for modules that expect them
$global:profileTiming = @{}
$global:backgroundJobs = @()

Set-Alias -Name rl -Value Update-Profile

function Reset-ProfileState {
    [CmdletBinding()]
    param(
        [switch]$Quiet
    )
    
    try {        # Clear any existing background jobs
        $global:backgroundJobs = @()
        $script:backgroundJobs = @()
        
        # Clear profile timing information
        $global:profileTiming = @{}
        $script:profileTiming = @{}
        
        # Reset preference variables to their defaults
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

function Update-Profile {
    [CmdletBinding()]
    param()
    
    try {
        # Clean up state first
        Reset-ProfileState -Quiet
        
        # Reload profile
        if (Test-Path $PROFILE) {
            $timer = [System.Diagnostics.Stopwatch]::StartNew()
            # Use dot-sourcing with string to avoid type conversion issues
            . ([string]$PROFILE)
            $timer.Stop()
            
            Write-Host "`n✓ Profile reloaded successfully" -ForegroundColor Green
            Write-Host "  Time: $($timer.ElapsedMilliseconds)ms" -ForegroundColor Gray
            
            # Verify critical modules
            $criticalModules = @('PSReadLine', 'Terminal-Icons')
            $missing = $criticalModules | Where-Object { -not (Get-Module $_) }
            if ($missing) {
                foreach ($module in $missing) {
                    Write-Host "Installing missing critical module: $module" -ForegroundColor Yellow
                    if (-not (Get-Module -ListAvailable $module)) {
                        try {
                            Install-Module $module -Scope CurrentUser -Force -AllowClobber
                            Import-Module $module -Force
                            Write-Host "Successfully installed and loaded $module" -ForegroundColor Green
                        } catch {
                            Write-Warning "Failed to install $module. Error: $_"
                        }
                    } else {
                        try {
                            Import-Module $module -Force
                            Write-Host "Successfully loaded $module" -ForegroundColor Green
                        } catch {
                            Write-Warning "Failed to load $module. Error: $_"
                        }
                    }
                }
            }
        } else {
            Write-Warning "Profile not found at: $PROFILE"
            return
        }
    } catch {
        Write-Error "Failed to reload profile: $_"
        Write-Host "Try these steps:" -ForegroundColor Yellow
        Write-Host " 1. Restart PowerShell with: pwsh -NoProfile" -ForegroundColor Gray
        Write-Host " 2. Then run: . `$PROFILE" -ForegroundColor Gray
    }
}

# Export functions
Export-ModuleMember -Function @('Reset-ProfileState', 'Update-Profile') -Variable @('profileTiming', 'backgroundJobs') -Alias 'rl'
