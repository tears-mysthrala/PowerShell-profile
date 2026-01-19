using namespace System.Threading
using namespace System.Collections.Concurrent

# Unified system update module
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'Continue'

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
    Write-UpdateLog "ERROR [$Source]: $ErrorMessage" $LogFile
    Write-UpdateLog "Details: $($Error[0].Exception.Message)" $LogFile
}

# Main update function with progress display
function Update-System {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("System", "Update")) {
        Activity         = 'System Upgrade'
        CurrentOperation = 'Initializing'
    }

    $logFile = Initialize-UpdateLog
    Write-UpdateLog "Starting system update..." $logFile

    try {
        # Windows Update
        Write-Progress @progressParams -Status 'Checking Windows updates'
        . "$PSScriptRoot\WindowsUpdateHelper.ps1"
        Update-WindowsUpdate

        # Winget updates
        Write-Progress @progressParams -Status 'Checking winget packages'
        . "$PSScriptRoot\UpdateAppsHelper.ps1"
        Update-Winget

        # Scoop updates
        Write-Progress @progressParams -Status 'Checking scoop apps'
        Update-Scoop

        # Chocolatey updates
        Write-Progress @progressParams -Status 'Checking choco packages'
        Update-Choco

        # NPM global updates
        Write-Progress @progressParams -Status 'Checking npm globals'
        Update-Npm

        # Microsoft Store updates
        Write-Progress @progressParams -Status 'Checking Store apps'
        Update-StoreApp

        # PowerShell module updates
        Write-Progress @progressParams -Status 'Checking PowerShell modules'
        Update-PowerShellModules
    }
    catch {
        Write-UpdateErrorLog $_.Exception.Message "System Update" $logFile
        Write-Warning "Update failed: $_"
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        Write-Progress -Completed @progressParams
    }

    Write-UpdateLog "System update completed" $logFile
}

# PowerShell module update function with parallel checking
function Update-PowerShellModule {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("PowerShell modules", "Update")) {
        $modulesToRetry = @()
        $modulesToUpdate = @{}
        $hasThreadJob = $null -ne (Get-Command Start-ThreadJob -ErrorAction SilentlyContinue)

        # Get all installed modules
        $allModules = Get-Module -ListAvailable | 
        Group-Object Name | 
        ForEach-Object { $_.Group | Sort-Object Version -Descending | Select-Object -First 1 }

        if ($hasThreadJob) {
            # Parallel version using ThreadJobs
            Write-Verbose "Checking module updates in parallel using ThreadJobs..."
            $jobs = @()
            
            foreach ($currentModule in $allModules) {
                $job = Start-ThreadJob -ScriptBlock {
                    param($moduleName, $currentVersion)
                    try {
                        $online = Find-Module -Name $moduleName -ErrorAction SilentlyContinue
                        if ($online -and ($online.Version -gt $currentVersion)) {
                            return @{
                                Name           = $moduleName
                                CurrentVersion = $currentVersion
                                NewVersion     = $online.Version
                            }
                        }
                    }
                    catch {
                        # Silently ignore errors
                    }
                    return $null
                } -ArgumentList $currentModule.Name, $currentModule.Version
                
                $jobs += $job
            }

            # Wait for all jobs and collect results
            $results = $jobs | Wait-Job | Receive-Job
            $jobs | Remove-Job -Force

            foreach ($result in $results) {
                if ($result) {
                    $modulesToUpdate[$result.Name] = @{
                        'CurrentVersion' = $result.CurrentVersion
                        'NewVersion'     = $result.NewVersion
                    }
                }
            }
        }
        else {
            # Sequential version (fallback)
            Write-Verbose "Checking module updates sequentially..."
            foreach ($currentModule in $allModules) {
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
                    Write-Warning "Could not check online version for module '$($currentModule.Name)': $($_.Exception.Message)"
                }
            }
        }

        # Update modules
        foreach ($moduleName in $modulesToUpdate.Keys) {
            try {
                $loadedModule = Get-Module -Name $moduleName -ErrorAction SilentlyContinue
                if ($loadedModule) {
                    Remove-Module -Name $moduleName -Force -ErrorAction Stop
                }

                Update-Module -Name $moduleName -Force -ErrorAction Stop

                if ($loadedModule) {
                    Import-Module -Name $moduleName -Force -ErrorAction Stop
                }
            }
            catch {
                if ($_.Exception.Message -match 'is currently in use') {
                    $modulesToRetry += $moduleName
                }
                else {
                    Write-Warning "Failed to update module '$moduleName': $($_.Exception.Message)"
                }
            }
        }

        if ($modulesToRetry.Count -gt 0) {
            Write-Warning "\nThe following modules require a PowerShell restart to update:"
            $modulesToRetry | ForEach-Object {
                $info = $modulesToUpdate[$_]
                Write-Warning "  - $_ (Current: $($info.CurrentVersion) → New: $($info.NewVersion))"
            }
        }
    }
}

# Create aliases
Set-Alias -Name upgrade -Value Update-System
