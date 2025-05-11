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

# Load core configurations
Measure-Block 'Core Setup' {    # Load aliases first as they're used by other modules
    . "$ProfileDir\Scripts\powershell-config\Shell\Aliases\unified_aliases.ps1"
    
    # Initialize startup tools
    Initialize-StartupTools
    
    # Configure Starship if available
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        $ENV:STARSHIP_CONFIG = "$ProfileDir\starship.toml"
        $ENV:STARSHIP_CACHE = "$ProfileDir\.starship\cache"
        Invoke-Expression $(&starship init powershell --print-full-init | Out-String)
    }
}

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

# Create module use functions
$script:moduleAliases = @{
    'CheckWifiPassword' = 'Network tools'
    'Chtsh' = 'Developer tools'
    'AppsManage' = 'Application management'
    'LinuxLike' = 'Shell utilities'
    'Gpg' = 'Security tools'
    'CloudflareWARP' = 'Network tools'
    'Clean' = 'System maintenance'
    'Stylus' = 'Development tools'
}

# Register module functions
foreach ($module in $script:moduleAliases.Keys) {
    $functionName = "Use-$module"
    $scriptBlock = {
        try {
            $moduleName = $args[0]
            Import-UnifiedModule $moduleName
            Write-Host "Loaded $moduleName module" -ForegroundColor Green
        } catch {
            Write-Error "Failed to load module: $_"
        }
    }.GetNewClosure()

    # Create function that automatically passes the module name
    $wrapper = [ScriptBlock]::Create(@"
        function global:$functionName { 
            `$scriptBlock.InvokeWithContext(`$null, [System.Management.Automation.PSVariable[]]@(), @('$module'))
        }
"@)
    
    . $wrapper
}

# Timing measurement was already initialized at the start

# Profile management functions
function Reset-ProfileState {
    [CmdletBinding()]
    param([switch]$Quiet)
    
    # Status tracking
    $status = @{
        ModulesRemoved = @()
        EnvVarsCleared = @()
        JobsRemoved = 0
    }
    
    # Remove background jobs
    $status.JobsRemoved = (Get-Job).Count
    Get-Job | Remove-Job -Force -ErrorAction SilentlyContinue
    
    # Remove modules
    @(
        'PSReadLine', 'Catppuccin', 'Terminal-Icons', 'posh-git',
        'DockerCompletion', 'CompletionPredictor'
    ) | ForEach-Object {
        if (Get-Module $_ -ErrorAction SilentlyContinue) {
            Remove-Module $_ -Force -ErrorAction SilentlyContinue
            $status.ModulesRemoved += $_
        }
    }
    
    # Clear environment variables
    @(
        '_LANGFLOW_COMPLETE', '_TYPER_COMPLETE_ARGS', '_TYPER_COMPLETE_WORD_TO_COMPLETE',
        'STARSHIP_SHELL', 'STARSHIP_SESSION_KEY'
    ) | ForEach-Object {
        if (Test-Path "env:$_") {
            Remove-Item "env:$_" -ErrorAction SilentlyContinue
            $status.EnvVarsCleared += $_
        }
    }
    
    # Report status unless quiet
    if (-not $Quiet -and ($status.ModulesRemoved.Count -gt 0 -or $status.JobsRemoved -gt 0)) {
        Write-Host "Profile state reset:" -ForegroundColor Blue
        if ($status.ModulesRemoved) { Write-Host " - Removed modules: $($status.ModulesRemoved -join ', ')" -ForegroundColor Gray }
        if ($status.EnvVarsCleared) { Write-Host " - Cleared variables: $($status.EnvVarsCleared -join ', ')" -ForegroundColor Gray }
        if ($status.JobsRemoved) { Write-Host " - Removed $($status.JobsRemoved) background jobs" -ForegroundColor Gray }
    }
}

function Update-Profile {    
    [CmdletBinding()]
    param()
    
    try {
        # Clean up state
        Reset-ProfileState -Quiet
        
        # Reload profile
        if (Test-Path $PROFILE) {
            $timer = [System.Diagnostics.Stopwatch]::StartNew()
            . $PROFILE
            $timer.Stop()
            
            Write-Host "`n✓ Profile reloaded successfully" -ForegroundColor Green
            Write-Host "  Time: $($timer.ElapsedMilliseconds)ms" -ForegroundColor Gray
            
            # Verify critical modules
            $criticalModules = @('PSReadLine', 'Terminal-Icons')
            $missing = $criticalModules | Where-Object { -not (Get-Module $_) }
            if ($missing) {
                Write-Warning "Some critical modules did not load: $($missing -join ', ')"
            }
        } else {
            Write-Warning "Profile not found at: $PROFILE"
            return
        }
    } catch {
        Write-Error "Failed to reload profile: $_"
        Write-Host "Try these steps:" -ForegroundColor Yellow
        Write-Host " 1. Restart PowerShell: pwsh -NoProfile" -ForegroundColor Gray
        Write-Host " 2. Then run: . `$PROFILE" -ForegroundColor Gray
    }
}

# Configure UI and theming
Register-UnifiedModule 'UI' -InitializerBlock {
    # Import UI modules if available
    $uiModules = @{
        'Terminal-Icons' = $null
        'Catppuccin' = {
            param($Module)
            if ($PSStyle -and $Module.Mocha) {
                @{
                    Debug = $Module.Mocha.Sky
                    Error = $Module.Mocha.Red
                    ErrorAccent = $Module.Mocha.Blue
                    FormatAccent = $Module.Mocha.Teal
                    TableHeader = $Module.Mocha.Rosewater
                    Verbose = $Module.Mocha.Yellow ?? '#FFFF00'
                    Warning = $Module.Mocha.Peach ?? '#FFA500'
                }.GetEnumerator() | ForEach-Object {
                    $PSStyle.Formatting.$($_.Key) = $_.Value.Foreground()
                }
            }
        }
    }
    
    foreach ($module in $uiModules.GetEnumerator()) {
        try {
            $imported = Import-Module $module.Key -PassThru -ErrorAction Stop
            if ($imported -and $module.Value) { 
                & $module.Value $imported
            }
        } catch {
            Write-Warning "Failed to load $($module.Key): $_"
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
# Register completion for CLI tools
Register-UnifiedModule 'Completions' -InitializerBlock {
    # Register langflow completion if available
    if (Get-Command langflow -ErrorAction SilentlyContinue) {
        $langflowCompleter = {
            param($wordToComplete, $commandAst, $cursorPosition)
            try {
                $env:_LANGFLOW_COMPLETE = "complete_powershell"
                $env:_TYPER_COMPLETE_ARGS = $commandAst.ToString()
                $env:_TYPER_COMPLETE_WORD_TO_COMPLETE = $wordToComplete
                
                $results = langflow | ForEach-Object {
                    $parts = $_ -split ":::", 2
                    if ($parts.Length -eq 2) {
                        [System.Management.Automation.CompletionResult]::new(
                            $parts[0], 
                            $parts[0], 
                            'ParameterValue', 
                            $parts[1]
                        )
                    }
                }
                $results
            }
            finally {
                Remove-Item 'env:_LANGFLOW_COMPLETE', 'env:_TYPER_COMPLETE_ARGS', 'env:_TYPER_COMPLETE_WORD_TO_COMPLETE' -ErrorAction SilentlyContinue
            }
        }
        Register-ArgumentCompleter -Native -CommandName langflow -ScriptBlock $langflowCompleter
    }
}

# Display timing results for key operations
$globalStopwatch.Stop()
Write-Host "Profile loaded in $($globalStopwatch.ElapsedMilliseconds)ms" -ForegroundColor Cyan


# End of profile configuration
