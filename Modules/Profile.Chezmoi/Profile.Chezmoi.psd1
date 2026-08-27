@{
    RootModule = 'Profile.Chezmoi.psm1'
    ModuleVersion = '1.0.0'
    GUID = '0ff068ea-3315-40bb-bb88-b68cfc361eb8'
    Author = 'Clawdia MKDL'
    Description = 'Autoloaded Chezmoi commands for the PowerShell profile.'
    PowerShellVersion = '7.5'
    FunctionsToExport = @('cmc', 'cma', 'cmp', 'cms')
    AliasesToExport = @('cm')
    CmdletsToExport = @()
    VariablesToExport = @()
}
