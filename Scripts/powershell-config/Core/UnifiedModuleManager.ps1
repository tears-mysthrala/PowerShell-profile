# Unified Module Manager for PowerShell Profile

$script:moduleRegistry = @{}
$script:loadedModules = @{}
$script:moduleLoadAttempts = @{}
$script:moduleDependencies = @{}
$script:moduleVersions = @{}
$script:moduleInitializers = @{}
$script:toolRegistry = @{}
$script:loadedTools = @{}

function Register-UnifiedModule {
    [CmdletBinding()]
    param(
        [string]$Name,
        [string]$MinVersion,
        [string]$RequiredVersion,
        [string[]]$Dependencies = @(),
        [scriptblock]$InitializerBlock,
        [scriptblock]$OnFailure,
        [scriptblock]$OnVersionMismatch,
        [bool]$LoadOnStartup = $false,
        [int]$MaxAttempts = 3,
        [switch]$IgnoreIfMissing,
        [string]$ModulePath
    )

    # Suppress all non-critical messages (log this action)
    Write-Verbose "[INFO] Suppressing Verbose, Debug, Warning, and Information output temporarily..." -ForegroundColor Yellow
    $oldVerbose = $VerbosePreference
    $oldDebug = $DebugPreference
    $oldWarning = $WarningPreference
    $oldInformation = $InformationPreference
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'
    $WarningPreference = 'SilentlyContinue'
    $InformationPreference = 'SilentlyContinue'

    # Check if module exists before registration
    # Restore previous preferences after block
    $VerbosePreference = $oldVerbose
    $DebugPreference = $oldDebug
    $WarningPreference = $oldWarning
    $InformationPreference = $oldInformation
    $moduleExists = $false
    $moduleInfo = $null
    $moduleSearchPaths = @($env:PSModulePath -split ';')
    $customPaths = @()

    if ($ModulePath) {
        $customPaths += $ModulePath
    }

    # Add common module locations
    $commonPaths = @(
        "$env:USERPROFILE\scoop\modules",
        "$env:ChocolateyInstall\helpers",
        "$PSScriptRoot\..\..\Modules"
    )
    $customPaths += $commonPaths | Where-Object { Test-Path $_ }

    foreach ($searchPath in ($customPaths + $moduleSearchPaths)) {
        $potentialPath = Join-Path $searchPath $Name
        if (Test-Path $potentialPath) {
            try {
                $manifestPath = Get-ChildItem -Path $potentialPath -Filter "*.psd1" -Recurse | Select-Object -First 1
                if ($manifestPath) {
                    $moduleInfo = Test-ModuleManifest -Path $manifestPath.FullName -ErrorAction Stop
                    $moduleExists = $true
                    break
                }
            } catch {
                Write-Verbose ("Failed to validate module manifest at {0}: {1}" -f $potentialPath, $_.Exception.Message)
                continue
            }
        }
    }

    if (-not $moduleExists) {
        # Suppress errors when checking for module (log this action)
        Write-Verbose "[INFO] Checking for module $Name with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
        $moduleInfo = Get-Module -ListAvailable $Name -ErrorAction SilentlyContinue |
                     Sort-Object Version -Descending |
                     Select-Object -First 1
        $moduleExists = $null -ne $moduleInfo
    }

    if (-not $moduleExists) {
        if ($IgnoreIfMissing) {
            # Silently register optional modules for lazy loading
            $script:moduleRegistry[$Name] = @{
                MinVersion = $MinVersion
                RequiredVersion = $RequiredVersion
                Dependencies = $Dependencies
                InitializerBlock = $InitializerBlock
                OnFailure = $OnFailure
                OnVersionMismatch = $OnVersionMismatch
                LoadOnStartup = $LoadOnStartup
                MaxAttempts = $MaxAttempts
                LoadAttempts = 0
                ModulePath = $ModulePath
                IgnoreIfMissing = $IgnoreIfMissing
            }
            return $null
        } else {
            return $null
        }
    }
    $script:moduleRegistry[$Name] = @{
        MinVersion = $MinVersion
        RequiredVersion = $RequiredVersion
        Dependencies = $Dependencies
        InitializerBlock = $InitializerBlock
        OnFailure = $OnFailure
        OnVersionMismatch = $OnVersionMismatch
        LoadOnStartup = $LoadOnStartup
        MaxAttempts = $MaxAttempts
        LoadAttempts = 0
        ModulePath = $ModulePath
        IgnoreIfMissing = $IgnoreIfMissing
    }
}

# Lazy loading functionality from LazyModuleManager
function Import-LazyModule {
    param([string]$Name)
    if ($script:loadedModules[$Name]) { return $true }

    if ($script:moduleRegistry.ContainsKey($Name)) {
        try {
            Import-UnifiedModule $Name
            return $true
        } catch {
            Write-Warning ("Failed to load module '{0}': {1}" -f $Name, $_.Exception.Message)
            return $false
        }
    }
    return $false
}

# Tool management functionality from LazyToolManager
function Register-UnifiedTool {
    param(
        [string]$Name,
        [scriptblock]$InitializerBlock,
        [bool]$LoadOnStartup = $false
    )
    $script:toolRegistry[$Name] = @{
        Block = $InitializerBlock
        LoadOnStartup = $LoadOnStartup
    }
}

function Import-UnifiedTool {
    param([string]$Name)
    if ($script:loadedTools[$Name]) { return $true }

    if ($script:toolRegistry.ContainsKey($Name)) {
        try {
            & $script:toolRegistry[$Name].Block
            $script:loadedTools[$Name] = $true
            return $true
        } catch {
            Write-Warning ("Failed to load tool '{0}': {1}" -f $Name, $_.Exception.Message)
            return $false
        }
    }
    return $false
}

function Initialize-StartupTool {
    $script:toolRegistry.GetEnumerator() | Where-Object { $_.Value.LoadOnStartup } | ForEach-Object {
        Import-UnifiedTool $_.Key
    }
}

function Get-UnifiedToolStatus {
    $script:loadedTools.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.Key
            Loaded = $_.Value
        }
    }
}

function Test-UnifiedModuleRequirement {
    [CmdletBinding()]
    param([string]$Name)

    if (-not $script:moduleRegistry.ContainsKey($Name)) { return $true }

    $moduleInfo = $script:moduleRegistry[$Name]
    $module = $null

    if ($moduleInfo.ModulePath -and (Test-Path $moduleInfo.ModulePath)) {
        try {
            $module = Test-ModuleManifest -Path $moduleInfo.ModulePath -ErrorAction Stop
        } catch {
            Write-Verbose "Module manifest validation failed for $($moduleInfo.ModulePath): $_"
        }
    }

    if (-not $module) {
        $module = Get-Module -ListAvailable $Name | Sort-Object Version -Descending | Select-Object -First 1
    }

    if (-not $module) {
        if ($moduleInfo.IgnoreIfMissing) {
            return $true
        }
        return $null
    }

    # Version checks
    if ($moduleInfo.RequiredVersion -and ($module.Version -ne $moduleInfo.RequiredVersion)) {
        if ($moduleInfo.OnVersionMismatch) {
            & $moduleInfo.OnVersionMismatch
        }
        return $null
    }

    if ($moduleInfo.MinVersion -and ($module.Version -lt $moduleInfo.MinVersion)) {
        return $null
    }

    # Dependency checks
    foreach ($dep in $moduleInfo.Dependencies) {
        if (-not (Test-UnifiedModuleRequirement $dep)) {
            return $null
        }
    }

    return $true
}

function Import-UnifiedModule {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Name,
        [switch]$Force
    )

    if ($script:loadedModules[$Name] -and -not $Force) { return $null }

    $moduleInfo = $script:moduleRegistry[$Name]
    if (-not $moduleInfo) {
        return $null
    }

    if ($moduleInfo.LoadAttempts -ge $moduleInfo.MaxAttempts) {
        return $null
    }

    $moduleInfo.LoadAttempts++

    if (-not (Test-UnifiedModuleRequirement $Name)) {
        if ($moduleInfo.OnFailure) {
            & $moduleInfo.OnFailure
            return $null
        }
        if ($moduleInfo.IgnoreIfMissing) {
            return $null
        }
        return $null
    }

    try {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $originalPreferences = @{
            Verbose = $VerbosePreference
            Debug = $DebugPreference
            Warning = $WarningPreference
            Information = $InformationPreference
        }

        # Suppress all non-critical messages (log this action)
        Write-Verbose "[INFO] Suppressing Verbose, Debug, Warning, and Information output temporarily..." -ForegroundColor Yellow
        $oldVerbose = $VerbosePreference
        $oldDebug = $DebugPreference
        $oldWarning = $WarningPreference
        $oldInformation = $InformationPreference
        $VerbosePreference = 'SilentlyContinue'
        $DebugPreference = 'SilentlyContinue'
        $WarningPreference = 'SilentlyContinue'
        $InformationPreference = 'SilentlyContinue'

        try {
            # Restore previous preferences after block
            $VerbosePreference = $oldVerbose
            $DebugPreference = $oldDebug
            $WarningPreference = $oldWarning
            $InformationPreference = $oldInformation
            if ($moduleInfo.InitializerBlock) {
                if ($PSCmdlet.ShouldProcess($Name, "Execute initializer block")) {
                    & $moduleInfo.InitializerBlock
                }
            } elseif ($moduleInfo.ModulePath -and (Test-Path $moduleInfo.ModulePath)) {
                if ($PSCmdlet.ShouldProcess($moduleInfo.ModulePath, "Import module")) {
                    Import-Module $moduleInfo.ModulePath -Force:$Force -ErrorAction Stop
                }
            } else {
                if ($PSCmdlet.ShouldProcess($Name, "Import module")) {
                    Import-Module $Name -Force:$Force -ErrorAction Stop
                }
            }
        } finally {
            $VerbosePreference = $originalPreferences.Verbose
            $DebugPreference = $originalPreferences.Debug
            $WarningPreference = $originalPreferences.Warning
            $InformationPreference = $originalPreferences.Information
        }

        $sw.Stop()
        $script:loadedModules[$Name] = $true
        return $null
    } catch {
        if ($moduleInfo.OnFailure) {
            & $moduleInfo.OnFailure
        }
        return $null
    }
}

function Initialize-StartupModule {
    [CmdletBinding(SupportsShouldProcess)]
    $startupModules = $script:moduleRegistry.GetEnumerator() |
        Where-Object { $_.Value.LoadOnStartup } |
        ForEach-Object { $_.Key }

    if ($startupModules.Count -eq 0) { return @{} }

    $loadTimes = @{}
    $totalTimer = [System.Diagnostics.Stopwatch]::StartNew()
    $jobs = @()

    # Suppress all non-critical messages (log this action)
    Write-Verbose "[INFO] Suppressing Verbose, Debug, Warning, and Information output temporarily..." -ForegroundColor Yellow
    $oldVerbose = $VerbosePreference
    $oldDebug = $DebugPreference
    $oldWarning = $WarningPreference
    $oldInformation = $InformationPreference
    $VerbosePreference = 'SilentlyContinue'
    $DebugPreference = 'SilentlyContinue'
    $WarningPreference = 'SilentlyContinue'
    $InformationPreference = 'SilentlyContinue'

    try {
        # Restore previous preferences after block
        $VerbosePreference = $oldVerbose
        $DebugPreference = $oldDebug
        $WarningPreference = $oldWarning
        $InformationPreference = $oldInformation
        # Create a hashtable to store module initialization scriptblocks

        foreach ($moduleName in $startupModules) {
            $moduleInfo = $script:moduleRegistry[$moduleName]

            # Create a job for each module
            $job = Start-Job -ScriptBlock {

                $sw = [System.Diagnostics.Stopwatch]::StartNew()

                try {
                    if ($using:moduleInfo.InitializerBlock) {
                        & $using:moduleInfo.InitializerBlock
                    } elseif ($using:moduleInfo.ModulePath -and (Test-Path $using:moduleInfo.ModulePath)) {
                        Import-Module $using:moduleInfo.ModulePath -Force
                    } else {
                        Import-Module $using:moduleName -Force
                    }

                    $sw.Stop()
                    return @{
                        Name = $using:moduleName
                        Success = $true
                        Time = $sw.ElapsedMilliseconds
                    }
                } catch {
                    if ($using:moduleInfo.OnFailure) {
                        & $using:moduleInfo.OnFailure
                    }
                    return @{
                        Name = $using:moduleName
                        Success = $false
                        Error = $_.Exception.Message
                    }
                }
            }

            $jobs += $job
        }

        # Wait for all jobs to complete
        $results = $jobs | Wait-Job | Receive-Job

        # Process results
        foreach ($result in $results) {
            if ($result.Success) {
                $script:loadedModules[$result.Name] = $true
                $loadTimes[$result.Name] = $result.Time
            }
        }
    } finally {
        $totalTimer.Stop()
        $loadTimes['Module load time'] = $totalTimer.ElapsedMilliseconds
        # Cleanup jobs
        $jobs | Remove-Job -Force
    }

    #return $loadTimes
}

function Get-UnifiedModuleStatus {
    $script:moduleRegistry.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.Key
            Loaded = $script:loadedModules.ContainsKey($_.Key)
            LoadAttempts = $_.Value.LoadAttempts
            MaxAttempts = $_.Value.MaxAttempts
            Dependencies = $_.Value.Dependencies -join ', '
            RequiredVersion = $_.Value.RequiredVersion
            MinVersion = $_.Value.MinVersion
            LoadOnStartup = $_.Value.LoadOnStartup
        }
    }
}

function Register-ChocolateyProfile {
    $chocoModule = "chocolatey-profile"
    $chocoPath = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

    if (-not $env:ChocolateyInstall) {
        Write-Debug "Chocolatey is not installed - skipping profile registration"
        return
    }

    # Suppress Verbose output for Chocolatey registration (log this action)
    Write-Verbose "[INFO] Suppressing Verbose output for Chocolatey registration..." -ForegroundColor Yellow
    $oldVerbose = $VerbosePreference
    $VerbosePreference = 'SilentlyContinue'
    try {
        # Restore previous VerbosePreference after block
        $VerbosePreference = $oldVerbose
        if (Test-Path $chocoPath) {
            Register-UnifiedModule -Name $chocoModule `
                                -InitializerBlock { Import-Module $chocoPath -Force -ErrorAction SilentlyContinue } `
                                -OnFailure { Write-Debug "Chocolatey profile module not loaded - this is normal if Chocolatey is not installed." } `
                                -LoadOnStartup $false `
                                -IgnoreIfMissing
        } else {
            Write-Debug "Chocolatey profile not found at $chocoPath - this is normal if Chocolatey is not installed."
        }
    } finally {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }
}
