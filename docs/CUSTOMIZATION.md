# Customization Guide

## Architecture Overview

```
PowerShell-profile/
├── Microsoft.PowerShell_profile.ps1    # Main orchestrator
├── Core/
│   ├── UnifiedModuleManager.ps1        # Module loading & caching
│   ├── Utils/unified_aliases.ps1       # Centralized aliases
│   ├── Apps/Updates/SystemUpdater.ps1  # Update management
│   └── System/                         # System utilities
├── Config/
│   ├── starship.toml                   # Prompt configuration
│   └── *-cache.*                       # Auto-generated caches
└── tools/
    └── generate_function_docs.ps1      # Documentation generator
```

## Adding Custom Functions

### Option 1: Direct Profile Addition

Add to `Microsoft.PowerShell_profile.ps1`:

```powershell
function My-CustomFunction {
    param([string]$Path)
    
    # Your logic here
    Get-ChildItem $Path -Recurse
}
```

### Option 2: Separate Module (Recommended)

Create `Core/Utils/MyCustomUtils.ps1`:

```powershell
<#
.SYNOPSIS
    Custom utilities for my workflow
.DESCRIPTION
    Collection of personalized helper functions
#>

function Deploy-Application {
    <#
    .SYNOPSIS
        Deploy application to target environment
    .EXAMPLE
        Deploy-Application -Environment Production
    #>
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Dev', 'Staging', 'Production')]
        [string]$Environment
    )
    
    Write-Host "Deploying to $Environment..."
    # Deployment logic
}

Export-ModuleMember -Function Deploy-Application
```

Then load in profile:

```powershell
# In Microsoft.PowerShell_profile.ps1
. "$PSScriptRoot\Core\Utils\MyCustomUtils.ps1"
```

## Adding Aliases

### Unified Aliases (Recommended)

Add to `Core/Utils/unified_aliases.ps1`:

```powershell
# Custom development aliases
Set-Alias -Name deploy -Value Deploy-Application
Set-Alias -Name build -Value Invoke-Build

# Tool shortcuts
if (Test-CommandExist 'kubectl') {
    Set-Alias -Name k -Value kubectl
    Set-Alias -Name kx -Value kubectx
}
```

### Profile-Specific Aliases

Add directly to `Microsoft.PowerShell_profile.ps1`:

```powershell
Set-Alias -Name myalias -Value My-CustomFunction
```

## Custom Module Integration

### Register External Modules

Add to profile after `Initialize-ModuleCache`:

```powershell
# Register custom modules
Register-UnifiedModule -Name 'MyCompanyModule' -ScriptBlock {
    Import-Module MyCompanyModule
    Write-Host "Company tools loaded" -ForegroundColor Green
}
```

### Conditional Module Loading

```powershell
# Load Azure modules only in work directories
if ($PWD.Path -match 'C:\\Work') {
    Register-UnifiedModule -Name 'Az' -ScriptBlock {
        Import-Module Az.Accounts, Az.Resources
    }
}
```

## Environment Variables

### Temporary (Session-only)

Add to profile:

```powershell
$env:MY_API_KEY = 'secret-key'
$env:WORKSPACE_ROOT = 'C:\Dev\Projects'
```

### Persistent (System-wide)

```powershell
[System.Environment]::SetEnvironmentVariable(
    'MY_VAR', 
    'value', 
    [System.EnvironmentVariableTarget]::User
)
```

## Prompt Customization

### Starship Configuration

Edit `Config/starship.toml`:

```toml
# Add custom modules
[custom.myproject]
command = "echo 🚀 MyProject"
when = "test -d .myproject"
style = "bold blue"
format = "[$output]($style) "

# Modify existing modules
[git_branch]
symbol = "🌱 "
style = "bold purple"
```

Invalidate cache after changes:

```powershell
Remove-Item Config\starship-init-cache.*
. $PROFILE
```

## Search Utilities

### Custom Search Functions

Add to `Core/Utils/SearchUtils.ps1`:

```powershell
function Search-CodePattern {
    <#
    .SYNOPSIS
        Search for specific code patterns
    #>
    param(
        [string]$Pattern,
        [string]$Path = '.'
    )
    
    if (Test-CommandExist fd) {
        fd -e ps1 -e psm1 -x rg $Pattern {} $Path
    } else {
        Get-ChildItem $Path -Recurse -Include *.ps1,*.psm1 | 
            Select-String $Pattern
    }
}
```

## Performance Optimization

### Custom Cache Implementation

```powershell
# Add to profile
$script:MyCache = @{}

function Get-CachedData {
    param([string]$Key)
    
    if (-not $script:MyCache.ContainsKey($Key)) {
        $script:MyCache[$Key] = Invoke-ExpensiveOperation $Key
    }
    return $script:MyCache[$Key]
}
```

### Lazy Loading Pattern

```powershell
function Initialize-DockerEnvironment {
    if (-not $script:DockerInitialized) {
        Import-Module DockerCompletion
        # Docker-specific setup
        $script:DockerInitialized = $true
    }
}

# Only initialize when needed
Set-Alias -Name docker -Value Initialize-DockerEnvironment
```

## Git Integration

### Custom Git Helpers

Add to `Core/Utils/Development/gitHelpers.ps1`:

```powershell
function New-FeatureBranch {
    param([Parameter(Mandatory)]
          [string]$Name)
    
    $branchName = "feature/$Name"
    git checkout -b $branchName
    git push -u origin $branchName
}

Set-Alias -Name gfb -Value New-FeatureBranch
```

## Update Management

### Custom Update Sources

Add to `Core/Apps/Updates/SystemUpdater.ps1`:

```powershell
function Update-CustomTools {
    <#
    .SYNOPSIS
        Update custom tool installations
    #>
    
    # Example: Update rust tools
    if (Test-CommandExist cargo) {
        cargo install-update -a
    }
    
    # Example: Update npm globals
    if (Test-CommandExist npm) {
        npm update -g
    }
}
```

Register in main updater:

```powershell
# In Update-AllSystems function
Update-CustomTools
```

## Testing Custom Functions

### Unit Testing with Pester

Create `tests/MyCustomUtils.Tests.ps1`:

```powershell
BeforeAll {
    . "$PSScriptRoot\..\Core\Utils\MyCustomUtils.ps1"
}

Describe 'Deploy-Application' {
    It 'Should accept valid environments' {
        { Deploy-Application -Environment Dev } | Should -Not -Throw
    }
    
    It 'Should reject invalid environments' {
        { Deploy-Application -Environment InvalidEnv } | Should -Throw
    }
}
```

Run tests:

```powershell
Invoke-Pester -Path tests\
```

## Documentation Generation

Custom functions automatically included in docs if properly commented:

```powershell
function My-Function {
    <#
    .SYNOPSIS
        Brief description
    
    .DESCRIPTION
        Detailed description
    
    .PARAMETER Name
        Parameter description
    
    .EXAMPLE
        My-Function -Name "Test"
        Example usage
    
    .NOTES
        Additional notes
    #>
    param([string]$Name)
    # Implementation
}
```

Regenerate docs:

```powershell
.\tools\generate_function_docs.ps1 -Verbose
```

## Best Practices

1. **Use structured comments** - Enable auto-documentation
2. **Cache expensive operations** - Improve load times
3. **Conditional loading** - Only load what's needed
4. **Test-CommandExist** - Check tool availability before use
5. **Export-ModuleMember** - Explicit module exports
6. **Validate parameters** - Use `[ValidateSet]`, `[Parameter(Mandatory)]`
7. **Version control** - Commit custom changes separately
8. **Document decisions** - Comments for complex logic

## Example: Complete Custom Module

```powershell
# File: Core/Utils/ProjectUtils.ps1

<#
.SYNOPSIS
    Project management utilities
#>

# Cache for project paths
$script:ProjectCache = @{}

function Set-ProjectRoot {
    <#
    .SYNOPSIS
        Register a project root directory
    .EXAMPLE
        Set-ProjectRoot -Name "MyApp" -Path "C:\Dev\MyApp"
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Path
    )
    
    $script:ProjectCache[$Name] = $Path
}

function Go-Project {
    <#
    .SYNOPSIS
        Navigate to registered project
    .EXAMPLE
        Go-Project MyApp
    #>
    param([Parameter(Mandatory)]
          [string]$Name)
    
    if ($script:ProjectCache.ContainsKey($Name)) {
        Set-Location $script:ProjectCache[$Name]
    } else {
        Write-Warning "Project '$Name' not registered"
    }
}

# Auto-register common projects
Set-ProjectRoot -Name "Profile" -Path "$HOME\Documents\PowerShell"
Set-ProjectRoot -Name "Repos" -Path "$HOME\source\repos"

# Aliases
Set-Alias -Name gp -Value Go-Project

Export-ModuleMember -Function Set-ProjectRoot, Go-Project -Alias gp
```

Load in profile:

```powershell
. "$PSScriptRoot\Core\Utils\ProjectUtils.ps1"
```
