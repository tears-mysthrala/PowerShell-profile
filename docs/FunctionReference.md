# Function Reference

> **Auto-generated documentation**
> Last updated: 2026-03-15 06:30:27
> Total functions: 144

## Table of Contents

- [Applications](#applications)
- [Core](#core)
- [Other](#other)
- [System](#system)
- [Utilities](#utilities)

## Applications

### `Get-ChocoApp`

**Signature:**
```powershell
function Get-ChocoApp {
    $apps = $(choco list --id-only --no-color).Split("\n")
    $apps = $apps[1..($apps.Length - 2)]
    return $apps
}

function Get-ScoopApp {
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Get-ScoopApp`

**Signature:**
```powershell
function Get-ScoopApp {
    $apps = $(scoop list | Select-Object -ExpandProperty "Name").Split("\n")
    $apps = $apps[1..($apps.Length - 1)]
    return $apps
}

function Select-App {
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Initialize-PowerShellGallery`

**Signature:**
```powershell
Write-UpdateLog "${Status}: $Message" $script:CurrentUpdateLogFile
    }
}

function Initialize-PowerShellGallery {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Initialize-UpdateLog`

**Signature:**
```powershell
function Initialize-UpdateLog {
    $logFile = Join-Path $env:TEMP "SystemUpdate_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    return $logFile
}

# Logging function
function Write-UpdateLog {
```

**Description:**

Initialize logging

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

### `Install-AllMissingTools`

**Signature:**
```powershell
function Install-AllMissingTools {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

<sub>**Source:** `Core\Apps\InstallMissingTools.ps1`</sub>

### `Install-Chezmoi`

**Signature:**
```powershell
function Install-Chezmoi {
    Write-InstallHeader "Installing Chezmoi (Dotfiles Manager)"

    if (Test-CommandExist 'chezmoi') {
```

<sub>**Source:** `Core\Apps\InstallMissingTools.ps1`</sub>

### `Install-Composer`

**Signature:**
```powershell
function Install-Composer {
    Write-InstallHeader "Installing PHP and Composer"

    if (Test-CommandExist 'composer') {
```

<sub>**Source:** `Core\Apps\InstallMissingTools.ps1`</sub>

### `Install-Conda`

**Signature:**
```powershell
function Install-Conda {
    Write-InstallHeader "Installing Conda (Miniforge/Mamba)"

    if (Test-CommandExist 'conda') {
```

<sub>**Source:** `Core\Apps\InstallMissingTools.ps1`</sub>

### `Install-Homebrew-WSL`

**Signature:**
```powershell
function Install-Homebrew-WSL {
    Write-InstallHeader "Installing Homebrew in WSL"

    if (-not (Test-CommandExist 'wsl')) {
```

<sub>**Source:** `Core\Apps\InstallMissingTools.ps1`</sub>

### `Install-Ruby`

**Signature:**
```powershell
function Install-Ruby {
    Write-InstallHeader "Installing Ruby with DevKit"

    if (Test-CommandExist 'ruby') {
```

<sub>**Source:** `Core\Apps\InstallMissingTools.ps1`</sub>

### `Invoke-RequiredModuleRepair`

**Signature:**
```powershell
Write-UpdateStatus "Failed to trust PSGallery: $_" -Status Warning
    }
}

function Invoke-RequiredModuleRepair {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Select-App`

**Signature:**
```powershell
function Select-App {
    param (
        [string[]] $apps
    )
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Test-CommandExist`

**Signature:**
```powershell
function Test-CommandExist {
        param([string]$Command)
```

<sub>**Source:** `Core\Apps\InstallMissingTools.ps1`</sub>

### `Uninstall-ChocoApp`

**Signature:**
```powershell
function Uninstall-ChocoApp {
    $apps = Select-App $(Get-ChocoApp)
    if ($apps.Length -eq 0) {
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Uninstall-ScoopApp`

**Signature:**
```powershell
function Uninstall-ScoopApp {
    $apps = Select-App $(Get-ScoopApp)
    if ($apps.Length -eq 0) {
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Update-AllApp`

**Signature:**
```powershell
function Update-AllApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Update-Cargo`

**Signature:**
```powershell
Write-UpdateStatus "Pipx not installed, skipping..." -Status Warning
        }
    }
}

function Update-Cargo {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Chezmoi`

**Signature:**
```powershell
Write-UpdateStatus "Homebrew not installed in WSL, skipping..." -Status Warning
        }
    }
}

function Update-Chezmoi {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Choco`

**Signature:**
```powershell
Write-UpdateStatus "Scoop not installed, skipping..." -Status Warning
        }
    }
}

function Update-Choco {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-ChocoApp`

**Signature:**
```powershell
function Update-ChocoApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Update-Composer`

**Signature:**
```powershell
} else {
            Write-UpdateStatus "Go not installed, skipping..." -Status Warning
        }
    }
}

function Update-Composer {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Conda`

**Signature:**
```powershell
finally {
            Set-Location $originalLocation
        }
    }
}

# Additional Development Tools

function Update-Conda {
```

**Description:**

Additional Development Tools

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-DotnetTool`

**Signature:**
```powershell
Write-UpdateStatus "Conda/Mamba not installed, skipping..." -Status Warning
        }
    }
}

function Update-DotnetTool {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Fzf`

**Signature:**
```powershell
Write-UpdateStatus "Starship not installed, skipping..." -Status Warning
        }
    }
}

function Update-Fzf {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Gem`

**Signature:**
```powershell
Write-UpdateStatus ".NET SDK not installed, skipping..." -Status Warning
        }
    }
}

function Update-Gem {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-GitSubmodule`

**Signature:**
```powershell
} else {
            Write-UpdateStatus "fzf not installed, skipping..." -Status Warning
        }
    }
}

function Update-GitSubmodule {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-GoTools`

**Signature:**
```powershell
Write-UpdateStatus "Ruby/Gem not installed, skipping..." -Status Warning
        }
    }
}

function Update-GoTools {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Homebrew`

**Signature:**
```powershell
Write-UpdateStatus "Composer not installed, skipping..." -Status Warning
        }
    }
}

function Update-Homebrew {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-NodeEnvironment`

**Signature:**
```powershell
} else {
            Write-UpdateStatus "Python not installed, skipping..." -Status Warning
        }
    }
}

function Update-NodeEnvironment {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Npm`

**Signature:**
```powershell
Write-UpdateStatus "Chocolatey not installed, skipping..." -Status Warning
        }
    }
}

function Update-Npm {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-NpmApp`

**Signature:**
```powershell
function Update-NpmApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Update-PipApp`

**Signature:**
```powershell
function Update-PipApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Update-Pipx`

**Signature:**
```powershell
Write-UpdateStatus "NPM not installed, skipping..." -Status Warning
        }
    }
}

function Update-Pipx {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-PowershellModule`

**Signature:**
```powershell
function Update-PowershellModule {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Update-PythonEnvironment`

**Signature:**
```powershell
} else {
            Write-UpdateStatus "WSL not installed, skipping..." -Status Warning
        }
    }
}

function Update-PythonEnvironment {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Scoop`

**Signature:**
```powershell
Write-UpdateStatus "Winget not installed, skipping..." -Status Warning
        }
    }
}

function Update-Scoop {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-ScoopApp`

**Signature:**
```powershell
function Update-ScoopApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Update-Starship`

**Signature:**
```powershell
Write-UpdateStatus "Chezmoi not installed, skipping..." -Status Warning
        }
    }
}

function Update-Starship {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-StoreApp`

**Signature:**
```powershell
Write-UpdateStatus "Windows Update via usoclient failed: $_" -Status Error
            }
        }
    }
}

function Update-StoreApp {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-System`

**Signature:**
```powershell
function Update-System {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

**Description:**

Main update function with visual progress

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

### `Update-Uv`

**Signature:**
```powershell
Write-UpdateStatus "Cargo not installed, skipping..." -Status Warning
        }
    }
}

function Update-Uv {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Vcpkg`

**Signature:**
```powershell
Write-UpdateStatus "Winget not available, skipping Store check..." -Status Warning
        }
    }
}

function Update-Vcpkg {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-VSCodeExtension`

**Signature:**
```powershell
} else {
            Write-UpdateStatus "Git not installed, skipping..." -Status Warning
        }
    }
}

function Update-VSCodeExtension {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-WindowsSystem`

**Signature:**
```powershell
Write-UpdateStatus "Failed to update $($mod.Name): $_" -Status Error
                }
            }
        }
    }
}

function Update-WindowsSystem {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-WindowsUpdate`

**Signature:**
```powershell
function Update-WindowsUpdate {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

<sub>**Source:** `Core\Apps\WindowsUpdateHelper.ps1`</sub>

### `Update-Winget`

**Signature:**
```powershell
Write-UpdateStatus "Required module repair failed: $_" -Status Warning
    }
}

function Update-Winget {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-WSL`

**Signature:**
```powershell
} else {
            Write-UpdateStatus "VS Code not found, skipping..." -Status Warning
        }
    }
}

function Update-WSL {
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Write-AppLog`

**Signature:**
```powershell
function Write-AppLog {
    param($Message)
```

<sub>**Source:** `Core\Apps\UpdateApps.ps1`</sub>

### `Write-ErrorLog`

**Signature:**
```powershell
function Write-ErrorLog {
    param($ErrorMessage)
```

**Description:**

Function to handle errors

<sub>**Source:** `Core\Apps\UpdateApps.ps1`</sub>

### `Write-InstallHeader`

**Signature:**
```powershell
function Write-InstallHeader {
    param([string]$Title)
```

<sub>**Source:** `Core\Apps\InstallMissingTools.ps1`</sub>

### `Write-InstallStatus`

**Signature:**
```powershell
function Write-InstallStatus {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Status = 'Info'
    )
```

<sub>**Source:** `Core\Apps\InstallMissingTools.ps1`</sub>

### `Write-UpdateErrorLog`

**Signature:**
```powershell
function Write-UpdateErrorLog {
    param($ErrorMessage, $Source, $LogFile)
```

**Description:**

Error handling function

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

### `Write-UpdateHeader`

**Signature:**
```powershell
function Write-UpdateHeader {
    param([string]$Title)
```

**Description:**

Helper function to write section headers

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Write-UpdateLog`

**Signature:**
```powershell
function Write-UpdateLog {
    param($Message, $LogFile)
```

**Description:**

Logging function

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

### `Write-UpdateStatus`

**Signature:**
```powershell
function Write-UpdateStatus {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Status = 'Info'
    )
```

**Description:**

Helper function to write status messages

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

## Core

### `Initialize-ModuleInstallationEnvironment`

**Signature:**
```powershell
Write-Verbose "Failed to write module cache: $_"
    }
}

function Initialize-ModuleInstallationEnvironment {
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

### `Install-RequiredModule`

**Signature:**
```powershell
if ($MinVersion -and ($module.Version -lt [version]$MinVersion)) {
            return $false
        }
        return $true
    }

    return $false
}

function Install-RequiredModule {
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

### `Save-ModuleCache`

**Signature:**
```powershell
}

function Save-ModuleCache {
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

### `Test-ModuleInstalled`

**Signature:**
```powershell
Path    = $Module.Path
    }) -Force
    Save-ModuleCache
}

function Test-ModuleInstalled {
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

### `Test-ModulePathHealthy`

**Signature:**
```powershell
Write-Warning "[ModuleInstaller] Failed to trust PSGallery: $_"
    }
}

function Test-ModulePathHealthy {
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

### `Update-ModuleCacheEntry`

**Signature:**
```powershell
Where-Object { $_.Extension -in '.psd1', '.psm1', '.dll' }

    return [bool]$moduleFiles
}

function Update-ModuleCacheEntry {
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

## Other

### `Disable-FullPSReadLine`

**Signature:**
```powershell
# Provide a function to disable PSReadLine features if needed
function Disable-FullPSReadLine {
```

**Description:**

Provide a function to disable PSReadLine features if needed

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Enable-TerminalIcon`

**Signature:**
```powershell
# Provide an explicit enable function for Terminal-Icons so nothing related to it is created at startup
        function Enable-TerminalIcon {
```

**Description:**

Provide an explicit enable function for Terminal-Icons so nothing related to it is created at startup

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Initialize-CachedToolInit`

**Signature:**
```powershell
# Reusable fingerprint-based cache for tool init scripts
function Initialize-CachedToolInit {
```

**Description:**

Reusable fingerprint-based cache for tool init scripts

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Initialize-NuGetProvider`

**Signature:**
```powershell
function Initialize-NuGetProvider {
    # Ensure NuGet provider is installed so Install-Module doesn't hang prompting the user
    $nuget = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
    if (-not $nuget -or $nuget.Version -lt [version]'2.8.5.201') {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-AiTools`

**Signature:**
```powershell
function Install-AiTools {
    Write-Host "`n===== AI CLI Tools =====" -ForegroundColor Cyan

    # Ensure prerequisites are available before installing AI tools
    Update-SessionPath

    # uv - needed for Kimi CLI; manages its own Python downloads
    if (-not (Test-CommandExist 'uv')) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-CliTools`

**Signature:**
```powershell
function Install-CliTools {
    Write-Host "`n===== CLI Tools (main) =====" -ForegroundColor Cyan

    foreach ($tool in $ScoopMainTools) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Dependency`

**Signature:**
```powershell
Initialize-CachedToolInit -ToolName 'gh' -InitCommand { gh completion -s powershell } -CacheBaseName 'gh-completion-cache'
}

function Install-Dependency {
```

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Install-DevRuntimes`

**Signature:**
```powershell
function Install-DevRuntimes {
    Write-Host "`n===== Development Runtimes =====" -ForegroundColor Cyan

    # Node.js
    Install-Tool -Name 'Node.js' -Command 'node' -ScoopPackage 'nodejs-lts' -WingetId 'OpenJS.NodeJS.LTS' -ChocoPackage 'nodejs-lts'
    Update-SessionPath

    # Python (scoop preferred - handles multiple versions, creates proper shims for python + pip)
    if (-not (Test-CommandExist 'python')) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-NpmPackages`

**Signature:**
```powershell
function Install-NpmPackages {
    Write-Host "`n===== npm Global Packages =====" -ForegroundColor Cyan

    if (-not (Test-CommandExist 'npm')) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-PackageManagers`

**Signature:**
```powershell
function Install-PackageManagers {
    Write-Host "`n===== Package Managers =====" -ForegroundColor Cyan

    # Scoop (no admin required)
    Write-Status "Scoop" -Type Header
    if (Test-CommandExist 'scoop') {
```

**Description:**

region Installation Functions

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-PipPackages`

**Signature:**
```powershell
function Install-PipPackages {
    Write-Host "`n===== pip Packages =====" -ForegroundColor Cyan

    if (-not (Test-CommandExist 'pip')) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-PowerShellModules`

**Signature:**
```powershell
function Install-PowerShellModules {
    Write-Host "`n===== PowerShell Modules =====" -ForegroundColor Cyan

    # Ensure NuGet provider and PSGallery trust so Install-Module doesn't hang
    Initialize-NuGetProvider

    foreach ($mod in $RequiredModules) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Tool`

**Signature:**
```powershell
function Install-Tool {
    param(
        [string]$Name,
        [string]$Command,
        [string]$ScoopPackage,
        [string]$ScoopBucket = 'main',
        [string]$WingetId,
        [string]$ChocoPackage
    )
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-WithChoco`

**Signature:**
```powershell
function Install-WithChoco {
    param([string]$Package)
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-WithScoop`

**Signature:**
```powershell
function Install-WithScoop {
    param(
        [string]$Package,
        [string]$Bucket = 'main'
    )
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-WithWinget`

**Signature:**
```powershell
function Install-WithWinget {
    param([string]$PackageId)
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Measure-Block`

**Signature:**
```powershell
function Measure-Block {
    param(
        [string]$Name,
        [scriptblock]$Block
    )
```

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Test-CachedPath`

**Signature:**
```powershell
function Test-CachedPath {
    param([string]$Path)
```

**Description:**

Helper function for cached Test-Path

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Test-SudoAvailable`

**Signature:**
```powershell
function Test-SudoAvailable {
    return (Test-CommandExist 'sudo')
}

if (-not (Get-Command Test-CommandExist -ErrorAction SilentlyContinue)) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Update-SessionPath`

**Signature:**
```powershell
function Update-SessionPath {
    # Refresh PATH from registry so newly installed tools are found in the current session
    $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$userPath;$machinePath"
}

function Test-IsAdmin {
```

**Description:**

region Helper Functions

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Write-Status`

**Signature:**
```powershell
function Write-Status {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Header')]
        [string]$Type = 'Info'
    )
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

## System

### `_fzf_get_path_using_fd`

**Signature:**
```powershell
function _fzf_get_path_using_fd
{
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `_fzf_get_path_using_rg`

**Signature:**
```powershell
function _fzf_get_path_using_rg
{
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `_fzf_open_path`

**Signature:**
```powershell
function _fzf_open_path
{
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `Clear-All`

**Signature:**
```powershell
function Clear-All {
    Clear-RecycleBin
    Clear-TempData
    Clear-Disk
}
```

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `Clear-Disk`

**Signature:**
```powershell
function Clear-Disk {
    Write-Host "Running Disk Cleanup tool..." -ForegroundColor Yellow
    cleanmgr /sagerun:1 | Out-Null
    Write-Host "$([char]7)"
    Write-Host "Disk Cleanup completed" -ForegroundColor Green
}

function Clear-All {
```

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `Clear-RecycleBin`

**Signature:**
```powershell
function Clear-RecycleBin {
    $Path = "$env:SystemDrive\`$Recycle.Bin"
    Write-Host "[INFO] Cleaning recycle bin..." -ForegroundColor Yellow
    Get-ChildItem $Path -Force -Recurse -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Exclude *.ini -ErrorAction SilentlyContinue
    Write-Host "Recycle bin cleaned successfully" -ForegroundColor Green
}

function Clear-TempData {
```

**Description:**

Disk cleanup utilities Source: https://www.geeksforgeeks.org/disk-cleanup-using-powershell-scripts/

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `Clear-TempData`

**Signature:**
```powershell
function Clear-TempData {
    Write-Host "Erasing temporary files..." -ForegroundColor Yellow

    $tempPaths = @(
        "$env:WinDir\Temp",
        "$env:WinDir\Prefetch",
        "$env:SystemDrive\Users\*\AppData\Local\Temp"
    )

    foreach ($path in $tempPaths) {
```

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `cma`

**Signature:**
```powershell
function cma {
    param (
        [string[]] $files
    )
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `cmc`

**Signature:**
```powershell
function cmc {
    param (
        [string] $msg
    )
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `cmp`

**Signature:**
```powershell
function cmp {
    chezmoi git push
}

function cms {
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `cms`

**Signature:**
```powershell
function cms {
    $current_dir = Get-Location
    try {
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `dirs`

**Signature:**
```powershell
function dirs {
    if ($args.Count -gt 0) {
```

**Description:**

Recursive file listing (equivalent of dir /s /b)

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `Env`

**Signature:**
```powershell
function Env: { Set-Location Env: }

# Recursive file listing (equivalent of dir /s /b)
function dirs {
```

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `fdg`

**Signature:**
```powershell
function fdg
{
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `HKCU`

**Signature:**
```powershell
function HKCU: { Set-Location HKCU: }
function Env: { Set-Location Env: }
```

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `HKLM`

**Signature:**
```powershell
function HKLM: { Set-Location HKLM: }
function HKCU: { Set-Location HKCU: }
```

**Description:**

Drive shortcuts

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `n`

**Signature:**
```powershell
function n {
    notepad $args
}

# Drive shortcuts
function HKLM: { Set-Location HKLM: }
```

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `rgg`

**Signature:**
```powershell
function rgg
{
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `sha256`

**Signature:**
```powershell
function sha256 {
    Get-FileHash -Algorithm SHA256 $args
}

function n {
```

**Description:**

Linux-like utility functions for PowerShell

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

## Utilities

### `akkorokamui`

**Signature:**
```powershell
function akkorokamui { ssh -p 54226 tears@192.168.1.100 }
Set-Alias -Name proxmox -Value akkorokamui

# Navigation aliases and utilities
function .. { Set-Location .\.. }
```

**Description:**

SSH alias for Proxmox

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Clear-DnsCache`

**Signature:**
```powershell
function Clear-DnsCache { Clear-DnsClientCache }
Set-Alias -Name flushdns -Value Clear-DnsCache

# Clipboard Utilities
function Set-ClipboardContent {
```

**Description:**

Networking Utilities

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `df`

**Signature:**
```powershell
function df { get-volume }

function Set-EnvironmentVariable {
```

**Description:**

System utilities

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Edit-FileContent`

**Signature:**
```powershell
function Edit-FileContent($file, $find, $replace) {
  (Get-Content $file).replace("$find", $replace) | Set-Content $file
}
Set-Alias -Name sed -Value Edit-FileContent

function Get-CommandPath($command) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Expand-CustomArchive`

**Signature:**
```powershell
function Expand-CustomArchive {
    param (
        [Parameter(Mandatory=$true)]
        [string]$File,
        [string]$Folder
    )
```

<sub>**Source:** `Core\Utils\FileSystemUtils.ps1`</sub>

### `Expand-MultipleArchives`

**Signature:**
```powershell
function Expand-MultipleArchives {
    param([string[]]$Files)
```

<sub>**Source:** `Core\Utils\FileSystemUtils.ps1`</sub>

### `Expand-ZipFile`

**Signature:**
```powershell
function Expand-ZipFile($file) {
  Write-Output("Extracting", $file, "to", $pwd)
  $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Find-File`

**Signature:**
```powershell
function Find-File {
    param(
        [Parameter(Position=0)]
        [string]$pattern = "*",
        [string]$path = ".",
        [switch]$recurse,
        [int]$depth = 3
    )
```

**Description:**

Search utilities for PowerShell profile

<sub>**Source:** `Core\Utils\SearchUtils.ps1`</sub>

### `Find-PowerShellCommand`

**Signature:**
```powershell
function Find-PowerShellCommand {
    param([string]$name)
```

<sub>**Source:** `Core\Utils\SearchUtils.ps1`</sub>

### `Find-String`

**Signature:**
```powershell
function Find-String($regex, $dir) {
  if ($dir) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-ClipboardContent`

**Signature:**
```powershell
function Get-ClipboardContent { Get-Clipboard }
Set-Alias -Name pst -Value Get-ClipboardContent

# System utilities
function df { get-volume }
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-CommandPath`

**Signature:**
```powershell
function Get-CommandPath($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
Set-Alias -Name which -Value Get-CommandPath
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-Font`

**Signature:**
```powershell
function Get-Font {
  param (
    $regex
  )
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-FormattedUptime`

**Signature:**
```powershell
function Get-FormattedUptime {
    $bootuptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    $CurrentDate = Get-Date
    $uptime = $CurrentDate - $bootuptime
    Write-Output "Uptime: $($uptime.Days) Days, $($uptime.Hours) Hours, $($uptime.Minutes) Minutes"
}

function Get-PubIP {
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `Get-GitStatus`

**Signature:**
```powershell
function Get-GitStatus { git status }
function Invoke-GitPull { git pull }
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-ProcessByName`

**Signature:**
```powershell
function Get-ProcessByName($name) { Get-Process $name }
Set-Alias -Name pgrep -Value Get-ProcessByName

# Search and find utilities
function find-file($name) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-PubIP`

**Signature:**
```powershell
function Get-PubIP {
    try {
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `hb`

**Signature:**
```powershell
function hb {
  if ($args.Length -eq 0) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `head`

**Signature:**
```powershell
function head {
  param($Path, $n = 10)
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Initialize-Editor`

**Signature:**
```powershell
function Initialize-Editor {
  if ($script:EditorInitialized) { return }
```

**Description:**

Editor detection and configuration - lazy loaded

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Initialize-EncodingConfig`

**Signature:**
```powershell
function Initialize-EncodingConfig {
    $env:PYTHONIOENCODING = 'utf-8'
    [System.Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
    [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
}
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `Invoke-GitPull`

**Signature:**
```powershell
function Invoke-GitPull { git pull }
function Invoke-GitPush { git push }
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Invoke-GitPush`

**Signature:**
```powershell
function Invoke-GitPush { git push }
Set-Alias -Name gst -Value Get-GitStatus
Set-Alias -Name pull -Value Invoke-GitPull
Set-Alias -Name push -Value Invoke-GitPush

# Docker aliases
Set-Alias -Name d -Value docker
Set-Alias -Name dc -Value docker-compose

# Conditional aliases
$script:hasLazygit = Test-CommandExist 'lazygit'
if ($script:hasLazygit) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `ix`

**Signature:**
```powershell
function ix ($file) {
  curl.exe -m 30 -F "f:1=@$file" ix.io
}

# Test-IsAdmin defined in CommonUtils.ps1

function Restart-BIOS {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `la_with_eza`

**Signature:**
```powershell
function la_with_eza {
    $ezaOutput = eza --icons --git --color=always --group-directories-first --all
    if ($script:hasBat) {
```

**Description:**

this should be the same as ls -al no tree

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `ll`

**Signature:**
```powershell
function ll {
    Get-ChildItem | Format-Table -AutoSize -Property Mode, LastWriteTime, Length, Name
  }
  # Remove the alias if it exists to avoid circular reference
  Remove-Alias -Name ll -ErrorAction SilentlyContinue
}

# File and directory management (mkcd/New-DirectoryAndEnter defined in FileSystemUtils.ps1)
function New-File {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `ll_with_eza`

**Signature:**
```powershell
function ll_with_eza {
    $ezaOutput = eza --icons --git --color=always --group-directories-first --long --header
    if ($script:hasBat) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `ls_with_eza`

**Signature:**
```powershell
function ls_with_eza {
    param([Parameter(ValueFromRemainingArguments = $true)]$params)
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `lt_with_eza`

**Signature:**
```powershell
function lt_with_eza {
    eza --icons --git --color=always --group-directories-first --long --header --tree --sort=name
  }
  Set-Alias -Name ls -Value ls_with_eza -Force -Option AllScope -Scope Global
  Set-Alias -Name ll -Value ll_with_eza -Force -Option AllScope -Scope Global
  Set-Alias -Name la -Value la_with_eza -Force -Option AllScope -Scope Global
  Set-Alias -Name lt -Value lt_with_eza -Force -Option AllScope -Scope Global
}
else {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `New-DirectoryAndEnter`

**Signature:**
```powershell
function New-DirectoryAndEnter {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$dir)
```

**Description:**

File system utilities for PowerShell profile

<sub>**Source:** `Core\Utils\FileSystemUtils.ps1`</sub>

### `New-File`

**Signature:**
```powershell
function New-File {
    [CmdletBinding(SupportsShouldProcess)]
    param($file)
```

**Description:**

File and directory management (mkcd/New-DirectoryAndEnter defined in FileSystemUtils.ps1)

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Reset-ProfileState`

**Signature:**
```powershell
function Reset-ProfileState {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$Quiet
    )
```

<sub>**Source:** `Core\Utils\profile_management.ps1`</sub>

### `Restart-BIOS`

**Signature:**
```powershell
function Restart-BIOS {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

**Description:**

Test-IsAdmin defined in CommonUtils.ps1

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Search-FileContent`

**Signature:**
```powershell
function Search-FileContent {
    param(
        [Parameter(Mandatory=$true)]
        [string]$pattern,
        [string]$path = ".",
        [string]$filter = "*.*",
        [switch]$caseSensitive
    )
```

<sub>**Source:** `Core\Utils\SearchUtils.ps1`</sub>

### `Set-ClipboardContent`

**Signature:**
```powershell
function Set-ClipboardContent {
    [CmdletBinding(SupportsShouldProcess)]
    param($content)
```

**Description:**

Clipboard Utilities

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Set-EnvironmentVariable`

**Signature:**
```powershell
function Set-EnvironmentVariable {
    [CmdletBinding(SupportsShouldProcess)]
    param($name, $value)
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Stop-ProcessByName`

**Signature:**
```powershell
function Stop-ProcessByName {
    [CmdletBinding(SupportsShouldProcess)]
    param($name)
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `sysinfo`

**Signature:**
```powershell
function sysinfo { Get-ComputerInfo }

# Networking Utilities
function Clear-DnsCache { Clear-DnsClientCache }
```

**Description:**

Quick Access to System Information

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `tail`

**Signature:**
```powershell
function tail {
  param($Path, $n = 10)
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Test-IsAdmin`

**Signature:**
```powershell
function Test-IsAdmin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-FormattedUptime {
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `Upgrade`

**Signature:**
```powershell
function Upgrade {
  if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `uptime`

**Signature:**
```powershell
function uptime {
  If ($PSVersionTable.PSVersion.Major -eq 5) {
```

**Description:**

System information and utilities (Get-PubIP, Get-FormattedUptime defined in CommonUtils.ps1)

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `v`

**Signature:**
```powershell
function v {
  if (-not $script:EditorInitialized) { Initialize-Editor }
```

**Description:**

Lazy editor alias that initializes on first use

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

