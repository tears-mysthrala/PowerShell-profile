# Load aliases
. "$PSScriptRoot/Core/Utils/unified_aliases.ps1"

# Load system updater
. "$PSScriptRoot/Core/Apps/Updates/SystemUpdater.ps1"

# Initialize profiling
$script:profileTiming = @{}
$script:pathCache = @{}  # Cache Test-Path results

# Helper function for cached Test-Path
function Test-CachedPath {
    param([string]$Path)
    if ($script:pathCache.ContainsKey($Path)) {
        return $script:pathCache[$Path]
    }
    $exists = Test-Path $Path
    $script:pathCache[$Path] = $exists
    return $exists
}

function Measure-Block {
    param(
        [string]$Name,
        [scriptblock]$Block
    )
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        & $Block
    }
    finally {
        $sw.Stop()
        $script:profileTiming[$Name] = $sw.ElapsedMilliseconds
    }
}

# Set essential environment variables
$ProfileDir = $PSScriptRoot
Measure-Block 'Environment Setup' {
    # Use cached environment settings if available
    $envCachePath = "$ProfileDir\Config\env-cache.clixml"

    if (Test-CachedPath $envCachePath) {
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

        # Scoop modules path (DockerCompletion, scoop-completion, etc.)
        $scoopModulePath = "$env:USERPROFILE\scoop\modules"
        if ((Test-Path $scoopModulePath) -and $env:PSModulePath -notlike "*$scoopModulePath*") {
            $env:PSModulePath = "$scoopModulePath;" + $env:PSModulePath
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
        $env:GIT_IPVERSION = '4'

        # Cache the environment settings
        $envToCache = @{
            PYTHONIOENCODING            = $env:PYTHONIOENCODING
            EDITOR                      = $env:EDITOR
            VISUAL                      = $env:VISUAL
            POWERSHELL_TELEMETRY_OPTOUT = $env:POWERSHELL_TELEMETRY_OPTOUT
            POWERSHELL_UPDATECHECK      = $env:POWERSHELL_UPDATECHECK
            GIT_IPVERSION               = $env:GIT_IPVERSION
        }
        $envToCache | Export-Clixml -Path $envCachePath
    }
}

# If is in non-interactive shell, then return early
if (!([Environment]::UserInteractive -and -not $([Environment]::GetCommandLineArgs() | Where-Object { $_ -like '-NonI*' }))) {
    return
}

# By default, show info logs unless suppressed explicitly
$script:ProfileSuppressInfoLogs = $false

# Suppress info logs if not loaded with --no-suppress
if ($MyInvocation.Line -notmatch '--no-suppress') {
    $script:ProfileSuppressInfoLogs = $true
}

Measure-Block 'Core Setup' {
    try {
        # Create module cache directory if it doesn't exist
        $moduleCacheDir = Join-Path $ProfileDir 'Config\ModuleCache'
        if (-not (Test-Path $moduleCacheDir)) {
            New-Item -ItemType Directory -Path $moduleCacheDir -Force | Out-Null
        }

        # Import ModuleInstaller and install required modules only when needed
        $script:LazyLoadModules = {
            if (-not (Get-Module -Name ModuleInstaller -ErrorAction SilentlyContinue)) {
                Import-Module "$ProfileDir\Core\ModuleInstaller.ps1" -Force -ErrorAction Stop
            }
            Install-RequiredModule
        }

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
                # Install missing modules before importing the real command implementation
                if ($script:LazyLoadModules) {
                    & $script:LazyLoadModules
                }
                # Load the actual module
                Import-Module $moduleName -ErrorAction Stop
                # For PSFzf, also initialize fzf configuration
                if ($moduleName -eq 'PSFzf' -and $script:InitializeFzf) {
                    & $script:InitializeFzf
                }
                # Call the original command with the same arguments
                $commandInfo = Get-Command $command
                & $commandInfo @args
            }.GetNewClosure()
            Set-Item "Function:\$command" -Value $sb
        }

        # Provide an explicit enable function for Terminal-Icons so nothing related to it is created at startup
        function Enable-TerminalIcon {
            try {
                Import-Module 'Terminal-Icons' -ErrorAction Stop
            }
            catch {
                Write-Warning "Terminal-Icons could not be loaded: $_"
            }
        }

        # Load utility modules directly (small files, ~200 lines total, negligible startup cost)
        $utilsPath = "$ProfileDir\Core\Utils"
        if (Test-CachedPath $utilsPath) {
            foreach ($file in (Get-ChildItem -Path $utilsPath -Filter "*.ps1")) {
                # unified_aliases is already loaded at startup (line 2)
                if ($file.Name -eq 'unified_aliases.ps1') { continue }
                try { . $file.FullName } catch { Write-Warning "Failed to load $($file.Name): $_" }
            }
        }
    }
    catch {
        Write-Error "Failed to load core modules: $_"
        Write-Warning "Some features may not be available"
    }
}

# Initialize shell enhancements - PSReadLine
# Configure PSReadLine with full features enabled
$PSReadLineOptions = @{
    PredictionSource              = 'History'
    PredictionViewStyle           = 'ListView'
    HistorySearchCursorMovesToEnd = $true
    HistoryNoDuplicates           = $true
    MaximumHistoryCount           = 10000
    AddToHistoryHandler           = {
        param([string]$Line)
        # Don't save commands containing secrets to history on disk
        $Line -notmatch '(?i)(password|secret|token|apikey|api_key|api-key|credential|secure[-_]?string|convertto-securestring)'
    }
}
try {
    Set-PSReadLineOption @PSReadLineOptions
    # Core navigation
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    # Undo/redo
    Set-PSReadLineKeyHandler -Key Ctrl+z -Function Undo
    Set-PSReadLineKeyHandler -Key Ctrl+y -Function Redo
    # Toggle between ListView and InlineView
    Set-PSReadLineKeyHandler -Key F2 -Function SwitchPredictionView
    # Force menu complete
    Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function MenuComplete
    # Select all
    Set-PSReadLineKeyHandler -Key Alt+a -Function SelectAll
    # Smart RightArrow: accept next word from suggestion when at end of line, else move cursor
    Set-PSReadLineKeyHandler -Key RightArrow -ScriptBlock {
        param($key, $arg)
        $line = $null; $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        if ($cursor -lt $line.Length) {
            [Microsoft.PowerShell.PSConsoleReadLine]::ForwardChar($key, $arg)
        } else {
            [Microsoft.PowerShell.PSConsoleReadLine]::ForwardWord($key, $arg)
        }
    }
}
catch {
    Write-Warning "PSReadLine configuration failed: $_"
}

# Deferred module loading - runs once after the first prompt renders (zero startup cost)
Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
    # Suppress verbose output from module imports (inherits 'Continue' from profile)
    $VerbosePreference = 'SilentlyContinue'
    $WarningPreference = 'SilentlyContinue'

    if ($script:LazyLoadModules) {
        try { & $script:LazyLoadModules } catch { Write-Verbose "Required module installation failed: $_" }
    }

    # DockerCompletion - docker/docker-compose tab completion
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        $dcMod = Get-Module -ListAvailable -Name DockerCompletion -ErrorAction SilentlyContinue
        if ($dcMod) { Import-Module DockerCompletion -ErrorAction SilentlyContinue }
    }

    # scoop-completion - scoop tab completion
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        $scMod = Get-Module -ListAvailable -Name scoop-completion -ErrorAction SilentlyContinue
        if ($scMod) { Import-Module scoop-completion -ErrorAction SilentlyContinue }
    }

    # CompletionPredictor - upgrades PredictionSource to HistoryAndPlugin
    $cpMod = Get-Module -ListAvailable -Name CompletionPredictor -ErrorAction SilentlyContinue
    if ($cpMod) {
        Import-Module CompletionPredictor -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin -ErrorAction SilentlyContinue
    }

    # Microsoft.WinGet.CommandNotFound - "did you mean?" + winget install suggestions
    $wcnfMod = Get-Module -ListAvailable -Name Microsoft.WinGet.CommandNotFound -ErrorAction SilentlyContinue
    if ($wcnfMod) {
        Import-Module Microsoft.WinGet.CommandNotFound -ErrorAction SilentlyContinue
    }

    # Package manager operations (Update-ChocoApp, Update-ScoopApp, etc.)
    $appsManagePath = "$ProfileDir\Core\Apps\appsManage.ps1"
    if (Test-Path $appsManagePath) {
        . $appsManagePath
    }
} | Out-Null

# Import PSFzf for enhanced history search with fzf (lazy-loaded)
try {
    # Remove synchronous import - PSFzf will be loaded on first use via proxy function
    # Load fzf configurations only after PSFzf is available
    $script:InitializeFzf = {
        if (-not (Get-Module PSFzf -ErrorAction SilentlyContinue)) {
            Import-Module PSFzf -ErrorAction Stop
        }
        $fzfPath = "$ProfileDir\Core\System\fzf.ps1"
        if (Test-Path $fzfPath) {
            . $fzfPath
        }
    }
}
catch {
    Write-Warning "PSFzf lazy loading setup failed: $_"
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

# Reusable fingerprint-based cache for tool init scripts
function Initialize-CachedToolInit {
    param(
        [string]$ToolName,
        [scriptblock]$InitCommand,
        [string]$CacheBaseName,
        [string]$ConfigPath
    )
    try {
        $cachePath = Join-Path $ProfileDir "Config\$CacheBaseName.ps1"
        $metaPath = Join-Path $ProfileDir "Config\$CacheBaseName.meta.clixml"

        $toolCmd = Get-Command $ToolName -ErrorAction SilentlyContinue
        $toolExe = $toolCmd.Source
        $toolExeMTime = if ($toolExe) { try { (Get-Item $toolExe).LastWriteTime } catch { $null } } else { $null }
        $cfgMTime = if ($ConfigPath -and (Test-Path $ConfigPath)) { try { (Get-Item $ConfigPath).LastWriteTime } catch { $null } } else { $null }

        $needRegen = $true
        if ((Test-Path $cachePath) -and (Test-Path $metaPath)) {
            try {
                $meta = Import-Clixml -Path $metaPath
                if ($meta -and $meta.CacheFormatVersion -ge 1) {
                    $needRegen = -not (
                        ($meta.ToolExe -eq $toolExe) -and
                        ($meta.ToolExeMTime -eq $toolExeMTime) -and
                        ($meta.ConfigPath -eq $ConfigPath) -and
                        ($meta.ConfigMTime -eq $cfgMTime)
                    )
                }
            }
            catch { $needRegen = $true }
        }

        if ($needRegen) {
            $initOutput = (& $InitCommand | Out-String)
            . ([scriptblock]::Create($initOutput))
            try {
                $initOutput | Set-Content -Path $cachePath -Encoding UTF8 -Force
                @{
                    CacheFormatVersion = 1
                    ToolExe            = $toolExe
                    ToolExeMTime       = $toolExeMTime
                    ConfigPath         = $ConfigPath
                    ConfigMTime        = $cfgMTime
                } | Export-Clixml -Path $metaPath -Force
            }
            catch { <# Ignore cache write failures; current session is already initialized #> }
        }
        else {
            try { . $cachePath }
            catch {
                try {
                    $initOutput = (& $InitCommand | Out-String)
                    . ([scriptblock]::Create($initOutput))
                }
                catch { Write-Verbose "$ToolName initialization failed: $_" }
            }
        }
    }
    catch { Write-Verbose "$ToolName initialization failed: $_" }
}

# Initialize shell tools (cached to avoid blocking startup)
if ($script:CommandExistsCache['zoxide']) {
    $env:_ZO_DATA_DIR = "$ProfileDir\.zo"
    Initialize-CachedToolInit -ToolName 'zoxide' -InitCommand { zoxide init powershell --cmd cd } -CacheBaseName 'zoxide-init-cache'
}

if ($script:CommandExistsCache['gh']) {
    Initialize-CachedToolInit -ToolName 'gh' -InitCommand { gh completion -s powershell } -CacheBaseName 'gh-completion-cache'
}

function Install-Dependency {
    <#
    .SYNOPSIS
        Install PowerShell profile dependencies
    .DESCRIPTION
        Installs package managers, CLI tools, and modules required by the PowerShell profile
    .PARAMETER All
        Install all dependencies
    .PARAMETER PackageManagers
        Install only package managers (Chocolatey, Scoop)
    .PARAMETER CliTools
        Install only CLI tools (git, fzf, bat, eza, etc.)
    .PARAMETER Modules
        Install only PowerShell modules
    .PARAMETER Tool
        Install a specific tool by name
    .EXAMPLE
        Install-Dependency -All
    .EXAMPLE
        Install-Dependency -Modules
    .EXAMPLE
        Install-Dependency -Tool git
    #>
    param(
        [switch]$All,
        [switch]$PackageManagers,
        [switch]$CliTools,
        [switch]$Modules,
        [string]$Tool
    )

    $installerPath = "$PSScriptRoot\tools\install-dependencies.ps1"

    if (-not (Test-Path $installerPath)) {
        Write-Error "Dependency installer not found at: $installerPath"
        return
    }

    $installerArgs = @()

    if ($All) { $installerArgs += "-All" }
    elseif ($PackageManagers) { $installerArgs += "-PackageManagers" }
    elseif ($CliTools) { $installerArgs += "-CliTools" }
    elseif ($Modules) { $installerArgs += "-Modules" }
    elseif ($Tool) { $installerArgs += "-Tool", $Tool }
    else {
        Write-Host "Usage: Install-Dependency [-All|-PackageManagers|-CliTools|-Modules|-Tool <name>]"
        Write-Host ""
        Write-Host "Examples:"
        Write-Host "  Install-Dependency -All            # Install everything"
        Write-Host "  Install-Dependency -Modules        # Install PowerShell modules"
        Write-Host "  Install-Dependency -CliTools       # Install CLI tools"
        Write-Host "  Install-Dependency -Tool git       # Install specific tool"
        return
    }

    & $installerPath @installerArgs
}

# Display profile loading timing if not suppressed
if (-not $script:ProfileSuppressInfoLogs -and $script:profileTiming) {
    $totalTime = ($script:profileTiming.GetEnumerator() | Measure-Object -Property Value -Sum).Sum
    Write-Host "Profile loaded in ${totalTime}ms" -ForegroundColor Green
    Write-Host "Timing breakdown:" -ForegroundColor Yellow
    $script:profileTiming.GetEnumerator() | Sort-Object -Property Value -Descending | ForEach-Object {
        Write-Host ("  {0}: {1}ms" -f $_.Key, $_.Value) -ForegroundColor Gray
    }
}

# Initialize Starship with a proper full-init cache (no process spawn on each load)
Measure-Block 'Starship Init' {
    if ($script:CommandExistsCache['starship']) {
        $starshipConfigPath = Join-Path $PSScriptRoot 'Config\starship.toml'
        $ENV:STARSHIP_CONFIG = $starshipConfigPath
        Initialize-CachedToolInit -ToolName 'starship' -InitCommand { starship init powershell --print-full-init } -CacheBaseName 'starship-init-cache' -ConfigPath $starshipConfigPath
    }
}
