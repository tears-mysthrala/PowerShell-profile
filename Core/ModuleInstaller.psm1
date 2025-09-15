# Module Installer for PowerShell Profile
# This script ensures all required modules are installed

$script:moduleRoot = Split-Path -Parent $PSCommandPath

$script:requiredModules = @{
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
        MinVersion  = '1.0.0'
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
    
    $module = Get-Module -ListAvailable $ModuleName | Sort-Object Version -Descending | Select-Object -First 1
    if (-not $module) {
        return $false
    }
    
    if ($MinVersion) {
        return [version]$module.Version -ge [version]$MinVersion
    }
    
    return $true
}

function Install-RequiredModules {
    foreach ($moduleName in $script:requiredModules.Keys) {
        $moduleInfo = $script:requiredModules[$moduleName]
        
        if (-not (Test-ModuleInstalled -ModuleName $moduleName -MinVersion $moduleInfo.MinVersion)) {
            Write-Host "Installing $moduleName ($($moduleInfo.Description))..." -ForegroundColor Yellow
            try {
                Install-Module -Name $moduleName -MinimumVersion $moduleInfo.MinVersion -Scope CurrentUser -Force -AllowClobber
                Write-Host "Successfully installed $moduleName" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to install $moduleName`: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

# Create module manifest if it doesn't exist
if (-not (Test-Path "$moduleRoot\ModuleInstaller.psd1")) {
    New-ModuleManifest -Path "$moduleRoot\ModuleInstaller.psd1" `
        -RootModule 'ModuleInstaller.psm1' `
        -ModuleVersion '1.0.0' `
        -Author 'unaiu' `
        -Description 'PowerShell module installer' `
        -FunctionsToExport @(
            'Test-ModuleInstalled',
            'Install-RequiredModules'
        )
}

# Export module members
Export-ModuleMember -Function Test-ModuleInstalled, Install-RequiredModules