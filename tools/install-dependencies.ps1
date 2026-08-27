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
    [switch]$DevTools,
    [switch]$AiTools
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

function Test-SudoAvailable {
    return (Test-CommandExist 'sudo')
}

if (-not (Get-Command Test-CommandExist -ErrorAction SilentlyContinue)) {
    function Test-CommandExist {
        param([string]$Command)
        return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
    }
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
        $output = scoop install "$Bucket/$Package" 2>&1
        $exitCode = $LASTEXITCODE
        if ($exitCode -ne 0) {
            Write-Status "scoop: $($output | Out-String)" -Type Warning
        }
        return ($exitCode -eq 0)
    } catch {
        Write-Status "scoop exception: $_" -Type Warning
        return $false
    }
}

function Install-WithWinget {
    param([string]$PackageId)
    if (-not (Test-CommandExist 'winget')) { return $false }
    try {
        $output = winget install --id $PackageId -e --source winget --silent --accept-source-agreements --accept-package-agreements 2>&1
        $exitCode = $LASTEXITCODE
        # winget returns 0 on success, -1978335189 (0x8A150019) if already installed
        return ($exitCode -eq 0 -or $exitCode -eq -1978335189)
    } catch { return $false }
}

function Install-WithChoco {
    param([string]$Package)
    if (-not (Test-CommandExist 'choco')) { return $false }
    try {
        $output = choco install $Package -y 2>&1
        $exitCode = $LASTEXITCODE
        if ($exitCode -ne 0) {
            Write-Status "choco: $($output | Out-String)" -Type Warning
        }
        return ($exitCode -eq 0)
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
    @{ Name = 'uv';         Command = 'uv';        ScoopPackage = 'uv';        WingetId = 'astral-sh.uv';                 ChocoPackage = $null }
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
    @{ Name = 'PSWindowsUpdate';               MinVersion = '2.2.0.3' }
    @{ Name = 'PowerShellGet';                 MinVersion = '2.2.5' }
    @{ Name = 'CompletionPredictor';           MinVersion = $null }
    @{ Name = 'Microsoft.WinGet.CommandNotFound'; MinVersion = $null }
    @{ Name = 'posh-wakatime';                 MinVersion = $null }
)

# npm global packages
$NpmGlobalPackages = @('markdownlint-cli', 'eslint', 'prettier')

# pip packages
$PipGlobalPackages = @('thefuck', 'cpplint', 'ruff')

# AI CLI tools
$AiCliTools = @(
    @{
        Name       = 'Claude Code'
        Command    = 'claude'
        Method     = 'winget'
        WingetId   = 'Anthropic.ClaudeCode'
        NpmPackage = '@anthropic-ai/claude-code'
    }
    @{
        Name       = 'Codex CLI'
        Command    = 'codex'
        Method     = 'npm'
        WingetId   = 'OpenAI.Codex'
        NpmPackage = '@openai/codex'
    }
    @{
        Name         = 'OpenCode'
        Command      = 'opencode'
        Method       = 'scoop'
        ScoopPackage = 'opencode'
        NpmPackage   = 'opencode-ai'
        ChocoPackage = 'opencode'
    }
    @{
        Name       = 'Kimi CLI'
        Command    = 'kimi'
        Method     = 'uv'
        PipPackage = 'kimi-cli'
        UvPython   = '3.13'
    }
    @{
        Name       = 'Gemini CLI'
        Command    = 'gemini'
        Method     = 'npm'
        NpmPackage = '@google/gemini-cli'
    }
    @{
        Name         = 'Ollama'
        Command      = 'ollama'
        Method       = 'scoop'
        ScoopPackage = 'ollama'
        WingetId     = 'Ollama.Ollama'
    }
)

#endregion

#region Installation Functions

function Get-DependencyInstallerWinget {
    $command = Get-Command winget -ErrorAction SilentlyContinue
    if ($command.Source -and (Test-Path -LiteralPath $command.Source)) {
        return $command.Source
    }

    $appInstaller = Get-AppxPackage Microsoft.DesktopAppInstaller -ErrorAction SilentlyContinue |
        Sort-Object Version -Descending |
        Select-Object -First 1
    if ($appInstaller) {
        $fallback = Join-Path $appInstaller.InstallLocation 'winget.exe'
        if (Test-Path -LiteralPath $fallback) {
            return $fallback
        }
    }

    return $null
}

function Install-PackageManagers {
    Write-Host "`n===== Package Managers =====" -ForegroundColor Cyan

    # Scoop (no admin required)
    Write-Status "Scoop" -Type Header
    if (Test-CommandExist 'scoop') {
        Write-Status "Scoop already installed" -Type Success
    } elseif ($WhatIfPreference) {
        Write-Status "Would install Scoop" -Type Warning
    } else {
        Write-Status "Scoop is not installed; automatic bootstrap is disabled because it would execute an unverified remote script" -Type Warning
        Write-Status "Review and follow the official installation instructions: https://scoop.sh" -Type Info
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

    # Chocolatey (requires admin - uses sudo for elevation)
    Write-Status "Chocolatey" -Type Header
    if (Test-CommandExist 'choco') {
        Write-Status "Chocolatey already installed" -Type Success
    } elseif ($WhatIfPreference) {
        Write-Status "Would install Chocolatey" -Type Warning
    } else {
        Write-Status "Installing Chocolatey..." -Type Info
        try {
            $winget = Get-DependencyInstallerWinget
            if (-not $winget) {
                Write-Status "Chocolatey installation requires WinGet; install Microsoft App Installer first" -Type Warning
                return
            }

            & $winget install --id Chocolatey.Chocolatey --exact --source winget --silent --accept-source-agreements --accept-package-agreements --disable-interactivity
            if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne -1978335189) {
                throw "WinGet exited with code $LASTEXITCODE"
            }

            Update-SessionPath
            if (Test-CommandExist 'choco') {
                Write-Status "Chocolatey installed" -Type Success
            } else {
                Write-Status "Chocolatey installation completed; restart PowerShell to refresh PATH" -Type Info
            }
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
    Update-SessionPath

    # Python (scoop preferred - handles multiple versions, creates proper shims for python + pip)
    if (-not (Test-CommandExist 'python')) {
        if ($WhatIfPreference) {
            Write-Status "Would install Python" -Type Warning
        } else {
            Write-Status "Installing Python..." -Type Info
            $pyInstalled = $false

            # Scoop is strongly preferred for Python - proper shims, multi-version support
            if (Test-CommandExist 'scoop') {
                $pyInstalled = Install-WithScoop -Package 'python'
                if ($pyInstalled) {
                    Update-SessionPath
                    # Reset shims to ensure python/pip are correctly linked
                    scoop reset python 2>&1 | Out-Null
                    Update-SessionPath
                }
            }
            if (-not $pyInstalled) { $pyInstalled = Install-WithWinget -PackageId 'Python.Python.3.12' }
            if (-not $pyInstalled) { $pyInstalled = Install-WithChoco -Package 'python3' }

            Update-SessionPath

            if ($pyInstalled -or (Test-CommandExist 'python')) {
                Write-Status "Python installed" -Type Success
            } else {
                Write-Status "Failed to install Python" -Type Error
            }
        }
    } else {
        Write-Status "Python already installed" -Type Success
    }

    # Ensure pip is available
    Update-SessionPath
    if ((Test-CommandExist 'python') -and -not (Test-CommandExist 'pip')) {
        Write-Status "pip not found, bootstrapping..." -Type Info
        try {
            python -m ensurepip --upgrade 2>&1 | Out-Null
            Update-SessionPath
        } catch {}
        if (-not (Test-CommandExist 'pip')) {
            Write-Status "pip still not found - try restarting terminal" -Type Warning
        }
    }

    # Ruby
    Install-Tool -Name 'Ruby' -Command 'ruby' -ScoopPackage 'ruby' -WingetId 'RubyInstallerTeam.RubyWithDevKit.3.2' -ChocoPackage 'ruby'
    Update-SessionPath

    # Conda/Mamba - check PATH and common install locations
    $condaFound = Test-CommandExist 'conda'
    if (-not $condaFound) {
        # Miniforge/Anaconda/Miniconda don't always add conda to PATH
        $condaPaths = @(
            "$env:USERPROFILE\miniforge3\condabin\conda.exe",
            "$env:USERPROFILE\miniforge3\Scripts\conda.exe",
            "$env:USERPROFILE\miniconda3\condabin\conda.exe",
            "$env:USERPROFILE\anaconda3\condabin\conda.exe",
            "$env:LOCALAPPDATA\miniforge3\condabin\conda.exe",
            "$env:LOCALAPPDATA\Programs\miniforge3\condabin\conda.exe"
        )
        foreach ($p in $condaPaths) {
            if (Test-Path $p) {
                $condaFound = $true
                break
            }
        }
    }
    if (-not $condaFound) {
        if ($WhatIfPreference) {
            Write-Status "Would install Miniforge3 (conda/mamba)" -Type Warning
        } else {
            Write-Status "Installing Miniforge3..." -Type Info
            $installed = Install-WithWinget -PackageId 'CondaForge.Miniforge3'
            Update-SessionPath
            if ($installed) {
                Write-Status "Miniforge3 installed (run 'conda init powershell' then restart terminal)" -Type Success
            } else {
                Write-Status "Failed to install Miniforge3" -Type Error
            }
        }
    } else {
        Write-Status "conda/Miniforge already installed" -Type Success
    }

    # Rust (rustup + cargo)
    if (-not (Test-CommandExist 'cargo')) {
        if ($WhatIfPreference) {
            Write-Status "Would install Rust (rustup + cargo)" -Type Warning
        } else {
            Write-Status "Installing Rust (rustup + cargo)..." -Type Info
            $rustInstalled = Install-WithScoop -Package 'rustup'
            if (-not $rustInstalled) { $rustInstalled = Install-WithWinget -PackageId 'Rustlang.Rustup' }
            Update-SessionPath
            if (Test-CommandExist 'rustup') {
                rustup default stable 2>&1 | Out-Null
                Update-SessionPath
                Write-Status "Rust installed" -Type Success
            } else {
                Write-Status "Failed to install Rust" -Type Error
            }
        }
    } else {
        Write-Status "Rust/cargo already installed" -Type Success
    }

    # Go
    Install-Tool -Name 'Go' -Command 'go' -ScoopPackage 'go' -WingetId 'GoLang.Go' -ChocoPackage 'golang'
    Update-SessionPath

    # .NET SDK
    Install-Tool -Name '.NET SDK' -Command 'dotnet' -ScoopPackage 'dotnet-sdk' -WingetId 'Microsoft.DotNet.SDK.8' -ChocoPackage 'dotnet-sdk'
    Update-SessionPath

    # pipx (isolated Python app runner, used by upgrade for global Python tools)
    if (-not (Test-CommandExist 'pipx')) {
        if ($WhatIfPreference) {
            Write-Status "Would install pipx" -Type Warning
        } else {
            Write-Status "Installing pipx..." -Type Info
            $pipxInstalled = $false
            if (Test-CommandExist 'scoop') {
                $pipxInstalled = Install-WithScoop -Package 'pipx'
            }
            if (-not $pipxInstalled -and (Test-CommandExist 'pip')) {
                pip install --user pipx 2>&1 | Out-Null
                $pipxInstalled = ($LASTEXITCODE -eq 0)
            }
            Update-SessionPath
            if (Test-CommandExist 'pipx') {
                pipx ensurepath 2>&1 | Out-Null
                Update-SessionPath
                Write-Status "pipx installed" -Type Success
            } else {
                Write-Status "Failed to install pipx" -Type Error
            }
        }
    } else {
        Write-Status "pipx already installed" -Type Success
    }

    # Composer (PHP package manager)
    if ((Test-CommandExist 'php') -and -not (Test-CommandExist 'composer')) {
        if ($WhatIfPreference) {
            Write-Status "Would install Composer" -Type Warning
        } else {
            Write-Status "Installing Composer..." -Type Info
            $composerInstalled = Install-WithScoop -Package 'composer'
            if (-not $composerInstalled) {
                if (Test-SudoAvailable) {
                    sudo winget install Composer.Composer --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
                    $composerInstalled = ($LASTEXITCODE -eq 0)
                } else {
                    $composerInstalled = Install-WithWinget -PackageId 'Composer.Composer'
                }
            }
            Update-SessionPath
            if ($composerInstalled -or (Test-CommandExist 'composer')) {
                Write-Status "Composer installed" -Type Success
            } else {
                Write-Status "Failed to install Composer" -Type Error
            }
        }
    } elseif (Test-CommandExist 'composer') {
        Write-Status "Composer already installed" -Type Success
    }

    # Chezmoi
    Install-Tool -Name 'chezmoi' -Command 'chezmoi' -ScoopPackage 'chezmoi' -WingetId 'twpayne.chezmoi' -ChocoPackage $null
}

function Install-AiTools {
    Write-Host "`n===== AI CLI Tools =====" -ForegroundColor Cyan

    # Ensure prerequisites are available before installing AI tools
    Update-SessionPath

    # uv - needed for Kimi CLI; manages its own Python downloads
    if (-not (Test-CommandExist 'uv')) {
        Write-Status "Installing uv (required for Python-based AI tools)..." -Type Info
        $uvInstalled = Install-WithScoop -Package 'uv'
        if (-not $uvInstalled) { $uvInstalled = Install-WithWinget -PackageId 'astral-sh.uv' }
        Update-SessionPath
        if (Test-CommandExist 'uv') {
            Write-Status "uv installed" -Type Success
        } else {
            Write-Status "Failed to install uv - Python-based AI tools may fail" -Type Warning
        }
    }

    # Python - needed by uv for tool installs; scoop preferred for multi-version support
    if ((Test-CommandExist 'uv') -and -not (Test-CommandExist 'python')) {
        Write-Status "Installing Python via scoop (needed by uv)..." -Type Info
        $pyInstalled = Install-WithScoop -Package 'python'
        if ($pyInstalled) {
            scoop reset python 2>&1 | Out-Null
        }
        Update-SessionPath
        if (Test-CommandExist 'python') {
            Write-Status "Python installed" -Type Success
        } else {
            Write-Status "Python not in PATH - uv will download its own Python" -Type Warning
        }
    }

    # npm - needed for Codex, Gemini CLI
    if (-not (Test-CommandExist 'npm')) {
        Write-Status "npm not found - installing Node.js..." -Type Info
        Install-Tool -Name 'Node.js' -Command 'node' -ScoopPackage 'nodejs-lts' -WingetId 'OpenJS.NodeJS.LTS' -ChocoPackage 'nodejs-lts'
        Update-SessionPath
    }

    foreach ($tool in $AiCliTools) {
        $name = $tool.Name
        $command = $tool.Command

        if (Test-CommandExist $command) {
            Write-Status "$name already installed" -Type Success
            continue
        }

        if ($WhatIfPreference) {
            Write-Status "Would install $name" -Type Warning
            continue
        }

        Write-Status "Installing $name..." -Type Info
        $installed = $false

        switch ($tool.Method) {
            'winget' {
                if ($tool.WingetId) { $installed = Install-WithWinget -PackageId $tool.WingetId }
                if (-not $installed -and $tool.NpmPackage -and (Test-CommandExist 'npm')) {
                    try { npm install -g $tool.NpmPackage 2>&1 | Out-Null; $installed = $true } catch {}
                }
            }
            'npm' {
                if ($tool.NpmPackage -and (Test-CommandExist 'npm')) {
                    try { npm install -g $tool.NpmPackage 2>&1 | Out-Null; $installed = $true } catch {}
                } elseif (-not (Test-CommandExist 'npm')) {
                    Write-Status "$name requires npm - install Node.js first" -Type Warning
                    continue
                }
                if (-not $installed -and $tool.WingetId) { $installed = Install-WithWinget -PackageId $tool.WingetId }
            }
            'uv' {
                # uv tool install creates an isolated env and downloads Python if needed
                if ($tool.PipPackage -and (Test-CommandExist 'uv')) {
                    $uvArgs = @('tool', 'install')
                    if ($tool.UvPython) { $uvArgs += @('--python', $tool.UvPython) }
                    $uvArgs += $tool.PipPackage
                    $uvOutput = & uv @uvArgs 2>&1
                    $uvExit = $LASTEXITCODE
                    if ($uvExit -eq 0) {
                        $installed = $true
                    } else {
                        Write-Status "uv tool install failed: $($uvOutput | Out-String)" -Type Warning
                    }
                }
                # Fallback to pip
                if (-not $installed -and $tool.PipPackage -and (Test-CommandExist 'pip')) {
                    Write-Status "Trying pip fallback..." -Type Info
                    $pipOutput = pip install $tool.PipPackage 2>&1
                    if ($LASTEXITCODE -eq 0) { $installed = $true }
                    else { Write-Status "pip failed: $($pipOutput | Out-String)" -Type Warning }
                }
                if (-not $installed -and -not (Test-CommandExist 'uv') -and -not (Test-CommandExist 'pip')) {
                    Write-Status "$name requires uv or pip - run with -CliTools -DevTools first" -Type Error
                    continue
                }
                if (-not $installed) {
                    Write-Status "$name failed to install" -Type Error
                    continue
                }
            }
            'pip' {
                if ($tool.PipPackage -and (Test-CommandExist 'pip')) {
                    try { pip install $tool.PipPackage 2>&1 | Out-Null; $installed = $true } catch {}
                } elseif (-not (Test-CommandExist 'pip')) {
                    Write-Status "$name requires pip - install Python first" -Type Warning
                    continue
                }
            }
            'scoop' {
                if ($tool.ScoopPackage) { $installed = Install-WithScoop -Package $tool.ScoopPackage }
                if (-not $installed -and $tool.WingetId) { $installed = Install-WithWinget -PackageId $tool.WingetId }
                if (-not $installed -and $tool.ChocoPackage) { $installed = Install-WithChoco -Package $tool.ChocoPackage }
                if (-not $installed -and $tool.NpmPackage -and (Test-CommandExist 'npm')) {
                    try { npm install -g $tool.NpmPackage 2>&1 | Out-Null; $installed = $true } catch {}
                }
            }
        }

        Update-SessionPath

        if ($installed -or (Test-CommandExist $command)) {
            Write-Status "$name installed" -Type Success
        } else {
            Write-Status "Failed to install $name" -Type Error
        }
    }
}

#endregion

#region Main

Write-Host ""
Write-Host "  PowerShell Profile Dependency Installer" -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan

$noSwitch = -not ($All -or $PackageManagers -or $CliTools -or $Modules -or $NpmPackages -or $PipPackages -or $DevTools -or $AiTools)

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
    -AiTools          Install AI CLI tools (Claude, Codex, OpenCode, Kimi, Gemini, Ollama)
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
if ($All -or $AiTools)         { Install-AiTools }
if ($All -or $NpmPackages)     { Install-NpmPackages }
if ($All -or $PipPackages)     { Install-PipPackages }

Write-Host ""
Write-Host "  Installation complete!" -ForegroundColor Green
if ($All -or $DevTools) {
    Write-Host "  Some tools may require a terminal restart to be available." -ForegroundColor Yellow
}
Write-Host ""

#endregion
