# Module Registry Configuration
$script:moduleAliases = @{
    'AppsManage' = @{ Description = 'Application management'; Category = 'Apps' }
    'LinuxLike' = @{ Description = 'Shell utilities'; Category = 'Shell' }
    'Clean' = @{ Description = 'System maintenance'; Category = 'System' }
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
    'AppsManage' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\appsManage.ps1" }; Category = 'Apps' }
    'LinuxLike' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\Helpers\linuxLike.ps1" }; Category = 'Shell' }
    'Clean' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\Helpers\clean.ps1" }; Category = 'System' }
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
# Export-ModuleMember -Function * -Variable moduleAliases
