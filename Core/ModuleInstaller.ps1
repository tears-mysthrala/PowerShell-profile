# Module Installer for PowerShell Profile
# This script ensures all required modules are installed

$requiredModules = @{
    'PSReadLine'                    = @{
        MinVersion  = '2.2.0'
        Description = 'Enhanced command line editing'
    }
    'Terminal-Icons'                = @{
        MinVersion  = '0.10.0'
        Description = 'File and folder icons in terminal'
    }
    'posh-git'                      = @{
        MinVersion  = '1.1.0'
        Description = 'Git integration for PowerShell'
    }
    'PSFzf'                         = @{
        MinVersion  = '2.5.0'
        Description = 'Fuzzy finder integration'
    }
    'z'                             = @{
        MinVersion  = '1.1.0'
        Description = 'Directory jumping'
    }
    'Catppuccin'                    = @{
        MinVersion  = '0.2.0'
        Description = 'Catppuccin theme for PowerShell'
    }
    'PSWindowsUpdate'               = @{
        MinVersion  = '2.2.0.3'
        Description = 'Windows Update management'
    }
    'PowerShellGet'                 = @{
        MinVersion  = '2.2.5'
        Description = 'PowerShell module management'
    }
    'Microsoft.PowerToys.Configure' = @{
        MinVersion  = '0.91.1.0'
        Description = 'PowerToys configuration'
    }
}

function Test-ModuleInstalled {
    param(
        [string]$ModuleName,
        [string]$MinVersion
    )
  
    # Default logic for other modules
    $module = Get-Module -ListAvailable $ModuleName | Sort-Object Version -Descending | Select-Object -First 1
    if (-not $module) {
        return $false
    }
    if ($MinVersion -and ($module.Version -lt [version]$MinVersion)) {
        return $false
    }
    return $true
}

function Install-RequiredModules {
    [CmdletBinding()]
    param()
    
    foreach ($module in $requiredModules.GetEnumerator()) {
        $moduleName = $module.Key
        $moduleInfo = $module.Value
        
        if (Test-ModuleInstalled -ModuleName $moduleName -MinVersion $moduleInfo.MinVersion) {
            continue
        }
        try {
            # Suppress warnings during module installation (log this action)
            Write-Host "[INFO] Installing module '$moduleName' with WarningAction SilentlyContinue (warnings will be suppressed)" -ForegroundColor Yellow
            Install-Module -Name $moduleName -MinimumVersion $moduleInfo.MinVersion -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop -Confirm:$false -WarningAction SilentlyContinue | Out-Null
        }
        catch {
            Write-Host "Failed to install module '$moduleName': $_" -ForegroundColor Red
        }
    }
}
