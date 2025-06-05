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
    
    if ($MinVersion -and ($module.Version -lt [version]$MinVersion)) {
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
        
        if (Test-ModuleInstalled -ModuleName $moduleName -MinVersion $moduleInfo.MinVersion) {
            Write-Host "✓ $moduleName is already installed and up to date" -ForegroundColor Green
            continue
        }
        
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