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
        }
        else {
            & $Block
        }
    }
    finally {
        $sw.Stop()
        if (-not $Async) {
            $script:profileTiming[$Name] = $sw.ElapsedMilliseconds
        }
    }
}

# Set essential environment variables
$ProfileDir = Split-Path -Parent $PROFILE
Measure-Block 'Environment Setup' {
    # Use cached environment settings if available
    $envCachePath = "$ProfileDir\Config\env-cache.clixml"
    
    if (Test-Path $envCachePath) {
        $cachedEnv = Import-Clixml $envCachePath
        foreach ($key in $cachedEnv.Keys) {
            Set-Item "env:$key" -Value $cachedEnv[$key]
        }
        [System.Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
    }
    else {
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
        
        # Cache the environment settings
        $envToCache = @{
            PYTHONIOENCODING = $env:PYTHONIOENCODING
            EDITOR = $env:EDITOR
            VISUAL = $env:VISUAL
            POWERSHELL_TELEMETRY_OPTOUT = $env:POWERSHELL_TELEMETRY_OPTOUT
            POWERSHELL_UPDATECHECK = $env:POWERSHELL_UPDATECHECK
        }
        $envToCache | Export-Clixml -Path $envCachePath
    }
}

# If is in non-interactive shell, then return early
if (!([Environment]::UserInteractive -and -not $([Environment]::GetCommandLineArgs() | Where-Object { $_ -like '-NonI*' }))) {
    return
}

# Initialize background jobs array
$global:backgroundJobs = @()
$script:backgroundJobs = @()
$global:profileTiming = @{}
$script:profileTiming = @{}

# By default, show info logs unless suppressed explicitly
$global:ProfileSuppressInfoLogs = $false

# Suppress info logs if not loaded with --no-supress
if ($MyInvocation.Line -notmatch '--no-supress') {
    $global:ProfileSuppressInfoLogs = $true
}

# Load core configuration
$global:WarningPreference = $global:VerbosePreference = $global:InformationPreference = 'SilentlyContinue'

Measure-Block 'Core Setup' {
    try {
        # Create module cache directory if it doesn't exist
        $moduleCacheDir = Join-Path $ProfileDir 'Config\ModuleCache'
        if (-not (Test-Path $moduleCacheDir)) {
            New-Item -ItemType Directory -Path $moduleCacheDir -Force | Out-Null
        }
        
        # Import ModuleInstaller only when needed
        $global:LazyLoadModules = {
            Import-Module "$ProfileDir\Core\ModuleInstaller.ps1" -Force -ErrorAction Stop
            Install-RequiredModules
        }
        
        # Create lazy-loading proxy functions for commonly used module commands
        $lazyLoadCommands = @{
            'Get-GitStatus' = 'posh-git'
            'Invoke-Fzf' = 'PSFzf'
            'Set-TerminalIcon' = 'Terminal-Icons'
        }
        
        foreach ($command in $lazyLoadCommands.Keys) {
            $moduleName = $lazyLoadCommands[$command]
            $sb = {
                param($cmd, $module)
                # Remove the proxy function
                Remove-Item "Function:\$cmd"
                # Load the actual module
                Import-Module $module -ErrorAction Stop
                # Call the original command with the same arguments
                $commandInfo = Get-Command $cmd
                & $commandInfo @args
            }.GetNewClosure()
            
            Set-Item "Function:\$command" -Value $sb
        }
        
        Import-Module ProfileManagement -Force -ErrorAction Stop
        Import-Module ProfileCore -Force -ErrorAction Stop
        
        # Restore preferences
        $WarningPreference = $originalPreferences.Warning
        $VerbosePreference = $originalPreferences.Verbose
        $InformationPreference = $originalPreferences.Information
        # Write-Host "Core module loaded successfully" -ForegroundColor Green        # Load common utilities with optimized caching
        $utilsPath = "$ProfileDir\Core\Utils"
        $utilsCachePath = "$ProfileDir\Config\utils-cache.clixml"
        
        if (Test-Path $utilsPath) {
            # Initialize cache
            $utilsCache = @{}
            if (Test-Path $utilsCachePath) {
                $utilsCache = Import-Clixml -Path $utilsCachePath
            }
            
            # Load utilities sequentially with optimized caching
            Get-ChildItem -Path $utilsPath -Filter "*.ps1" | ForEach-Object {
                $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
                $filePath = $_.FullName
                
                # Check if module needs loading based on cache
                $needsLoading = $true
                if ($utilsCache.ContainsKey($moduleName)) {
                    $cached = $utilsCache[$moduleName]
                    if ((Get-Item $filePath).LastWriteTime -eq $cached.LastWriteTime) {
                        $needsLoading = $false
                        # Try to import from cache
                        try {
                            $cachedModule = Get-Module -Name $moduleName -ErrorAction SilentlyContinue
                            if (-not $cachedModule) {
                                $needsLoading = $true
                            }
                        } catch {
                            $needsLoading = $true
                        }
                    }
                }
                
                if ($needsLoading) {
                    try {
                        # Load module directly
                        $scriptBlock = {
                            param($ScriptPath)
                            Set-StrictMode -Version Latest
                            . $ScriptPath
                        }
                        New-Module -Name $moduleName -ScriptBlock $scriptBlock -ArgumentList $filePath |
                            Import-Module -Global -WarningAction SilentlyContinue
                    
                        # Update cache
                        $utilsCache[$moduleName] = @{
                            LastWriteTime = (Get-Item $filePath).LastWriteTime
                            Path = $filePath
                        }
                    } catch {
                        Write-Warning "Failed to load utility module $moduleName`: $_"
                    }
                }
            }

            # Save updated cache
            $utilsCache | Export-Clixml -Path $utilsCachePath
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
            # Temporarily suppress warnings (log this action)
            if (-not $global:ProfileSuppressInfoLogs) {
                Write-Host "[INFO] Suppressing warnings and verbose output for alias loading..." -ForegroundColor Yellow
            }
            $WarningPreference = 'SilentlyContinue'
            $VerbosePreference = 'SilentlyContinue'
            try {
                . $aliasPath
            }
            finally {
                # Restore preferences
                $WarningPreference = 'Continue'
                $VerbosePreference = 'Continue'
            }
            # Write-Host "Aliases loaded successfully" -ForegroundColor Green
        }
        catch {
            # Write-Host "Failed to load aliases: $_" -ForegroundColor Red
        }
    }
    # Initialize shell enhancements
    # Load Terminal-Icons module for file icons
    if (Get-Module -ListAvailable Terminal-Icons) {
        # Import Terminal-Icons, but log if suppressed errors might occur
        if (-not $global:ProfileSuppressInfoLogs) {
            Write-Host "[INFO] Importing Terminal-Icons with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
        }
        Import-Module Terminal-Icons -ErrorAction SilentlyContinue
    }
    
    # Initialize starship prompt
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        # Initialize starship prompt, log if command is not found
        $ENV:STARSHIP_CONFIG = "$ProfileDir\Config\starship.toml"
        $ENV:STARSHIP_CACHE = "$ProfileDir\.starship\cache"
        try {
            Invoke-Expression $(&starship init powershell --print-full-init | Out-String)
        }
        catch {
            if (-not $global:ProfileSuppressInfoLogs) {
                Write-Host "[WARN] Failed to initialize starship prompt: $_" -ForegroundColor Yellow
            }
        }
    }
    else {
        if (-not $global:ProfileSuppressInfoLogs) {
            Write-Host "[INFO] Starship not found, skipping prompt initialization." -ForegroundColor Yellow
        }
    }
    
    # Configure PSReadLine
    $PSReadLineOptions = @{
        PredictionSource              = 'HistoryAndPlugin'
        PredictionViewStyle           = 'ListView'
        HistorySearchCursorMovesToEnd = $true
        Colors                        = @{
            Command   = '#8BE9FD'
            Number    = '#BD93F9'
            Member    = '#50FA7B'
            Parameter = '#FFB86C'
            Comment   = '#6272A4'
            String    = '#F1FA8C'
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

# --- Catppuccin Theme Setup ---
function Test-CatppuccinPresent {
    $module = Get-Module -ListAvailable Catppuccin | Sort-Object Version -Descending | Select-Object -First 1
    if ($module) { return $true }
    $customPaths = @(
        "$env:USERPROFILE\\Documents\\PowerShell\\Modules\\Catppuccin",
        "$env:USERPROFILE\\Documents\\WindowsPowerShell\\Modules\\Catppuccin",
        "$env:USERPROFILE\\OneDrive\\Documents\\PowerShell\\Modules\\Catppuccin"
    )
    foreach ($path in $customPaths) {
        if (Test-Path $path) {
            $files = Get-ChildItem -Path $path -Include *.psd1, *.psm1 -File -ErrorAction SilentlyContinue
            if ($files) {
                return $true
            }
        }
    }
    return $false
}

if (-not (Test-CatppuccinPresent)) {
    try {
        if (Get-Command git -ErrorAction SilentlyContinue) {
            git clone https://github.com/catppuccin/powershell.git "$HOME\Documents\PowerShell\Modules\Catppuccin"
            Write-Host "Catppuccin module cloned successfully." -ForegroundColor Green
        }
        else {
            Write-Host "Git is not installed. Please install Git to clone Catppuccin module." -ForegroundColor Yellow
        }
    }
    catch {
        # Silently ignore if not found in repositories
    }
}
else {
    # Catppuccin module already present.
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
Write-Host "Profile loaded in ${totalTime}ms" -ForegroundColor Cyan
$script:profileTiming.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
    Write-Host "$($_.Key): $($_.Value)ms" -ForegroundColor Green
}

#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58
Import-Module PSReadLine
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete
$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $Env:_MOV_CLI_COMPLETE = "complete_powershell"
    $Env:_TYPER_COMPLETE_ARGS = $commandAst.ToString()
    $Env:_TYPER_COMPLETE_WORD_TO_COMPLETE = $wordToComplete
    mov-cli | ForEach-Object {
        $commandArray = $_ -Split ":::"
        $command = $commandArray[0]
        $helpString = $commandArray[1]
        [System.Management.Automation.CompletionResult]::new(
            $command, $command, 'ParameterValue', $helpString)
    }
    $Env:_MOV_CLI_COMPLETE = ""
    $Env:_TYPER_COMPLETE_ARGS = ""
    $Env:_TYPER_COMPLETE_WORD_TO_COMPLETE = ""
}
Register-ArgumentCompleter -Native -CommandName mov-cli -ScriptBlock $scriptblock
