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
        MinVersion  = '1.0.0'
        Description = 'Catppuccin theme for PowerShell (manual install: git clone or git pull only)'
        ManualInstall = $true
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
    
    $module = Get-Module -ListAvailable $ModuleName | Sort-Object Version -Descending | Select-Object -First 1
    if (-not $module) {
        return $false
    }
    
    if ($MinVersion -and ($module.Version -lt [version]$MinVersion)) {
        return $false
    }
    if($ManualInstall) {
        Write-Warning "$ModuleName must be installed/updated manually (git clone/pull). Skipping automatic installation."
        return $false
    }
    return $true
}

function Install-RequiredModules {
    [CmdletBinding()]
    param()
    
    Write-Host "Checking required PowerShell modules..." -ForegroundColor Cyan
    
    foreach ($module in $requiredModules.GetEnumerator()) {
        $moduleName = $module.Key
        $moduleInfo = $module.Value
        
        Write-Host "`nChecking $moduleName ($($moduleInfo.Description))..." -ForegroundColor Yellow
        if (-not (Get-Module -ListAvailable -Name $moduleName)) {
            Write-Warning "$moduleName is not installed. Attempting to install..."
        }
        
        if ($moduleInfo.ContainsKey('ManualInstall') -and $moduleInfo.ManualInstall) {
            Write-Warning "$moduleName must be installed/updated manually (git clone/pull). Skipping automatic installation."
            continue
        }
        if (Test-ModuleInstalled -ModuleName $moduleName -MinVersion $moduleInfo.MinVersion) {
            Write-Host "✓ $moduleName is already installed and up to date" -ForegroundColor Green
            continue
        }
        
        
        # Only show this if actually installing
        Write-Host "Installing $moduleName..." -ForegroundColor Yellow
        try {
            Install-Module -Name $moduleName -MinimumVersion $moduleInfo.MinVersion -Scope CurrentUser -Force -AllowClobber
            Write-Host "✓ Successfully installed $moduleName" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to install $moduleName`: $_"
        }
    }
    
    Write-Host "`nModule installation complete!" -ForegroundColor Cyan
}

# Export the function
Export-ModuleMember -Function Install-RequiredModules