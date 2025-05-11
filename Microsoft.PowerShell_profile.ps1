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

# Load core modules with error handling
Measure-Block 'Core Modules' {
    try {
        Import-Module ProfileCore -Force -ErrorAction Stop
        Write-Host "Core modules loaded successfully" -ForegroundColor Green
    } catch {
        Write-Host "Failed to load core modules: $_" -ForegroundColor Red
        Write-Host "Some features may not be available" -ForegroundColor Yellow
    }
}

# Load core configurations with error handling
Measure-Block 'Shell Setup' {
    $aliasPath = "$ProfileDir\Scripts\powershell-config\Shell\Aliases\unified_aliases.ps1"
    if (Test-Path $aliasPath) {
        try {
            . $aliasPath
            Write-Host "Aliases loaded successfully" -ForegroundColor Green
        } catch {
            Write-Host "Failed to load aliases: $_" -ForegroundColor Red
        }
    }
}

# Configure Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Measure-Block 'Starship Init' {
        $ENV:STARSHIP_CONFIG = "$ProfileDir\starship.toml"
        $ENV:STARSHIP_CACHE = "$ProfileDir\.starship\cache"
        Invoke-Expression $(&starship init powershell --print-full-init | Out-String)
    }
}

# Configure shell enhancements asynchronously
Measure-Block 'Shell Enhancements' -Async {
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

# PSReadLine configuration
Measure-Block 'PSReadLine Setup' {
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

# Initialize startup modules
Measure-Block 'Module Initialization' {
    Initialize-StartupModules
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
