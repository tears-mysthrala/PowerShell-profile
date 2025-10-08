# Functions & Aliases Reference

This file contains an auto-generated summary of functions and aliases discovered in the PowerShell profile repository.

**Scanned on:** 2025-10-08

## Notable Functions

| Function | Source File |
|----------|-------------|
| Register-UnifiedModule | Core/UnifiedModuleManager.ps1 |
| Import-LazyModule | Core/UnifiedModuleManager.ps1 |
| Register-UnifiedTool | Core/UnifiedModuleManager.ps1 |
| Import-UnifiedTool | Core/UnifiedModuleManager.ps1 |
| Initialize-StartupTools | Core/UnifiedModuleManager.ps1 |
| Get-UnifiedToolStatus | Core/UnifiedModuleManager.ps1 |
| Test-UnifiedModuleRequirements | Core/UnifiedModuleManager.ps1 |
| Import-UnifiedModule | Core/UnifiedModuleManager.ps1 |
| Initialize-StartupModules | Core/UnifiedModuleManager.ps1 |
| Get-UnifiedModuleStatus | Core/UnifiedModuleManager.ps1 |
| Register-ChocolateyProfile | Core/UnifiedModuleManager.ps1 |
| Measure-Block | Microsoft.PowerShell_profile.ps1 |
| Start-BackgroundJob | Microsoft.PowerShell_profile.ps1 |
| Enable-TerminalIcons | Microsoft.PowerShell_profile.ps1 |
| Ensure-ProfileManagement | Microsoft.PowerShell_profile.ps1 |
| Ensure-ProfileCore | Microsoft.PowerShell_profile.ps1 |
| Initialize-PSModules | Microsoft.PowerShell_profile.ps1 |
| Import-PSModule | Microsoft.PowerShell_profile.ps1 |
| Register-PSModule | Microsoft.PowerShell_profile.ps1 |
| Initialize-Starship | Microsoft.PowerShell_profile.ps1 (helper to initialize starship prompt) |
| Test-CatppuccinPresent | Microsoft.PowerShell_profile.ps1 |
| Enable-FullPSReadLine | Microsoft.PowerShell_profile.ps1 |
| Test-CommandExists | Core/Utils/unified_aliases.ps1 |
| New-DirectoryAndEnter | Core/Utils/FileSystemUtils.ps1 (aliased as `mkcd`) |
| Find-Files | Core/Utils/SearchUtils.ps1 (aliased as `ff`) |
| Search-FileContent | Core/Utils/SearchUtils.ps1 (aliased as `search`) |

## Notable Aliases

| Alias | Target | Notes |
|-------|--------|-------|
| v | $EDITOR | editor shortcut |
| e | explorer.exe |  |
| c, csl | cls | clear screen |
| ss, grep | Select-String | search within files |
| shutdownnow | Stop-Computer |  |
| rebootnow | Restart-Computer |  |
| g | git |  |
| gst | git-status |  |
| pull | git-pull |  |
| push | git-push |  |
| d | docker |  |
| dc | docker-compose |  |
| lg | lazygit |  |
| cat | bat | if `bat` is available |
| ls | ls_with_exa | if `eza`/exa integration is available |
| ll | ll_with_exa / ll |  |
| touch | New-File |  |
| grep | Find-String | note: `grep` may be remapped in multiple places |
| export | Set-EnvironmentVariable |  |
| pkill | Stop-ProcessByName |  |
| pgrep | Get-ProcessByName |  |
| unzip | Expand-ZipFile |  |
| flushdns | Clear-DnsCache |  |
| cpy | Set-ClipboardContent |  |
| pst | Get-ClipboardContent |  |
| sed | Edit-FileContent |  |
| which | Get-CommandPath / Find-Command | multiple `which` aliases appear in different modules |
| extract | Expand-CustomArchive |  |
| extract_multi / extract-multi | Expand-MultipleArchives / Expand-CustomArchives |  |
| ff | Find-Files |  |
| search | Search-FileContent |  |

## Notes

- Some aliases are defined in multiple files and may be conditionally set depending on available tools (e.g. `bat`, `eza`, `lazygit`). Check the source file to see conditional guards.
- If you want this list to be exhaustive or to include parameter signatures and examples, I can add per-function usage snippets (requires reading each file's header-comments).

## Detailed Function Reference

A detailed per-function reference with signatures, descriptions, and source file references is available at [`docs/FunctionReference.md`](FunctionReference.md) (auto-generated). It contains 499 functions found in the codebase.

## Regenerating Documentation

Run the generator script to re-scan source files and refresh the documentation:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\generate_function_docs.ps1
```

This script performs heuristic extraction of functions and nearby comment blocks. It is best-effort — if you want it to include examples from comment-based help, I can extend it to parse advanced comment formats.



