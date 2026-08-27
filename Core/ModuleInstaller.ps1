# Module Installer for PowerShell Profile
# This script ensures all required modules are installed
# Optimization: read/write a single cache and install missing modules in a background job

$requiredModules = @{
    'PSReadLine'                    = @{
        MinVersion  = '2.2.0'
        Description = 'Enhanced command line editing'
    }
    'Terminal-Icons'                = @{
        MinVersion  = '0.10.0'
        Description = 'File and folder icons in terminal'
    }
    'posh-git'                      = @{
        MinVersion  = '1.1.0'
        Description = 'Git integration for PowerShell'
    }
    'PSFzf'                         = @{
        MinVersion  = '2.5.0'
        Description = 'Fuzzy finder integration'
    }
    'z'                             = @{
        MinVersion  = '1.1.0'
        Description = 'Directory jumping'
    }
    'PSWindowsUpdate'               = @{
        MinVersion  = '2.2.0.3'
        Description = 'Windows Update management'
    }
    'PowerShellGet'                 = @{
        MinVersion  = '2.2.5'
        Description = 'PowerShell module management'
    }
    'Microsoft.PowerToys.Configure' = @{
        MinVersion  = '0.91.1.0'
        Description = 'PowerToys configuration'
    }
    'CompletionPredictor'           = @{
        MinVersion  = '0.1.0'
        Description = 'Plugin-based command completion predictions'
    }
    'Microsoft.WinGet.CommandNotFound' = @{
        MinVersion  = '1.0.0'
        Description = 'Suggests winget packages for unrecognized commands'
    }
}

function Save-ModuleCache {
    $cacheFile = Join-Path $env:TEMP 'PSModuleCache.json'
    try {
        $script:PSModuleCache | ConvertTo-Json -Depth 4 | Set-Content $cacheFile -Force
    }
    catch {
        Write-Verbose "Failed to write module cache: $_"
    }
}

function Initialize-ModuleInstallationEnvironment {
    try {
        $nuget = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
        if (-not $nuget -or $nuget.Version -lt [version]'2.8.5.201') {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force -ErrorAction Stop | Out-Null
        }
    }
    catch {
        Write-Warning "[ModuleInstaller] Failed to initialize NuGet provider: $_"
    }

}

function Test-ModulePathHealthy {
    param([string]$ModulePath)

    if (-not $ModulePath -or -not (Test-Path $ModulePath)) {
        return $false
    }

    $item = Get-Item -LiteralPath $ModulePath -ErrorAction SilentlyContinue
    if (-not $item) {
        return $false
    }

    if (-not $item.PSIsContainer) {
        return $true
    }

    $moduleFiles = Get-ChildItem -Path $ModulePath -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -in '.psd1', '.psm1', '.dll' }

    return [bool]$moduleFiles
}

function Write-ModuleCacheEntry {
    param(
        [string]$ModuleName,
        [object]$Module
    )

    $script:PSModuleCache | Add-Member -NotePropertyName $ModuleName -NotePropertyValue (@{
        Version = $Module.Version.ToString()
        Path    = $Module.Path
    }) -Force
    Save-ModuleCache
}

function Test-ModuleInstalled {
    param(
        [string]$ModuleName,
        [string]$MinVersion
    )

    # Single cache file for this process
    $cacheFile = Join-Path $env:TEMP 'PSModuleCache.json'
    if (-not $script:PSModuleCache) {
        try {
            if (Test-Path $cacheFile) {
                $script:PSModuleCache = Get-Content $cacheFile -ErrorAction Stop | ConvertFrom-Json
            }
            else {
                $script:PSModuleCache = @{}
            }
        }
        catch {
            # Corrupt cache? start fresh
            $script:PSModuleCache = @{}
        }
    }

    # Fast path: check in-memory cache
    if ($script:PSModuleCache -and $script:PSModuleCache.PSObject.Properties.Name -contains $ModuleName) {
        $cachedModule = $script:PSModuleCache.$ModuleName
        if (Test-ModulePathHealthy -ModulePath $cachedModule.Path) {
            try {
                if (-not $MinVersion) {
                    return $true
                }
                return [version]$cachedModule.Version -ge [version]$MinVersion
            }
            catch {
                Write-Verbose "Version comparison failed for cached module $ModuleName, falling back to probing: $_"
            }
        }

        [void]$script:PSModuleCache.PSObject.Properties.Remove($ModuleName)
        Save-ModuleCache
    }

    # Probe installed modules only when cache miss or cached path is stale
    try {
        $module = Get-Module -ListAvailable -Name $ModuleName -ErrorAction SilentlyContinue |
            Where-Object { Test-ModulePathHealthy -ModulePath $_.Path } |
            Sort-Object Version -Descending |
            Select-Object -First 1
    }
    catch {
        $module = $null
    }

    if ($module) {
        Write-ModuleCacheEntry -ModuleName $ModuleName -Module $module

        if ($MinVersion -and ($module.Version -lt [version]$MinVersion)) {
            return $false
        }
        return $true
    }

    return $false
}

function Install-RequiredModule {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string[]]$Name = @($requiredModules.Keys)
    )

    foreach ($moduleName in $Name) {
        if (-not $requiredModules.ContainsKey($moduleName)) {
            throw "Unknown required module: $moduleName"
        }
    }

    Initialize-ModuleInstallationEnvironment

    # Collect missing modules (fast checks)
    $missing = @()
    foreach ($moduleName in $Name) {
        $moduleInfo = $requiredModules[$moduleName]
        if (-not (Test-ModuleInstalled -ModuleName $moduleName -MinVersion $moduleInfo.MinVersion)) {
            $missing += @{ Name = $moduleName; MinVersion = $moduleInfo.MinVersion }
        }
    }

    if ($missing.Count -eq 0) {
        return
    }

    Write-Verbose "[INFO] Missing modules detected: $($missing.Name -join ', '). Installing synchronously for immediate availability."

    # Install missing modules synchronously but efficiently
    foreach ($module in $missing) {
        $moduleName = $module.Name
        $info = $requiredModules[$moduleName]
        try {
            Write-Verbose "[ModuleInstaller] Installing module '$moduleName' (MinVersion: $($info.MinVersion))"
            Install-Module -Name $moduleName -MinimumVersion $info.MinVersion -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop -Confirm:$false -WarningAction SilentlyContinue | Out-Null
            
            # Update cache immediately after install
            $installedModule = Get-Module -ListAvailable -Name $moduleName -ErrorAction SilentlyContinue |
                Where-Object { Test-ModulePathHealthy -ModulePath $_.Path } |
                Sort-Object Version -Descending |
                Select-Object -First 1
            if ($installedModule -and $script:PSModuleCache) {
                Write-ModuleCacheEntry -ModuleName $moduleName -Module $installedModule
            }
        }
        catch {
            Write-Warning "[ModuleInstaller] Failed to install module '$moduleName': $_"
        }
    }
}
