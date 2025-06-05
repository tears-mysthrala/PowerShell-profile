<#
.SYNOPSIS

Appends the existing Windows PowerShell PSModulePath to existing PSModulePath

.DESCRIPTION

If the current PSModulePath does not contain the Windows PowerShell PSModulePath, it will
be appended to the end.

.INPUTS

None.

.OUTPUTS

None.

.EXAMPLE

C:\PS> Add-WindowsPSModulePath
C:\PS> Import-Module Hyper-V

.EXAMPLE

C:\PS> Add-WindowsPSModulePath
C:\PS> Get-Module -ListAvailable
#>

function Add-WindowsPSModulePath
{

    if (! $IsWindows)
    {
        throw "This cmdlet is only supported on Windows"
    }

    $WindowsPSModulePath = [System.Environment]::GetEnvironmentVariable("psmodulepath", [System.EnvironmentVariableTarget]::Machine)
    if (-not ($env:PSModulePath).Contains($WindowsPSModulePath))
    {
        $env:PSModulePath += ";${env:userprofile}\Documents\WindowsPowerShell\Modules;${env:programfiles}\WindowsPowerShell\Modules;${WindowsPSModulePath}"
    }

}
