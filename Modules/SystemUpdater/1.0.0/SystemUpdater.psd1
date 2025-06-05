@{
    RootModule = 'SystemUpdater.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'a1b2c3d4-e5f6-4708-89a0-91b2c3d4e5f6'
    Author = 'System Administrator'
    Description = 'A unified system update module for PowerShell'
    PowerShellVersion = '5.1'
    RequiredModules = @('PSWindowsUpdate')
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