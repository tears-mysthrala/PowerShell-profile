# Initialize profiling
$script:profileTiming = @{}
$globalStopwatch = [System.Diagnostics.Stopwatch]::StartNew()

function Measure-Block {
    param(
        [string]$Name,
        [scriptblock]$Block,
        [switch]$Async
    )
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        if ($Async) {
            $job = Start-Job -ScriptBlock $Block
            $script:backgroundJobs += @{ Name = $Name; Job = $job }
        } else {
            & $Block
        }
    } finally {
        $sw.Stop()
        if (-not $Async) {
            $script:profileTiming[$Name] = $sw.ElapsedMilliseconds
        }
    }
}

# Set essential environment variables
$ProfileDir = Split-Path -Parent $PROFILE
Measure-Block 'Environment Setup' {
    # Encoding settings
    $env:PYTHONIOENCODING = 'utf-8'
    [System.Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
    
    # Module path
    $customModulePath = "$ProfileDir\Modules"
    if ($env:PSModulePath -notlike "*$customModulePath*") {
        $env:PSModulePath = "$customModulePath;" + $env:PSModulePath
    }
    
    # Editor preferences with fallbacks
    $editors = @(
        @{ Command = 'nvim'; EnvVar = 'EDITOR' },
        @{ Command = 'code'; EnvVar = 'VISUAL' },
        @{ Command = 'notepad'; EnvVar = 'EDITOR' }
    )
    
    foreach ($editor in $editors) {
        if (Get-Command $editor.Command -ErrorAction SilentlyContinue) {
            Set-Item "env:$($editor.EnvVar)" -Value $editor.Command
            break
        }
    }
    
    # Performance optimizations
    $env:POWERSHELL_TELEMETRY_OPTOUT = 1
    $env:POWERSHELL_UPDATECHECK = 'Off'
}

# If is in non-interactive shell, then return early
if (!([Environment]::UserInteractive -and -not $([Environment]::GetCommandLineArgs() | Where-Object { $_ -like '-NonI*' }))) {
    return
}

# Initialize background jobs array
$script:backgroundJobs = @()

# Load core configuration
Measure-Block 'Core Setup' {
    try {        # Import core modules
        $originalPreferences = @{
            Warning = $WarningPreference
            Verbose = $VerbosePreference
            Information = $InformationPreference
        }
        
        # Suppress all non-critical messages
        $WarningPreference = 'SilentlyContinue'
        $VerbosePreference = 'SilentlyContinue'
        $InformationPreference = 'SilentlyContinue'
        
        Import-Module ProfileManagement -Force -ErrorAction Stop
        Import-Module ProfileCore -Force -ErrorAction Stop
        
        # Restore preferences
        $WarningPreference = $originalPreferences.Warning
        $VerbosePreference = $originalPreferences.Verbose
        $InformationPreference = $originalPreferences.Information
        Write-Host "Core module loaded successfully" -ForegroundColor Green        # Load common utilities
        $utilsPath = "$ProfileDir\Core\Utils"
        if (Test-Path $utilsPath) {
            # Create a hashtable to store already loaded modules
            $loadedUtilModules = @{}
              Get-ChildItem -Path $utilsPath -Filter "*.ps1" | ForEach-Object {
                $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
                if (-not $loadedUtilModules.ContainsKey($moduleName)) {
                    $scriptBlock = {
                        param($Path)
                        # Save all preference variables
                        $origPrefs = @{
                            Warning = $global:WarningPreference
                            Verbose = $global:VerbosePreference
                            Information = $global:InformationPreference
                        }
                        
                        # Suppress all warnings and verbose output
                        $global:WarningPreference = 'SilentlyContinue'
                        $global:VerbosePreference = 'SilentlyContinue'
                        $global:InformationPreference = 'SilentlyContinue'
                        
                        try {
                            New-Module -Name $([System.IO.Path]::GetFileNameWithoutExtension($Path)) -ScriptBlock {
                                param($ScriptPath)
                                Set-StrictMode -Version Latest
                                $ErrorActionPreference = 'Stop'
                                . $ScriptPath
                                Export-ModuleMember -Function * -Alias *
                            } -ArgumentList $Path | Import-Module -Global -WarningAction SilentlyContinue
                        }
                        finally {
                            # Restore all preference variables
                            $global:WarningPreference = $origPrefs.Warning
                            $global:VerbosePreference = $origPrefs.Verbose
                            $global:InformationPreference = $origPrefs.Information
                        }
                    }
                    
                    & $scriptBlock -Path $_.FullName
                    $loadedUtilModules[$moduleName] = $true
                }
            }
            Write-Host "Utility modules loaded successfully" -ForegroundColor Green
        }
    } catch {
        Write-Host "Failed to load core modules: $_" -ForegroundColor Red
        Write-Host "Some features may not be available" -ForegroundColor Yellow
    }
}

# Configure shell environment
Measure-Block 'Shell Setup' {
    # Load aliases
    $aliasPath = "$ProfileDir\Scripts\Shell\unified_aliases.ps1"
    if (Test-Path $aliasPath) {
        try {
            # Temporarily suppress warnings
            $WarningPreference = 'SilentlyContinue'
            $VerbosePreference = 'SilentlyContinue'
            . $aliasPath
            # Restore preferences
            $WarningPreference = 'Continue'
            $VerbosePreference = 'Continue'
            Write-Host "Aliases loaded successfully" -ForegroundColor Green
        } catch {
            Write-Host "Failed to load aliases: $_" -ForegroundColor Red
        }
    }
      # Initialize shell enhancements
    # Load Terminal-Icons module for file icons
    if (Get-Module -ListAvailable Terminal-Icons) {
        Import-Module Terminal-Icons -ErrorAction SilentlyContinue
    }
    
    # Initialize starship prompt
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        $ENV:STARSHIP_CONFIG = "$ProfileDir\Config\starship.toml"
        $ENV:STARSHIP_CACHE = "$ProfileDir\.starship\cache"
        Invoke-Expression $(&starship init powershell --print-full-init | Out-String)
    }
    
    # Configure PSReadLine
    $PSReadLineOptions = @{
        PredictionSource = 'HistoryAndPlugin'
        PredictionViewStyle = 'ListView'
        HistorySearchCursorMovesToEnd = $true
        Colors = @{
            Command = '#8BE9FD'
            Number = '#BD93F9'
            Member = '#50FA7B'
            Parameter = '#FFB86C'
            Comment = '#6272A4'
            String = '#F1FA8C'
        }
    }
    
    Set-PSReadLineOption @PSReadLineOptions
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# Initialize shell tools asynchronously
Measure-Block 'Shell Tools' -Async {
    # Zoxide directory jumper
    if (Get-Command zoxide -ErrorAction SilentlyContinue) {
        $env:_ZO_DATA_DIR = "$using:ProfileDir\.zo"
        Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
    }
    
    # GitHub CLI completion
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        Invoke-Expression (& { (gh completion -s powershell | Out-String) })
    }
}

# Initialize startup modules
Measure-Block 'Module Initialization' {
    Initialize-PSModules
}

# Wait for background jobs and record timing
$globalStopwatch.Stop()
$script:backgroundJobs | ForEach-Object {
    $job = $_.Job
    $name = $_.Name
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $null = $job | Wait-Job | Receive-Job
    $sw.Stop()
    $script:profileTiming[$name] = $sw.ElapsedMilliseconds
}

# Report startup performance
$totalTime = $globalStopwatch.ElapsedMilliseconds
Write-Host "`nProfile loaded in ${totalTime}ms" -ForegroundColor Cyan
$script:profileTiming.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
    Write-Host "$($_.Key): $($_.Value)ms" -ForegroundColor Gray
}
