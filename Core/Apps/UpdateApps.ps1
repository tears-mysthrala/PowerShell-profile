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
    Update-WindowsUpdate -UseLog
}
catch {
    Write-ErrorLog "Failed to process Windows updates"
}

# Update package managers in parallel
$jobs = @()

. "$PSScriptRoot\UpdateAppsHelper.ps1"

# Winget updates
if (Test-CommandExist 'winget') {
    if (Get-Command -Name Start-ThreadJob -ErrorAction SilentlyContinue) {
        $jobs += Start-ThreadJob -ScriptBlock {
            try {
                Write-AppLog "Starting Winget update..."
                Update-Winget -Silent
                Write-AppLog "Winget update completed successfully"
            }
            catch {
                Write-Output "ERROR: Winget update failed - $($_.Exception.Message)"
            }
        } -Name 'WingetUpdate'
        Write-AppLog "Started Winget update job"
    }
}

# Scoop updates
if (Test-CommandExist 'scoop') {
    if (Get-Command -Name Start-ThreadJob -ErrorAction SilentlyContinue) {
        $jobs += Start-ThreadJob -ScriptBlock {
            try {
                Write-AppLog "Starting Scoop update..."
                Update-Scoop -Silent
                Write-AppLog "Scoop update completed successfully"
            }
            catch {
                Write-Output "ERROR: Scoop update failed - $($_.Exception.Message)"
            }
        } -Name 'ScoopUpdate'
        Write-AppLog "Started Scoop update job"
    }
}

# Chocolatey updates
if (Test-CommandExist 'choco') {
    if (Get-Command -Name Start-ThreadJob -ErrorAction SilentlyContinue) {
        $jobs += Start-ThreadJob -ScriptBlock {
            try {
                Write-AppLog "Starting Chocolatey update..."
                Update-Choco -Silent
                Write-AppLog "Chocolatey update completed successfully"
            }
            catch {
                Write-Output "ERROR: Chocolatey update failed - $($_.Exception.Message)"
            }
        } -Name 'ChocolateyUpdate'
        Write-AppLog "Started Chocolatey update job"
    }
}

# NPM global updates
if (Test-CommandExist 'npm') {
    if (Get-Command -Name Start-ThreadJob -ErrorAction SilentlyContinue) {
        $jobs += Start-ThreadJob -ScriptBlock {
            try {
                Write-AppLog "Starting NPM global packages update..."
                Update-Npm -Silent
                Write-AppLog "NPM global packages update completed successfully"
            }
            catch {
                Write-Output "ERROR: NPM update failed - $($_.Exception.Message)"
            }
        } -Name 'NpmUpdate'
        Write-AppLog "Started NPM update job"
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
            #Write-Verbose "[INFO] Checking online version for module '$($currentModule.Name)' with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
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
            # Check if module is currently loaded
            #Write-Verbose "[INFO] Checking if module '$moduleName' is loaded with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
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

# Wait for all package manager jobs to complete
Write-AppLog "Waiting for package manager updates to complete..."
Wait-Job -Job $jobs | Out-Null


# Color map for each job name
$jobColors = @{
    'WingetUpdate'     = 'Cyan'
    'ScoopUpdate'      = 'Yellow'
    'ChocolateyUpdate' = 'Magenta'
    'NpmUpdate'        = 'Green'
}

# Process results from jobs with color
foreach ($job in $jobs) {
    $result = Receive-Job -Job $job
    $color = $jobColors[$job.Name]
    if (-not $color) { $color = 'White' }
    Write-Information ("Results from $($job.Name):")
    if ($result) {
        $result | ForEach-Object { Write-Information $_ }
    }
    else {
        Write-Verbose "(No output)"
    }
    Remove-Job -Job $job
}

Write-AppLog "All updates completed. Log file: $logFile"
