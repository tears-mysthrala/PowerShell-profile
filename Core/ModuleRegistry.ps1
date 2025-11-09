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
            . "$ProfileDir\Core\Apps\Updates\SystemUpdater.ps1"
        }
        Category = 'System'
    }
    'AppsManage' = @{ Block = { . "$ProfileDir\Core\Apps\appsManage.ps1" }; Category = 'Apps' }
    'LinuxLike' = @{ Block = { . "$ProfileDir\Core\System\linuxLike.ps1" }; Category = 'Shell' }
    'Clean' = @{ Block = { . "$ProfileDir\Core\System\clean.ps1" }; Category = 'System' }
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
            Write-Verbose "Loaded $($script:moduleAliases[$module].Description) successfully" -ForegroundColor Green
        } catch {
            Write-Verbose "Failed to load $($script:moduleAliases[$module].Description): $_" -ForegroundColor Red
        }
    }.GetNewClosure()
}

# Export functions
# Export-ModuleMember -Function * -Variable moduleAliases
