# Lazy Module Manager for PowerShell Profile

$script:loadedModules = @{}
$script:moduleInitializers = @{}

function Register-LazyModule {
    param(
        [string]$Name,
        [scriptblock]$InitializerBlock
    )
    $script:moduleInitializers[$Name] = $InitializerBlock
}

function Import-LazyModule {
    param([string]$Name)
    if ($script:loadedModules[$Name]) { return $true }
    
    if ($script:moduleInitializers.ContainsKey($Name)) {
        try {
            & $script:moduleInitializers[$Name]
            $script:loadedModules[$Name] = $true
            return $true
        } catch {
            Write-Warning "Failed to load module ${Name}: $($_.Exception.Message)"
            return $false
        }
    }
    return $false
}

function Get-LazyModuleStatus {
    $script:loadedModules.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.Key
            Loaded = $_.Value
        }
    }
}