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

# Set essential environment variables
$env:PYTHONIOENCODING = 'utf-8'
if (Get-Command nvim -ErrorAction SilentlyContinue) { $env:EDITOR = 'nvim' }
if (Get-Command code -ErrorAction SilentlyContinue) { $env:VISUAL = 'code' }

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

# Initialize core components
$VerbosePreference = 'SilentlyContinue'
Initialize-StartupModules

# Initialize shell enhancements if available
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    $env:_ZO_DATA_DIR = "$ProfileDir\.zo"
    Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
}
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (gh completion -s powershell | Out-String) })
}

# Register utility modules (lazy-loaded)
@{
    'SystemUpdater' = @{ 
        Block = { 
            Import-Module "$ProfileDir\Scripts\powershell-config\Apps\Updates\SystemUpdater.psd1" -Force
            . "$ProfileDir\Scripts\powershell-config\setAlias.ps1"
        }
        Category = 'System'
    }
    'CheckWifiPassword' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\Helpers\checkWifiPassword.ps1" }; Category = 'Network' }
    'CloudflareWARP' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\Helpers\cloudflareWARP.ps1" }; Category = 'Network' }
    'Gpg' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\Helpers\gpg.ps1" }; Category = 'Security' }
    'Chtsh' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\chtsh.ps1" }; Category = 'Dev' }
    'LinuxLike' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\Helpers\linuxLike.ps1" }; Category = 'Shell' }
    'AppsManage' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\appsManage.ps1" }; Category = 'Apps' }
    'Clean' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\Helpers\clean.ps1" }; Category = 'System' }
    'Stylus' = @{ Block = { . "$ProfileDir\Scripts\powershell-config\Helpers\stylus.ps1" }; Category = 'Dev' }
}.GetEnumerator() | ForEach-Object {
    Register-UnifiedModule $_.Key -InitializerBlock $_.Value.Block
}

# Create wrapper functions for module loading
$moduleAliases = @{
    'CheckWifiPassword' = 'Network tools'
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

# Add Update-Profile function with proper state cleanup
function Update-Profile {    
    try {
        # Clean up state
        Remove-Module -Name PSReadLine, Catppuccin, Terminal-Icons -ErrorAction SilentlyContinue
        Get-Job | Remove-Job -Force -ErrorAction SilentlyContinue
        
        # Reload profile
        if (Test-Path $PROFILE) {
            . $PROFILE
            Write-Host "PowerShell profile successfully reloaded." -ForegroundColor Green
        } else {
            Write-Warning "Profile file not found at: $PROFILE"
        }
    } catch {
        Write-Error "Failed to reload profile: $_"
        Write-Host "Try restarting your PowerShell session instead." -ForegroundColor Yellow
    }
}

# Register essential UI modules
Register-UnifiedModule 'UI' -InitializerBlock {
    Import-Module 'Terminal-Icons' -ErrorAction SilentlyContinue
    if (Import-Module 'Catppuccin' -PassThru) {
        try {
            $Flavor = $Catppuccin.Mocha
            if ($Flavor -and $PSStyle) {
                $styleMap = @{
                    Debug = $Flavor.Sky
                    Error = $Flavor.Red
                    ErrorAccent = $Flavor.Blue
                    FormatAccent = $Flavor.Teal
                    TableHeader = $Flavor.Rosewater
                    Verbose = $Flavor.Yellow ?? '#FFFF00'
                    Warning = $Flavor.Peach ?? '#FFA500'
                }
                foreach ($style in $styleMap.GetEnumerator()) {
                    $PSStyle.Formatting.$($style.Key) = $style.Value.Foreground()
                }
            }
        } catch {
            Write-Warning "Failed to apply theme: $_"
        }
    }
} -LoadOnStartup $true

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
# Only register langflow completion if the command exists
if (Get-Command langflow -ErrorAction SilentlyContinue) {
    $langflowCompleter = {
        param($wordToComplete, $commandAst, $cursorPosition)
        
        try {
            $env:_LANGFLOW_COMPLETE = "complete_powershell"
            $env:_TYPER_COMPLETE_ARGS = $commandAst.ToString()
            $env:_TYPER_COMPLETE_WORD_TO_COMPLETE = $wordToComplete
            
            langflow | ForEach-Object {
                $command, $helpString = $_ -split ":::"
                [System.Management.Automation.CompletionResult]::new(
                    $command, $command, 'ParameterValue', $helpString)
            }
        }
        finally {
            $env:_LANGFLOW_COMPLETE = ""
            $env:_TYPER_COMPLETE_ARGS = ""
            $env:_TYPER_COMPLETE_WORD_TO_COMPLETE = ""
        }
    }
    
    Register-ArgumentCompleter -Native -CommandName langflow -ScriptBlock $langflowCompleter
}

# Display timing results for key operations
$globalStopwatch.Stop()
Write-Host "Profile loaded in $($globalStopwatch.ElapsedMilliseconds)ms" -ForegroundColor Cyan


# End of profile configuration
