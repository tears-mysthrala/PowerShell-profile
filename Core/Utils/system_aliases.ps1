# Navigation aliases and utilities
function .. { Set-Location .\.. }
function ... { Set-Location .\..\..\ }
function .3 { Set-Location .\..\..\..\.. }
function .4 { Set-Location .\..\..\..\..\ }
function .5 { Set-Location .\..\..\..\..\..\.. }

# File and directory management
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }
function New-File($file) { 
    [CmdletBinding(SupportsShouldProcess)]
    param($file)
    if ($PSCmdlet.ShouldProcess($file, "Create file")) {
        "" | Out-File $file -Encoding ASCII 
    }
}
Set-Alias -Name touch -Value New-File

# System aliases
Set-Alias -Name e -Value explorer.exe
Set-Alias -Name c -Value cls
Set-Alias -Name csl -Value cls
Set-Alias -Name ss -Value Select-String
Set-Alias -Name grep -Value Select-String
Set-Alias -Name shutdownnow -Value Stop-Computer
Set-Alias -Name rebootnow -Value Restart-Computer

# Quick Access to System Information
function sysinfo { Get-ComputerInfo }

# Networking Utilities
function Clear-DnsCache { Clear-DnsClientCache }
Set-Alias -Name flushdns -Value Clear-DnsCache

# Clipboard Utilities
function Set-ClipboardContent { Set-Clipboard $args[0] }
Set-Alias -Name cpy -Value Set-ClipboardContent

function Get-ClipboardContent { Get-Clipboard }
Set-Alias -Name pst -Value Get-ClipboardContent

# System utilities
function df { get-volume }
function which($name) { Get-Command $name | Select-Object -ExpandProperty Definition }
function Set-EnvironmentVariable($name, $value) { set-item -force -path "env:$name" -value $value }
Set-Alias -Name export -Value Set-EnvironmentVariable

function Stop-ProcessByName($name) { Get-Process $name -ErrorAction SilentlyContinue | Stop-Process }
Set-Alias -Name pkill -Value Stop-ProcessByName

function Get-ProcessByName($name) { Get-Process $name }
Set-Alias -Name pgrep -Value Get-ProcessByName
