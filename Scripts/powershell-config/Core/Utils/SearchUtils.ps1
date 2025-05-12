# Search utilities for PowerShell profile

function Find-Files {
    param(
        [Parameter(Position=0)]
        [string]$pattern = "*",
        [string]$path = ".",
        [switch]$recurse
    )
    
    Get-ChildItem -Path $path -Filter $pattern -Recurse:$recurse | 
        Select-Object FullName, LastWriteTime, Length | 
        Sort-Object LastWriteTime -Descending
}

function Search-FileContent {
    param(
        [Parameter(Mandatory=$true)]
        [string]$pattern,
        [string]$path = ".",
        [string]$filter = "*.*",
        [switch]$caseSensitive
    )
    
    $params = @{
        Path = $path
        Filter = $filter
        Recurse = $true
        ErrorAction = "SilentlyContinue"
    }
    
    Get-ChildItem @params | 
        Select-String -Pattern $pattern -CaseSensitive:$caseSensitive |
        Select-Object Path, Line, LineNumber
}

function Find-Command {
    param([string]$name)
    Get-Command -Name "*$name*" | 
        Select-Object Name, CommandType, Version, Source |
        Format-Table -AutoSize
}

# Set aliases
Set-Alias -Name ff -Value Find-Files
Set-Alias -Name search -Value Search-FileContent
Set-Alias -Name which -Value Find-Command


