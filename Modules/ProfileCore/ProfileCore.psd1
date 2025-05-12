# Module manifest for module 'ProfileCore'
@{
    ModuleVersion = '1.0.0'
    GUID = '12345678-1234-5678-1234-567812345678'
    Author = 'unaiu'
    CompanyName = 'None'
    Copyright = '(c) 2025 unaiu. All rights reserved.'
    Description = 'Core profile functionality for PowerShell'
    PowerShellVersion = '7.0'
    RootModule = 'ProfileCore.psm1'
    FunctionsToExport = @(
        'Register-PSModule',
        'Import-PSModule',
        'Initialize-PSModules',
        'Get-PSModules',
        'Get-AvailableModules',
        # Dynamic Use-* functions are added at runtime
        'Use-LinuxLike',
        'Use-Chtsh',
        'Use-Clean',
        'Use-SystemUpdater',
        'Use-AppsManage',
        'Use-CheckWifiPassword',
        'Use-CloudflareWARP',
        'Use-Stylus',
        'Use-Gpg'
    )
    VariablesToExport = @('moduleAliases')
    AliasesToExport = @('modules')
    CmdletsToExport = @()
    TypesToProcess = @()
    ScriptsToProcess = @()
    RequiredModules = @()
}
