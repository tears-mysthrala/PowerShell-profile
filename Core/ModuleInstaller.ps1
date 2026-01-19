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
    'Catppuccin'                    = @{
        MinVersion  = '0.2.0'
        Description = 'Catppuccin theme for PowerShell'
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
        try {
            return [version]$cachedModule.Version -ge [version]$MinVersion
        }
        catch {
            Write-Verbose "Version comparison failed for cached module $ModuleName, falling back to probing: $_"
        }
    }

    # Probe installed modules (fast) only when cache miss
    try {
        $module = Get-Module -ListAvailable -Name $ModuleName -ErrorAction SilentlyContinue | Sort-Object Version -Descending | Select-Object -First 1
    }
    catch {
        $module = $null
    }

    if ($module) {
        # Update in-memory cache and persist
        $script:PSModuleCache | Add-Member -NotePropertyName $ModuleName -NotePropertyValue (@{
            Version = $module.Version.ToString()
            Path = $module.ModuleBase
        }) -Force
        try {
            $script:PSModuleCache | ConvertTo-Json -Depth 4 | Set-Content $cacheFile -Force
        }
        catch {
            Write-Verbose "Failed to write module cache: $_"
        }

        if ($MinVersion -and ($module.Version -lt [version]$MinVersion)) {
            return $false
        }
        return $true
    }

    return $false
}

function Install-RequiredModule {
    [CmdletBinding()]
    param()

    # Collect missing modules (fast checks)
    $missing = @()
    foreach ($module in $requiredModules.GetEnumerator()) {
        $moduleName = $module.Key
        $moduleInfo = $module.Value
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
            $installedModule = Get-Module -ListAvailable -Name $moduleName -ErrorAction SilentlyContinue | Sort-Object Version -Descending | Select-Object -First 1
            if ($installedModule -and $script:PSModuleCache) {
                $script:PSModuleCache | Add-Member -NotePropertyName $moduleName -NotePropertyValue (@{
                        Version = $installedModule.Version.ToString()
                        Path    = $installedModule.ModuleBase
                    }) -Force
                
                $cacheFile = Join-Path $env:TEMP 'PSModuleCache.json'
                try {
                    $script:PSModuleCache | ConvertTo-Json -Depth 4 | Set-Content $cacheFile -Force
                }
                catch {
                    Write-Verbose "Failed to write module cache: $_"
                }
            }
        }
        catch {
            Write-Warning "[ModuleInstaller] Failed to install module '$moduleName': $_"
        }
    }
}
