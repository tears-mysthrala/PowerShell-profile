# Common utility functions used across the PowerShell profile

# Create module scope
$script:moduleRoot = Split-Path -Parent $PSCommandPath

function Test-CommandExists {
    [CmdletBinding()]
    param([string]$command)
    
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    try {
        if (Get-Command $command) {
            return $true
        }
    } finally {
        $ErrorActionPreference = $oldPreference
    }
    return $false
}

function Test-IsAdmin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-FormatedUptime {
    $bootuptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    $CurrentDate = Get-Date
    $uptime = $CurrentDate - $bootuptime
    Write-Output "Uptime: $($uptime.Days) Days, $($uptime.Hours) Hours, $($uptime.Minutes) Minutes"
}

function Get-PubIP {
    (Invoke-WebRequest https://ifconfig.me/ip).Content
}

function Initialize-EncodingConfig {
    $env:PYTHONIOENCODING = 'utf-8'
    [System.Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
    [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
}

# Create module manifest if it doesn't exist
if (-not (Test-Path "$moduleRoot\CommonUtils.psd1")) {
    New-ModuleManifest -Path "$moduleRoot\CommonUtils.psd1" `
        -RootModule 'CommonUtils.psm1' `
        -ModuleVersion '1.0.0' `
        -Author 'unaiu' `
        -Description 'Common utility functions for PowerShell profile' `
        -FunctionsToExport @('Test-CommandExists', 'Test-IsAdmin', 'Get-FormatedUptime', 'Get-PubIP', 'Initialize-EncodingConfig')
}

# Export module members
Export-ModuleMember -Function Test-CommandExists, Test-IsAdmin, Get-FormatedUptime, Get-PubIP, Initialize-EncodingConfig
