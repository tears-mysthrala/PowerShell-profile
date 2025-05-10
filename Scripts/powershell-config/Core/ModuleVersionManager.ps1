# Module Version Manager for PowerShell Profile

$script:moduleVersions = @{}
$script:moduleLoadAttempts = @{}

function Register-ModuleVersion {
    param(
        [string]$ModuleName,
        [string]$RequiredVersion,
        [scriptblock]$OnVersionMismatch
    )
    $script:moduleVersions[$ModuleName] = @{
        RequiredVersion = $RequiredVersion
        OnVersionMismatch = $OnVersionMismatch
    }
}

function Test-ModuleVersion {
    param([string]$ModuleName)
    
    if (-not $script:moduleVersions.ContainsKey($ModuleName)) { return $true }
    
    $versionInfo = $script:moduleVersions[$ModuleName]
    $module = Get-Module -ListAvailable $ModuleName | Sort-Object Version -Descending | Select-Object -First 1
    
    if (-not $module) {
        Write-Warning "Module $ModuleName not found"
        return $false
    }
    
    if ($versionInfo.RequiredVersion -and ($module.Version -ne $versionInfo.RequiredVersion)) {
        if ($versionInfo.OnVersionMismatch) {
            & $versionInfo.OnVersionMismatch
        }
        Write-Warning "Module $ModuleName version mismatch. Required: $($versionInfo.RequiredVersion), Found: $($module.Version)"
        return $false
    }
    
    return $true
}

function Import-ModuleWithVersion {
    param(
        [string]$ModuleName,
        [int]$MaxAttempts = 3,
        [switch]$Force
    )
    
    if (-not $script:moduleLoadAttempts.ContainsKey($ModuleName)) {
        $script:moduleLoadAttempts[$ModuleName] = 0
    }
    
    if ($script:moduleLoadAttempts[$ModuleName] -ge $MaxAttempts) {
        Write-Warning "Maximum load attempts reached for module $ModuleName"
        return $false
    }
    
    $script:moduleLoadAttempts[$ModuleName]++
    
    if (-not (Test-ModuleVersion $ModuleName)) {
        return $false
    }
    
    try {
        Import-Module $ModuleName -Force:$Force -ErrorAction Stop
        $script:moduleLoadAttempts[$ModuleName] = 0
        return $true
    } catch {
        Write-Warning "Failed to import module $ModuleName: $_"
        return $false
    }
}