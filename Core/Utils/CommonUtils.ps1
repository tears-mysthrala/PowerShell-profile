# Common utility functions used across the PowerShell profile

if (-not (Get-Command Test-CommandExist -ErrorAction SilentlyContinue)) {
    function Test-CommandExist {
        [CmdletBinding()]
        param([string]$command)
        return [bool](Get-Command $command -ErrorAction SilentlyContinue)
    }
}

function Test-IsAdmin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-FormattedUptime {
    $bootuptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    $CurrentDate = Get-Date
    $uptime = $CurrentDate - $bootuptime
    Write-Output "Uptime: $($uptime.Days) Days, $($uptime.Hours) Hours, $($uptime.Minutes) Minutes"
}

function Get-PubIP {
    try {
        (Invoke-WebRequest https://ifconfig.me/ip -TimeoutSec 10).Content
    } catch {
        Write-Warning "Failed to get public IP: $_"
    }
}

function Initialize-EncodingConfig {
    $env:PYTHONIOENCODING = 'utf-8'
    [System.Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
    [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
}
