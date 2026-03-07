# Script to update all installed applications
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'Continue'

# Initialize logging
$logFile = Join-Path $env:TEMP "UpdateApps_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
function Write-AppLog {
    param($Message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
    Write-Verbose $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

# Function to handle errors
function Write-ErrorLog {
    param($ErrorMessage)
    Write-AppLog "ERROR: $ErrorMessage"
    Write-AppLog "Details: $($Error[0].Exception.Message)"
}

# Load common utilities
. "$PSScriptRoot\..\Utils\CommonUtils.ps1"

# Update Windows using native API
Write-AppLog "Starting Windows Update..."
try {
    . "$PSScriptRoot\WindowsUpdateHelper.ps1"
    Update-WindowsUpdate
}
catch {
    Write-ErrorLog "Failed to process Windows updates"
}

# Load update helper functions
. "$PSScriptRoot\UpdateAppsHelper.ps1"

# Update package managers sequentially
if (Test-CommandExist 'winget') {
    Write-AppLog "Starting Winget update..."
    try {
        Update-Winget
        Write-AppLog "Winget update completed successfully"
    }
    catch {
        Write-ErrorLog "Winget update failed - $($_.Exception.Message)"
    }
}

if (Test-CommandExist 'scoop') {
    Write-AppLog "Starting Scoop update..."
    try {
        Update-Scoop
        Write-AppLog "Scoop update completed successfully"
    }
    catch {
        Write-ErrorLog "Scoop update failed - $($_.Exception.Message)"
    }
}

if (Test-CommandExist 'choco') {
    Write-AppLog "Starting Chocolatey update..."
    try {
        Update-Choco
        Write-AppLog "Chocolatey update completed successfully"
    }
    catch {
        Write-ErrorLog "Chocolatey update failed - $($_.Exception.Message)"
    }
}

if (Test-CommandExist 'npm') {
    Write-AppLog "Starting NPM global packages update..."
    try {
        Update-Npm
        Write-AppLog "NPM global packages update completed successfully"
    }
    catch {
        Write-ErrorLog "NPM update failed - $($_.Exception.Message)"
    }
}

# PowerShell module updates
try {
    Write-AppLog "Updating PowerShell modules..."
    $modulesToRetry = @()
    $modulesToUpdate = @{}

    # First, get all modules that need updates
    Get-Module -ListAvailable | ForEach-Object {
        $currentModule = $_
        try {
            $online = Find-Module -Name $currentModule.Name -ErrorAction SilentlyContinue
            if ($online -and ($online.Version -gt $currentModule.Version)) {
                $modulesToUpdate[$currentModule.Name] = @{
                    'CurrentVersion' = $currentModule.Version
                    'NewVersion'     = $online.Version
                }
            }
        }
        catch {
            Write-AppLog "WARNING: Could not check online version for module '$($currentModule.Name)': $($_.Exception.Message)"
        }
    }

    # Then attempt to update each module
    foreach ($moduleName in $modulesToUpdate.Keys) {
        $moduleInfo = $modulesToUpdate[$moduleName]
        try {
            $loadedModule = Get-Module -Name $moduleName -ErrorAction SilentlyContinue
            if ($loadedModule) {
                Write-AppLog "INFO: Unloading module '$moduleName' for update..."
                try {
                    Remove-Module -Name $moduleName -Force -ErrorAction Stop
                    Write-AppLog "INFO: Successfully unloaded module '$moduleName'"
                }
                catch {
                    $modulesToRetry += $moduleName
                    Write-AppLog "WARNING: Could not unload module '$moduleName'. Will update after restart: $($_.Exception.Message)"
                    continue
                }
            }

            Update-Module -Name $moduleName -AcceptLicense -Force -ErrorAction Stop
            Write-AppLog "SUCCESS: Updated module '$moduleName' from version $($moduleInfo.CurrentVersion) to $($moduleInfo.NewVersion)"

            # Attempt to reload the module if it was previously loaded
            if ($loadedModule) {
                try {
                    Import-Module -Name $moduleName -Force -ErrorAction Stop
                    Write-AppLog "INFO: Successfully reloaded module '$moduleName' with new version"
                }
                catch {
                    Write-AppLog "WARNING: Could not reload module '$moduleName': $($_.Exception.Message)"
                }
            }
        }
        catch {
            if ($_.Exception.Message -match 'is currently in use') {
                $modulesToRetry += $moduleName
                Write-AppLog "WARNING: Module '$moduleName' is in use. Will update from $($moduleInfo.CurrentVersion) to $($moduleInfo.NewVersion) after restart."
            }
            else {
                Write-ErrorLog "Failed to update module '$moduleName': $($_.Exception.Message)"
            }
        }
    }

    if ($modulesToRetry.Count -gt 0) {
        Write-AppLog "\nModules requiring restart to update:"
        $modulesToRetry | ForEach-Object {
            $info = $modulesToUpdate[$_]
            Write-AppLog "  - $_ (Current: $($info.CurrentVersion) → New: $($info.NewVersion))"
        }
        Write-AppLog "\nPlease restart PowerShell to complete these updates."
    }
    elseif ($modulesToUpdate.Count -eq 0) {
        Write-AppLog "All PowerShell modules are up to date."
    }
}
catch {
    Write-ErrorLog "Failed to process PowerShell module updates: $($_.Exception.Message)"
}

Write-AppLog "All updates completed. Log file: $logFile"
