# Dependency Installer for PowerShell Profile
# This script installs all external tools, modules, and packages required by the profile

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$All,
    [switch]$PackageManagers,
    [switch]$CliTools,
    [switch]$Modules,
    [switch]$NpmPackages,
    [switch]$PipPackages,
    [switch]$DevTools
)

$ErrorActionPreference = 'Continue'

#region Helper Functions

function Update-SessionPath {
    # Refresh PATH from registry so newly installed tools are found in the current session
    $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$userPath;$machinePath"
}

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-CommandExist {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

function Write-Status {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Header')]
        [string]$Type = 'Info'
    )
    switch ($Type) {
        'Header'  { Write-Host "`n  $Message" -ForegroundColor Cyan }
        'Success' { Write-Host "    [OK] $Message" -ForegroundColor Green }
        'Warning' { Write-Host "    [!!] $Message" -ForegroundColor Yellow }
        'Error'   { Write-Host "    [XX] $Message" -ForegroundColor Red }
        'Info'    { Write-Host "    [..] $Message" -ForegroundColor White }
    }
}

function Initialize-NuGetProvider {
    # Ensure NuGet provider is installed so Install-Module doesn't hang prompting the user
    $nuget = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
    if (-not $nuget -or $nuget.Version -lt [version]'2.8.5.201') {
        Write-Status "Installing NuGet provider..." -Type Info
        try {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force -ErrorAction Stop | Out-Null
            Write-Status "NuGet provider installed" -Type Success
        } catch {
            Write-Status "Failed to install NuGet provider: $_" -Type Error
        }
    }

    # Trust PSGallery so Install-Module doesn't prompt
    $repo = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
    if ($repo -and $repo.InstallationPolicy -ne 'Trusted') {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
    }
}

function Install-WithScoop {
    param(
        [string]$Package,
        [string]$Bucket = 'main'
    )
    if (-not (Test-CommandExist 'scoop')) { return $false }
    try {
        scoop install "$Bucket/$Package" 2>&1 | Out-Null
        return ($LASTEXITCODE -eq 0)
    } catch { return $false }
}

function Install-WithWinget {
    param([string]$PackageId)
    if (-not (Test-CommandExist 'winget')) { return $false }
    try {
        winget install --id $PackageId -e --source winget --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
        return ($LASTEXITCODE -eq 0)
    } catch { return $false }
}

function Install-WithChoco {
    param([string]$Package)
    if (-not (Test-CommandExist 'choco')) { return $false }
    try {
        choco install $Package -y 2>&1 | Out-Null
        return ($LASTEXITCODE -eq 0)
    } catch { return $false }
}

function Install-Tool {
    param(
        [string]$Name,
        [string]$Command,
        [string]$ScoopPackage,
        [string]$ScoopBucket = 'main',
        [string]$WingetId,
        [string]$ChocoPackage
    )

    if (Test-CommandExist $Command) {
        Write-Status "$Name already installed" -Type Success
        return
    }

    if ($WhatIfPreference) {
        Write-Status "Would install $Name" -Type Warning
        return
    }

    Write-Status "Installing $Name..." -Type Info

    $installed = $false

    # Try scoop first (preferred for CLI tools)
    if ($ScoopPackage -and -not $installed) {
        $installed = Install-WithScoop -Package $ScoopPackage -Bucket $ScoopBucket
    }
    # Try winget
    if ($WingetId -and -not $installed) {
        $installed = Install-WithWinget -PackageId $WingetId
    }
    # Try choco
    if ($ChocoPackage -and -not $installed) {
        $installed = Install-WithChoco -Package $ChocoPackage
    }

    if ($installed -or (Test-CommandExist $Command)) {
        Write-Status "$Name installed successfully" -Type Success
    } else {
        Write-Status "Failed to install $Name - no package manager succeeded" -Type Error
    }
}

#endregion

#region Tool Definitions

# CLI tools used by the profile (matching appsManage.ps1 scoop lists)
$ScoopMainTools = @(
    @{ Name = 'Git';        Command = 'git';       ScoopPackage = 'git';       WingetId = 'Git.Git';                      ChocoPackage = 'git' }
    @{ Name = 'fzf';        Command = 'fzf';       ScoopPackage = 'fzf';       WingetId = 'junegunn.fzf';                 ChocoPackage = 'fzf' }
    @{ Name = 'bat';        Command = 'bat';       ScoopPackage = 'bat';       WingetId = 'sharkdp.bat';                  ChocoPackage = 'bat' }
    @{ Name = 'eza';        Command = 'eza';       ScoopPackage = 'eza';       WingetId = 'eza-community.eza';            ChocoPackage = 'eza' }
    @{ Name = 'fd';         Command = 'fd';        ScoopPackage = 'fd';        WingetId = 'sharkdp.fd';                   ChocoPackage = 'fd' }
    @{ Name = 'ripgrep';    Command = 'rg';        ScoopPackage = 'ripgrep';   WingetId = 'BurntSushi.ripgrep.MSVC';      ChocoPackage = 'ripgrep' }
    @{ Name = 'zoxide';     Command = 'zoxide';    ScoopPackage = 'zoxide';    WingetId = 'ajeetdsouza.zoxide';            ChocoPackage = 'zoxide' }
    @{ Name = 'starship';   Command = 'starship';  ScoopPackage = 'starship';  WingetId = 'Starship.Starship';            ChocoPackage = 'starship' }
    @{ Name = 'delta';      Command = 'delta';     ScoopPackage = 'delta';     WingetId = 'dandavison.delta';             ChocoPackage = 'git-delta' }
    @{ Name = 'neovim';     Command = 'nvim';      ScoopPackage = 'neovim';    WingetId = 'Neovim.Neovim';                ChocoPackage = 'neovim' }
    @{ Name = 'fastfetch';  Command = 'fastfetch'; ScoopPackage = 'fastfetch'; WingetId = 'Fastfetch-cli.Fastfetch';      ChocoPackage = 'fastfetch' }
    @{ Name = 'lazygit';    Command = 'lazygit';   ScoopPackage = 'lazygit';   WingetId = 'JesseDuffield.lazygit';         ChocoPackage = 'lazygit' }
    @{ Name = 'lazydocker'; Command = 'lazydocker';ScoopPackage = 'lazydocker';WingetId = 'JesseDuffield.Lazydocker';      ChocoPackage = 'lazydocker' }
    @{ Name = 'lf';         Command = 'lf';        ScoopPackage = 'lf';        WingetId = $null;                          ChocoPackage = 'lf' }
    @{ Name = 'tldr';       Command = 'tldr';      ScoopPackage = 'tldr';      WingetId = $null;                          ChocoPackage = 'tldr' }
    @{ Name = 'sd';         Command = 'sd';        ScoopPackage = 'sd';        WingetId = $null;                          ChocoPackage = $null }
    @{ Name = 'rclone';     Command = 'rclone';    ScoopPackage = 'rclone';    WingetId = 'Rclone.Rclone';                ChocoPackage = 'rclone' }
    @{ Name = 'sudo';       Command = 'sudo';      ScoopPackage = 'sudo';      WingetId = $null;                          ChocoPackage = $null }
    @{ Name = 'touch';      Command = 'touch';     ScoopPackage = 'touch';     WingetId = $null;                          ChocoPackage = $null }
    @{ Name = 'sed';        Command = 'sed';       ScoopPackage = 'sed';       WingetId = $null;                          ChocoPackage = $null }
    @{ Name = 'grep';       Command = 'grep';      ScoopPackage = 'grep';      WingetId = $null;                          ChocoPackage = $null }
    @{ Name = 'actionlint'; Command = 'actionlint';ScoopPackage = 'actionlint';WingetId = $null;                          ChocoPackage = $null }
    @{ Name = 'GitHub CLI'; Command = 'gh';        ScoopPackage = 'gh';        WingetId = 'GitHub.cli';                   ChocoPackage = 'gh' }
)

$ScoopExtrasTools = @(
    @{ Name = 'VS Code';              Command = 'code';              ScoopPackage = 'vscode';            ScoopBucket = 'extras'; WingetId = 'Microsoft.VisualStudioCode'; ChocoPackage = 'vscode' }
    @{ Name = 'PowerToys';            Command = $null;               ScoopPackage = 'powertoys';         ScoopBucket = 'extras'; WingetId = 'Microsoft.PowerToys';        ChocoPackage = 'powertoys' }
    @{ Name = 'AutoHotkey';           Command = $null;               ScoopPackage = 'autohotkey';        ScoopBucket = 'extras'; WingetId = 'AutoHotkey.AutoHotkey';       ChocoPackage = 'autohotkey' }
    @{ Name = 'OBS Studio';           Command = $null;               ScoopPackage = 'obs-studio';        ScoopBucket = 'extras'; WingetId = 'OBSProject.OBSStudio';        ChocoPackage = 'obs-studio' }
    @{ Name = 'Scoop Completion';     Command = $null;               ScoopPackage = 'scoop-completion';  ScoopBucket = 'extras'; WingetId = $null;                         ChocoPackage = $null }
    @{ Name = 'Docker Completion';    Command = $null;               ScoopPackage = 'dockercompletion';  ScoopBucket = 'extras'; WingetId = $null;                         ChocoPackage = $null }
)

# PowerShell modules (from ModuleInstaller.ps1 + appsManage.ps1)
$RequiredModules = @(
    @{ Name = 'PSReadLine';                    MinVersion = '2.2.0' }
    @{ Name = 'Terminal-Icons';                MinVersion = '0.10.0' }
    @{ Name = 'posh-git';                      MinVersion = '1.1.0' }
    @{ Name = 'PSFzf';                         MinVersion = '2.5.0' }
    @{ Name = 'z';                             MinVersion = '1.1.0' }
    @{ Name = 'Catppuccin';                    MinVersion = '0.2.0' }
    @{ Name = 'PSWindowsUpdate';               MinVersion = '2.2.0.3' }
    @{ Name = 'PowerShellGet';                 MinVersion = '2.2.5' }
    @{ Name = 'CompletionPredictor';           MinVersion = $null }
    @{ Name = 'posh-wakatime';                 MinVersion = $null }
)

# npm global packages
$NpmGlobalPackages = @('markdownlint-cli', 'eslint', 'prettier')

# pip packages
$PipGlobalPackages = @('thefuck', 'cpplint', 'ruff')

#endregion

#region Installation Functions

function Install-PackageManagers {
    Write-Host "`n===== Package Managers =====" -ForegroundColor Cyan

    # Scoop (no admin required)
    Write-Status "Scoop" -Type Header
    if (Test-CommandExist 'scoop') {
        Write-Status "Scoop already installed" -Type Success
    } elseif ($WhatIfPreference) {
        Write-Status "Would install Scoop" -Type Warning
    } else {
        Write-Status "Installing Scoop..." -Type Info
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
            Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
            Update-SessionPath
            Write-Status "Scoop installed" -Type Success
        } catch {
            Write-Status "Failed to install Scoop: $_" -Type Error
        }
    }

    # Scoop needs git for adding buckets - install it early
    if ((Test-CommandExist 'scoop') -and -not (Test-CommandExist 'git')) {
        Write-Status "Installing git (required by scoop for buckets)..." -Type Info
        scoop install git 2>&1 | Out-Null
        Update-SessionPath
    }

    # Add scoop buckets
    if (Test-CommandExist 'scoop') {
        $existingBuckets = @()
        try {
            $existingBuckets = @(scoop bucket list 2>$null | Select-Object -ExpandProperty Name -ErrorAction SilentlyContinue)
        } catch {}
        foreach ($bucket in @('main', 'extras')) {
            if ($existingBuckets -notcontains $bucket) {
                Write-Status "Adding scoop bucket: $bucket" -Type Info
                scoop bucket add $bucket 2>&1 | Out-Null
            }
        }
    }

    # Winget (comes pre-installed on Windows 11, may need App Installer on Windows 10)
    Write-Status "Winget" -Type Header
    if (Test-CommandExist 'winget') {
        Write-Status "Winget already installed" -Type Success
    } else {
        Write-Status "Winget not found - install 'App Installer' from Microsoft Store" -Type Warning
    }

    # Chocolatey (requires admin)
    Write-Status "Chocolatey" -Type Header
    if (Test-CommandExist 'choco') {
        Write-Status "Chocolatey already installed" -Type Success
    } elseif ($WhatIfPreference) {
        Write-Status "Would install Chocolatey" -Type Warning
    } elseif (-not (Test-IsAdmin)) {
        Write-Status "Chocolatey requires admin - run this script as Administrator to install it" -Type Warning
    } else {
        Write-Status "Installing Chocolatey..." -Type Info
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            $installScript = (New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')
            & ([scriptblock]::Create($installScript))
            Update-SessionPath
            Write-Status "Chocolatey installed" -Type Success
        } catch {
            Write-Status "Failed to install Chocolatey: $_" -Type Error
        }
    }
}

function Install-CliTools {
    Write-Host "`n===== CLI Tools (main) =====" -ForegroundColor Cyan

    foreach ($tool in $ScoopMainTools) {
        Install-Tool @tool
    }

    Write-Host "`n===== CLI Tools (extras) =====" -ForegroundColor Cyan

    # Cache scoop list once for tools without a command to check
    $scoopInstalledApps = @()
    if (Test-CommandExist 'scoop') {
        try {
            $scoopInstalledApps = @(scoop list 2>$null | Select-Object -ExpandProperty Name -ErrorAction SilentlyContinue)
        } catch {}
    }

    foreach ($tool in $ScoopExtrasTools) {
        $command = $tool.Command
        $name = $tool.Name

        # For tools without a command to check, verify via scoop
        if (-not $command) {
            if ($scoopInstalledApps -contains $tool.ScoopPackage) {
                Write-Status "$name already installed" -Type Success
                continue
            }
        } elseif (Test-CommandExist $command) {
            Write-Status "$name already installed" -Type Success
            continue
        }

        if ($WhatIfPreference) {
            Write-Status "Would install $name" -Type Warning
            continue
        }

        Write-Status "Installing $name..." -Type Info
        $installed = Install-WithScoop -Package $tool.ScoopPackage -Bucket $tool.ScoopBucket
        if (-not $installed -and $tool.WingetId) {
            $installed = Install-WithWinget -PackageId $tool.WingetId
        }
        if (-not $installed -and $tool.ChocoPackage) {
            $installed = Install-WithChoco -Package $tool.ChocoPackage
        }

        if ($installed) {
            Write-Status "$name installed" -Type Success
        } else {
            Write-Status "Failed to install $name" -Type Error
        }
    }
}

function Install-PowerShellModules {
    Write-Host "`n===== PowerShell Modules =====" -ForegroundColor Cyan

    # Ensure NuGet provider and PSGallery trust so Install-Module doesn't hang
    Initialize-NuGetProvider

    foreach ($mod in $RequiredModules) {
        $name = $mod.Name
        $minVer = $mod.MinVersion

        $existing = Get-Module -ListAvailable -Name $name -ErrorAction SilentlyContinue |
            Sort-Object Version -Descending | Select-Object -First 1

        if ($existing) {
            if ($minVer -and ($existing.Version -lt [version]$minVer)) {
                Write-Status "$name v$($existing.Version) found, needs >= $minVer" -Type Warning
            } else {
                Write-Status "$name v$($existing.Version)" -Type Success
                continue
            }
        }

        if ($WhatIfPreference) {
            Write-Status "Would install $name" -Type Warning
            continue
        }

        Write-Status "Installing $name..." -Type Info
        try {
            $installParams = @{
                Name            = $name
                Scope           = 'CurrentUser'
                Force           = $true
                AllowClobber    = $true
                Confirm         = $false
                WarningAction   = 'SilentlyContinue'
                ErrorAction     = 'Stop'
            }
            if ($minVer) {
                $installParams.MinimumVersion = $minVer
            }
            Install-Module @installParams | Out-Null
            Write-Status "$name installed" -Type Success
        } catch {
            Write-Status "Failed to install $name`: $_" -Type Error
        }
    }
}

function Install-NpmPackages {
    Write-Host "`n===== npm Global Packages =====" -ForegroundColor Cyan

    if (-not (Test-CommandExist 'npm')) {
        Write-Status "npm not found - install Node.js first (winget install OpenJS.NodeJS.LTS)" -Type Warning
        return
    }

    foreach ($pkg in $NpmGlobalPackages) {
        $installed = npm list -g $pkg --depth=0 2>$null
        if ($installed -match $pkg) {
            Write-Status "$pkg already installed" -Type Success
            continue
        }

        if ($WhatIfPreference) {
            Write-Status "Would install $pkg" -Type Warning
            continue
        }

        Write-Status "Installing $pkg..." -Type Info
        try {
            npm install -g $pkg 2>&1 | Out-Null
            Write-Status "$pkg installed" -Type Success
        } catch {
            Write-Status "Failed to install $pkg" -Type Error
        }
    }
}

function Install-PipPackages {
    Write-Host "`n===== pip Packages =====" -ForegroundColor Cyan

    if (-not (Test-CommandExist 'pip')) {
        Write-Status "pip not found - install Python first" -Type Warning
        return
    }

    foreach ($pkg in $PipGlobalPackages) {
        $installed = pip show $pkg 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Status "$pkg already installed" -Type Success
            continue
        }

        if ($WhatIfPreference) {
            Write-Status "Would install $pkg" -Type Warning
            continue
        }

        Write-Status "Installing $pkg..." -Type Info
        try {
            pip install $pkg 2>&1 | Out-Null
            Write-Status "$pkg installed" -Type Success
        } catch {
            Write-Status "Failed to install $pkg" -Type Error
        }
    }
}

function Install-DevRuntimes {
    Write-Host "`n===== Development Runtimes =====" -ForegroundColor Cyan

    # Node.js
    Install-Tool -Name 'Node.js' -Command 'node' -ScoopPackage 'nodejs-lts' -WingetId 'OpenJS.NodeJS.LTS' -ChocoPackage 'nodejs-lts'

    # Python
    Install-Tool -Name 'Python' -Command 'python' -ScoopPackage 'python' -WingetId 'Python.Python.3.12' -ChocoPackage 'python3'

    # Ruby
    Install-Tool -Name 'Ruby' -Command 'ruby' -ScoopPackage 'ruby' -WingetId 'RubyInstallerTeam.RubyWithDevKit.3.2' -ChocoPackage 'ruby'

    # Conda/Mamba
    if (-not (Test-CommandExist 'conda')) {
        if ($WhatIfPreference) {
            Write-Status "Would install Miniforge3 (conda/mamba)" -Type Warning
        } else {
            Write-Status "Installing Miniforge3..." -Type Info
            $installed = Install-WithWinget -PackageId 'CondaForge.Miniforge3'
            if ($installed) {
                Write-Status "Miniforge3 installed (restart terminal to use conda)" -Type Success
            } else {
                Write-Status "Failed to install Miniforge3" -Type Error
            }
        }
    } else {
        Write-Status "conda already installed" -Type Success
    }

    # Chezmoi
    Install-Tool -Name 'chezmoi' -Command 'chezmoi' -ScoopPackage 'chezmoi' -WingetId 'twpayne.chezmoi' -ChocoPackage $null
}

#endregion

#region Main

Write-Host ""
Write-Host "  PowerShell Profile Dependency Installer" -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan

$noSwitch = -not ($All -or $PackageManagers -or $CliTools -or $Modules -or $NpmPackages -or $PipPackages -or $DevTools)

if ($noSwitch) {
    Write-Host @"

  Usage: .\install-dependencies.ps1 [options]

  Options:
    -All              Install everything
    -PackageManagers  Install scoop, winget check, chocolatey
    -CliTools         Install all CLI tools (fzf, bat, eza, starship, etc.)
    -Modules          Install PowerShell modules
    -NpmPackages      Install global npm packages (eslint, prettier, etc.)
    -PipPackages      Install pip packages (thefuck, ruff, etc.)
    -DevTools         Install dev runtimes (Node, Python, Ruby, conda, chezmoi)
    -WhatIf           Show what would be installed without installing

  Examples:
    .\install-dependencies.ps1 -All
    .\install-dependencies.ps1 -CliTools -Modules
    .\install-dependencies.ps1 -All -WhatIf

"@
    return
}

if ($All -or $PackageManagers) { Install-PackageManagers }
if ($All -or $CliTools)        { Install-CliTools }
if ($All -or $Modules)         { Install-PowerShellModules }
if ($All -or $DevTools)        { Install-DevRuntimes; Update-SessionPath }
if ($All -or $NpmPackages)     { Install-NpmPackages }
if ($All -or $PipPackages)     { Install-PipPackages }

Write-Host ""
Write-Host "  Installation complete!" -ForegroundColor Green
if ($All -or $DevTools) {
    Write-Host "  Some tools may require a terminal restart to be available." -ForegroundColor Yellow
}
Write-Host ""

#endregion
