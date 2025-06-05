# Module manifest for ProfileManagement
@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'ProfileManagement.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = '12345678-90ab-cdef-1234-567890abcdef'

    # Author of this module
    Author = 'unaiu'

    # Company or vendor of this module
    CompanyName = 'None'

    # Copyright statement for this module
    Copyright = '(c) 2025 unaiu. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'PowerShell Profile Management Module'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @('Reset-ProfileState', 'Update-Profile')

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @('profileTiming', 'backgroundJobs')

    # Aliases to export from this module
    AliasesToExport = @('rl')

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('profile', 'management')
        }
    }
}
