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
            # Fall through to probing
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
            # ignore write errors on cache
        }

        if ($MinVersion -and ($module.Version -lt [version]$MinVersion)) {
            return $false
        }
        return $true
    }

    return $false
}

function Install-RequiredModules {
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

    Write-Host "[INFO] Missing modules detected: $($missing.Name -join ', '). Installing in background job 'BackgroundModuleInstaller'." -ForegroundColor Yellow

    # Run installation in a background job to avoid blocking the profile
    $missingList = $missing | ForEach-Object { $_.Name }
    $req = $requiredModules
    $scriptBlock = {
        param($mods, $required)
        foreach ($m in $mods) {
            $info = $required[$m]
            try {
                Write-Output "[BackgroundModuleInstaller] Installing module '$m' (MinVersion: $($info.MinVersion))"
                Install-Module -Name $m -MinimumVersion $info.MinVersion -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop -Confirm:$false -WarningAction SilentlyContinue | Out-Null
            }
            catch {
                Write-Output "[BackgroundModuleInstaller] Failed to install module '$m': $_"
            }
        }
    }

    if (Get-Command -Name Start-ThreadJob -ErrorAction SilentlyContinue) {
        Start-ThreadJob -Name 'BackgroundModuleInstaller' -ScriptBlock $scriptBlock -ArgumentList (,$missingList,,$req) | Out-Null
    } else {
        Start-Job -Name 'BackgroundModuleInstaller' -ScriptBlock $scriptBlock -ArgumentList (,$missingList,,$req) | Out-Null
    }
}
