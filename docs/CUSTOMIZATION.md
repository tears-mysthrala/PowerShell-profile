# Customization

The PowerShell environment is modular and can be customized to fit your workflow.

## Adding New Functions

Add new functions to the appropriate directory in `Core/Utils/`:

- `Core/Utils/FileSystemUtils.ps1`: File and directory operations
- `Core/Utils/SearchUtils.ps1`: Search and find operations
- `Core/Utils/CommonUtils.ps1`: General utility functions

Example of adding a new function:

```powershell
function Get-MyCustomFunction {
    param([string]$Parameter)
    # Your function logic here
    Write-Host "Custom function executed with: $Parameter"
}
```

## Modifying Aliases

Modify aliases in `Core/Utils/unified_aliases.psd1`. The file uses a hashtable format:

```powershell
@{
    'myalias' = 'target-command'
    'll' = 'Get-ChildItem'
}
```

## Adding New Modules

Use the built-in module management system:

```powershell
Register-PSModule -Name "MyModule" -Path "C:\Path\To\MyModule.psm1"
Import-PSModule -Name "MyModule"
```

## Configuration Files

### Starship Prompt

Customize the starship prompt in `Config/starship.toml`:

```toml
[character]
success_symbol = "[➜](bold green) "
error_symbol = "[✗](bold red) "

[git_branch]
symbol = "🌱 "
```

### Environment Variables

Environment variables are cached in `Config/env-cache.clixml` for performance. To force a refresh:

```powershell
Remove-Item "$PSScriptRoot\Config\env-cache.clixml"
. $PROFILE
```

## Conditional Loading

Functions can be conditionally loaded based on available tools:

```powershell
if (Get-Command 'bat' -ErrorAction SilentlyContinue) {
    Set-Alias 'cat' 'bat' -Option AllScope
}
```

## Performance Optimization

- Functions are loaded on-demand where possible
- Heavy operations are performed asynchronously
- Results are cached to improve subsequent loads

## Troubleshooting

### Profile Loading Issues

Check the startup timing output for slow-loading components:

```powershell
# The profile displays timing information on load
# Look for any components taking unusually long
```

### Function Conflicts

If you encounter function conflicts, check for duplicate definitions:

```powershell
Get-Command -Name ConflictingFunctionName -All
```

### Module Loading Problems

Verify module requirements are met:

```powershell
Test-UnifiedModuleRequirements -Name "ProblemModule"
```