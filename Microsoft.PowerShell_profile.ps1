# Load aliases by default
. "$PSScriptRoot/Core/Utils/unified_aliases.ps1"
# Initialize profiling
$script:profileTiming = @{}

function Measure-Block {
    param(
        [string]$Name,
        [scriptblock]$Block,
        [switch]$Async
    )
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        if ($Async) {
            # Use faster thread jobs when available
            $job = Start-BackgroundJob -ScriptBlock $Block
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

function Start-BackgroundJob {
    param(
        [scriptblock]$ScriptBlock,
        [Parameter(ValueFromRemainingArguments = $true)] $ArgumentList
    )
    try {
        if (Get-Command -Name Start-ThreadJob -ErrorAction SilentlyContinue) {
            return Start-ThreadJob -ScriptBlock $ScriptBlock -ArgumentList $ArgumentList
        }
    }
    catch {
        # fall back
    }
    return Start-Job -ScriptBlock $ScriptBlock -ArgumentList $ArgumentList
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
            PYTHONIOENCODING            = $env:PYTHONIOENCODING
            EDITOR                      = $env:EDITOR
            VISUAL                      = $env:VISUAL
            POWERSHELL_TELEMETRY_OPTOUT = $env:POWERSHELL_TELEMETRY_OPTOUT
            POWERSHELL_UPDATECHECK      = $env:POWERSHELL_UPDATECHECK
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
                'Invoke-Fzf'    = 'PSFzf'
            }
            foreach ($command in $lazyLoadCommands.Keys) {
                $moduleName = $lazyLoadCommands[$command]
                $sb = {
                    # Remove the proxy function
                    Remove-Item "Function:\$command"
                    # Load the actual module
                    Import-Module $moduleName -ErrorAction Stop
                    # Call the original command with the same arguments
                    $commandInfo = Get-Command $command
                    & $commandInfo @args
                }.GetNewClosure()
                Set-Item "Function:\$command" -Value $sb
            }
        }

        # Provide an explicit enable function for Terminal-Icons so nothing related to it is created at startup
        function Enable-TerminalIcons {
            param(
                [switch]$Async
            )
            $sb = {
                try {
                    Import-Module 'Terminal-Icons' -ErrorAction Stop
                }
                catch {
                    Write-Warning "Terminal-Icons could not be loaded: $_"
                    return
                }
                # Optionally replace/seed any helper functions
                if (-not (Get-Command -Name Set-TerminalIcon -ErrorAction SilentlyContinue)) {
                    # nothing to do; module should export functions
                }
            }
            if ($Async) {
                if (Get-Command -Name Start-ThreadJob -ErrorAction SilentlyContinue) {
                    Start-ThreadJob -ScriptBlock $sb | Out-Null
                }
                else {
                    Start-Job -ScriptBlock $sb | Out-Null
                }
            }
            else {
                & $sb
            }
        }

        Measure-Block 'ImportProfileModules' {
            # Defer importing heavy profile modules until first use
            function Initialize-ProfileManagement {
                if (-not (Get-Module -Name ProfileManagement -ListAvailable)) { 
                    $path = Join-Path $ProfileDir 'Modules\ProfileManagement\ProfileManagement.psm1'
                    if (Test-Path $path) { Import-Module $path -Force -ErrorAction SilentlyContinue }
                }
            }

            function Initialize-ProfileCore {
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

            # Enumerate utility files
            $utilsFiles = Get-ChildItem -Path $utilsPath -Filter "*.ps1"

            # Enqueue background jobs for utils that need loading (measured)
            Measure-Block 'Utils:EnqueueJobs' {
                foreach ($file in $utilsFiles) {
                    $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                    $filePath = $file.FullName

                    # Skip unified_aliases.ps1 as it's already loaded synchronously at startup
                    if ($moduleName -eq 'unified_aliases') { continue }

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
                        }
                        catch {
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
                                }
                                catch {
                                    Write-Error ("Utility module import failed for {0}: {1}" -f $Name, $_)
                                }
                            } -ArgumentList $filePath, $moduleName

                            # Track background job so we can inspect later if needed
                            $script:backgroundJobs += @{ Name = $moduleName; Job = $job }

                            # Update cache in main session
                            $utilsCache[$moduleName] = @{
                                LastWriteTime = (Get-Item $filePath).LastWriteTime
                                Path          = $filePath
                            }
                        }
                        catch {
                            Write-Warning "Failed to enqueue utility module $moduleName`: $_"
                        }
                    }
                }
            }

            # Save updated cache (measured)
            Measure-Block 'Utils:SaveCache' {
                try {
                    $utilsCache | Export-Clixml -Path $utilsCachePath
                }
                catch {
                    # ignore cache write errors
                }
            }
        }
    }
    catch {
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
                        param($arguments)
                        # Replace this proxy with a real loader and invoke it
                        Remove-Item "Function:$functionName" -ErrorAction SilentlyContinue
                        Import-PSModule $name
                        & (Get-Command -Name $functionName -ErrorAction SilentlyContinue) @arguments
                    }.GetNewClosure()
                }
            }
        }
    }
    catch {
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

    # Simple Starship prompt initialization with config file
    $starshipConfigPath = Join-Path $ProfileDir 'Config\starship.toml'
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        $ENV:STARSHIP_CONFIG = $starshipConfigPath
        Invoke-Expression (&starship init powershell)
    }
    else {
        Write-Host "[INFO] Starship not found, skipping prompt initialization." -ForegroundColor Yellow
    }

    Measure-Block 'PSReadLine' {
        # Configure PSReadLine with full features enabled
        $PSReadLineOptions = @{
            PredictionSource              = 'History'   # enable history prediction
            HistorySearchCursorMovesToEnd = $true
        }
        try {
            Set-PSReadLineOption @PSReadLineOptions
            # Set key handlers for better autocomplete
            Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
            Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
            Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        }
        catch {
            Write-Warning "PSReadLine configuration failed: $_"
        }

        # Provide a function to disable PSReadLine features if needed
        function Disable-FullPSReadLine {
            try {
                $minimalOptions = @{
                    PredictionSource              = 'None'
                    HistorySearchCursorMovesToEnd = $true
                }
                Set-PSReadLineOption @minimalOptions
                # Minimal key handlers
                Set-PSReadLineKeyHandler -Key Tab -Function Complete
            }
            catch {
                Write-Warning "Disabling full PSReadLine options failed: $_"
            }
        }
    }
}

# Initialize shell tools (asynchronous to avoid blocking startup)
Measure-Block 'ShellToolsInit' {
    Start-Job -ScriptBlock {
        # Initialize Zoxide asynchronously
        if (Get-Command zoxide -ErrorAction SilentlyContinue) {
            try {
                $env:_ZO_DATA_DIR = "$using:ProfileDir\.zo"
                $zoxideInit = & { (zoxide init powershell --cmd cd | Out-String) }
                Invoke-Expression $zoxideInit
            } catch {
                Write-Verbose "Zoxide initialization failed: $_"
            }
        }

        # Initialize GitHub CLI completion asynchronously
        if (Get-Command gh -ErrorAction SilentlyContinue) {
            try {
                $ghCompletion = & { (gh completion -s powershell | Out-String) }
                Invoke-Expression $ghCompletion
            } catch {
                Write-Verbose "GitHub CLI completion initialization failed: $_"
            }
        }
    } | Out-Null
}

# Initialize startup modules asynchronously
Start-Job -ScriptBlock {
    try {
        Initialize-PSModules
    } catch {
        Write-Verbose "Module initialization failed: $_"
    }
} | Out-Null

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

# Dependency installer functions
function Install-Dependencies {
    <#
    .SYNOPSIS
        Install PowerShell profile dependencies
    .DESCRIPTION
        Installs package managers and CLI tools required by the PowerShell profile
    .PARAMETER All
        Install all dependencies (package managers + CLI tools)
    .PARAMETER PackageManagers
        Install only package managers (Chocolatey, Scoop)
    .PARAMETER CliTools
        Install only CLI tools (git, fzf, bat, eza, etc.)
    .PARAMETER Tool
        Install a specific tool by name
    .EXAMPLE
        Install-Dependencies -All
    .EXAMPLE
        Install-Dependencies -PackageManagers
    .EXAMPLE
        Install-Dependencies -Tool git
    #>
    param(
        [switch]$All,
        [switch]$PackageManagers,
        [switch]$CliTools,
        [string]$Tool
    )

    $installerPath = "$PSScriptRoot\tools\DependencyInstaller.ps1"

    if (-not (Test-Path $installerPath)) {
        Write-Error "Dependency installer not found at: $installerPath"
        return
    }

    $args = @()

    if ($All) { $args += "-InstallAll" }
    elseif ($PackageManagers) { $args += "-PackageManagers" }
    elseif ($CliTools) { $args += "-CliTools" }
    elseif ($Tool) { $args += "-Tool", $Tool }
    else {
        Write-Host "PowerShell Profile Dependency Installer" -ForegroundColor Cyan
        Write-Host "=====================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "USAGE:" -ForegroundColor Yellow
        Write-Host "    Install-Dependencies [-All|-PackageManagers|-CliTools|-Tool <name>]"
        Write-Host ""
        Write-Host "EXAMPLES:" -ForegroundColor Yellow
        Write-Host "    Install-Dependencies -All"
        Write-Host "    Install-Dependencies -PackageManagers"
        Write-Host "    Install-Dependencies -CliTools"
        Write-Host "    Install-Dependencies -Tool git"
        Write-Host ""
        Write-Host "Run 'Install-Dependencies -List' to see available tools."
        return
    }

    # Execute the installer
    & $installerPath @args
}
