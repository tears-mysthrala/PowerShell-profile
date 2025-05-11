# Let the script run even on error
# $ErrorActionPreference = "SilentlyContinue"
$ProfileDir = Split-Path -Parent $PROFILE
# Initialize profiling
$profileTiming = @{}
$globalStopwatch = [System.Diagnostics.Stopwatch]::StartNew()

function Measure-Block {
    param([string]$Name, [scriptblock]$Block)
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    & $Block
    $sw.Stop()
    $profileTiming[$Name] = $sw.ElapsedMilliseconds
}

# VARIABLES
# Environment Variables
$envVars = @{
    'EDITOR' = 'nvim'
    'VISUAL' = 'code'
    'PAGER'  = 'delta'
    'PYTHONIOENCODING' = 'utf-8'
}

foreach ($key in $envVars.Keys) {
    if (Get-Command $envVars[$key] -ErrorAction SilentlyContinue) {
        Set-Item -Path "env:$key" -Value $envVars[$key]
    }
}

# If is in non-interactive shell, then return
if (!([Environment]::UserInteractive -and -not $([Environment]::GetCommandLineArgs() | Where-Object { $_ -like '-NonI*' }))) {
  return
}

# Initialize Unified Module Manager
. "$ProfileDir\Scripts\powershell-config\Core\UnifiedModuleManager.ps1"

# Initialize Starship
Measure-Block 'Starship' {
    $ENV:STARSHIP_CONFIG = "$ProfileDir\starship.toml"
    Invoke-Expression (&starship init powershell)
}

# Initialize startup tools
Measure-Block 'Tool Initialization' {
    Initialize-StartupTools
}

# Register core modules
# Register unified aliases
. "$ProfileDir\Scripts\powershell-config\Shell\Aliases\unified_aliases.ps1"

Register-UnifiedModule 'scoop-completion' -InitializerBlock {
    Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion" -ErrorAction SilentlyContinue
} -LoadOnStartup $true

Register-UnifiedModule 'chocolatey-profile' -InitializerBlock {
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" -ErrorAction SilentlyContinue
} -LoadOnStartup $true

# Shell enhancements
Measure-Block 'Shell Enhancements' {
    # zoxide
    Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
    # gh completion
    Invoke-Expression (& { (gh completion -s powershell | Out-String) })
}

# Initialize core tools and modules
Measure-Block 'Core Initialization' {
    $VerbosePreference = 'Continue'
    Initialize-StartupModules
    $VerbosePreference = 'SilentlyContinue'
}

# Register System Management Utilities
Register-UnifiedModule 'SystemUpdater' -InitializerBlock { 
    Import-Module "$ProfileDir\Scripts\powershell-config\Apps\Updates\SystemUpdater.psd1" -Force
    . "$ProfileDir\Scripts\powershell-config\setAlias.ps1"
} -LoadOnStartup $true

# Register Network & Security Utilities
Register-UnifiedModule 'CheckWifiPassword' -InitializerBlock { . "$ProfileDir\Scripts\powershell-config\Helpers\checkWifiPassword.ps1" }
Register-UnifiedModule 'CloudflareWARP' -InitializerBlock { . "$ProfileDir\Scripts\powershell-config\Helpers\cloudflareWARP.ps1" }
Register-UnifiedModule 'Gpg' -InitializerBlock { . "$ProfileDir\Scripts\powershell-config\Helpers\gpg.ps1" }

# Register Developer Tools
Register-UnifiedModule 'Chtsh' -InitializerBlock { . "$ProfileDir\Scripts\powershell-config\chtsh.ps1" }
Register-UnifiedModule 'LinuxLike' -InitializerBlock { . "$ProfileDir\Scripts\powershell-config\Helpers\linuxLike.ps1" }

# Register Application Management
Register-UnifiedModule 'AppsManage' -InitializerBlock { . "$ProfileDir\Scripts\powershell-config\appsManage.ps1" }
Register-UnifiedModule 'Clean' -InitializerBlock { . "$ProfileDir\Scripts\powershell-config\Helpers\clean.ps1" }
Register-UnifiedModule 'Stylus' -InitializerBlock { . "$ProfileDir\Scripts\powershell-config\Helpers\stylus.ps1" }

# Create wrapper functions for module loading
$moduleAliases = @{
    'CheckWifiPassword' = 'Network tools'
    'CheckBattery' = 'System tools'
    'Chezmoi' = 'Configuration management'
    'Chtsh' = 'Developer tools'
    'AppsManage' = 'Application management'
    'LinuxLike' = 'Shell utilities'
    'Gpg' = 'Security tools'
    'CloudflareWARP' = 'Network tools'
    'Clean' = 'System maintenance'
    'Stylus' = 'Development tools'
}

foreach ($module in $moduleAliases.Keys) {
    Set-Item -Path "function:Use-$module" -Value ([scriptblock]::Create("Import-UnifiedModule '$module'"))
}

# Timing measurement was already initialized at the start

# Add Update-Profile function
function Update-Profile {    
    try {
        $profilePath = $PROFILE
        if (Test-Path $profilePath) {
            . $profilePath
            Write-Host "PowerShell profile successfully reloaded." -ForegroundColor Green
        } else {
            Write-Warning "Profile file not found at: $profilePath"
        }
    } catch {
        Write-Error "Failed to reload profile: $_"
    }
}

# Register UI and theming modules
Register-UnifiedModule 'Terminal-Icons' -InitializerBlock { Import-Module 'Terminal-Icons' } -LoadOnStartup $true -OnFailure { Write-Warning "Failed to load Terminal-Icons module" }
Register-UnifiedModule 'Catppuccin' -InitializerBlock { Import-Module 'Catppuccin' } -LoadOnStartup $true -OnFailure { Write-Warning "Failed to load Catppuccin module" }

# Configure Catppuccin theme
Register-UnifiedModule 'CatppuccinTheme' -InitializerBlock {
    Import-Module 'Catppuccin' -ErrorAction SilentlyContinue
    $Flavor = $Catppuccin.Mocha
    if ($Flavor) {
        $styleMap = @{
            Debug = $Flavor.Sky
            Error = $Flavor.Red
            ErrorAccent = $Flavor.Blue
            FormatAccent = $Flavor.Teal
            TableHeader = $Flavor.Rosewater
            Verbose = $Flavor.Yellow ?? '#FFFF00'
            Warning = $Flavor.Peach ?? '#FFA500'
        }
        
        foreach ($style in $styleMap.Keys) {
            $PSStyle.Formatting.$style = $styleMap[$style].Foreground()
        }
    }
} -LoadOnStartup $true -OnFailure { Write-Warning "Failed to initialize Catppuccin theme" }
Register-UnifiedModule 'Terminal-Icons' -InitializerBlock { Import-Module 'Terminal-Icons' } -LoadOnStartup $true -OnFailure { Write-Warning "Failed to load Terminal-Icons module" }
Register-UnifiedModule 'Catppuccin' -InitializerBlock { Import-Module 'Catppuccin' } -LoadOnStartup $true -OnFailure { Write-Warning "Failed to load Catppuccin module" }

# Register editor and completion modules
Register-UnifiedModule 'PSReadLine' -InitializerBlock {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    . "$ProfileDir\Scripts\powershell-config\Helpers\PSReadLine.ps1"
    Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete
} -LoadOnStartup $true -OnFailure { Write-Warning "Failed to initialize PSReadLine" }

# Register git and docker completions
if (Get-Command git -ErrorAction SilentlyContinue) {
    Register-UnifiedModule 'GitCompletion' -InitializerBlock { Import-Module posh-git } -LoadOnStartup $true -OnFailure { Write-Warning "Failed to load git completion" }
}

if (Get-Command docker -ErrorAction SilentlyContinue) {
    Register-UnifiedModule 'DockerCompletion' -InitializerBlock { Import-Module DockerCompletion } -LoadOnStartup $true -OnFailure { Write-Warning "Failed to load docker completion" }
}
$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $Env:_LANGFLOW_COMPLETE = "complete_powershell"
    $Env:_TYPER_COMPLETE_ARGS = $commandAst.ToString()
    $Env:_TYPER_COMPLETE_WORD_TO_COMPLETE = $wordToComplete
    langflow | ForEach-Object {
        $commandArray = $_ -Split ":::"
        $command = $commandArray[0]
        $helpString = $commandArray[1]
        [System.Management.Automation.CompletionResult]::new(
            $command, $command, 'ParameterValue', $helpString)
    }
    $Env:_LANGFLOW_COMPLETE = ""
    $Env:_TYPER_COMPLETE_ARGS = ""
    $Env:_TYPER_COMPLETE_WORD_TO_COMPLETE = ""
}
Register-ArgumentCompleter -Native -CommandName langflow -ScriptBlock $scriptblock

# Display timing results for key operations
$globalStopwatch.Stop()
Write-Host "Profile loaded in $($globalStopwatch.ElapsedMilliseconds)ms" -ForegroundColor Cyan


function Import-ScriptFile {
    param([string]$Path)
    if (Test-Path $Path) {
        try {
            . $Path
        } catch {
            Write-Warning "Failed to load $Path : $_"
        }
    } else {
        Write-Warning "Script file not found: $Path"
    }
}

# Chocolatey tab completion is handled by the chocolatey-profile module registration above
