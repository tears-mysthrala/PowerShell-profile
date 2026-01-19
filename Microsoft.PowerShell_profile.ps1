# Load aliases
. "$PSScriptRoot/Core/Utils/unified_aliases.ps1"

# Initialize profiling
$script:profileTiming = @{}
$script:backgroundJobs = @{}
$script:pathCache = @{}  # Cache Test-Path results

# Cache Start-ThreadJob availability once at startup for better performance
$script:hasThreadJob = $null -ne (Get-Command -Name Start-ThreadJob -ErrorAction SilentlyContinue)

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

function Start-BackgroundJob {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [scriptblock]$ScriptBlock,
        [Parameter(ValueFromRemainingArguments = $true)] $ArgumentList
    )
    if ($PSCmdlet.ShouldProcess("Background job", "Start")) {
        try {
            if ($script:hasThreadJob) {
                return Start-ThreadJob -ScriptBlock $ScriptBlock -ArgumentList $ArgumentList
            }
            else {
                # Execute synchronously instead of using slow Start-Job
                Write-Verbose "Start-ThreadJob not available, executing synchronously"
                & $ScriptBlock @ArgumentList
                return $null
            }
        }
        catch {
            Write-Verbose "Job execution failed: $_"
            # Execute synchronously as fallback
            & $ScriptBlock @ArgumentList
            return $null
        }
    }
}

function Measure-Block {
    param(
        [string]$Name,
        [scriptblock]$Block,
        [switch]$Async
    )
    
    # Simplified timing - skip async for now since we removed most jobs
    try {
        & $Block
    }
    finally {
        # Optionally track timing in verbose mode only
        if ($VerbosePreference -eq 'Continue') {
            # Minimal overhead when not verbose
        }
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

# Initialize background jobs array
$script:backgroundJobs = @()
$script:profileTiming = @{}

# By default, show info logs unless suppressed explicitly
$script:ProfileSuppressInfoLogs = $false

# Suppress info logs if not loaded with --no-supress
if ($MyInvocation.Line -notmatch '--no-supress') {
    $script:ProfileSuppressInfoLogs = $true
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
        function Initialize-PSModule {
            Ensure-ProfileCore
            $cmd = Get-Command -Module ProfileCore -Name Initialize-PSModule -ErrorAction SilentlyContinue
            if ($cmd) { & $cmd @args } else { Write-Warning 'Initialize-PSModule not available' }
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

        # Restore preferences
        $WarningPreference = $originalPreferences.Warning
        $VerbosePreference = $originalPreferences.Verbose
        $InformationPreference = $originalPreferences.Information
        # Write-Verbose "Core module loaded successfully" -ForegroundColor Green
        # Register lazy-loading wrappers for utility modules instead of importing all on startup
        $utilsPath = "$ProfileDir\Core\Utils"
        if (Test-CachedPath $utilsPath) {
            $utilsFiles = Get-ChildItem -Path $utilsPath -Filter "*.ps1"

            foreach ($file in $utilsFiles) {
                $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

                # unified_aliases ya está cargado explícitamente al inicio
                if ($moduleName -eq 'unified_aliases') { continue }

                $script:utilityModules ??= @{}
                $script:utilityModules[$moduleName] = $file.FullName

                # Solo crear wrapper si no existe ya una función/comando con ese nombre
                if (-not (Get-Command -Name $moduleName -ErrorAction SilentlyContinue)) {
                    $sb = {
                        param()
                        $name = $MyInvocation.MyCommand.Name
                        $path = $script:utilityModules[$name]
                        if ($path -and (Test-Path $path)) {
                            try {
                                . $path
                            }
                            catch {
                                Write-Warning "Failed to load utility module ${name}: $_"
                            }
                        }
                        # Reinvoca el comando original con los mismos argumentos tras la carga
                        $cmd = Get-Command -Name $name -ErrorAction SilentlyContinue
                        if ($cmd -and $cmd -ne $MyInvocation.MyCommand) {
                            & $cmd @args
                        }
                    }.GetNewClosure()

                    Set-Item -Path "Function:$moduleName" -Value $sb -Force
                }
            }
        }
    }
    catch {
        Write-Error "Failed to load core modules: $_"
        Write-Warning "Some features may not be available"
    }
}

# Configure shell environment
# Load aliases
$aliasPath = "$ProfileDir\Scripts\Shell\unified_aliases.ps1"
if (Test-CachedPath $aliasPath) {
    try {
        # Temporarily suppress warnings (log this action)
        if (-not $script:ProfileSuppressInfoLogs) {
            Write-Verbose "[INFO] Suppressing warnings and verbose output for alias loading..." -ForegroundColor Yellow
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

# Initialize shell enhancements - PSReadLine
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

# Initialize shell tools (cached to avoid blocking startup)
# Execute in current session for faster startup (caching makes it fast enough)
# Use pre-cached command checks from unified_aliases
if ($script:CommandExistsCache['zoxide']) {
    try {
        $env:_ZO_DATA_DIR = "$ProfileDir\.zo"

        $zoxideCachePath = Join-Path $ProfileDir 'Config\zoxide-init-cache.ps1'
        $zoxideMetaPath = Join-Path $ProfileDir 'Config\zoxide-init-cache.meta.clixml'

        $zoxideCmd = Get-Command zoxide -ErrorAction SilentlyContinue
        $zoxideExe = $zoxideCmd.Source
        $zoxideExeMTime = if ($zoxideExe) { try { (Get-Item $zoxideExe).LastWriteTime } catch { $null } } else { $null }

        $needRegen = $true
        if ((Test-Path $zoxideCachePath) -and (Test-Path $zoxideMetaPath)) {
            try {
                $meta = Import-Clixml -Path $zoxideMetaPath
                if ($meta -and $meta.CacheFormatVersion -ge 1) {
                    $needRegen = -not (
                        ($meta.ZoxideExe -eq $zoxideExe) -and
                        ($meta.ZoxideExeMTime -eq $zoxideExeMTime)
                    )
                }
            }
            catch {
                $needRegen = $true
            }
        }

        if ($needRegen) {
            # Direct init for current session
            $zoxideInit = (zoxide init powershell --cmd cd | Out-String)
            . ([scriptblock]::Create($zoxideInit))

            # Persist cache for future sessions
            try {
                $zoxideInit | Set-Content -Path $zoxideCachePath -Encoding UTF8 -Force
                @{
                    CacheFormatVersion = 1
                    ZoxideExe          = $zoxideExe
                    ZoxideExeMTime     = $zoxideExeMTime
                } | Export-Clixml -Path $zoxideMetaPath -Force
            }
            catch {
                # Ignore cache write failures; current session is already initialized
            }
        }
        else {
            try {
                . $zoxideCachePath
            }
            catch {
                # Fallback: regenerate on failure
                try {
                    $zoxideInit = (zoxide init powershell --cmd cd | Out-String)
                    . ([scriptblock]::Create($zoxideInit))
                }
                catch {
                    Write-Verbose "Zoxide initialization failed: $_"
                }
            }
        }
    }
    catch {
        Write-Verbose "Zoxide initialization failed: $_"
    }
}

# Initialize GitHub CLI completion with cached script
if ($script:CommandExistsCache['gh']) {
    try {
        $ghCachePath = Join-Path $ProfileDir 'Config\gh-completion-cache.ps1'
        $ghMetaPath = Join-Path $ProfileDir 'Config\gh-completion-cache.meta.clixml'

        $ghCmd = Get-Command gh -ErrorAction SilentlyContinue
        $ghExe = $ghCmd.Source
        $ghExeMTime = if ($ghExe) { try { (Get-Item $ghExe).LastWriteTime } catch { $null } } else { $null }

        $needRegenGh = $true
        if ((Test-Path $ghCachePath) -and (Test-Path $ghMetaPath)) {
            try {
                $metaGh = Import-Clixml -Path $ghMetaPath
                if ($metaGh -and $metaGh.CacheFormatVersion -ge 1) {
                    $needRegenGh = -not (
                        ($metaGh.GhExe -eq $ghExe) -and
                        ($metaGh.GhExeMTime -eq $ghExeMTime)
                    )
                }
            }
            catch {
                $needRegenGh = $true
            }
        }

        if ($needRegenGh) {
            $ghCompletion = (gh completion -s powershell | Out-String)
            . ([scriptblock]::Create($ghCompletion))

            try {
                $ghCompletion | Set-Content -Path $ghCachePath -Encoding UTF8 -Force
                @{
                    CacheFormatVersion = 1
                    GhExe              = $ghExe
                    GhExeMTime         = $ghExeMTime
                } | Export-Clixml -Path $ghMetaPath -Force
            }
            catch {
                # Ignore cache write failures
            }
        }
        else {
            try {
                . $ghCachePath
            }
            catch {
                try {
                    $ghCompletion = (gh completion -s powershell | Out-String)
                    . ([scriptblock]::Create($ghCompletion))
                }
                catch {
                    Write-Verbose "GitHub CLI completion initialization failed: $_"
                }
            }
        }
    }
    catch {
        Write-Verbose "GitHub CLI completion initialization failed: $_"
    }
}

# Initialize startup modules - deferred to first use for faster startup
# Modules will be loaded on-demand via lazy-loading proxies
# Uncomment below to force eager loading:
# Initialize-PSModule

function Install-Dependency {
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
        Install-Dependency -All
    .EXAMPLE
        Install-Dependency -PackageManagers
    .EXAMPLE
        Install-Dependency -Tool git
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

    $installerArgs = @()

    if ($All) { $installerArgs += "-InstallAll" }
    elseif ($PackageManagers) { $installerArgs += "-PackageManagers" }
    elseif ($CliTools) { $installerArgs += "-CliTools" }
    elseif ($Tool) { $installerArgs += "-Tool", $Tool }
    else {
        Write-Verbose "PowerShell Profile Dependency Installer"
        Write-Verbose "====================================="
        Write-Verbose ""
        Write-Verbose "USAGE:"
        Write-Verbose "    Install-Dependency [-All|-PackageManagers|-CliTools|-Tool <name>]"
        Write-Verbose ""
        Write-Verbose "EXAMPLES:"
        Write-Verbose "    Install-Dependency -All"
        Write-Verbose "    Install-Dependency -PackageManagers"
        Write-Verbose "    Install-Dependency -CliTools"
        Write-Verbose "    Install-Dependency -Tool git"
        Write-Verbose ""
        Write-Verbose "Run 'Install-Dependency -List' to see available tools."
        return
    }

    # Execute the installer
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
    # Use cached command check from unified_aliases
    if ($script:CommandExistsCache['starship']) {
        $starshipConfigPath = Join-Path $PSScriptRoot 'Config\starship.toml'
        $ENV:STARSHIP_CONFIG = $starshipConfigPath

        $starshipCachePath = "$PSScriptRoot\Config\starship-init-cache.ps1"
        $starshipMetaPath = "$PSScriptRoot\Config\starship-init-cache.meta.clixml"

        # Build current fingerprints without invoking starship.exe (fast path)
        $starshipCmd = Get-Command starship -ErrorAction SilentlyContinue
        $starshipExe = $starshipCmd.Source
        $starshipExeMTime = if ($starshipExe) { try { (Get-Item $starshipExe).LastWriteTime } catch { $null } } else { $null }
        $configMTime = if (Test-Path $starshipConfigPath) { try { (Get-Item $starshipConfigPath).LastWriteTime } catch { $null } } else { $null }

        $needRegen = $true
        if ((Test-Path $starshipCachePath) -and (Test-Path $starshipMetaPath)) {
            try {
                $meta = Import-Clixml -Path $starshipMetaPath
                if ($meta -and $meta.CacheFormatVersion -ge 1) {
                    $needRegen = -not (
                        ($meta.StarshipExe -eq $starshipExe) -and
                        ($meta.StarshipExeMTime -eq $starshipExeMTime) -and
                        ($meta.ConfigPath -eq $starshipConfigPath) -and
                        ($meta.ConfigMTime -eq $configMTime)
                    )
                }
            }
            catch {
                $needRegen = $true
            }
        }

        if ($needRegen) {
            # Fast path: do a quick direct init for the current session so the prompt appears
            # promptly, then regenerate and persist the full cached init synchronously
            $didDirectInit = $false
            try {
                # Direct init (may spawn starship) but returns quickly for current session
                Invoke-Expression (& starship init powershell --print-full-init | Out-String)
                $didDirectInit = $true
            }
            catch {
                Write-Verbose "Starship direct init failed: $_"
            }

            # Regenerate cache synchronously since it's quick
            try {
                $fullInit = (& starship init powershell --print-full-init | Out-String)
                $fullInit | Set-Content -Path $starshipCachePath -Encoding UTF8 -Force
                @{
                    CacheFormatVersion = 1
                    StarshipExe        = $starshipExe
                    StarshipExeMTime   = $starshipExeMTime
                    ConfigPath         = $starshipConfigPath
                    ConfigMTime        = $configMTime
                } | Export-Clixml -Path $starshipMetaPath -Force
            }
            catch {
                # Ignore cache write failures
            }
        }
        else {
            # Dot-source the cached init script (no starship.exe spawn during startup)
            try { . $starshipCachePath } catch {
                # As last resort, try direct init
                try { Invoke-Expression (& starship init powershell --print-full-init | Out-String) } catch {}
            }
        }
    }
}
