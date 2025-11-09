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
    #Write-Host "[INFO] Checking for command '$Command' with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
    $null -ne (Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

# Main update function with progress display
function Update-System {
    [CmdletBinding()]
    param()

    $progressParams = @{
        Activity         = 'System Upgrade'
        CurrentOperation = 'Initializing'
    }

    $logFile = Initialize-UpdateLog
    Write-UpdateLog "Starting system update..." $logFile

    try {
        # Windows Update
        Write-Progress @progressParams -Status 'Checking Windows updates'
        try {
            # Use native Windows Update API via COM objects
            $UpdateSession = New-Object -ComObject Microsoft.Update.Session
            $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
            $SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software'")
            $Updates = $SearchResult.Updates | Where-Object { !$_.IsHidden }
            
            if ($Updates.Count -gt 0) {
                Write-Host "Found $($Updates.Count) Windows updates to install." -ForegroundColor Yellow
                $UpdatesToDownload = New-Object -ComObject Microsoft.Update.UpdateColl
                $UpdatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
                
                foreach ($Update in $Updates) {
                    $UpdatesToDownload.Add($Update) | Out-Null
                    $UpdatesToInstall.Add($Update) | Out-Null
                }
                
                # Download updates
                $Downloader = $UpdateSession.CreateUpdateDownloader()
                $Downloader.Updates = $UpdatesToDownload
                Write-Host "Downloading updates..." -ForegroundColor Cyan
                $DownloadResult = $Downloader.Download()
                
                # Install updates
                $Installer = $UpdateSession.CreateUpdateInstaller()
                $Installer.Updates = $UpdatesToInstall
                Write-Host "Installing updates..." -ForegroundColor Cyan
                $InstallationResult = $Installer.Install()
                
                if ($InstallationResult.ResultCode -eq 2) {
                    Write-Host "Windows updates installed successfully. Reboot may be required." -ForegroundColor Green
                } else {
                    Write-Host "Some updates failed to install." -ForegroundColor Red
                }
            } else {
                Write-Host "No Windows updates available." -ForegroundColor Green
            }
        }
        catch {
            Write-Host "Failed to check/install Windows updates: $_" -ForegroundColor Red
        }

        # Winget updates
        Write-Progress @progressParams -Status 'Checking winget packages'
        if (Test-CommandExists 'winget') {
            winget upgrade -rhu --accept-source-agreements --accept-package-agreements
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
            #Write-Host "[INFO] Checking online version for module '$($currentModule.Name)' with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
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
    
    foreach ($moduleName in $modulesToUpdate.Keys) {
        $moduleInfo = $modulesToUpdate[$moduleName]
        try {
            #Write-Host "[INFO] Checking if module '$moduleName' is loaded with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
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