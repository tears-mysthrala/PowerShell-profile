<#
.SYNOPSIS
    Dependency Installer for PowerShell Profile
    Installs package managers and CLI tools required by the PowerShell profile

.DESCRIPTION
    This script provides functions to install various package managers and CLI tools
    that enhance the PowerShell profile experience. It supports multiple installation
    methods and package managers.

.PARAMETER InstallAll
    Install all recommended dependencies

.PARAMETER PackageManagers
    Install package managers (Chocolatey, Scoop, Winget)

.PARAMETER CliTools
        Install CLI tools (git, fzf, bat, eza, lazygit, zoxide, ripgrep, fd)

.PARAMETER Tool
    Install a specific tool by name

.EXAMPLE
    .\DependencyInstaller.ps1 -InstallAll

.EXAMPLE
    .\DependencyInstaller.ps1 -PackageManagers

.EXAMPLE
    .\DependencyInstaller.ps1 -CliTools

.EXAMPLE
    .\DependencyInstaller.ps1 -Tool git
#>

param(
    [switch]$InstallAll,
    [switch]$InstallPackageManagers,
    [switch]$InstallCliTools,
    [string]$Tool
)

# Requires -RunAsAdministrator for some installations
#Requires -Version 7.0

$ErrorActionPreference = 'Stop'

# Package manager definitions
$script:pkgManagers = @{
    'Chocolatey' = @{
        Name = 'Chocolatey'
        InstallScript = {
            Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
            try {
                Set-ExecutionPolicy Bypass -Scope Process -Force
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
                Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
                refreshenv
                Write-Host "Chocolatey installed successfully!" -ForegroundColor Green
            }
            catch {
                Write-Error "Failed to install Chocolatey: $_"
            }
        }
        CheckCommand = { Get-Command choco -ErrorAction SilentlyContinue }
    }
    'Scoop' = @{
        Name = 'Scoop'
        InstallScript = {
            Write-Host "Installing Scoop..." -ForegroundColor Yellow
            try {
                if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
                    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
                }
                Write-Host "Scoop installed successfully!" -ForegroundColor Green
            }
            catch {
                Write-Error "Failed to install Scoop: $_"
            }
        }
        CheckCommand = { Get-Command scoop -ErrorAction SilentlyContinue }
    }
    'Winget' = @{
        Name = 'Winget'
        InstallScript = {
            Write-Host "Checking Winget..." -ForegroundColor Yellow
            if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
                Write-Host "Winget is not available on this system. Please install it manually from the Microsoft Store or Windows Package Manager." -ForegroundColor Red
                Write-Host "Visit: https://github.com/microsoft/winget-cli" -ForegroundColor Cyan
            } else {
                Write-Host "Winget is already installed!" -ForegroundColor Green
            }
        }
        CheckCommand = { Get-Command winget -ErrorAction SilentlyContinue }
    }
}

# CLI tool definitions with installation methods
$script:cliTools = @{
    'git' = @{
        Name = 'Git'
        CheckCommand = { Get-Command git -ErrorAction SilentlyContinue }
        InstallMethods = @(
            @{
                Manager = 'winget'
                Command = { winget install --id Git.Git --source winget --accept-package-agreements --accept-source-agreements }
            }
            @{
                Manager = 'choco'
                Command = { choco install git -y }
            }
            @{
                Manager = 'scoop'
                Command = { scoop install git }
            }
        )
    }
    'fzf' = @{
        Name = 'fzf'
        CheckCommand = { Get-Command fzf -ErrorAction SilentlyContinue }
        InstallMethods = @(
            @{
                Manager = 'winget'
                Command = { winget install --id junegunn.fzf --source winget --accept-package-agreements --accept-source-agreements }
            }
            @{
                Manager = 'choco'
                Command = { choco install fzf -y }
            }
            @{
                Manager = 'scoop'
                Command = { scoop install fzf }
            }
        )
    }
    'bat' = @{
        Name = 'bat'
        CheckCommand = { Get-Command bat -ErrorAction SilentlyContinue }
        InstallMethods = @(
            @{
                Manager = 'winget'
                Command = { winget install --id sharkdp.bat --source winget --accept-package-agreements --accept-source-agreements }
            }
            @{
                Manager = 'choco'
                Command = { choco install bat -y }
            }
            @{
                Manager = 'scoop'
                Command = { scoop install bat }
            }
        )
    }
    'eza' = @{
        Name = 'eza'
        CheckCommand = { Get-Command eza -ErrorAction SilentlyContinue }
        InstallMethods = @(
            @{
                Manager = 'winget'
                Command = { winget install --id eza-community.eza --source winget --accept-package-agreements --accept-source-agreements }
            }
            @{
                Manager = 'choco'
                Command = { choco install eza -y }
            }
            @{
                Manager = 'scoop'
                Command = { scoop install eza }
            }
        )
    }
    'lazygit' = @{
        Name = 'lazygit'
        CheckCommand = { Get-Command lazygit -ErrorAction SilentlyContinue }
        InstallMethods = @(
            @{
                Manager = 'winget'
                Command = { winget install --id JesseDuffield.lazygit --source winget --accept-package-agreements --accept-source-agreements }
            }
            @{
                Manager = 'choco'
                Command = { choco install lazygit -y }
            }
            @{
                Manager = 'scoop'
                Command = { scoop install lazygit }
            }
        )
    }
    'zoxide' = @{
        Name = 'zoxide'
        CheckCommand = { Get-Command zoxide -ErrorAction SilentlyContinue }
        InstallMethods = @(
            @{
                Manager = 'winget'
                Command = { winget install --id ajeetdsouza.zoxide --source winget --accept-package-agreements --accept-source-agreements }
            }
            @{
                Manager = 'choco'
                Command = { choco install zoxide -y }
            }
            @{
                Manager = 'scoop'
                Command = { scoop install zoxide }
            }
        )
    }
    'ripgrep' = @{
        Name = 'ripgrep (rg)'
        CheckCommand = { Get-Command rg -ErrorAction SilentlyContinue }
        InstallMethods = @(
            @{
                Manager = 'winget'
                Command = { winget install --id BurntSushi.ripgrep.MSVC --source winget --accept-package-agreements --accept-source-agreements }
            }
            @{
                Manager = 'choco'
                Command = { choco install ripgrep -y }
            }
            @{
                Manager = 'scoop'
                Command = { scoop install ripgrep }
            }
        )
    }
    'fd' = @{
        Name = 'fd'
        CheckCommand = { Get-Command fd -ErrorAction SilentlyContinue }
        InstallMethods = @(
            @{
                Manager = 'winget'
                Command = { winget install --id sharkdp.fd --source winget --accept-package-agreements --accept-source-agreements }
            }
            @{
                Manager = 'choco'
                Command = { choco install fd -y }
            }
            @{
                Manager = 'scoop'
                Command = { scoop install fd }
            }
        )
    }
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-PackageManager {
    param([string]$Name)

    if ($script:pkgManagers.ContainsKey($Name)) {
        $pm = $script:pkgManagers[$Name]

        Write-Host "`n=== Installing $Name ===" -ForegroundColor Cyan

        # Check if already installed
        if (& $pm.CheckCommand) {
            Write-Host "$Name is already installed!" -ForegroundColor Green
            return $true
        }

        # Install
        try {
            & $pm.InstallScript
            return $true
        }
        catch {
            Write-Error "Failed to install $Name`: $_"
            return $false
        }
    }
    else {
        Write-Error "Unknown package manager: $Name"
        return $false
    }
}

function Install-CliTool {
    param([string]$Name)

    if ($script:cliTools.ContainsKey($Name)) {
        $tool = $script:cliTools[$Name]

        Write-Host "`n=== Installing $($tool.Name) ===" -ForegroundColor Cyan

        # Check if already installed
        if (& $tool.CheckCommand) {
            Write-Host "$($tool.Name) is already installed!" -ForegroundColor Green
            return $true
        }

        # Try each installation method
        foreach ($method in $tool.InstallMethods) {
            $manager = $method.Manager
            $command = $method.Command

            Write-Host "Trying to install via $manager..." -ForegroundColor Yellow

            # Check if package manager is available
            if (& $script:pkgManagers[$manager].CheckCommand) {
                try {
                    & $script:pkgManagers[$manager].InstallCommand
                    if (& $tool.CheckCommand) {
                        Write-Host "$($tool.Name) installed successfully via $manager!" -ForegroundColor Green
                        return $true
                    }
                }
                catch {
                    Write-Host "Failed to install via $manager`: $_" -ForegroundColor Red
                    continue
                }
            }
            else {
                Write-Host "$manager is not available, skipping..." -ForegroundColor Yellow
                continue
            }
        }

        Write-Error "Failed to install $($tool.Name) with any available package manager"
        return $false
    }
    else {
        Write-Error "Unknown tool: $Name"
        return $false
    }
}

function Install-PackageManagers {
    Write-Host "Installing Package Managers..." -ForegroundColor Magenta
    Write-Host "================================" -ForegroundColor Magenta

    foreach ($pm in $script:pkgManagers.Keys) {
        Install-PackageManager -Name $pm
    }
}

function Install-CliTools {
    Write-Host "Installing CLI Tools..." -ForegroundColor Magenta
    Write-Host "=======================" -ForegroundColor Magenta

    foreach ($tool in $script:cliTools.Keys) {
        Install-CliTool -Name $tool
    }
}

function Show-Help {
    Write-Host @"
PowerShell Profile Dependency Installer

USAGE:
    .\DependencyInstaller.ps1 [options]

OPTIONS:
    -InstallAll        Install all recommended dependencies
    -PackageManagers   Install package managers (Chocolatey, Scoop, Winget)
    -CliTools         Install CLI tools (git, fzf, bat, eza, lazygit, zoxide, ripgrep, fd)
    -Tool <name>      Install a specific tool by name

EXAMPLES:
    .\DependencyInstaller.ps1 -InstallAll
    .\DependencyInstaller.ps1 -PackageManagers
    .\DependencyInstaller.ps1 -CliTools
    .\DependencyInstaller.ps1 -Tool git

AVAILABLE TOOLS:
"@ -ForegroundColor Cyan

    Write-Host "Package Managers:" -ForegroundColor Yellow
    $script:pkgManagers.Keys | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }

    Write-Host "`nCLI Tools:" -ForegroundColor Yellow
    $script:cliTools.Keys | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
}

# Main execution logic
if ($Tool) {
    # Install specific tool
    if ($script:cliTools.ContainsKey($Tool)) {
        Install-CliTool -Name $Tool
    }
    elseif ($script:pkgManagers.ContainsKey($Tool)) {
        Install-PackageManager -Name $Tool
    }
    else {
        Write-Error "Unknown tool or package manager: $Tool"
        Show-Help
        exit 1
    }
}
elseif ($InstallAll) {
    Install-PackageManagers
    Install-CliTools
}
elseif ($InstallPackageManagers) {
    Install-PackageManagers
}
elseif ($InstallCliTools) {
    Install-CliTools
}
else {
    Show-Help
}