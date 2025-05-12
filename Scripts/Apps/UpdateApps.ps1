# Script to update all installed applications
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'Continue'

# Initialize logging
$logFile = Join-Path $env:TEMP "UpdateApps_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
function Write-Log {
    param($Message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

# Function to handle errors
function Handle-Error {
    param($ErrorMessage)
    Write-Log "ERROR: $ErrorMessage"
    Write-Log "Details: $($Error[0].Exception.Message)"
}

# Function to check if a command exists
function Test-CommandExists {
    param($Command)
    $null -ne (Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

# Update Windows using PowerShell module
Write-Log "Starting Windows Update..."
try {
    if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Log "Installing PSWindowsUpdate module..."
        Install-Module PSWindowsUpdate -Force -AllowClobber
    }
    Import-Module PSWindowsUpdate
    Get-WindowsUpdate -AcceptAll -Install -AutoReboot:$false | ForEach-Object {
        Write-Log "Installing Windows Update: $($_.Title)"
    }
} catch {
    Handle-Error "Failed to process Windows updates"
}

# Update package managers in parallel
$jobs = @()

# Winget updates
if (Test-CommandExists 'winget') {
    $jobs += Start-Job -ScriptBlock {
        try {
            winget upgrade --all --accept-source-agreements --disable-interactivity
        } catch {
            Write-Output "ERROR: Winget update failed - $($_.Exception.Message)"
        }
    } -Name 'WingetUpdate'
    Write-Log "Started Winget update job"
}

# Scoop updates
if (Test-CommandExists 'scoop') {
    $jobs += Start-Job -ScriptBlock {
        try {
            scoop update *
        } catch {
            Write-Output "ERROR: Scoop update failed - $($_.Exception.Message)"
        }
    } -Name 'ScoopUpdate'
    Write-Log "Started Scoop update job"
}

# Chocolatey updates
if (Test-CommandExists 'choco') {
    $jobs += Start-Job -ScriptBlock {
        try {
            choco upgrade all -y --no-progress
        } catch {
            Write-Output "ERROR: Chocolatey update failed - $($_.Exception.Message)"
        }
    } -Name 'ChocolateyUpdate'
    Write-Log "Started Chocolatey update job"
}

# NPM global updates
if (Test-CommandExists 'npm') {
    $jobs += Start-Job -ScriptBlock {
        try {
            npm update -g --silent
        } catch {
            Write-Output "ERROR: NPM update failed - $($_.Exception.Message)"
        }
    } -Name 'NpmUpdate'
    Write-Log "Started NPM update job"
}

# PowerShell module updates
try {
    Write-Log "Updating PowerShell modules..."
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
                    'NewVersion' = $online.Version
                }
            }
        } catch {
            Write-Log "WARNING: Could not check online version for module '$($currentModule.Name)': $($_.Exception.Message)"
        }
    }
    
    # Then attempt to update each module
    foreach ($moduleName in $modulesToUpdate.Keys) {
        $moduleInfo = $modulesToUpdate[$moduleName]
        try {
            # Check if module is currently loaded
            $loadedModule = Get-Module -Name $moduleName -ErrorAction SilentlyContinue
            if ($loadedModule) {
                Write-Log "INFO: Unloading module '$moduleName' for update..."
                try {
                    Remove-Module -Name $moduleName -Force -ErrorAction Stop
                    Write-Log "INFO: Successfully unloaded module '$moduleName'"
                } catch {
                    $modulesToRetry += $moduleName
                    Write-Log "WARNING: Could not unload module '$moduleName'. Will update after restart: $($_.Exception.Message)"
                    continue
                }
            }
            
            Update-Module -Name $moduleName -AcceptLicense -Force -ErrorAction Stop
            Write-Log "SUCCESS: Updated module '$moduleName' from version $($moduleInfo.CurrentVersion) to $($moduleInfo.NewVersion)"
            
            # Attempt to reload the module if it was previously loaded
            if ($loadedModule) {
                try {
                    Import-Module -Name $moduleName -Force -ErrorAction Stop
                    Write-Log "INFO: Successfully reloaded module '$moduleName' with new version"
                } catch {
                    Write-Log "WARNING: Could not reload module '$moduleName': $($_.Exception.Message)"
                }
            }
        } catch {
            if ($_.Exception.Message -match 'is currently in use') {
                $modulesToRetry += $moduleName
                Write-Log "WARNING: Module '$moduleName' is in use. Will update from $($moduleInfo.CurrentVersion) to $($moduleInfo.NewVersion) after restart."
            } else {
                Handle-Error "Failed to update module '$moduleName': $($_.Exception.Message)"
            }
        }
    }
    
    if ($modulesToRetry.Count -gt 0) {
        Write-Log "\nModules requiring restart to update:"
        $modulesToRetry | ForEach-Object {
            $info = $modulesToUpdate[$_]
            Write-Log "  - $_ (Current: $($info.CurrentVersion) → New: $($info.NewVersion))"
        }
        Write-Log "\nPlease restart PowerShell to complete these updates."
    } elseif ($modulesToUpdate.Count -eq 0) {
        Write-Log "All PowerShell modules are up to date."
    }
} catch {
    Handle-Error "Failed to process PowerShell module updates: $($_.Exception.Message)"
}

# Wait for all package manager jobs to complete
Write-Log "Waiting for package manager updates to complete..."
Wait-Job -Job $jobs | Out-Null

# Process results from jobs
foreach ($job in $jobs) {
    $result = Receive-Job -Job $job
    Write-Log "Results from $($job.Name):"
    $result | ForEach-Object { Write-Log $_ }
    Remove-Job -Job $job
}

Write-Log "All updates completed. Log file: $logFile"