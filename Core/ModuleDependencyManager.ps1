# Module Dependency Manager for PowerShell Profile

$script:moduleDependencies = @{}
$script:moduleVersions = @{}

function Register-ModuleDependency {
    param(
        [string]$ModuleName,
        [string]$MinVersion,
        [string[]]$Dependencies = @(),
        [scriptblock]$OnFailure
    )
    $script:moduleDependencies[$ModuleName] = @{
        MinVersion = $MinVersion
        Dependencies = $Dependencies
        OnFailure = $OnFailure
    }
}

function Test-ModuleRequirements {
    param([string]$ModuleName)
    
    if (-not $script:moduleDependencies.ContainsKey($ModuleName)) { return $true }
    
    $dependency = $script:moduleDependencies[$ModuleName]
    
    # Check version requirement
    $module = Get-Module -ListAvailable $ModuleName | Sort-Object Version -Descending | Select-Object -First 1
    if (-not $module) {
        Write-Warning "Module $ModuleName not found"
        return $false
    }
    
    if ($dependency.MinVersion -and ($module.Version -lt $dependency.MinVersion)) {
        Write-Warning "Module $ModuleName version $($module.Version) is below required version $($dependency.MinVersion)"
        return $false
    }
    
    # Check dependencies
    foreach ($dep in $dependency.Dependencies) {
        if (-not (Test-ModuleRequirements $dep)) {
            Write-Warning "Dependency $dep for module $ModuleName not satisfied"
            return $false
        }
    }
    
    return $true
}

function Import-ModuleWithDependencies {
    param(
        [string]$ModuleName,
        [switch]$Force
    )
    
    if (-not (Test-ModuleRequirements $ModuleName)) {
        if ($script:moduleDependencies[$ModuleName].OnFailure) {
            & $script:moduleDependencies[$ModuleName].OnFailure
        }
        return $false
    }
    
    try {
        Import-Module $ModuleName -Force:$Force -ErrorAction Stop
        return $true
    } catch {
        Write-Warning "Failed to import module $ModuleName: $_"
        return $false
    }
}