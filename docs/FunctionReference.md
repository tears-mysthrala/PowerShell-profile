% This file contains a curated snapshot of function docs extracted from the profile and core utils.

# Function Reference (auto-generated)

This document contains per-function documentation extracted from source files. To regenerate this file with live comments and signatures, run the generator script at `tools/generate_function_docs.ps1`.

## Register-UnifiedModule

Signature:

```powershell
Register-UnifiedModule [-Name] <string> [-MinVersion <string>] [-RequiredVersion <string>] [-Dependencies <string[]>] [-InitializerBlock <scriptblock>] [-OnFailure <scriptblock>] [-OnVersionMismatch <scriptblock>] [-LoadOnStartup <bool>] [-MaxAttempts <int>] [-IgnoreIfMissing] [-ModulePath <string>]
```

Summary:

Registers a module for lazy loading and enforces version/dependency constraints.

Example:

```powershell
Register-UnifiedModule -Name 'MyModule' -InitializerBlock { Import-Module 'MyModule' }
```

## Import-LazyModule

Signature:

```powershell
Import-LazyModule <string>
```

Summary:

Attempts to load a previously registered unified module.

## Register-UnifiedTool / Import-UnifiedTool

Signature:

```powershell
Register-UnifiedTool -Name <string> -InitializerBlock <scriptblock> [-LoadOnStartup <bool>]
Import-UnifiedTool <string>
```

Summary:

Register and import lightweight tool initializers (used for lazy tool setup).

## Initialize-StartupTools / Initialize-StartupModules

Signature:

```powershell
Initialize-StartupTools
Initialize-StartupModules
```

Summary:

Load tools and modules marked for startup. Modules are loaded in background jobs when possible and their load times are measured.

## Import-UnifiedModule

Signature:

```powershell
Import-UnifiedModule -Name <string> [-Force] [-Silent]
```

Summary:

Import a registered module using its initializer or module path, with retry and failure hooks.

## Get-UnifiedModuleStatus / Get-UnifiedToolStatus

Signature:

```powershell
Get-UnifiedModuleStatus
Get-UnifiedToolStatus
```

Summary:

Return the registry status for modules and tools (loaded, attempts, version constraints).

## Test-UnifiedModuleRequirements

Signature:

```powershell
Test-UnifiedModuleRequirements <string>
```

Summary:

Verify that a registered module satisfies its dependency and version requirements.

## Measure-Block / Start-BackgroundJob

Signature:

```powershell
Measure-Block -Name <string> -Block <scriptblock> [-Async]
Start-BackgroundJob -ScriptBlock <scriptblock> [-ArgumentList <object[]>]
```

Summary:

Helpers for measuring block execution time and creating background jobs (prefers Start-ThreadJob when available).

## Enable-TerminalIcons

Signature:

```powershell
Enable-TerminalIcons [-Async]
```

Summary:

Load the Terminal-Icons module (optionally in background).

## Ensure-ProfileManagement / Ensure-ProfileCore / Initialize-PSModules / Import-PSModule / Register-PSModule

Signature:

```powershell
Initialize-PSModules
Import-PSModule <string>
Register-PSModule -Name <string> -Description <string> -Category <string> -InitializerBlock <scriptblock>
```

Summary:

Lightweight wrappers and proxies that load profile helper modules on demand.

## Test-CatppuccinPresent

Signature:

```powershell
Test-CatppuccinPresent
```

Summary:

Check for the Catppuccin theme module in common module paths and attempt to clone if missing.

## Enable-FullPSReadLine

Signature:

```powershell
Enable-FullPSReadLine
```

Summary:

Enable full PSReadLine features (prediction, richer key handlers) lazily.

---

This file is a curated snapshot. To update it automatically, run `.	ools\generate_function_docs.ps1` from the repository root.

---

Note: This file was created by a heuristic extractor and may not contain every parameter detail or advanced examples. Run the generator script in `tools/` to refresh and expand entries.
 # Function Reference (auto-generated)

This document contains per-function documentation extracted from source files. It was generated from the repository's PowerShell scripts and profile. If you need more detail or examples, run the generator script in `tools/` to refresh.

### Register-UnifiedModule

Signature:

```powershell
Register-UnifiedModule [-Name] <string> [-MinVersion <string>] [-RequiredVersion <string>] [-Dependencies <string[]>] [-InitializerBlock <scriptblock>] [-OnFailure <scriptblock>] [-OnVersionMismatch <scriptblock>] [-LoadOnStartup <bool>] [-MaxAttempts <int>] [-IgnoreIfMissing] [-ModulePath <string>]
```
Short description:
Register a module with the unified module registry for lazy-loading, version checks and dependency handling.

Example:
```powershell
Register-UnifiedModule -Name 'MyModule' -MinVersion '1.0.0' -InitializerBlock { Import-Module 'MyModule' }
```

### Import-LazyModule
Signature:
```powershell
Import-LazyModule [<string>] $Name
```
Short description:
Attempts to load a registered unified module lazily.

Example:
```powershell
Import-LazyModule 'MyModule'
```

### Register-UnifiedTool
Signature:
```powershell
Register-UnifiedTool [-Name] <string> [-InitializerBlock <scriptblock>] [-LoadOnStartup <bool>]
```
Short description:
Register a tool initializer for lazy tool initialization.

Example:
```powershell
Register-UnifiedTool -Name 'MyTool' -InitializerBlock { Import-Module 'MyToolModule' }
```

### Import-UnifiedTool
Signature:
```powershell
Import-UnifiedTool [<string>] $Name
```
Short description:
Invoke a previously registered unified tool's initializer.

Example:
```powershell
Import-UnifiedTool 'MyTool'
```

### Initialize-StartupTools
Signature:
```powershell
Initialize-StartupTools
```
Short description:
Import all registered tools marked to load at startup.

### Get-UnifiedToolStatus
Signature:
```powershell
Get-UnifiedToolStatus
```
Short description:
Return an object listing known tool names and their loaded status.

### Test-UnifiedModuleRequirements
Signature:
```powershell
Test-UnifiedModuleRequirements [<string>] $Name
```
Short description:
Validate that a registered module meets its declared requirements (version, dependencies) before importing.

### Import-UnifiedModule
Signature:
```powershell
Import-UnifiedModule [-Name] <string> [-Force] [-Silent]
```
Short description:
Import a unified module, honoring registered initializers, manifest paths and error handlers.
# Function Reference (auto-generated)

This document contains per-function documentation extracted from source files. It was generated from the repository's PowerShell scripts and profile. If you need more detail or examples, run the generator script in `tools/` to refresh.

## Register-UnifiedModule

Signature:

```powershell
Register-UnifiedModule [-Name] <string> [-MinVersion <string>] [-RequiredVersion <string>] [-Dependencies <string[]>] [-InitializerBlock <scriptblock>] [-OnFailure <scriptblock>] [-OnVersionMismatch <scriptblock>] [-LoadOnStartup <bool>] [-MaxAttempts <int>] [-IgnoreIfMissing] [-ModulePath <string>]
```

Short description:

Register a module with the unified module registry for lazy-loading, version checks and dependency handling.

Example:

```powershell
Register-UnifiedModule -Name 'MyModule' -MinVersion '1.0.0' -InitializerBlock { Import-Module 'MyModule' }
```

## Import-LazyModule

Signature:

```powershell
Import-LazyModule [<string>] $Name
```

Short description:

Attempts to load a registered unified module lazily.

Example:

```powershell
Import-LazyModule 'MyModule'
```

## Register-UnifiedTool

Signature:

```powershell
Register-UnifiedTool [-Name] <string> [-InitializerBlock <scriptblock>] [-LoadOnStartup <bool>]
```

Short description:

Register a tool initializer for lazy tool initialization.

Example:

```powershell
Register-UnifiedTool -Name 'MyTool' -InitializerBlock { Import-Module 'MyToolModule' }
```

## Import-UnifiedTool

Signature:

```powershell
Import-UnifiedTool [<string>] $Name
```

Short description:

Invoke a previously registered unified tool's initializer.

Example:

```powershell
Import-UnifiedTool 'MyTool'
```

## Initialize-StartupTools

Signature:

```powershell
Initialize-StartupTools
```

Short description:

Import all registered tools marked to load at startup.

## Get-UnifiedToolStatus

Signature:

```powershell
Get-UnifiedToolStatus
```

Short description:

Return an object listing known tool names and their loaded status.

## Test-UnifiedModuleRequirements

Signature:

```powershell
Test-UnifiedModuleRequirements [<string>] $Name
```

Short description:

Validate that a registered module meets its declared requirements (version, dependencies) before importing.

## Import-UnifiedModule

Signature:

```powershell
Import-UnifiedModule [-Name] <string> [-Force] [-Silent]
```

Short description:

Import a unified module, honoring registered initializers, manifest paths and error handlers.

## Initialize-StartupModules

Signature:

```powershell
Initialize-StartupModules
```

Short description:

Load modules marked for startup in parallel background jobs and measure their load times.

## Get-UnifiedModuleStatus

Signature:

```powershell
Get-UnifiedModuleStatus
```

Short description:

Return module registry status including loaded flag, load attempts and version constraints.

## Register-ChocolateyProfile

Signature:

```powershell
Register-ChocolateyProfile
```

Short description:

Attempt to register a Chocolatey-specific profile module if Chocolatey is installed.

## Measure-Block

Signature:

```powershell
Measure-Block -Name <string> -Block <scriptblock> [-Async]
```

Short description:

Measure execution time for a provided block and optionally run it asynchronously via background jobs.

## Start-BackgroundJob

Signature:

```powershell
Start-BackgroundJob -ScriptBlock <scriptblock> [-ArgumentList <object[]>]
```

Short description:

Start a job using Start-ThreadJob when available or fall back to Start-Job.

## Enable-TerminalIcons

Signature:

```powershell
Enable-TerminalIcons [-Async]
```

Short description:

Load the Terminal-Icons module either synchronously or in the background.

## Ensure-ProfileManagement, Ensure-ProfileCore, Initialize-PSModules, Import-PSModule, Register-PSModule

Signature & short descriptions: see source in `Microsoft.PowerShell_profile.ps1`.

## Test-CatppuccinPresent

Signature:

```powershell
Test-CatppuccinPresent
```

Short description:

Check for the presence of the Catppuccin theme module in common module paths.

## Enable-FullPSReadLine

Signature:

```powershell
Enable-FullPSReadLine
```

Short description:

Enable full PSReadLine features and richer key handlers lazily.

---

Note: This file was created by a heuristic extractor and may not contain every parameter detail or advanced examples. Run the generator script in `tools/` to refresh and expand entries.
