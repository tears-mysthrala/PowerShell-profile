# Function Reference

> **Auto-generated documentation**
> Last updated: 2026-08-27 16:34:05
> Total functions: 128

## Table of Contents

- [Applications](#applications)
- [Core](#core)
- [Profile](#profile)
- [System](#system)
- [Tools](#tools)
- [Utilities](#utilities)

## Applications

### `ConvertFrom-ScoopStatusOutput`

**Signature:**
```powershell
function ConvertFrom-ScoopStatusOutput {
[CmdletBinding()]
param(
        [Parameter(ValueFromPipeline)]
        [AllowEmptyString()]
        [object[]]$Output
    )
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `ConvertFrom-WingetUpgradeOutput`

**Signature:**
```powershell
function ConvertFrom-WingetUpgradeOutput {
[CmdletBinding()]
param([object[]]$Output)
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Get-ScoopPackageBlockers`

**Signature:**
```powershell
function Get-ScoopPackageBlockers {
param(
        [string]$Name,
        [object[]]$Process = @(Get-Process -ErrorAction SilentlyContinue)
    )
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Get-UvSelfUpdateCommandPath`

**Signature:**
```powershell
function Get-UvSelfUpdateCommandPath {
param(
        [string]$ActiveCommandPath,
        [string]$LegacyStandalonePath
    )
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Get-WingetExecutable`

**Signature:**
```powershell
function Get-WingetExecutable
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Initialize-PowerShellGallery`

**Signature:**
```powershell
function Initialize-PowerShellGallery
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Initialize-UpdateLog`

**Signature:**
```powershell
function Initialize-UpdateLog
```

**Description:**

Initialize logging

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

### `Invoke-RequiredModuleRepair`

**Signature:**
```powershell
function Invoke-RequiredModuleRepair
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Test-CommandExist`

**Signature:**
```powershell
function Test-CommandExist {
param([string]$Command)
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Test-WingetManagedCommandPath`

**Signature:**
```powershell
function Test-WingetManagedCommandPath {
param([string]$CommandPath)
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Test-WingetPackageInstalled`

**Signature:**
```powershell
function Test-WingetPackageInstalled {
param([string]$Id)
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Cargo`

**Signature:**
```powershell
function Update-Cargo {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Chezmoi`

**Signature:**
```powershell
function Update-Chezmoi {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Choco`

**Signature:**
```powershell
function Update-Choco {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Composer`

**Signature:**
```powershell
function Update-Composer {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Conda`

**Signature:**
```powershell
function Update-Conda {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

**Description:**

Additional Development Tools

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-DotnetTool`

**Signature:**
```powershell
function Update-DotnetTool {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Fzf`

**Signature:**
```powershell
function Update-Fzf {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Gcloud`

**Signature:**
```powershell
function Update-Gcloud {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Gem`

**Signature:**
```powershell
function Update-Gem {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-GoTools`

**Signature:**
```powershell
function Update-GoTools {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Homebrew`

**Signature:**
```powershell
function Update-Homebrew {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-NodeEnvironment`

**Signature:**
```powershell
function Update-NodeEnvironment {
[CmdletBinding(SupportsShouldProcess)]
param(
        [switch]$CleanCache,
        [switch]$ForceReinstall
    )
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Npm`

**Signature:**
```powershell
function Update-Npm {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Pipx`

**Signature:**
```powershell
function Update-Pipx {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-PowerShellModule`

**Signature:**
```powershell
function Update-PowerShellModule {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-PowerShellRuntime`

**Signature:**
```powershell
function Update-PowerShellRuntime {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-PythonEnvironment`

**Signature:**
```powershell
function Update-PythonEnvironment {
[CmdletBinding(SupportsShouldProcess)]
param(
        [switch]$CleanCache
    )
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Scoop`

**Signature:**
```powershell
function Update-Scoop {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Starship`

**Signature:**
```powershell
function Update-Starship {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-StoreApp`

**Signature:**
```powershell
function Update-StoreApp {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-System`

**Signature:**
```powershell
function Update-System {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

**Description:**

Main update function with visual progress

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

### `Update-Uv`

**Signature:**
```powershell
function Update-Uv {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Vcpkg`

**Signature:**
```powershell
function Update-Vcpkg {
[CmdletBinding(SupportsShouldProcess)]
param(
        [string[]]$VcpkgRoots = @('C:\vcpkg', 'D:\opt\vcpkg', 'C:\tools\vcpkg')
    )
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-VSCodeExtension`

**Signature:**
```powershell
function Update-VSCodeExtension {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-WindowsSystem`

**Signature:**
```powershell
function Update-WindowsSystem {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-Winget`

**Signature:**
```powershell
function Update-Winget {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-WSL`

**Signature:**
```powershell
function Update-WSL {
[CmdletBinding(SupportsShouldProcess)]
param()
}
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Write-UpdateErrorLog`

**Signature:**
```powershell
function Write-UpdateErrorLog {
param($ErrorMessage, $Source, $LogFile)
}
```

**Description:**

Error handling function

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

### `Write-UpdateHeader`

**Signature:**
```powershell
function Write-UpdateHeader {
param([string]$Title)
}
```

**Description:**

Helper function to write section headers

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Write-UpdateLog`

**Signature:**
```powershell
function Write-UpdateLog {
param($Message, $LogFile)
}
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
}
```

**Description:**

Helper function to write status messages

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

## Core

### `Initialize-ModuleInstallationEnvironment`

**Signature:**
```powershell
function Initialize-ModuleInstallationEnvironment
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

### `Install-RequiredModule`

**Signature:**
```powershell
function Install-RequiredModule {
[CmdletBinding()]
param(
        [ValidateNotNullOrEmpty()]
        [string[]]$Name = @($requiredModules.Keys)
    )
}
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

### `Save-ModuleCache`

**Signature:**
```powershell
function Save-ModuleCache
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

### `Test-ModuleInstalled`

**Signature:**
```powershell
function Test-ModuleInstalled {
param(
        [string]$ModuleName,
        [string]$MinVersion
    )
}
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

### `Test-ModulePathHealthy`

**Signature:**
```powershell
function Test-ModulePathHealthy {
param([string]$ModulePath)
}
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

### `Write-ModuleCacheEntry`

**Signature:**
```powershell
function Write-ModuleCacheEntry {
param(
        [string]$ModuleName,
        [object]$Module
    )
}
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

## Profile

### `Disable-FullPSReadLine`

**Signature:**
```powershell
function Disable-FullPSReadLine
```

**Description:**

Provide a function to disable PSReadLine features if needed

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Enable-TerminalIcon`

**Signature:**
```powershell
function Enable-TerminalIcon
```

**Description:**

Provide an explicit enable function for Terminal-Icons so nothing related to it is created at startup

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Initialize-CachedToolInit`

**Signature:**
```powershell
function Initialize-CachedToolInit {
param(
        [string]$ToolName,
        [scriptblock]$InitCommand,
        [string]$CacheBaseName,
        [string]$ConfigPath
    )
}
```

**Description:**

Reusable fingerprint-based cache for tool init scripts

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Install-Dependency`

**Signature:**
```powershell
function Install-Dependency {
param(
        [switch]$All,
        [switch]$PackageManagers,
        [switch]$CliTools,
        [switch]$Modules,
        [string]$Tool
    )
}
```

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Measure-Block`

**Signature:**
```powershell
function Measure-Block {
param(
        [string]$Name,
        [scriptblock]$Block
    )
}
```

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Test-CachedPath`

**Signature:**
```powershell
function Test-CachedPath {
param([string]$Path)
}
```

**Description:**

Helper function for cached Test-Path

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

## System

### `_fzf_get_path_using_fd`

**Signature:**
```powershell
function _fzf_get_path_using_fd
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `_fzf_get_path_using_rg`

**Signature:**
```powershell
function _fzf_get_path_using_rg
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `_fzf_open_path`

**Signature:**
```powershell
function _fzf_open_path {
param (
    [Parameter(Mandatory=$true)]
    [string]$input_path
  )
}
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `Clear-All`

**Signature:**
```powershell
function Clear-All {
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param()
}
```

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `Clear-Disk`

**Signature:**
```powershell
function Clear-Disk
```

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `Clear-RecycleBin`

**Signature:**
```powershell
function Clear-RecycleBin {
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param()
}
```

**Description:**

Disk cleanup utilities Source: https://www.geeksforgeeks.org/disk-cleanup-using-powershell-scripts/

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `Clear-TempData`

**Signature:**
```powershell
function Clear-TempData {
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param()
}
```

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `cma`

**Signature:**
```powershell
function cma {
param (
        [string[]] $files
    )
}
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `cmc`

**Signature:**
```powershell
function cmc {
param (
        [string] $msg
    )
}
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `cmp`

**Signature:**
```powershell
function cmp
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `cms`

**Signature:**
```powershell
function cms
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `dirs`

**Signature:**
```powershell
function dirs
```

**Description:**

Recursive file listing (equivalent of dir /s /b)

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `Env:`

**Signature:**
```powershell
function Env:
```

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `fdg`

**Signature:**
```powershell
function fdg
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `HKCU:`

**Signature:**
```powershell
function HKCU:
```

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `HKLM:`

**Signature:**
```powershell
function HKLM:
```

**Description:**

Drive shortcuts

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `n`

**Signature:**
```powershell
function n
```

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `Remove-FzfSelectedPath`

**Signature:**
```powershell
function Remove-FzfSelectedPath {
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param([Parameter(Mandatory)][string]$Path)
}
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `rgg`

**Signature:**
```powershell
function rgg
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `sha256`

**Signature:**
```powershell
function sha256
```

**Description:**

Linux-like utility functions for PowerShell

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

## Tools

### `Get-DependencyInstallerWinget`

**Signature:**
```powershell
function Get-DependencyInstallerWinget
```

**Description:**

region Installation Functions

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Initialize-NuGetProvider`

**Signature:**
```powershell
function Initialize-NuGetProvider
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-AiTools`

**Signature:**
```powershell
function Install-AiTools
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-CliTools`

**Signature:**
```powershell
function Install-CliTools
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-DevRuntimes`

**Signature:**
```powershell
function Install-DevRuntimes
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-NpmPackages`

**Signature:**
```powershell
function Install-NpmPackages
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-PackageManagers`

**Signature:**
```powershell
function Install-PackageManagers
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-PipPackages`

**Signature:**
```powershell
function Install-PipPackages
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-PowerShellModules`

**Signature:**
```powershell
function Install-PowerShellModules
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
}
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-WithChoco`

**Signature:**
```powershell
function Install-WithChoco {
param([string]$Package)
}
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
}
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-WithWinget`

**Signature:**
```powershell
function Install-WithWinget {
param([string]$PackageId)
}
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Sync-SessionPath`

**Signature:**
```powershell
function Sync-SessionPath
```

**Description:**

region Helper Functions

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Test-SudoAvailable`

**Signature:**
```powershell
function Test-SudoAvailable
```

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
}
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

## Utilities

### `..`

**Signature:**
```powershell
function ..
```

**Description:**

Navigation aliases and utilities

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `...`

**Signature:**
```powershell
function ...
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `.4`

**Signature:**
```powershell
function .4
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Clear-DnsCache`

**Signature:**
```powershell
function Clear-DnsCache
```

**Description:**

Networking Utilities

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Connect-Proxmox`

**Signature:**
```powershell
function Connect-Proxmox {
param(
    [string]$Target = $env:PROXMOX_SSH_TARGET,
    [int]$Port = $(if ($env:PROXMOX_SSH_PORT) { $env:PROXMOX_SSH_PORT } else { 22 })
  )
}
```

**Description:**

SSH helper for Proxmox. Configure PROXMOX_SSH_TARGET (for example, user@host) and optionally PROXMOX_SSH_PORT outside the repository.

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `df`

**Signature:**
```powershell
function df
```

**Description:**

System utilities

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
}
```

<sub>**Source:** `Core\Utils\FileSystemUtils.ps1`</sub>

### `Expand-MultipleArchives`

**Signature:**
```powershell
function Expand-MultipleArchives {
param([string[]]$Files)
}
```

<sub>**Source:** `Core\Utils\FileSystemUtils.ps1`</sub>

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
}
```

**Description:**

Search utilities for PowerShell profile

<sub>**Source:** `Core\Utils\SearchUtils.ps1`</sub>

### `Find-PowerShellCommand`

**Signature:**
```powershell
function Find-PowerShellCommand {
param([string]$name)
}
```

<sub>**Source:** `Core\Utils\SearchUtils.ps1`</sub>

### `Find-String`

**Signature:**
```powershell
function Find-String
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-ClipboardContent`

**Signature:**
```powershell
function Get-ClipboardContent
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-CommandPath`

**Signature:**
```powershell
function Get-CommandPath
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-Font`

**Signature:**
```powershell
function Get-Font {
param (
    $regex
  )
}
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-FormattedUptime`

**Signature:**
```powershell
function Get-FormattedUptime
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `Get-ProcessByName`

**Signature:**
```powershell
function Get-ProcessByName
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-PubIP`

**Signature:**
```powershell
function Get-PubIP
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `head`

**Signature:**
```powershell
function head {
param($Path, $n = 10)
}
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Initialize-Editor`

**Signature:**
```powershell
function Initialize-Editor
```

**Description:**

Editor detection and configuration - lazy loaded

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Invoke-GitPull`

**Signature:**
```powershell
function Invoke-GitPull
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Invoke-GitPush`

**Signature:**
```powershell
function Invoke-GitPush
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `la_with_eza`

**Signature:**
```powershell
function la_with_eza
```

**Description:**

this should be the same as ls -al no tree

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `ll`

**Signature:**
```powershell
function ll
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `ll_with_eza`

**Signature:**
```powershell
function ll_with_eza
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `ls_with_eza`

**Signature:**
```powershell
function ls_with_eza {
param([Parameter(ValueFromRemainingArguments = $true)]$params)
}
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `lt_with_eza`

**Signature:**
```powershell
function lt_with_eza
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `New-DirectoryAndEnter`

**Signature:**
```powershell
function New-DirectoryAndEnter {
[CmdletBinding(SupportsShouldProcess)]
param([string]$dir)
}
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
}
```

**Description:**

File and directory management (mkcd/New-DirectoryAndEnter defined in FileSystemUtils.ps1)

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Restart-BIOS`

**Signature:**
```powershell
function Restart-BIOS {
[CmdletBinding(SupportsShouldProcess)]
param()
}
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
}
```

<sub>**Source:** `Core\Utils\SearchUtils.ps1`</sub>

### `Set-ClipboardContent`

**Signature:**
```powershell
function Set-ClipboardContent {
[CmdletBinding(SupportsShouldProcess)]
param($content)
}
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
}
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Stop-ProcessByName`

**Signature:**
```powershell
function Stop-ProcessByName {
[CmdletBinding(SupportsShouldProcess)]
param($name)
}
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `sysinfo`

**Signature:**
```powershell
function sysinfo
```

**Description:**

Quick Access to System Information

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `tail`

**Signature:**
```powershell
function tail {
param($Path, $n = 10)
}
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Test-IsAdmin`

**Signature:**
```powershell
function Test-IsAdmin
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `uptime`

**Signature:**
```powershell
function uptime
```

**Description:**

System information and utilities (Get-PubIP, Get-FormattedUptime defined in CommonUtils.ps1)

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `v`

**Signature:**
```powershell
function v
```

**Description:**

Lazy editor alias that initializes on first use

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>
