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

# Import core utility modules first
$utilsPath = "$ProfileDir\Scripts\powershell-config\Core\Utils"
if (Test-Path $utilsPath) {
    Get-ChildItem -Path $utilsPath -Filter "*.ps1" | ForEach-Object {
        $utilFile = $_
        $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($utilFile.Name)
        $moduleContent = Get-Content -Path $utilFile.FullName -Raw
        
        # Create a new module with the utility script content
        New-Module -Name $moduleName -ScriptBlock ([ScriptBlock]::Create(@"
            Set-StrictMode -Version Latest
            `$ErrorActionPreference = 'Stop'
            `$script:moduleRoot = Split-Path -Parent '$($utilFile.FullName)'
            
            # Define functions and aliases from the script
            $moduleContent
            
            # Export all functions and aliases from this module scope
            Export-ModuleMember -Function * -Alias *
"@)) | Import-Module -Global -Force
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
    $script:moduleAliases.Keys | Where-Object { 
        $script:moduleAliases[$_].LoadOnStartup 
    } | ForEach-Object {
        $moduleName = $_
        $moduleInfo = $script:moduleAliases[$moduleName]
        
        try {            if ($moduleInfo.Path -match '\.psd1$') {
                Import-Module $moduleInfo.Path -Force
            } else {
                $moduleContent = Get-Content -Path $moduleInfo.Path -Raw
                
                # Create a new module with the script content
                New-Module -Name $moduleName -ScriptBlock ([ScriptBlock]::Create(@"
                    Set-StrictMode -Version Latest
                    `$ErrorActionPreference = 'Stop'
                    `$script:moduleRoot = Split-Path -Parent '$($moduleInfo.Path)'
                    
                    # Define functions and aliases from the script
                    $moduleContent
                    
                    # Export all functions and aliases from this module scope
                    Export-ModuleMember -Function * -Alias *
"@)) | Import-Module -Global -Force
            }
            Write-Host "Loaded $($moduleInfo.Description) successfully" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to initialize module $moduleName`: $($_.Exception.Message)"
        }
    }
}

# Load module configuration
$moduleConfig = Import-PowerShellDataFile "$moduleRoot\Config\ModuleConfig.psd1"

# Register modules from configuration
foreach ($category in $moduleConfig.Keys) {
    foreach ($module in $moduleConfig[$category]) {        $scriptPath = "$env:USERPROFILE\OneDrive\Documents\PowerShell\Scripts\powershell-config\$($module.Path)"
        
        $initBlock = [ScriptBlock]::Create(@"
            # Create module scope
            New-Module -Name '$($module.Name)' -ScriptBlock {
                Set-StrictMode -Version Latest
                `$ErrorActionPreference = 'Stop'
                
                # Script-level variables
                `$script:moduleRoot = Split-Path -Parent '$scriptPath'
                
                # Import the script content
                . '$scriptPath'
                
                # Export all functions and aliases
                Export-ModuleMember -Function * -Alias *
            } | Import-Module -Global
"@)
        
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
