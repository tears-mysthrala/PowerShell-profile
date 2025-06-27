# Module Installer for PowerShell Profile
# This script ensures all required modules are installed

$requiredModules = @{
    'PSReadLine'                    = @{
        MinVersion  = '2.2.0'
        Description = 'Enhanced command line editing'
        ManualInstall = $false
    }
    'Terminal-Icons'                = @{
        MinVersion  = '0.10.0'
        Description = 'File and folder icons in terminal'
        ManualInstall = $false
    }
    'posh-git'                      = @{
        MinVersion  = '1.1.0'
        Description = 'Git integration for PowerShell'
        ManualInstall = $false
    }
    'PSFzf'                         = @{
        MinVersion  = '2.5.0'
        Description = 'Fuzzy finder integration'
        ManualInstall = $false
    }
    'z'                             = @{
        MinVersion  = '1.1.0'
        Description = 'Directory jumping'
        ManualInstall = $false
    }
    'Catppuccin'                    = @{
        MinVersion  = '0.2.0'
        Description = 'Catppuccin theme for PowerShell'
    }
    'PSWindowsUpdate'               = @{
        MinVersion  = '2.2.0.3'
        Description = 'Windows Update management'
        ManualInstall = $false
    }
    'PowerShellGet'                 = @{
        MinVersion  = '2.2.5'
        Description = 'PowerShell module management'
        ManualInstall = $false
    }
    'Microsoft.PowerToys.Configure' = @{
        MinVersion  = '0.91.1.0'
        Description = 'PowerToys configuration'
        ManualInstall = $false
    }
}

function Test-ModuleInstalled {
    param(
        [string]$ModuleName,
        [string]$MinVersion,
        [bool]$ManualInstall = $false
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
        
        if ($moduleInfo.ContainsKey('ManualInstall') -and $moduleInfo.ManualInstall) {
            Write-Warning "$moduleName must be installed/updated manually (git clone/pull). Skipping automatic installation."
            continue
        }
        if (Test-ModuleInstalled -ModuleName $moduleName -MinVersion $moduleInfo.MinVersion) {
            continue
        }
        try {
            Install-Module -Name $moduleName -MinimumVersion $moduleInfo.MinVersion -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop -Confirm:$false -WarningAction SilentlyContinue | Out-Null
        }
        catch {
            Write-Host "Failed to install module '$moduleName': $_" -ForegroundColor Red
        }
    }
}
