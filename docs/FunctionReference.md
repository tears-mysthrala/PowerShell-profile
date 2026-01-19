# Function Reference

> **Auto-generated documentation**
> Last updated: 2026-01-19 19:29:33
> Total functions: 145

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

### `Select-App`

**Signature:**
```powershell
function Select-App {
    param (
      [string[]] $apps
    )
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Uninstall-ChocoApp`

**Signature:**
```powershell
function Uninstall-ChocoApp {
      $apps = Select-App $(Get-ChocoApp)
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

### `Update-Choco`

**Signature:**
```powershell
function Update-Choco {
    [CmdletBinding(SupportsShouldProcess)]
    param([switch]$Silent)
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

### `Update-Npm`

**Signature:**
```powershell
function Update-Npm {
    [CmdletBinding(SupportsShouldProcess)]
    param([switch]$Silent)
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

### `Update-PowerShellModule`

**Signature:**
```powershell
function Update-PowerShellModule {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

**Description:**

PowerShell module update function with parallel checking

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

### `Update-Scoop`

**Signature:**
```powershell
function Update-Scoop {
    [CmdletBinding(SupportsShouldProcess)]
    param()
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

### `Update-StoreApp`

**Signature:**
```powershell
function Update-StoreApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
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

Main update function with progress display

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

### `Update-WindowsUpdate`

**Signature:**
```powershell
function Update-WindowsUpdate {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$UseLog
    )
```

<sub>**Source:** `Core\Apps\WindowsUpdateHelper.ps1`</sub>

### `Update-Winget`

**Signature:**
```powershell
function Update-Winget {
    [CmdletBinding(SupportsShouldProcess)]
    param([switch]$Silent)
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

### `Write-UpdateErrorLog`

**Signature:**
```powershell
function Write-UpdateErrorLog {
    param($ErrorMessage, $Source, $LogFile)
```

**Description:**

Error handling function

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

### `Write-UpdateLog`

**Signature:**
```powershell
function Write-UpdateLog {
    param($Message, $LogFile)
```

**Description:**

Logging function

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

## Core

### `Get-CachedModuleInfo`

**Signature:**
```powershell
function Get-CachedModuleInfo {
    param([string]$Name)
```

**Description:**

Get module info from cache or scan

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Get-UnifiedModuleStatus`

**Signature:**
```powershell
function Get-UnifiedModuleStatus {
    $script:moduleRegistry.GetEnumerator() | ForEach-Object {
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Get-UnifiedToolStatus`

**Signature:**
```powershell
function Get-UnifiedToolStatus {
    $script:loadedTools.GetEnumerator() | ForEach-Object {
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Import-LazyModule`

**Signature:**
```powershell
function Import-LazyModule {
    param([string]$Name)
```

**Description:**

Lazy loading functionality from LazyModuleManager

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Import-ModuleWithDependency`

**Signature:**
```powershell
function Import-ModuleWithDependency {
    param(
        [string]$ModuleName,
        [switch]$Force
    )
```

<sub>**Source:** `Core\ModuleDependencyManager.ps1`</sub>

### `Import-ModuleWithVersion`

**Signature:**
```powershell
function Import-ModuleWithVersion {
    param(
        [string]$ModuleName,
        [int]$MaxAttempts = 3,
        [switch]$Force
    )
```

<sub>**Source:** `Core\ModuleVersionManager.ps1`</sub>

### `Import-UnifiedModule`

**Signature:**
```powershell
function Import-UnifiedModule {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Name,
        [switch]$Force
    )
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Import-UnifiedTool`

**Signature:**
```powershell
function Import-UnifiedTool {
    param([string]$Name)
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Initialize-ModuleCache`

**Signature:**
```powershell
function Initialize-ModuleCache {
    if (Test-Path $script:moduleCachePath) {
```

**Description:**

Initialize module cache from disk

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Initialize-StartupModule`

**Signature:**
```powershell
function Initialize-StartupModule {
    [CmdletBinding(SupportsShouldProcess)]
    $startupModules = $script:moduleRegistry.GetEnumerator() |
    Where-Object { $_.Value.LoadOnStartup } |
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Initialize-StartupTool`

**Signature:**
```powershell
function Initialize-StartupTool {
    # Mantener compatibilidad pero evitar trabajo innecesario: solo
    # se inicializarán herramientas marcadas explícitamente como LoadOnStartup.
    $script:toolRegistry.GetEnumerator() |
    Where-Object { $_.Value.LoadOnStartup } |
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Install-RequiredModule`

**Signature:**
```powershell
function Install-RequiredModule {
    [CmdletBinding()]
    param()
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

### `Register-ChocolateyProfile`

**Signature:**
```powershell
function Register-ChocolateyProfile {
    $chocoModule = "chocolatey-profile"
    $chocoPath = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

    if (-not $env:ChocolateyInstall) {
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Register-ModuleDependency`

**Signature:**
```powershell
function Register-ModuleDependency {
    param(
        [string]$ModuleName,
        [string]$MinVersion,
        [string[]]$Dependencies = @(),
        [scriptblock]$OnFailure
    )
```

<sub>**Source:** `Core\ModuleDependencyManager.ps1`</sub>

### `Register-ModuleVersion`

**Signature:**
```powershell
function Register-ModuleVersion {
    param(
        [string]$ModuleName,
        [string]$RequiredVersion,
        [scriptblock]$OnVersionMismatch
    )
```

<sub>**Source:** `Core\ModuleVersionManager.ps1`</sub>

### `Register-UnifiedModule`

**Signature:**
```powershell
function Register-UnifiedModule {
    [CmdletBinding()]
    param(
        [string]$Name,
        [string]$MinVersion,
        [string]$RequiredVersion,
        [string[]]$Dependencies = @(),
        [scriptblock]$InitializerBlock,
        [scriptblock]$OnFailure,
        [scriptblock]$OnVersionMismatch,
        [bool]$LoadOnStartup = $false,
        [int]$MaxAttempts = 3,
        [switch]$IgnoreIfMissing,
        [string]$ModulePath
    )
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Register-UnifiedTool`

**Signature:**
```powershell
function Register-UnifiedTool {
    param(
        [string]$Name,
        [scriptblock]$InitializerBlock,
        [bool]$LoadOnStartup = $false
    )
```

**Description:**

Tool management functionality from LazyToolManager

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Save-ModuleCache`

**Signature:**
```powershell
function Save-ModuleCache {
    try {
```

**Description:**

Save module cache to disk

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Test-ModuleInstalled`

**Signature:**
```powershell
function Test-ModuleInstalled {
    param(
        [string]$ModuleName,
        [string]$MinVersion
    )
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

### `Test-ModuleRequirement`

**Signature:**
```powershell
function Test-ModuleRequirement {
    param([string]$ModuleName)
```

<sub>**Source:** `Core\ModuleDependencyManager.ps1`</sub>

### `Test-ModuleVersion`

**Signature:**
```powershell
function Test-ModuleVersion {
    param([string]$ModuleName)
```

<sub>**Source:** `Core\ModuleVersionManager.ps1`</sub>

### `Test-UnifiedModuleRequirement`

**Signature:**
```powershell
function Test-UnifiedModuleRequirement {
    [CmdletBinding()]
    param([string]$Name)
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

## Other

### `__gh_debug`

**Signature:**
```powershell
function __gh_debug {
    if ($env:BASH_COMP_DEBUG_FILE) {
```

**Description:**

powershell completion for gh                                   -*- shell-script -*-

<sub>**Source:** `Config\gh-completion-cache.ps1`</sub>

### `Disable-FullPSReadLine`

**Signature:**
```powershell
function Disable-FullPSReadLine {
    try {
```

**Description:**

Provide a function to disable PSReadLine features if needed

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Disable-TransientPrompt`

**Signature:**
```powershell
function Disable-TransientPrompt {
        Set-PSReadLineKeyHandler -Key Enter -Function AcceptLine
        $script:TransientPrompt = $false
    }

    function global:prompt {
```

<sub>**Source:** `Config\starship-init-cache.ps1`</sub>

### `Enable-TerminalIcon`

**Signature:**
```powershell
function Enable-TerminalIcon {
            try {
```

**Description:**

Provide an explicit enable function for Terminal-Icons so nothing related to it is created at startup

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Enable-TransientPrompt`

**Signature:**
```powershell
function Enable-TransientPrompt {
        Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
```

<sub>**Source:** `Config\starship-init-cache.ps1`</sub>

### `Get-Cwd`

**Signature:**
```powershell
function Get-Cwd {
        $cwd = Get-Location
        $provider_prefix = "$($cwd.Provider.ModuleName)\$($cwd.Provider.Name)::"
        return @{
```

<sub>**Source:** `Config\starship-init-cache.ps1`</sub>

### `global`

**Signature:**
```powershell
function global:prompt {
        $origDollarQuestion = $global:?
        $origLastExitCode = $global:LASTEXITCODE

        # Invoke precmd, if specified
        try {
```

<sub>**Source:** `Config\starship-init-cache.ps1`</sub>

### `Import-PSModule`

**Signature:**
```powershell
function Import-PSModule {
            param([string]$Name)
```

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Initialize-ProfileCore`

**Signature:**
```powershell
function Initialize-ProfileCore {
            if (-not (Get-Module -Name ProfileCore -ListAvailable)) {
```

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Initialize-ProfileManagement`

**Signature:**
```powershell
function Initialize-ProfileManagement {
            if (-not (Get-Module -Name ProfileManagement -ListAvailable)) {
```

**Description:**

Defer importing heavy profile modules until first use

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Initialize-PSModule`

**Signature:**
```powershell
function Initialize-PSModule {
            Ensure-ProfileCore
            $cmd = Get-Command -Module ProfileCore -Name Initialize-PSModule -ErrorAction SilentlyContinue
            if ($cmd) { & $cmd @args } else { Write-Warning 'Initialize-PSModule not available' }
```

**Description:**

Lightweight proxies that import the module on first use and then invoke the real function

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Install-Bat`

**Signature:**
```powershell
function Install-Bat {
    Write-ColorOutput "Installing bat..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Chocolatey`

**Signature:**
```powershell
function Install-Chocolatey {
    Write-ColorOutput "Installing Chocolatey..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Dependency`

**Signature:**
```powershell
function Install-Dependency {
    <#
    .SYNOPSIS
        Install PowerShell profile dependencies
    .DESCRIPTION
        Installs package managers and CLI tools required by the PowerShell profile
    .PARAMETER All
        Install all dependencies (package managers + CLI tools)
    .PARAMETER PackageManagers
        Install only package managers (Chocolatey, Scoop)
    .PARAMETER CliTools
        Install only CLI tools (git, fzf, bat, eza, etc.)
    .PARAMETER Tool
        Install a specific tool by name
    .EXAMPLE
        Install-Dependency -All
    .EXAMPLE
        Install-Dependency -PackageManagers
    .EXAMPLE
        Install-Dependency -Tool git
    #>
    param(
        [switch]$All,
        [switch]$PackageManagers,
        [switch]$CliTools,
        [string]$Tool
    )
```

**Description:**

Initialize startup modules - deferred to first use for faster startup Modules will be loaded on-demand via lazy-loading proxies Uncomment below to force eager loading: Initialize-PSModule

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Install-Eza`

**Signature:**
```powershell
function Install-Eza {
    Write-ColorOutput "Installing eza..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Fd`

**Signature:**
```powershell
function Install-Fd {
    Write-ColorOutput "Installing fd..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Fzf`

**Signature:**
```powershell
function Install-Fzf {
    Write-ColorOutput "Installing fzf..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Git`

**Signature:**
```powershell
function Install-Git {
    Write-ColorOutput "Installing Git..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Lazygit`

**Signature:**
```powershell
function Install-Lazygit {
    Write-ColorOutput "Installing lazygit..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Ripgrep`

**Signature:**
```powershell
function Install-Ripgrep {
    Write-ColorOutput "Installing ripgrep..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Scoop`

**Signature:**
```powershell
function Install-Scoop {
    Write-ColorOutput "Installing Scoop..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Winget`

**Signature:**
```powershell
function Install-Winget {
    Write-ColorOutput "Checking Winget..." $Cyan
    if (Test-CommandExist 'winget') {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Zoxide`

**Signature:**
```powershell
function Install-Zoxide {
    Write-ColorOutput "Installing zoxide..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Invoke-Native`

**Signature:**
```powershell
function Invoke-Native {
        param($Executable, $Arguments)
```

<sub>**Source:** `Config\starship-init-cache.ps1`</sub>

### `Measure-Block`

**Signature:**
```powershell
function Measure-Block {
    param(
        [string]$Name,
        [scriptblock]$Block,
        [switch]$Async
    )
```

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Register-PSModule`

**Signature:**
```powershell
function Register-PSModule {
            param(
                [string]$Name,
                [string]$Description,
                [string]$Category,
                [scriptblock]$InitializerBlock
            )
```

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Start-BackgroundJob`

**Signature:**
```powershell
function Start-BackgroundJob {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [scriptblock]$ScriptBlock,
        [Parameter(ValueFromRemainingArguments = $true)] $ArgumentList
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

### `Write-ColorOutput`

**Signature:**
```powershell
function Write-ColorOutput {
    param([string]$Message)
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
  Delete-TempData
  Run-DiskCleanUp
}
```

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `Clear-Disk`

**Signature:**
```powershell
function Clear-Disk {
  #3# Using Disk cleanup Tool
  # Display a message indicating the usage of the Disk Cleanup tool
  Write-Verbose "Using Disk cleanup Tool" -ForegroundColor Yellow
  # Run the Disk Cleanup tool with the specified sagerun parameter
  cleanmgr /sagerun:1 | out-Null
  # Emit a beep sound using ASCII code 7
  Write-Verbose "$([char]7)"
  # Display a success message indicating that Disk Cleanup was successfully done
  Write-Verbose "Disk Cleanup Successfully done" -ForegroundColor Green
}

function Clear-All {
```

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `Clear-RecycleBin`

**Signature:**
```powershell
function Clear-RecycleBin {
  #1# Removing recycle bin files
  # Set the path to the recycle bin on the C drive
  $Path = 'C' + ':\$Recycle.Bin'
  # Get all items (files and directories) within the recycle bin path, including hidden ones
  Write-Verbose "[INFO] Cleaning recycle bin with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
  Get-ChildItem $Path -Force -Recurse -ErrorAction SilentlyContinue |
  # Remove the items, excluding any files with the .ini extension
  Remove-Item -Recurse -Exclude *.ini -ErrorAction SilentlyContinue
  # Display a success message
  Write-Verbose "All the necessary data removed from recycle bin successfully" -ForegroundColor Green
}

function Clear-TempData {
```

**Description:**

Source: https://www.geeksforgeeks.org/disk-cleanup-using-powershell-scripts/

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `Clear-TempData`

**Signature:**
```powershell
function Clear-TempData {
  #2# Remove Temp files from various locations
  Write-Verbose "Erasing temporary files from various locations" -ForegroundColor Yellow
  # Specify the path where temporary files are stored in the Windows Temp folder
  $Path1 = 'C' + ':\Windows\Temp'
  # Remove all items (files and directories) from the Windows Temp folder
  Write-Verbose "[INFO] Cleaning Windows Temp folder with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
  Get-ChildItem $Path1 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  # Specify the path where temporary files are stored in the Windows Prefetch folder
  $Path2 = 'C' + ':\Windows\Prefetch'
  # Remove all items (files and directories) from the Windows Prefetch folder
  Write-Verbose "[INFO] Cleaning Windows Prefetch folder with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
  Get-ChildItem $Path2 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  # Specify the path where temporary files are stored in the user's AppData\Local\Temp folder
  $Path3 = 'C' + ':\Users\*\AppData\Local\Temp'
  # Remove all items (files and directories) from the specified user's Temp folder
  Write-Verbose "[INFO] Cleaning user Temp folder with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
  Get-ChildItem $Path3 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  # Display a success message
  Write-Verbose "removed all the temp files successfully" -ForegroundColor Green
}

function Clear-Disk {
```

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `cma`

**Signature:**
```powershell
function cma
{
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `cmc`

**Signature:**
```powershell
function cmc
{
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `cmp`

**Signature:**
```powershell
function cmp
{
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `cms`

**Signature:**
```powershell
function cms
{
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `dirs`

**Signature:**
```powershell
function dirs
{
```

**Description:**

Does the the rough equivalent of dir /s /b. For example, dirs *.png is dir /s /b *.png

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `Env`

**Signature:**
```powershell
function Env:
{ Set-Location Env:
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
function HKCU:
{ Set-Location HKCU:
```

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `HKLM`

**Signature:**
```powershell
function HKLM:
{ Set-Location HKLM:
```

**Description:**

Drive shortcuts

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `n`

**Signature:**
```powershell
function n
{ notepad $args
```

**Description:**

Quick shortcut to start notepad

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
function sha256
{ Get-FileHash -Algorithm SHA256 $args
```

**Description:**

FROM https://github.com/ChrisTitusTech/powershell-profile/ If so and the current host is a command line, then change to red color as warning to user that they are operating in an elevated context Useful shortcuts for traversing directories Compute file hashes - useful for checking successful downloads

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

## Utilities

### `akkorokamui`

**Signature:**
```powershell
function akkorokamui { ssh -p 54226 tears@192.168.1.100 }
```

**Description:**

SSH Aliases

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
function which($name) { Get-Command $name | Select-Object -ExpandProperty Definition }
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

### `Expand-MultipleArchive`

**Signature:**
```powershell
function Expand-MultipleArchive {
  $CurrentDate = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
  $Folder = "extracted_$($CurrentDate)"
  New-Item -Path $Folder -ItemType Directory | Out-Null
  foreach ($File in $args) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Expand-ZipFile`

**Signature:**
```powershell
function Expand-ZipFile($file) {
  Write-Output("Extracting", $file, "to", $pwd)
  $fullFile = Get-ChildItem -Path $pwd -Filter .\cove.zip | ForEach-Object { $_.FullName }
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

# SSH Aliases
function akkorokamui { ssh -p 54226 tears@192.168.1.100 }
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

### `Get-FormatedUptime`

**Signature:**
```powershell
function Get-FormatedUptime {
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
    (Invoke-WebRequest http://ifconfig.me/ip).Content
}

function Initialize-EncodingConfig {
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `Get-PwshInstalled`

**Signature:**
```powershell
function Get-PwshInstalled {
    return Get-Command pwsh -ErrorAction SilentlyContinue
  }

  # Function to install PowerShell 7 using winget
  function Install-Pwsh {
```

**Description:**

Function to check if pwsh is installed

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

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

# Create module manifest if it doesn't exist
if (-not (Test-Path "$moduleRoot\CommonUtils.psd1")) {
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `Install-Pwsh`

**Signature:**
```powershell
function Install-Pwsh {
    Write-Verbose "Installing PowerShell 7..."
    winget install --id Microsoft.Powershell --source winget -y
  }

  # Check if pwsh is installed
  if (-not (Get-PwshInstalled)) {
```

**Description:**

Function to install PowerShell 7 using winget

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

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
  curl.exe -F "f:1=@$file" ix.io
}

function Test-IsAdmin {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `la_with_eza`

**Signature:**
```powershell
function la_with_eza{
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

# File and directory management
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }
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

### `mkcd`

**Signature:**
```powershell
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }
function New-File {
```

**Description:**

File and directory management

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

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `pretty_git_branch`

**Signature:**
```powershell
function pretty_git_branch
{
```

<sub>**Source:** `Core\Utils\Development\gitHelpers.ps1`</sub>

### `pretty_git_branch_sorted`

**Signature:**
```powershell
function pretty_git_branch_sorted
{
```

<sub>**Source:** `Core\Utils\Development\gitHelpers.ps1`</sub>

### `pretty_git_format`

**Signature:**
```powershell
function pretty_git_format
{
```

<sub>**Source:** `Core\Utils\Development\gitHelpers.ps1`</sub>

### `pretty_git_log`

**Signature:**
```powershell
function pretty_git_log
{
```

<sub>**Source:** `Core\Utils\Development\gitHelpers.ps1`</sub>

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

### `show_git_head`

**Signature:**
```powershell
function show_git_head
{
```

<sub>**Source:** `Core\Utils\Development\gitHelpers.ps1`</sub>

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

### `Test-CommandExist`

**Signature:**
```powershell
function Test-CommandExist {
    [CmdletBinding()]
    param([string]$command)
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `Test-IsAdmin`

**Signature:**
```powershell
function Test-IsAdmin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-FormatedUptime {
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `Upgrade`

**Signature:**
```powershell
function Upgrade {
  # Function to check if pwsh is installed
  function Get-PwshInstalled {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `uptime`

**Signature:**
```powershell
function uptime {
  If ($PSVersionTable.PSVersion.Major -eq 5) {
```

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

### `which`

**Signature:**
```powershell
function which($name) { Get-Command $name | Select-Object -ExpandProperty Definition }

function Set-EnvironmentVariable {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

