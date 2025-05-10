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

# Register System Utilities
Register-UnifiedModule 'SystemUpdater' -InitializerBlock { 
    Import-Module "$ProfileDir\Scripts\powershell-config\Apps\Updates\SystemUpdater.psd1" -Force
    . "$ProfileDir\Scripts\powershell-config\setAlias.ps1"
} -LoadOnStartup $true
Register-UnifiedModule 'CheckWifiPassword' -InitializerBlock { . "$ProfileDir\Scripts\powershell-config\Helpers\checkWifiPassword.ps1" }
Register-UnifiedModule 'Chtsh' -InitializerBlock { . "$env:USERPROFILE/OneDrive\Documents/PowerShell/Scripts/powershell-config/chtsh.ps1" }
Register-UnifiedModule 'AppsManage' -InitializerBlock { . "$env:USERPROFILE/OneDrive\Documents/PowerShell/Scripts/powershell-config/appsManage.ps1" }

# Register Additional Utilities
Register-UnifiedModule 'LinuxLike' -InitializerBlock { . "$ProfileDir\Scripts\powershell-config\Helpers\linuxLike.ps1" }
Register-UnifiedModule 'Gpg' -InitializerBlock { . "$ProfileDir\Scripts\powershell-config\Helpers\gpg.ps1" }
Register-UnifiedModule 'CloudflareWARP' -InitializerBlock { . "$ProfileDir\Scripts\powershell-config\Helpers\cloudflareWARP.ps1" }
Register-UnifiedModule 'Clean' -InitializerBlock { . "$ProfileDir\Scripts\powershell-config\Helpers\clean.ps1" }
Register-UnifiedModule 'Stylus' -InitializerBlock { . "$ProfileDir\Scripts\powershell-config\Helpers\stylus.ps1" }
Register-UnifiedModule 'Utils' -InitializerBlock { . "$ProfileDir\Scripts\powershell-config\Helpers\utils.ps1" }

# Create wrapper functions for module loading
function Use-CheckWifiPassword { Import-UnifiedModule 'CheckWifiPassword' }
function Use-CheckBattery { Import-UnifiedModule 'CheckBattery' }
function Use-Chezmoi { Import-UnifiedModule 'Chezmoi' }
function Use-Chtsh { Import-UnifiedModule 'Chtsh' }
function Use-AppsManage { Import-UnifiedModule 'AppsManage' }
function Use-LinuxLike { Import-UnifiedModule 'LinuxLike' }
function Use-Gpg { Import-UnifiedModule 'Gpg' }
function Use-CloudflareWARP { Import-UnifiedModule 'CloudflareWARP' }
function Use-Clean { Import-UnifiedModule 'Clean' }
function Use-Stylus { Import-UnifiedModule 'Stylus' }
function Use-Utils { Import-UnifiedModule 'Utils' }

# Group related imports
$modulesToImport = @(
    'Terminal-Icons',
    'posh-wakatime',
    'CompletionPredictor',
    'Catppuccin'
)


# Add timing measurement
# Already initialized at the start

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

# Register Catppuccin theme configuration
Register-UnifiedModule 'CatppuccinTheme' -InitializerBlock {
    if (Get-Module Catppuccin) {
        try {
            $Flavor = $Catppuccin.Mocha
            if ($Flavor) {
                $PSStyle.Formatting.Debug = $Flavor.Sky.Foreground()
                $PSStyle.Formatting.Error = $Flavor.Red.Foreground()
                $PSStyle.Formatting.ErrorAccent = $Flavor.Blue.Foreground()
                $PSStyle.Formatting.FormatAccent = $Flavor.Teal.Foreground()
                $PSStyle.Formatting.TableHeader = $Flavor.Rosewater.Foreground()
                $PSStyle.Formatting.Verbose = if($Flavor.Yellow) { $Flavor.Yellow.Foreground() } else { '#FFFF00' }
                $PSStyle.Formatting.Warning = if($Flavor.Peach) { $Flavor.Peach.Foreground() } else { '#FFA500' }
            }
        } catch {
            Write-Warning "Failed to apply Catppuccin theme: $_"
        }
    }
} -LoadOnStartup $true -OnFailure { Write-Warning "Failed to initialize Catppuccin theme" }

# Register optional modules
Register-UnifiedModule 'Terminal-Icons' -InitializerBlock { Import-Module 'Terminal-Icons' } -OnFailure { Write-Warning "Failed to load Terminal-Icons module" }
Register-UnifiedModule 'posh-wakatime' -InitializerBlock { Import-Module 'posh-wakatime' } -OnFailure { Write-Warning "Failed to load posh-wakatime module" }
Register-UnifiedModule 'CompletionPredictor' -InitializerBlock { Import-Module 'CompletionPredictor' } -OnFailure { Write-Warning "Failed to load CompletionPredictor module" }
Register-UnifiedModule 'Catppuccin' -InitializerBlock { Import-Module 'Catppuccin' } -OnFailure { Write-Warning "Failed to load Catppuccin module" }

# Register PSReadLine with startup priority
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

# Add at the end of the profile
$globalStopwatch.Stop()

# Display timing results for key operations
# Remove these lines from the end of the file:
# $profileTiming.GetEnumerator() | Where-Object { $_.Key -in @('Core Initialization', 'Shell Enhancements', 'Starship') } | Sort-Object Value -Descending | ForEach-Object {
#     Write-Host ("$($_.Key): $($_.Value)ms").PadRight(40) -NoNewline
#     Write-Host "[$('=' * [math]::Min(40, [math]::Floor($_.Value / 10)))]" -ForegroundColor Yellow
# }
# 
# Write-Host "Total profile load time: $($globalStopwatch.ElapsedMilliseconds)ms" -ForegroundColor Cyan


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

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
