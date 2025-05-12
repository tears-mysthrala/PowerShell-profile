# Module Registry Configuration
$script:moduleAliases = @{
    'CheckWifiPassword' = @{ Description = 'Network tools'; Category = 'Network' }
    'Chtsh' = @{ Description = 'Developer tools'; Category = 'Dev' }
    'AppsManage' = @{ Description = 'Application management'; Category = 'Apps' }
    'LinuxLike' = @{ Description = 'Shell utilities'; Category = 'Shell' }
    'Gpg' = @{ Description = 'Security tools'; Category = 'Security' }
    'CloudflareWARP' = @{ Description = 'Network tools'; Category = 'Network' }
    'Clean' = @{ Description = 'System maintenance'; Category = 'System' }
    'Stylus' = @{ Description = 'Development tools'; Category = 'Dev' }
}

# Register utility modules (lazy-loaded)
$moduleConfigs = @{
    'SystemUpdater' = @{ 
        Block = { 
            Import-Module "$ProfileDir\Scripts\powershell-config\Apps\Updates\SystemUpdater.psd1" -Force
            . "$ProfileDir\Scripts\powershell-config\setAlias.ps1"
        }
        Category = 'System'
    }
    'CheckWifiPassword' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\Helpers\checkWifiPassword.ps1" }; Category = 'Network' }
    'CloudflareWARP' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\Helpers\cloudflareWARP.ps1" }; Category = 'Network' }
    'Gpg' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\Helpers\gpg.ps1" }; Category = 'Security' }
    'Chtsh' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\chtsh.ps1" }; Category = 'Dev' }
    'LinuxLike' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\Helpers\linuxLike.ps1" }; Category = 'Shell' }
    'AppsManage' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\appsManage.ps1" }; Category = 'Apps' }
    'Clean' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\Helpers\clean.ps1" }; Category = 'System' }
    'Stylus' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\Helpers\stylus.ps1" }; Category = 'Dev' }
}

$moduleConfigs.GetEnumerator() | ForEach-Object {
    Register-UnifiedModule $_.Key -InitializerBlock $_.Value.Block
}

# Create module loading functions with improved error handling
foreach ($module in $script:moduleAliases.Keys) {
    $functionName = "Use-$module"
    Set-Item -Path "Function:$functionName" -Value {
        try {
            Import-UnifiedModule $module
            Write-Host "Loaded $($script:moduleAliases[$module].Description) successfully" -ForegroundColor Green
        } catch {
            Write-Host "Failed to load $($script:moduleAliases[$module].Description): $_" -ForegroundColor Red
        }
    }.GetNewClosure()
}

# Export functions
Export-ModuleMember -Function * -Variable moduleAliases
