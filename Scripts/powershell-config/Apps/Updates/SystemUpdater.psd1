@{
    RootModule = 'SystemUpdater.ps1'
    ModuleVersion = '1.0.0'
    GUID = 'a1b2c3d4-e5f6-47g8-h9i0-j1k2l3m4n5o6'
    Author = 'System Administrator'
    Description = 'A unified system update module for PowerShell'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Update-System', 'Update-PowerShellModules')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @('upgrade')
    PrivateData = @{
        PSData = @{
            Tags = @('system', 'update', 'maintenance')
        }
    }
}