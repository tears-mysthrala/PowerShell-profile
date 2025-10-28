using namespace System.Collections.Generic
using namespace System.Management.Automation

# Core module for PowerShell profile

# Set up script-level variables
$script:moduleRoot = Split-Path -Parent $PSCommandPath

# Provide a lightweight Measure-Block stub when loaded outside the interactive profile
if (-not (Get-Command -Name Measure-Block -ErrorAction SilentlyContinue)) {
    function Measure-Block {
        param(
            [string]$Name,
            [scriptblock]$Block,
            [switch]$Async
        )
        try {
            if ($Async) { Start-Job -ScriptBlock $Block | Out-Null } else { & $Block }
        } catch {
            # best-effort, swallow errors in the stub
        }
    }
}

# Define module management types
class ModuleInfo {
    [string]$Name
    [string]$Description
    [string]$Category
    [string]$MinVersion
    [string]$RequiredVersion
    [string[]]$Dependencies
    [ScriptBlock]$InitializerBlock
    [ScriptBlock]$OnFailure
    [ScriptBlock]$OnVersionMismatch
    [bool]$LoadOnStartup
    [int]$MaxAttempts
    [int]$LoadAttempts
    [string]$ModulePath
    [bool]$IgnoreIfMissing
    [bool]$IsLoaded
    [List[string]]$Tags

    ModuleInfo([string]$name) {
        $this.Name = $name
        $this.MaxAttempts = 3
        $this.LoadAttempts = 0
        $this.Tags = [List[string]]::new()
    }
}

class ModuleManager {
    hidden [Dictionary[string,ModuleInfo]]$Modules
    hidden [string]$ProfileDir
    hidden [System.Diagnostics.Stopwatch]$Timer

    ModuleManager([string]$profileDir) {
        $this.Modules = [Dictionary[string,ModuleInfo]]::new()
        $this.ProfileDir = $profileDir
        $this.Timer = [System.Diagnostics.Stopwatch]::new()
    }

    [void] Register(
        [string]$Name,
        [string]$Description,
        [string]$Category,
        [ScriptBlock]$InitializerBlock,
        [bool]$LoadOnStartup = $false,
        [string]$MinVersion = "",
        [string[]]$Dependencies = @()
    ) {
        $module = [ModuleInfo]::new($Name)
        $module.Description = $Description
        $module.Category = $Category
        $module.InitializerBlock = $InitializerBlock
        $module.LoadOnStartup = $LoadOnStartup
        $module.MinVersion = $MinVersion
        $module.Dependencies = $Dependencies
        
        if ($Category) { $module.Tags.Add($Category) }
        if ($Dependencies.Count -gt 0) { $module.Tags.Add('HasDependencies') }
        if ($MinVersion) { $module.Tags.Add('VersionSpecific') }
        
        $this.Modules[$Name] = $module
    }

    [object] Import([string]$Name) {
        $module = $this.Modules[$Name]
        if (-not $module) {
            throw "Module '$Name' is not registered"
        }

        if ($module.IsLoaded) {
            return @{ Success = $true; Time = 0 }
        }

        if ($module.LoadAttempts -ge $module.MaxAttempts) {
            throw "Maximum load attempts reached for module '$Name'"
        }

        $module.LoadAttempts++
        $this.Timer.Restart()

        try {
            if ($module.InitializerBlock) {
                & $module.InitializerBlock
            }
            $module.IsLoaded = $true
            return @{
                Success = $true
                Time = $this.Timer.ElapsedMilliseconds
            }
        }
        catch {
            if ($module.OnFailure) {
                & $module.OnFailure
            }
            return @{
                Success = $false
                Error = $_.Exception.Message
            }
        }
    }
}

# Initialize module registry
$script:moduleAliases = [System.Collections.Generic.Dictionary[string,hashtable]]::new()
$script:manager = [ModuleManager]::new($moduleRoot)

# Register core utility scripts for deferred loading (do not import at startup)
$utilsPath = "$ProfileDir\Scripts\powershell-config\Core\Utils"
if (Test-Path $utilsPath) {
    Get-ChildItem -Path $utilsPath -Filter "*.ps1" | ForEach-Object {
        $utilFile = $_
        $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($utilFile.Name)
        $scriptPath = $utilFile.FullName

        # Register utility script for on-demand loading
        $script:moduleAliases[$moduleName] = @{
            Description = "Utility: $moduleName"
            Category = 'Utility'
            Path = $scriptPath
            LoadOnStartup = $false
        }
    }
}

function Register-PSModule {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        
        [Parameter(Mandatory=$true)]
        [string]$Description,
        
        [Parameter(Mandatory=$true)]
        [string]$Category,
        
        [Parameter(Mandatory=$true)]
        [scriptblock]$InitializerBlock,
        
        [bool]$LoadOnStartup = $false,
        
        [string]$MinVersion = $null,
        
        [string[]]$Dependencies = @()
    )
    
    $script:manager.Register($Name, $Description, $Category, $InitializerBlock, $LoadOnStartup, $MinVersion, $Dependencies)
}

function Import-PSModule {    param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )
    
    if (-not $script:moduleAliases.ContainsKey($Name)) {
        throw "Module '$Name' is not registered"
    }
    
    $moduleInfo = $script:moduleAliases[$Name]
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        $moduleContent = Get-Content -Path $moduleInfo.Path -Raw
        
        # Create a new module with the script content
        New-Module -Name $Name -ScriptBlock ([ScriptBlock]::Create(@"
            Set-StrictMode -Version Latest
            # Set ErrorActionPreference to 'Stop' to ensure errors are not silently ignored (restored after module load if needed)
            Write-Host "[INFO] Setting ErrorActionPreference to 'Stop' for module load..." -ForegroundColor Yellow
            `$ErrorActionPreference = 'Stop'
            `$script:moduleRoot = Split-Path -Parent '$($moduleInfo.Path)'
            
            # Define functions and aliases from the script
            $moduleContent
            
            # Export all functions and aliases from this module scope
            Export-ModuleMember -Function * -Alias *
"@)) | Import-Module -Global -Force
        
        $timer.Stop()
        return @{
            Success = $true
            Time = $timer.ElapsedMilliseconds
        }
    } catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Get-PSModules {
    $script:moduleAliases.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.Key
            Description = $_.Value.Description
            Category = $_.Value.Category
            Path = $_.Value.Path
        }
    }
}

function Initialize-PSModules {
    # Make initialization metadata-only: don't perform heavy imports at startup.
    # For modules marked LoadOnStartup, create a lightweight Use-* proxy which will
    # perform the real import in the interactive runspace on first use.
    $toProxy = $script:moduleAliases.Keys | Where-Object { $script:moduleAliases[$_].LoadOnStartup }
    foreach ($moduleName in $toProxy) {
        $funcName = "Use-$moduleName"
        try {
            if (-not (Get-Command -Name $funcName -ErrorAction SilentlyContinue)) {
                # capture the current module name to avoid foreach variable capture issues
                $m = $moduleName
                $sb = {
                    param($args)
                    $name = $m
                    # Remove this proxy so subsequent calls execute the real Use-* if it redefines itself
                    Remove-Item -Path "Function:Use-$name" -ErrorAction SilentlyContinue
                    try {
                        # Perform the real import in the interactive runspace
                        Import-PSModule $name
                    } catch {
                        Write-Warning ("Failed to import module {0}: {1}" -f $name, $_.Exception.Message)
                        return
                    }
                    # If a Use-* function was defined by the module, invoke it with the original args
                    $real = Get-Command -Name "Use-$name" -CommandType Function -ErrorAction SilentlyContinue
                    if ($real) { & $real @args }
                }.GetNewClosure()
                Set-Item -Path "Function:$funcName" -Value $sb
            }
        } catch {
            Write-Warning "Failed to create proxy for module $moduleName`: $($_.Exception.Message)"
        }
    }
}

# Load module configuration and register modules (timed)
Measure-Block 'ProfileCore:LoadAndRegisterModules' {
    # Load module configuration
    $moduleConfig = Import-PowerShellDataFile "$moduleRoot\Config\ModuleConfig.psd1"

    # Register modules from configuration
    foreach ($category in $moduleConfig.Keys) {
        foreach ($module in $moduleConfig[$category]) {
            $scriptPath = "$env:USERPROFILE\OneDrive\Documents\PowerShell\Scripts\powershell-config\$($module.Path)"

            # Use a lightweight initializer that imports the module on demand to avoid heavy string creation at startup
            $initBlock = [ScriptBlock]::Create("Import-PSModule '$($module.Name)'")
            Register-PSModule -Name $module.Name -Description $module.Description -Category $category -InitializerBlock $initBlock
            $script:moduleAliases[$module.Name] = @{
                Description = $module.Description
                Category = $category
                Path = $scriptPath
            }
        }
    }

    # NOTE: Creation of Use-* functions is intentionally deferred to the interactive profile
    # to avoid creating many functions synchronously at startup. The profile will create
    # lightweight Use-* functions lazily (in background) so the prompt returns quickly.
}

# Helper functions
function Get-AvailableModules {
    Get-PSModules | Format-Table -AutoSize
}

# Set up aliases
Set-Alias -Name modules -Value Get-AvailableModules

# Create a list of all functions to export
$functionsToExport = @(
    'Register-PSModule'
    'Import-PSModule'
    'Initialize-PSModules'
    'Get-PSModules'
    'Get-AvailableModules'
)

# Add all Use-* functions dynamically
$functionsToExport += $script:moduleAliases.Keys | ForEach-Object {
    "Use-$_"
}

# Export module members
Export-ModuleMember -Function $functionsToExport -Variable moduleAliases -Alias modules
