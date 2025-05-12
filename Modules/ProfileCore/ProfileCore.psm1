using namespace System.Collections.Generic
using namespace System.Management.Automation

# Core module for PowerShell profile

# Set up script-level variables
$script:moduleRoot = Split-Path -Parent $PSCommandPath

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

function Import-PSModule {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )
    
    $result = $script:manager.Import($Name)
    
    if (-not $result.Success) {
        throw $result.Error
    }
    
    return $result
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
    $script:moduleAliases.Keys | Where-Object { 
        $script:moduleAliases[$_].LoadOnStartup 
    } | ForEach-Object {
        try {
            Import-PSModule $_
        } catch {
            Write-Warning "Failed to initialize module $_`: $($_.Exception.Message)"
        }
    }
}

# Load module configuration
$moduleConfig = Import-PowerShellDataFile "$moduleRoot\Config\ModuleConfig.psd1"

# Register modules from configuration
foreach ($category in $moduleConfig.Keys) {
    foreach ($module in $moduleConfig[$category]) {
        $scriptPath = "$env:USERPROFILE\OneDrive\Documents\PowerShell\Scripts\powershell-config\$($module.Path)"
        
        $initBlock = if ($module.IsModule) {
            [ScriptBlock]::Create("Import-Module '$scriptPath' -Force")
        } else {
            [ScriptBlock]::Create(". '$scriptPath'")
        }
        
        Register-PSModule -Name $module.Name -Description $module.Description -Category $category -InitializerBlock $initBlock
        $script:moduleAliases[$module.Name] = @{
            Description = $module.Description
            Category = $category
            Path = $scriptPath
        }
    }
}

# Create module loading functions
$script:moduleAliases.Keys | ForEach-Object {
    $moduleName = $_
    $functionName = "Use-$moduleName"
    
    Set-Item -Path "Function:$functionName" -Value {
        try {
            Import-PSModule $moduleName
            Write-Host "Loaded $($script:moduleAliases[$moduleName].Description) successfully" -ForegroundColor Green
        } catch {
            Write-Host "Failed to load $($script:moduleAliases[$moduleName].Description): $_" -ForegroundColor Red
        }
    }.GetNewClosure()
}

# Helper function to list available modules
function Get-AvailableModules {
    Get-PSModules | Format-Table -AutoSize
}

Set-Alias -Name modules -Value Get-AvailableModules

Export-ModuleMember -Function * -Variable moduleAliases -Alias modules
