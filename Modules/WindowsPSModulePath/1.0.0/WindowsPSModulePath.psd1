@{
    RootModule = '.\WindowsPSModulePath.psm1'
    ModuleVersion = '1.0.0'
    CompatiblePSEditions = 'Core', 'Desktop'
    GUID = '735537ea-edfe-43c6-8d9e-f210471061b8'
    Author = 'Steve Lee'
    CompanyName = 'Microsoft Corp'
    Copyright = '(c) Microsoft. All rights reserved.'
    Description = 'Simplify using existing Windows PowerShell modules on PowerShell Core by appending the PSModulePath from Windows PowerShell.  PSModulePath is not persisted and only applicable to the current process and child processes'
    PowerShellVersion = '5.1'
    FunctionsToExport = 'Add-WindowsPSModulePath'
    PrivateData = @{
        PSData = @{
            Tags = 'Windows', 'PowerShellCore'
        }
    }
}

