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
        Measure-Block 'ModuleCacheDir' {
            # Create module cache directory if it doesn't exist
            $moduleCacheDir = Join-Path $ProfileDir 'Config\ModuleCache'
            if (-not (Test-Path $moduleCacheDir)) {
                New-Item -ItemType Directory -Path $moduleCacheDir -Force | Out-Null
            }
        }

        Measure-Block 'LazyLoadSetup' {
            # Import ModuleInstaller only when needed
            $global:LazyLoadModules = {
                Import-Module "$ProfileDir\Core\ModuleInstaller.ps1" -Force -ErrorAction Stop
                Install-RequiredModules
            }
        }

        Measure-Block 'ProxyFunctions' {
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
        }

        Measure-Block 'ImportProfileModules' {
            # Defer importing heavy profile modules until first use
            function Ensure-ProfileManagement {
                if (-not (Get-Module -Name ProfileManagement -ListAvailable)) { 
                    $path = Join-Path $ProfileDir 'Modules\ProfileManagement\ProfileManagement.psm1'
                    if (Test-Path $path) { Import-Module $path -Force -ErrorAction SilentlyContinue }
                }
            }

            function Ensure-ProfileCore {
                if (-not (Get-Module -Name ProfileCore -ListAvailable)) {
                    $path = Join-Path $ProfileDir 'Modules\ProfileCore\ProfileCore.psm1'
                    if (Test-Path $path) { Import-Module $path -Force -ErrorAction SilentlyContinue }
                }
            }

            # Lightweight proxies that import the module on first use and then invoke the real function
            function Initialize-PSModules {
                Ensure-ProfileCore
                $cmd = Get-Command -Module ProfileCore -Name Initialize-PSModules -ErrorAction SilentlyContinue
                if ($cmd) { & $cmd @args } else { Write-Warning 'Initialize-PSModules not available' }
            }

            function Import-PSModule {
                param([string]$Name)
                Ensure-ProfileCore
                $cmd = Get-Command -Module ProfileCore -Name Import-PSModule -ErrorAction SilentlyContinue
                if ($cmd) { & $cmd $Name } else { Write-Warning 'Import-PSModule not available' }
            }

            function Register-PSModule {
                param(
                    [string]$Name,
                    [string]$Description,
                    [string]$Category,
                    [scriptblock]$InitializerBlock
                )
                Ensure-ProfileCore
                $cmd = Get-Command -Module ProfileCore -Name Register-PSModule -ErrorAction SilentlyContinue
                if ($cmd) { & $cmd -Name $Name -Description $Description -Category $Category -InitializerBlock $InitializerBlock } else { Write-Warning 'Register-PSModule not available' }
            }
        }

        # Restore preferences
        $WarningPreference = $originalPreferences.Warning
        $VerbosePreference = $originalPreferences.Verbose
        $InformationPreference = $originalPreferences.Information
        # Write-Host "Core module loaded successfully" -ForegroundColor Green
        # Load common utilities with optimized caching (measured in sub-steps)
        $utilsPath = "$ProfileDir\Core\Utils"
        $utilsCachePath = "$ProfileDir\Config\utils-cache.clixml"

        if (Test-Path $utilsPath) {
            # Initialize cache
            $utilsCache = @{}
            if (Test-Path $utilsCachePath) {
                $utilsCache = Import-Clixml -Path $utilsCachePath
            }

            # Enumerate utility files (measured)
            Measure-Block 'Utils:Enumerate' {
                $utilsFiles = Get-ChildItem -Path $utilsPath -Filter "*.ps1"
            }

            # Enqueue background jobs for utils that need loading (measured)
            Measure-Block 'Utils:EnqueueJobs' {
                foreach ($file in $utilsFiles) {
                    $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                    $filePath = $file.FullName

                    # Check if module needs loading based on cache
                    $needsLoading = $true
                    if ($utilsCache.ContainsKey($moduleName)) {
                        $cached = $utilsCache[$moduleName]
                        try {
                            if ((Get-Item $filePath).LastWriteTime -eq $cached.LastWriteTime) {
                                # If module is already imported in this session, skip
                                $cachedModule = Get-Module -Name $moduleName -ErrorAction SilentlyContinue
                                if ($cachedModule) { $needsLoading = $false }
                            }
                        } catch {
                            $needsLoading = $true
                        }
                    }

                    if ($needsLoading) {
                        try {
                            # Start background job to create and import the module (non-blocking)
                            $job = Start-Job -ScriptBlock {
                                param($Path, $Name)
                                Set-StrictMode -Version Latest
                                $ErrorActionPreference = 'Stop'
                                try {
                                    $scriptBlock = {
                                        param($ScriptPath)
                                        . $ScriptPath
                                    }
                                    New-Module -Name $Name -ScriptBlock $scriptBlock -ArgumentList $Path |
                                        Import-Module -Global -WarningAction SilentlyContinue
                                } catch {
                                    Write-Error ("Utility module import failed for {0}: {1}" -f $Name, $_)
                                }
                            } -ArgumentList $filePath, $moduleName

                            # Track background job so we can inspect later if needed
                            $script:backgroundJobs += @{ Name = $moduleName; Job = $job }

                            # Update cache in main session
                            $utilsCache[$moduleName] = @{
                                LastWriteTime = (Get-Item $filePath).LastWriteTime
                                Path = $filePath
                            }
                        } catch {
                            Write-Warning "Failed to enqueue utility module $moduleName`: $_"
                        }
                    }
                }
            }

            # Save updated cache (measured)
            Measure-Block 'Utils:SaveCache' {
                try {
                    $utilsCache | Export-Clixml -Path $utilsCachePath
                } catch {
                    # ignore cache write errors
                }
            }
        }
    } catch {
        Write-Host "Failed to load core modules: $_" -ForegroundColor Red
        Write-Host "Some features may not be available" -ForegroundColor Yellow
    }
}

# Create lightweight Use-* functions lazily in the background to avoid startup cost
Start-Job -ScriptBlock {
    Start-Sleep -Milliseconds 200
    try {
        if ($script:moduleAliases) {
            foreach ($name in $script:moduleAliases.Keys) {
                $functionName = "Use-$name"
                if (-not (Get-Command -Name $functionName -ErrorAction SilentlyContinue)) {
                    Set-Item -Path "Function:$functionName" -Value {
                        param($args)
                        # Replace this proxy with a real loader and invoke it
                        Remove-Item "Function:$functionName" -ErrorAction SilentlyContinue
                        Import-PSModule $name
                        & (Get-Command -Name $functionName -ErrorAction SilentlyContinue) @args
                    }.GetNewClosure()
                }
            }
        }
    } catch {
        # non-fatal
    }
} | Out-Null

# Configure shell environment
Measure-Block 'Shell Setup' {
    Measure-Block 'Aliases' {
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
            }
            catch {
                Write-Warning "Failed to load aliases: $_"
            }
        }
    }

    # Initialize shell enhancements
    # Create a lazy proxy for Terminal-Icons: don't probe module lists at startup (avoids slow Get-Module)
    Measure-Block 'Terminal-Icons:LazyProxy' {
        try {
            # Define a small helper to lazy-load Terminal-Icons on first use of its expected functions
            $tiCommands = @('Set-TerminalIcon','Get-Icon','Get-TerminalIcon')
            foreach ($name in $tiCommands) {
                if (-not (Get-Command -Name $name -ErrorAction SilentlyContinue)) {
                    Set-Item -Path "Function:$name" -Value {
                        param($args)
                        # Remove the proxy
                        Remove-Item "Function:$name" -ErrorAction SilentlyContinue
                        try {
                            Import-Module 'Terminal-Icons' -ErrorAction SilentlyContinue
                        } catch {
                            # If import fails, recreate a stub that warns once
                            Set-Item -Path "Function:$name" -Value { param($a) Write-Warning "Terminal-Icons is not available." }
                            return
                        }
                        # Invoke the now-available command
                        $cmd = Get-Command -Name $name -ErrorAction SilentlyContinue
                        if ($cmd) { & $cmd @args }
                    }.GetNewClosure()
                }
            }
        } catch {
            # non-fatal
        }
    }

    # Lazy-initialize starship at first prompt to avoid blocking startup
    $starshipCmd = Get-Command starship -ErrorAction SilentlyContinue
    if ($starshipCmd) {
        $ENV:STARSHIP_CONFIG = "$ProfileDir\Config\starship.toml"
        $ENV:STARSHIP_CACHE = "$ProfileDir\.starship\cache"
        $script:StarshipInitialized = $false

        Measure-Block 'Prompt:InitFunc' {
            function Initialize-Starship {
                if ($script:StarshipInitialized) { return }
                try {
                    $init = & starship init powershell --print-full-init 2>$null
                    if ($init) { Invoke-Expression $init }
                    $script:StarshipInitialized = $true
                } catch {
                    Write-Warning "Starship init failed: $_"
                }
            }
        }

        # Define a lightweight prompt that initializes starship on first run
        Measure-Block 'Prompt:PromptWrapper' {
            $script:OriginalPrompt = $null
            if ($function:prompt) { $script:OriginalPrompt = $function:prompt }

            function prompt {
                if (-not $script:StarshipInitialized) {
                    Initialize-Starship
                    Start-Sleep -Milliseconds 10
                }
                # Enable full PSReadLine features lazily on first prompt
                if (-not $script:PSReadLineFullEnabled -and (Get-Command -Name Enable-FullPSReadLine -ErrorAction SilentlyContinue)) {
                    try {
                        Enable-FullPSReadLine
                    } catch { }
                    $script:PSReadLineFullEnabled = $true
                }
                $current = Get-Command prompt -CommandType Function -ErrorAction SilentlyContinue
                if ($current -and $current.ScriptBlock -ne $function:prompt.ScriptBlock) {
                    try {
                        return & $current.ScriptBlock
                    } catch {
                        # fallthrough to basic prompt
                    }
                }
                return "PS $($executionContext.SessionState.Path.CurrentLocation)> "
            }
        }
    } else {
        if (-not $global:ProfileSuppressInfoLogs) {
            Write-Host "[INFO] Starship not found, skipping prompt initialization." -ForegroundColor Yellow
        }
    }

    Measure-Block 'PSReadLine' {
        # Configure PSReadLine with an ultra-light startup; full features are enabled lazily
        $PSReadLineOptions = @{
            PredictionSource              = 'None'   # disable prediction at startup to reduce load
            HistorySearchCursorMovesToEnd = $true
        }
        try {
            Set-PSReadLineOption @PSReadLineOptions
            # Minimal key handlers to avoid extra initialization
            Set-PSReadLineKeyHandler -Key Tab -Function Complete
        } catch {
            Write-Warning "PSReadLine minimal configuration failed: $_"
        }

        # Provide a function to enable full PSReadLine features lazily
        function Enable-FullPSReadLine {
            try {
                $fullOptions = @{
                    PredictionSource = 'History'
                    HistorySearchCursorMovesToEnd = $true
                }
                Set-PSReadLineOption @fullOptions
                # Restore richer key handlers
                Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
                Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
                Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
            } catch {
                Write-Warning "Enabling full PSReadLine options failed: $_"
            }
        }
    }
}

# Initialize shell tools (synchronous measurement pass)
Measure-Block 'Zoxide' -Async {
    if (Get-Command zoxide -ErrorAction SilentlyContinue) {
        $env:_ZO_DATA_DIR = "$ProfileDir\.zo"
        Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
    }
}

Measure-Block 'GHCompletion' -Async {
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

# Stop the startup stopwatch. Background jobs (if any) are intentionally NOT waited on so the prompt appears quickly.
$globalStopwatch.Stop()

# Provide helper functions to enable features on demand instead of importing heavy modules at startup.
function Enable-TerminalIcons {
    if (Get-Module -ListAvailable -Name Terminal-Icons) {
        Import-Module Terminal-Icons -ErrorAction SilentlyContinue
        Write-Host 'Terminal-Icons enabled' -ForegroundColor Green
    } else {
        Write-Host 'Terminal-Icons not available on PSModulePath' -ForegroundColor Yellow
    }
}

function Enable-GHCompletion {
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        try {
            Invoke-Expression (& { (gh completion -s powershell | Out-String) })
            Write-Host 'GH completion registered' -ForegroundColor Green
        } catch {
            Write-Warning "Failed to register GH completion: $_"
        }
    } else {
        Write-Host 'gh CLI not found' -ForegroundColor Yellow
    }
}

function Enable-Zoxide {
    if (Get-Command zoxide -ErrorAction SilentlyContinue) {
        $env:_ZO_DATA_DIR = "$ProfileDir\.zo"
        try {
            Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
            Write-Host 'Zoxide initialized' -ForegroundColor Green
        } catch {
            Write-Warning "Failed to initialize zoxide: $_"
        }
    } else {
        Write-Host 'zoxide not found' -ForegroundColor Yellow
    }
}

# Report startup performance
$totalTime = $globalStopwatch.ElapsedMilliseconds
Write-Host "Profile loaded in ${totalTime}ms" -ForegroundColor Cyan
try {
    $script:profileTiming.GetEnumerator() | Sort-Object -Property Value -Descending | ForEach-Object {
        $k = $_.Key; $v = $_.Value
        Write-Host ("{0}: {1}ms" -f $k, $v) -ForegroundColor Green
    }
} catch {
    Write-Warning "Failed to enumerate profile timing: $_"
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
