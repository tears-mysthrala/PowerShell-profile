# Dependency Installer for PowerShell Profile
# This script installs external tools and package managers required by the PowerShell profile

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$All,
    [switch]$PackageManagers,
    [switch]$Git,
    [switch]$Fzf,
    [switch]$Bat,
    [switch]$Eza,
    [switch]$Lazygit,
    [switch]$Zoxide,
    [switch]$Ripgrep,
    [switch]$Fd
)

$ErrorActionPreference = 'Stop'

# Colors for output
$Green = [ConsoleColor]::Green
$Yellow = [ConsoleColor]::Yellow
$Red = [ConsoleColor]::Red
$Cyan = [ConsoleColor]::Cyan

function Write-ColorOutput {
    param([string]$Message)
    Write-Verbose $Message
}

function Install-Chocolatey {
    Write-ColorOutput "Installing Chocolatey..." $Cyan
    if ($WhatIf) {
        Write-ColorOutput "  [WHATIF] Would install Chocolatey" $Yellow
        return
    }

    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        $installScript = (New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')
        & ([scriptblock]::Create($installScript))
        Write-ColorOutput "  ✓ Chocolatey installed successfully" $Green
    } catch {
        Write-ColorOutput "  ✗ Failed to install Chocolatey: $($_.Exception.Message)" $Red
    }
}

function Install-Scoop {
    Write-ColorOutput "Installing Scoop..." $Cyan
    if ($WhatIf) {
        Write-ColorOutput "  [WHATIF] Would install Scoop" $Yellow
        return
    }

    try {
        if (!(Test-CommandExist 'scoop')) {
            $installScript = Invoke-RestMethod -Uri 'https://get.scoop.sh'
            & ([scriptblock]::Create($installScript))
            Write-ColorOutput "  ✓ Scoop installed successfully" $Green
        } else {
            Write-ColorOutput "  ✓ Scoop already installed" $Green
        }
    } catch {
        Write-ColorOutput "  ✗ Failed to install Scoop: $($_.Exception.Message)" $Red
    }
}

function Install-Winget {
    Write-ColorOutput "Checking Winget..." $Cyan
    if (Test-CommandExist 'winget') {
        Write-ColorOutput "  ✓ Winget already installed" $Green
        return
    }

    Write-ColorOutput "  Winget not found. Please install from Microsoft Store or GitHub releases." $Yellow
    Write-ColorOutput "  Download: https://github.com/microsoft/winget-cli/releases" $Yellow
}

function Install-Git {
    Write-ColorOutput "Installing Git..." $Cyan
    if ($WhatIf) {
        Write-ColorOutput "  [WHATIF] Would install Git" $Yellow
        return
    }

    if (Test-CommandExist 'git') {
        Write-ColorOutput "  ✓ Git already installed" $Green
        return
    }

    try {
        # Try Chocolatey first
        if (Test-CommandExist 'choco') {
            Write-ColorOutput "  Installing via Chocolatey..." $Yellow
            choco install git -y
        }
        # Try Scoop
        elseif (Test-CommandExist 'scoop') {
            Write-ColorOutput "  Installing via Scoop..." $Yellow
            scoop install git
        }
        # Try Winget
        elseif (Test-CommandExist 'winget') {
            Write-ColorOutput "  Installing via Winget..." $Yellow
            winget install --id Git.Git -e --source winget
        }
        else {
            Write-ColorOutput "  ✗ No package manager found. Please install Git manually." $Red
            Write-ColorOutput "  Download: https://git-scm.com/downloads" $Yellow
            return
        }

        if (Test-CommandExist 'git') {
            Write-ColorOutput "  ✓ Git installed successfully" $Green
        } else {
            Write-ColorOutput "  ✗ Git installation failed" $Red
        }
    } catch {
        Write-ColorOutput "  ✗ Failed to install Git: $($_.Exception.Message)" $Red
    }
}

function Install-Fzf {
    Write-ColorOutput "Installing fzf..." $Cyan
    if ($WhatIf) {
        Write-ColorOutput "  [WHATIF] Would install fzf" $Yellow
        return
    }

    if (Test-CommandExist 'fzf') {
        Write-ColorOutput "  ✓ fzf already installed" $Green
        return
    }

    try {
        # Try Chocolatey first
        if (Test-CommandExist 'choco') {
            Write-ColorOutput "  Installing via Chocolatey..." $Yellow
            choco install fzf -y
        }
        # Try Scoop
        elseif (Test-CommandExist 'scoop') {
            Write-ColorOutput "  Installing via Scoop..." $Yellow
            scoop install fzf
        }
        # Try Winget
        elseif (Test-CommandExist 'winget') {
            Write-ColorOutput "  Installing via Winget..." $Yellow
            winget install --id junegunn.fzf -e --source winget
        }
        else {
            Write-ColorOutput "  ✗ No package manager found. Please install fzf manually." $Red
            Write-ColorOutput "  Download: https://github.com/junegunn/fzf/releases" $Yellow
            return
        }

        if (Test-CommandExist 'fzf') {
            Write-ColorOutput "  ✓ fzf installed successfully" $Green
        } else {
            Write-ColorOutput "  ✗ fzf installation failed" $Red
        }
    } catch {
        Write-ColorOutput "  ✗ Failed to install fzf: $($_.Exception.Message)" $Red
    }
}

function Install-Bat {
    Write-ColorOutput "Installing bat..." $Cyan
    if ($WhatIf) {
        Write-ColorOutput "  [WHATIF] Would install bat" $Yellow
        return
    }

    if (Test-CommandExist 'bat') {
        Write-ColorOutput "  ✓ bat already installed" $Green
        return
    }

    try {
        # Try Chocolatey first
        if (Test-CommandExist 'choco') {
            Write-ColorOutput "  Installing via Chocolatey..." $Yellow
            choco install bat -y
        }
        # Try Scoop
        elseif (Test-CommandExist 'scoop') {
            Write-ColorOutput "  Installing via Scoop..." $Yellow
            scoop install bat
        }
        # Try Winget
        elseif (Test-CommandExist 'winget') {
            Write-ColorOutput "  Installing via Winget..." $Yellow
            winget install --id sharkdp.bat -e --source winget
        }
        else {
            Write-ColorOutput "  ✗ No package manager found. Please install bat manually." $Red
            Write-ColorOutput "  Download: https://github.com/sharkdp/bat/releases" $Yellow
            return
        }

        if (Test-CommandExist 'bat') {
            Write-ColorOutput "  ✓ bat installed successfully" $Green
        } else {
            Write-ColorOutput "  ✗ bat installation failed" $Red
        }
    } catch {
        Write-ColorOutput "  ✗ Failed to install bat: $($_.Exception.Message)" $Red
    }
}

function Install-Eza {
    Write-ColorOutput "Installing eza..." $Cyan
    if ($WhatIf) {
        Write-ColorOutput "  [WHATIF] Would install eza" $Yellow
        return
    }

    if (Test-CommandExist 'eza') {
        Write-ColorOutput "  ✓ eza already installed" $Green
        return
    }

    try {
        # Try Scoop first (has eza)
        if (Test-CommandExist 'scoop') {
            Write-ColorOutput "  Installing via Scoop..." $Yellow
            scoop install eza
        }
        # Try Chocolatey
        elseif (Test-CommandExist 'choco') {
            Write-ColorOutput "  Installing via Chocolatey..." $Yellow
            choco install eza -y
        }
        # Try Winget
        elseif (Test-CommandExist 'winget') {
            Write-ColorOutput "  Installing via Winget..." $Yellow
            winget install --id eza-community.eza -e --source winget
        }
        else {
            Write-ColorOutput "  ✗ No package manager found. Please install eza manually." $Red
            Write-ColorOutput "  Download: https://github.com/eza-community/eza/releases" $Yellow
            return
        }

        if (Test-CommandExist 'eza') {
            Write-ColorOutput "  ✓ eza installed successfully" $Green
        } else {
            Write-ColorOutput "  ✗ eza installation failed" $Red
        }
    } catch {
        Write-ColorOutput "  ✗ Failed to install eza: $($_.Exception.Message)" $Red
    }
}

function Install-Lazygit {
    Write-ColorOutput "Installing lazygit..." $Cyan
    if ($WhatIf) {
        Write-ColorOutput "  [WHATIF] Would install lazygit" $Yellow
        return
    }

    if (Test-CommandExist 'lazygit') {
        Write-ColorOutput "  ✓ lazygit already installed" $Green
        return
    }

    try {
        # Try Chocolatey first
        if (Test-CommandExist 'choco') {
            Write-ColorOutput "  Installing via Chocolatey..." $Yellow
            choco install lazygit -y
        }
        # Try Scoop
        elseif (Test-CommandExist 'scoop') {
            Write-ColorOutput "  Installing via Scoop..." $Yellow
            scoop install lazygit
        }
        # Try Winget
        elseif (Test-CommandExist 'winget') {
            Write-ColorOutput "  Installing via Winget..." $Yellow
            winget install --id JesseDuffield.lazygit -e --source winget
        }
        else {
            Write-ColorOutput "  ✗ No package manager found. Please install lazygit manually." $Red
            Write-ColorOutput "  Download: https://github.com/jesseduffield/lazygit/releases" $Yellow
            return
        }

        if (Test-CommandExist 'lazygit') {
            Write-ColorOutput "  ✓ lazygit installed successfully" $Green
        } else {
            Write-ColorOutput "  ✗ lazygit installation failed" $Red
        }
    } catch {
        Write-ColorOutput "  ✗ Failed to install lazygit: $($_.Exception.Message)" $Red
    }
}

function Install-Zoxide {
    Write-ColorOutput "Installing zoxide..." $Cyan
    if ($WhatIf) {
        Write-ColorOutput "  [WHATIF] Would install zoxide" $Yellow
        return
    }

    if (Test-CommandExist 'zoxide') {
        Write-ColorOutput "  ✓ zoxide already installed" $Green
        return
    }

    try {
        # Try Scoop first
        if (Test-CommandExist 'scoop') {
            Write-ColorOutput "  Installing via Scoop..." $Yellow
            scoop install zoxide
        }
        # Try Chocolatey
        elseif (Test-CommandExist 'choco') {
            Write-ColorOutput "  Installing via Chocolatey..." $Yellow
            choco install zoxide -y
        }
        # Try Winget
        elseif (Test-CommandExist 'winget') {
            Write-ColorOutput "  Installing via Winget..." $Yellow
            winget install --id ajeetdsouza.zoxide -e --source winget
        }
        else {
            Write-ColorOutput "  ✗ No package manager found. Please install zoxide manually." $Red
            Write-ColorOutput "  Download: https://github.com/ajeetdsouza/zoxide/releases" $Yellow
            return
        }

        if (Test-CommandExist 'zoxide') {
            Write-ColorOutput "  ✓ zoxide installed successfully" $Green
        } else {
            Write-ColorOutput "  ✗ zoxide installation failed" $Red
        }
    } catch {
        Write-ColorOutput "  ✗ Failed to install zoxide: $($_.Exception.Message)" $Red
    }
}

function Install-Ripgrep {
    Write-ColorOutput "Installing ripgrep..." $Cyan
    if ($WhatIf) {
        Write-ColorOutput "  [WHATIF] Would install ripgrep" $Yellow
        return
    }

    if (Test-CommandExist 'rg') {
        Write-ColorOutput "  ✓ ripgrep already installed" $Green
        return
    }

    try {
        # Try Scoop first
        if (Test-CommandExist 'scoop') {
            Write-ColorOutput "  Installing via Scoop..." $Yellow
            scoop install ripgrep
        }
        # Try Chocolatey
        elseif (Test-CommandExist 'choco') {
            Write-ColorOutput "  Installing via Chocolatey..." $Yellow
            choco install ripgrep -y
        }
        # Try Winget
        elseif (Test-CommandExist 'winget') {
            Write-ColorOutput "  Installing via Winget..." $Yellow
            winget install --id BurntSushi.ripgrep.MSVC -e --source winget
        }
        else {
            Write-ColorOutput "  ✗ No package manager found. Please install ripgrep manually." $Red
            Write-ColorOutput "  Download: https://github.com/BurntSushi/ripgrep/releases" $Yellow
            return
        }

        if (Test-CommandExist 'rg') {
            Write-ColorOutput "  ✓ ripgrep installed successfully" $Green
        } else {
            Write-ColorOutput "  ✗ ripgrep installation failed" $Red
        }
    } catch {
        Write-ColorOutput "  ✗ Failed to install ripgrep: $($_.Exception.Message)" $Red
    }
}

function Install-Fd {
    Write-ColorOutput "Installing fd..." $Cyan
    if ($WhatIf) {
        Write-ColorOutput "  [WHATIF] Would install fd" $Yellow
        return
    }

    if (Test-CommandExist 'fd') {
        Write-ColorOutput "  ✓ fd already installed" $Green
        return
    }

    try {
        # Try Scoop first
        if (Test-CommandExist 'scoop') {
            Write-ColorOutput "  Installing via Scoop..." $Yellow
            scoop install fd
        }
        # Try Chocolatey
        elseif (Test-CommandExist 'choco') {
            Write-ColorOutput "  Installing via Chocolatey..." $Yellow
            choco install fd -y
        }
        # Try Winget
        elseif (Test-CommandExist 'winget') {
            Write-ColorOutput "  Installing via Winget..." $Yellow
            winget install --id sharkdp.fd -e --source winget
        }
        else {
            Write-ColorOutput "  ✗ No package manager found. Please install fd manually." $Red
            Write-ColorOutput "  Download: https://github.com/sharkdp/fd/releases" $Yellow
            return
        }

        if (Test-CommandExist 'fd') {
            Write-ColorOutput "  ✓ fd installed successfully" $Green
        } else {
            Write-ColorOutput "  ✗ fd installation failed" $Red
        }
    } catch {
        Write-ColorOutput "  ✗ Failed to install fd: $($_.Exception.Message)" $Red
    }
}

# Main installation logic
Write-ColorOutput "PowerShell Profile Dependency Installer" $Cyan
Write-ColorOutput "=====================================" $Cyan
Write-ColorOutput ""

if ($All) {
    Write-ColorOutput "Installing ALL dependencies..." $Yellow
    Install-Chocolatey
    Install-Scoop
    Install-Winget
    Install-Git
    Install-Fzf
    Install-Bat
    Install-Eza
    Install-Lazygit
    Install-Zoxide
    Install-Ripgrep
    Install-Fd
} elseif ($PackageManagers) {
    Write-ColorOutput "Installing package managers..." $Yellow
    Install-Chocolatey
    Install-Scoop
    Install-Winget
} else {
    if ($Git) { Install-Git }
    if ($Fzf) { Install-Fzf }
    if ($Bat) { Install-Bat }
    if ($Eza) { Install-Eza }
    if ($Lazygit) { Install-Lazygit }
    if ($Zoxide) { Install-Zoxide }
    if ($Ripgrep) { Install-Ripgrep }
    if ($Fd) { Install-Fd }
}

if (-not ($All -or $PackageManagers -or $Git -or $Fzf -or $Bat -or $Eza -or $Lazygit -or $Zoxide -or $Ripgrep -or $Fd)) {
    Write-ColorOutput "Usage: .\install-dependencies.ps1 [options]" $Yellow
    Write-ColorOutput ""
    Write-ColorOutput "Options:" $Cyan
    Write-ColorOutput "  -All              Install all dependencies"
    Write-ColorOutput "  -PackageManagers  Install package managers only (choco, scoop, winget)"
    Write-ColorOutput "  -Git              Install Git"
    Write-ColorOutput "  -Fzf              Install fzf"
    Write-ColorOutput "  -Bat              Install bat"
    Write-ColorOutput "  -Eza              Install eza"
    Write-ColorOutput "  -Lazygit          Install lazygit"
    Write-ColorOutput "  -Zoxide           Install zoxide"
    Write-ColorOutput "  -Ripgrep          Install ripgrep"
    Write-ColorOutput "  -Fd               Install fd"
    Write-ColorOutput "  -Force            Force reinstallation"
    Write-ColorOutput "  -WhatIf           Show what would be installed without installing"
    Write-ColorOutput ""
    Write-ColorOutput "Examples:" $Cyan
    Write-ColorOutput "  .\install-dependencies.ps1 -All"
    Write-ColorOutput "  .\install-dependencies.ps1 -Git -Fzf -Bat"
    Write-ColorOutput "  .\install-dependencies.ps1 -PackageManagers"
    Write-ColorOutput "  .\install-dependencies.ps1 -All -WhatIf"
}

Write-ColorOutput ""
Write-ColorOutput "Installation complete!" $Green
