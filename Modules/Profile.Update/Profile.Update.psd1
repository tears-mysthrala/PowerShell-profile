@{
    RootModule = 'Profile.Update.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'dd22ef14-c3ef-4f8a-9a91-95b03732107b'
    Author = 'Clawdia MKDL'
    Description = 'Autoloaded system update entry point for the PowerShell profile.'
    PowerShellVersion = '7.5'
    FunctionsToExport = @('Update-System')
    AliasesToExport = @('upgrade')
    CmdletsToExport = @()
    VariablesToExport = @()
}
