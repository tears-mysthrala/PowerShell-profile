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

        Write-UpdateLog "System update completed successfully" $logFile
    }
    catch {
        Handle-UpdateError $_.Exception.Message "System Update" $logFile
        Write-Warning "Update failed: $_"
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        Write-Progress -Activity 'System Upgrade' -Completed
    }
}

# PowerShell module update function
function Update-PowerShellModules {
    [CmdletBinding()]
    param()

    $logFile = Initialize-UpdateLog
    Write-UpdateLog "Starting PowerShell module updates..." $logFile

    try {
        $modules = Get-InstalledModule

        foreach ($module in $modules) {
            try {
                $online = Find-Module -Name $module.Name -ErrorAction SilentlyContinue
                if ($online.Version -gt $module.Version) {
                    Write-UpdateLog "Updating module: $($module.Name)" $logFile
                    Update-Module -Name $module.Name -Force -ErrorAction Continue
                }
            }
            catch {
                Handle-UpdateError $_.Exception.Message "Module Update: $($module.Name)" $logFile
                continue
            }
        }

        Write-UpdateLog "PowerShell module updates completed" $logFile
    }
    catch {
        Handle-UpdateError $_.Exception.Message "PowerShell Module Updates" $logFile
        Write-Warning "Module updates failed: $_"
        throw
    }
}

# Export functions
Export-ModuleMember -Function @('Update-System', 'Update-PowerShellModules')
# Export alias
New-Alias -Name 'upgrade' -Value 'Update-System'
Export-ModuleMember -Alias 'upgrade'