# Script to install missing development tools
# Uses winget primarily, with sudo for admin privileges when needed

$ErrorActionPreference = 'Continue'

function Write-InstallHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
}

function Write-InstallStatus {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Status = 'Info'
    )
    $colors = @{ Info = 'White'; Success = 'Green'; Warning = 'Yellow'; Error = 'Red' }
    $prefixes = @{ Info = '>'; Success = 'OK'; Warning = '!!'; Error = 'XX' }
    Write-Host "[$($prefixes[$Status])] $Message" -ForegroundColor $colors[$Status]
}

if (-not (Get-Command Test-CommandExist -ErrorAction SilentlyContinue)) {
    function Test-CommandExist {
        param([string]$Command)
        return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
    }
}

function Install-Conda {
    Write-InstallHeader "Installing Conda (Miniforge/Mamba)"
    
    if (Test-CommandExist 'conda') {
        Write-InstallStatus "Conda is already installed" -Status Success
        return
    }
    
    Write-InstallStatus "Installing Miniforge3 (includes Mamba)..." -Status Info
    try {
        # Miniforge es la versión más ligera y moderna de Conda con Mamba incluido
        winget install CondaForge.Miniforge3 --silent --accept-source-agreements --accept-package-agreements
        
        if ($LASTEXITCODE -eq 0) {
            Write-InstallStatus "Miniforge3 installed successfully!" -Status Success
            Write-InstallStatus "Please restart your terminal to use conda/mamba" -Status Warning
        } else {
            Write-InstallStatus "Installation failed with exit code: $LASTEXITCODE" -Status Error
        }
    } catch {
        Write-InstallStatus "Failed to install Conda: $_" -Status Error
    }
}

function Install-Ruby {
    Write-InstallHeader "Installing Ruby with DevKit"
    
    if (Test-CommandExist 'ruby') {
        Write-InstallStatus "Ruby is already installed" -Status Success
        return
    }
    
    Write-InstallStatus "Installing Ruby with DevKit..." -Status Info
    try {
        # Instalar Ruby con DevKit para poder compilar gemas nativas
        sudo winget install RubyInstallerTeam.RubyWithDevKit.3.2 --silent --accept-source-agreements --accept-package-agreements
        
        if ($LASTEXITCODE -eq 0) {
            Write-InstallStatus "Ruby installed successfully!" -Status Success
            Write-InstallStatus "Please restart your terminal to use ruby/gem" -Status Warning
        } else {
            Write-InstallStatus "Installation failed with exit code: $LASTEXITCODE" -Status Error
        }
    } catch {
        Write-InstallStatus "Failed to install Ruby: $_" -Status Error
    }
}

function Install-Composer {
    Write-InstallHeader "Installing PHP and Composer"
    
    if (Test-CommandExist 'composer') {
        Write-InstallStatus "Composer is already installed" -Status Success
        return
    }
    
    # Primero verificar/instalar PHP
    if (-not (Test-CommandExist 'php')) {
        Write-InstallStatus "Installing PHP first..." -Status Info
        try {
            sudo winget install PHP.PHP.8.3 --silent --accept-source-agreements --accept-package-agreements
            
            if ($LASTEXITCODE -ne 0) {
                Write-InstallStatus "Failed to install PHP" -Status Error
                return
            }
        } catch {
            Write-InstallStatus "Failed to install PHP: $_" -Status Error
            return
        }
    }
    
    Write-InstallStatus "Installing Composer..." -Status Info
    try {
        sudo winget install Composer.Composer --silent --accept-source-agreements --accept-package-agreements
        
        if ($LASTEXITCODE -eq 0) {
            Write-InstallStatus "Composer installed successfully!" -Status Success
        } else {
            Write-InstallStatus "Installation failed with exit code: $LASTEXITCODE" -Status Error
        }
    } catch {
        Write-InstallStatus "Failed to install Composer: $_" -Status Error
    }
}

function Install-Chezmoi {
    Write-InstallHeader "Installing Chezmoi (Dotfiles Manager)"
    
    if (Test-CommandExist 'chezmoi') {
        Write-InstallStatus "Chezmoi is already installed" -Status Success
        return
    }
    
    Write-InstallStatus "Installing Chezmoi..." -Status Info
    try {
        # Intentar con winget primero
        winget install twpayne.chezmoi --silent --accept-source-agreements --accept-package-agreements
        
        if ($LASTEXITCODE -eq 0) {
            Write-InstallStatus "Chezmoi installed successfully!" -Status Success
        } else {
            # Fallback a scoop si está disponible
            if (Test-CommandExist 'scoop') {
                Write-InstallStatus "Trying with Scoop..." -Status Info
                scoop install chezmoi
                if ($LASTEXITCODE -eq 0) {
                    Write-InstallStatus "Chezmoi installed via Scoop!" -Status Success
                } else {
                    Write-InstallStatus "Installation failed" -Status Error
                }
            } else {
                Write-InstallStatus "Installation failed with exit code: $LASTEXITCODE" -Status Error
            }
        }
    } catch {
        Write-InstallStatus "Failed to install Chezmoi: $_" -Status Error
    }
}

function Install-Homebrew-WSL {
    Write-InstallHeader "Installing Homebrew in WSL"
    
    if (-not (Test-CommandExist 'wsl')) {
        Write-InstallStatus "WSL not installed, skipping Homebrew" -Status Warning
        return
    }
    
    Write-InstallStatus "Checking if Homebrew is already installed in WSL..." -Status Info
    $brewCheck = & wsl which brew 2>$null
    
    if ($brewCheck) {
        Write-InstallStatus "Homebrew is already installed in WSL" -Status Success
        return
    }
    
    Write-InstallStatus "Installing Homebrew in WSL..." -Status Info
    try {
        & wsl -e bash -c "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        
        Write-InstallStatus "Homebrew installation initiated in WSL" -Status Success
        Write-InstallStatus "Follow the instructions in WSL to complete setup" -Status Warning
    } catch {
        Write-InstallStatus "Failed to install Homebrew in WSL: $_" -Status Error
    }
}

function Install-AllMissingTools {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "       INSTALLING MISSING DEVELOPMENT TOOLS                 " -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host ""
    Write-InstallStatus "This will install: Conda, Ruby, Composer, Chezmoi, and WSL Homebrew" -Status Info
    Write-InstallStatus "Using winget with sudo for admin privileges..." -Status Info
    Write-Host ""
    
    if ($PSCmdlet.ShouldProcess("Missing development tools", "Install")) {
        Install-Conda
        Install-Ruby
        Install-Composer
        Install-Chezmoi
        Install-Homebrew-WSL
        
        Write-Host ""
        Write-Host "============================================================" -ForegroundColor Green
        Write-InstallStatus "Installation process completed!" -Status Success
        Write-InstallStatus "Some tools may require terminal restart to be available" -Status Warning
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host ""
    }
}

# Create alias
Set-Alias -Name install-dev-tools -Value Install-AllMissingTools
