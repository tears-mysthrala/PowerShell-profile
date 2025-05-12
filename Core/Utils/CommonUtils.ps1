# Common utility functions used across the PowerShell profile

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
    (Invoke-WebRequest http://ifconfig.me/ip).Content
}

function Initialize-EncodingConfig {
    $env:PYTHONIOENCODING = 'utf-8'
    [System.Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
    [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
}

Export-ModuleMember -Function *
