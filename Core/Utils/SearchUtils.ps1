# Search utilities for PowerShell profile

function Find-File {
    param(
        [Parameter(Position=0)]
        [string]$pattern = "*",
        [string]$path = ".",
        [switch]$recurse,
        [int]$depth = 3
    )

    # Use fd if available (much faster)
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        if ($recurse) {
            fd --type f $pattern $path
        } else {
            fd --type f --max-depth $depth $pattern $path
        }
    }
    else {
        # Use PowerShell native with depth limit to prevent hanging
        $params = @{
            Path = $path
            Filter = $pattern
            ErrorAction = 'SilentlyContinue'
        }
        
        if ($recurse) {
            $params.Recurse = $true
        } else {
            $params.Depth = $depth
        }
        
        Get-ChildItem @params |
            Select-Object FullName, LastWriteTime, Length |
            Sort-Object LastWriteTime -Descending
    }
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

function Find-PowerShellCommand {
    param([string]$name)
    Get-Command -Name "*$name*" |
        Select-Object Name, CommandType, Version, Source |
        Format-Table -AutoSize
}

# Set aliases
Set-Alias -Name ff -Value Find-File
Set-Alias -Name search -Value Search-FileContent
Set-Alias -Name which -Value Find-PowerShellCommand


