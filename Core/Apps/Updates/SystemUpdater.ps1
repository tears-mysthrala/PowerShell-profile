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
    Write-Host $logMessage
    Add-Content -Path $LogFile -Value $logMessage
}

# Error handling function
function Handle-UpdateError {
    param($ErrorMessage, $Source, $LogFile)
    Write-UpdateLog "ERROR [$Source]: $ErrorMessage" $LogFile
    Write-UpdateLog "Details: $($Error[0].Exception.Message)" $LogFile
}

# Command existence check
function Test-CommandExists {
    param($Command)
    $null -ne (Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

# Main update function with progress display
function Update-System {
    [CmdletBinding()]
    param()

    $progressParams = @{
        Activity = 'System Upgrade'
        CurrentOperation = 'Initializing'
    }

    $logFile = Initialize-UpdateLog
    Write-UpdateLog "Starting system update..." $logFile

    try {
        # Windows Update
        Write-Progress @progressParams -Status 'Checking Windows updates'
        if (Get-Command Get-WindowsUpdate -ErrorAction SilentlyContinue) {
            if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
                Install-Module PSWindowsUpdate -Force -AllowClobber
            }
            Import-Module PSWindowsUpdate
            Get-WindowsUpdate -AcceptAll -Install -AutoReboot:$false
        }

        # Winget updates
        Write-Progress @progressParams -Status 'Checking winget packages'
        if (Test-CommandExists 'winget') {
            winget upgrade --all --accept-source-agreements --accept-package-agreements
        }

        # Scoop updates
        Write-Progress @progressParams -Status 'Checking scoop apps'
        if (Test-CommandExists 'scoop') {
            scoop update
            scoop update *
        }

        # Chocolatey updates
        Write-Progress @progressParams -Status 'Checking choco packages'
        if (Test-CommandExists 'choco') {
            choco upgrade all -y
        }

        # NPM global updates
        Write-Progress @progressParams -Status 'Checking npm globals'
        if (Test-CommandExists 'npm') {
            npm update -g
        }

        # Microsoft Store updates
        Write-Progress @progressParams -Status 'Checking Store apps'
        if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
            Get-CimInstance -Namespace 'Root\cimv2' -ClassName 'Win32_AppxUpdateInfo' | 
                Where-Object { $_.UpdateAvailable -eq $true } | 
                ForEach-Object { Add-AppxPackage -Path $_.PackageLocation }
        }

        # PowerShell module updates
        Write-Progress @progressParams -Status 'Checking PowerShell modules'
        Update-PowerShellModules
    }
    catch {
        Handle-UpdateError $_.Exception.Message "System Update" $logFile
        Write-Warning "Update failed: $_"
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        Write-Progress -Completed @progressParams
    }

    Write-UpdateLog "System update completed" $logFile
}

# PowerShell module update function
function Update-PowerShellModules {
    $modulesToRetry = @()
    $modulesToUpdate = @{}
    
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
            Write-Warning "Could not check online version for module '$($currentModule.Name)': $($_.Exception.Message)"
        }
    }
    
    foreach ($moduleName in $modulesToUpdate.Keys) {
        $moduleInfo = $modulesToUpdate[$moduleName]
        try {
            $loadedModule = Get-Module -Name $moduleName -ErrorAction SilentlyContinue
            if ($loadedModule) {
                Remove-Module -Name $moduleName -Force -ErrorAction Stop
            }
            
            Update-Module -Name $moduleName -Force -ErrorAction Stop
            
            if ($loadedModule) {
                Import-Module -Name $moduleName -Force -ErrorAction Stop
            }
        } catch {
            if ($_.Exception.Message -match 'is currently in use') {
                $modulesToRetry += $moduleName
            } else {
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

# Create aliases
Set-Alias -Name upgrade -Value Update-System