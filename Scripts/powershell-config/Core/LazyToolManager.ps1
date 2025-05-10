# Lazy Tool Manager for PowerShell Profile

$script:loadedTools = @{}
$script:toolInitializers = @{}

function Register-LazyTool {
    param(
        [string]$Name,
        [scriptblock]$InitializerBlock,
        [bool]$LoadOnStartup = $false
    )
    $script:toolInitializers[$Name] = @{
        Block = $InitializerBlock
        LoadOnStartup = $LoadOnStartup
    }
}

function Import-LazyTool {
    param([string]$Name)
    if ($script:loadedTools[$Name]) { $true | Out-Null; return }
    
    if ($script:toolInitializers.ContainsKey($Name)) {
        try {
            & $script:toolInitializers[$Name].Block
            $script:loadedTools[$Name] = $true
            $true | Out-Null
            return
        } catch {
            Write-Warning ("Failed to load tool '{0}': {1}" -f $Name, $_.Exception.Message)
            $false | Out-Null
            return
        }
    }
    $false | Out-Null
    return
}

function Initialize-StartupTools {
    $script:toolInitializers.GetEnumerator() | Where-Object { $_.Value.LoadOnStartup } | ForEach-Object {
        Import-LazyTool $_.Key
    }
}

function Get-LazyToolStatus {
    $script:loadedTools.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.Key
            Loaded = $_.Value
        }
    }
}

# Register core tools that should always be loaded
Register-LazyTool 'PSReadLine' {
    Import-Module PSReadLine
    . "$env:USERPROFILE/OneDrive\Documents/PowerShell/Scripts/powershell-config/PSReadLine.ps1"
} -LoadOnStartup $true

# Register optional tools
Register-LazyTool 'Fzf' {
    . "$env:USERPROFILE/OneDrive\Documents/PowerShell/Scripts/powershell-config/Fzf.ps1"
}

Register-LazyTool 'Eza' {
    . "$env:USERPROFILE/OneDrive\Documents/PowerShell/Scripts/powershell-config/eza.ps1"
}

Register-LazyTool 'Bat' {
    . "$env:USERPROFILE/OneDrive\Documents/PowerShell/Scripts/powershell-config/bat.ps1"
}

Register-LazyTool 'Yazi' {
    . "$env:USERPROFILE/OneDrive\Documents/PowerShell/Scripts/powershell-config/yazi.ps1"
}

# Create wrapper functions for lazy loading
function Use-Fzf { Import-LazyTool 'Fzf' }
function Use-Eza { Import-LazyTool 'Eza' }
function Use-Bat { Import-LazyTool 'Bat' }
function Use-Yazi { Import-LazyTool 'Yazi' }