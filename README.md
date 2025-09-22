# PowerShell Environment Configuration [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/tears-mysthrala/PowerShell-profile)

A comprehensive PowerShell environment setup with various utilities, aliases, and functions for enhanced productivity.

## Features

### File Operations

- `New-File` (alias: `touch`): Create a new empty file
- `mkcd`: Create a directory and navigate into it
- `find-file`: Search for files by name
- `Find-String` (alias: `grep`): Search for text within files
- `Edit-FileContent` (alias: `sed`): Edit file content with find and replace

Archive Operations:

- `Expand-ZipFile` (alias: `unzip`): Extract zip files
- `Expand-CustomArchive` (alias: `extract`): Extract various archive formats
- `Expand-MultipleArchives` (alias: `extract_multi`): Extract multiple archives

### Navigation and Directory Management

- `..`: Go up one directory
- `...`: Go up two directories
- `.3`, `.4`, `.5`: Go up three, four, or five directories

Directory listing (using eza if available):

- `l`: Simple listing
- `ll`: Detailed listing
- `ld`: List directories
- `lt`: Tree view
- `llt`: Detailed tree view

### System Operations

- `Get-BatteryReport`: Generate battery health report
- `Get-PubIP`: Get public IP address
- `Get-FormatedUptime` (alias: `uptime`): Display system uptime
- `Clear-DnsCache` (alias: `flushdns`): Clear DNS cache
- `Test-IsAdmin`: Check if running as administrator
- `sysinfo`: Display system information

Cleanup utilities:

- `Clean-RecycleBin`: Empty recycle bin
- `Clean-TempData`: Clean temporary files
- `Clean-Disk`: Run disk cleanup
- `Clean-All`: Run all cleanup operations

### Process Management

- `Stop-ProcessByName` (alias: `pkill`): Stop processes by name
- `Get-ProcessByName` (alias: `pgrep`): Get processes by name

### Clipboard Operations

- `Set-ClipboardContent` (alias: `cpy`): Copy content to clipboard
- `Get-ClipboardContent` (alias: `pst`): Get content from clipboard

### Git Operations

- `g` (alias for `git`)
- `gst`: Git status
- `pull`: Git pull
- `push`: Git push
- `lg` (alias for `lazygit` if installed)

Git helpers:

- `show_git_head`: Show current HEAD
- `pretty_git_log`: Formatted git log
- `pretty_git_branch`: Formatted branch list
- `pretty_git_branch_sorted`: Sorted branch list

### Development Tools

- `chtsh`: Access cheat.sh for command documentation
- `bat`: Enhanced file viewer (replaces `cat` if available)
- `fzf`: Fuzzy finder integration

- `Ctrl+f`: Fuzzy file search
- `Ctrl+g`: Fuzzy git branch selection
- `fdg`: Directory search
- `rgg`: Ripgrep search

### System Updates

- `Update-System`: Update system components
- `Update-PowerShellModules`: Update PowerShell modules
- `Update-AllApps`: Update all package managers and applications

### Package Management

Chocolatey:

- `Get-ChocoApps`: List installed Chocolatey packages
- `Update-ChocoApps`: Update Chocolatey packages
- `Uninstall-ChocoApps`: Remove Chocolatey packages

Scoop:

- `Get-ScoopApps`: List installed Scoop packages
- `Update-ScoopApps`: Update Scoop packages
- `Uninstall-ScoopApps`: Remove Scoop packages

### Module Management

- `Get-AvailableModules` (alias: `modules`): List available modules
- `Register-PSModule`: Register a new PowerShell module
- `Import-PSModule`: Import a registered module
- `Initialize-PSModules`: Initialize startup modules

## Installation

Clone this repository to your PowerShell directory:

```powershell
git clone https://github.com/yourusername/powershell-config.git $HOME\Documents\PowerShell
```

Initialize the environment:

```powershell
. $PROFILE
```

## Requirements

- PowerShell 7+

Optional but recommended tools:

- `git`: Version control
- `fzf`: Fuzzy finder
- `bat`: Enhanced file viewer
- `eza`: Modern ls replacement
- `lazygit`: Terminal UI for git
- `zoxide`: Smarter cd command

## Customization

The environment is modular and can be customized by:

1. Adding new functions to `Core/Utils/`
2. Modifying aliases in `Core/Utils/unified_aliases.psd1`
3. Adding new modules through `Register-PSModule`

## Performance

The profile includes performance monitoring and will display startup timing information for each component when loaded.

## New functions & aliases (auto-generated)

The following is a concise, auto-generated summary of additional functions and aliases discovered in this repository (scanned files in `Core/`, `Scripts/` and the profile). Use these names in your profile or modules as documented in their source files.

Scanned on: 2025-09-16

### Notable functions (name — source file)

- Register-UnifiedModule — Core/UnifiedModuleManager.ps1
- Import-LazyModule — Core/UnifiedModuleManager.ps1
- Register-UnifiedTool — Core/UnifiedModuleManager.ps1
- Import-UnifiedTool — Core/UnifiedModuleManager.ps1
- Initialize-StartupTools — Core/UnifiedModuleManager.ps1
- Get-UnifiedToolStatus — Core/UnifiedModuleManager.ps1
- Test-UnifiedModuleRequirements — Core/UnifiedModuleManager.ps1
- Import-UnifiedModule — Core/UnifiedModuleManager.ps1
- Initialize-StartupModules — Core/UnifiedModuleManager.ps1
- Get-UnifiedModuleStatus — Core/UnifiedModuleManager.ps1
- Register-ChocolateyProfile — Core/UnifiedModuleManager.ps1
- Measure-Block — Microsoft.PowerShell_profile.ps1
- Start-BackgroundJob — Microsoft.PowerShell_profile.ps1
- Enable-TerminalIcons — Microsoft.PowerShell_profile.ps1
- Ensure-ProfileManagement — Microsoft.PowerShell_profile.ps1
- Ensure-ProfileCore — Microsoft.PowerShell_profile.ps1
- Initialize-PSModules — Microsoft.PowerShell_profile.ps1
- Import-PSModule — Microsoft.PowerShell_profile.ps1
- Register-PSModule — Microsoft.PowerShell_profile.ps1
- Initialize-Starship — Microsoft.PowerShell_profile.ps1 (helper to initialize starship prompt)
- Test-CatppuccinPresent — Microsoft.PowerShell_profile.ps1
- Enable-FullPSReadLine — Microsoft.PowerShell_profile.ps1
- Test-CommandExists — Core/Utils/unified_aliases.ps1
- New-DirectoryAndEnter — Core/Utils/FileSystemUtils.ps1 (aliased as `mkcd`)
- Find-Files — Core/Utils/SearchUtils.ps1 (aliased as `ff`)
- Search-FileContent — Core/Utils/SearchUtils.ps1 (aliased as `search`)

### Notable aliases (alias -> target)

- v -> $EDITOR (editor shortcut)
- e -> explorer.exe
- c, csl -> cls (clear screen)
- ss, grep -> Select-String (search within files)
- shutdownnow -> Stop-Computer
- rebootnow -> Restart-Computer
- g -> git
- gst -> git-status
- pull -> git-pull
- push -> git-push
- d -> docker
- dc -> docker-compose
- lg -> lazygit
- cat -> bat (if `bat` is available)
- ls -> ls_with_exa (if `eza`/exa integration is available)
- ll -> ll_with_exa / ll
- touch -> New-File
- grep -> Find-String (note: `grep` may be remapped in multiple places)
- export -> Set-EnvironmentVariable
- pkill -> Stop-ProcessByName
- pgrep -> Get-ProcessByName
- unzip -> Expand-ZipFile
- flushdns -> Clear-DnsCache
- cpy -> Set-ClipboardContent
- pst -> Get-ClipboardContent
- sed -> Edit-FileContent
- which -> Get-CommandPath / Find-Command (multiple `which` aliases appear in different modules)
- extract -> Expand-CustomArchive
- extract_multi / extract-multi -> Expand-MultipleArchives / Expand-CustomArchives
- ff -> Find-Files
- search -> Search-FileContent

Notes:

- Some aliases are defined in multiple files and may be conditionally set depending on available tools (e.g. `bat`, `eza`, `lazygit`). Check the source file to see conditional guards.
- If you want this list to be exhaustive or to include parameter signatures and examples, I can add per-function usage snippets (requires reading each file's header-comments).

Function reference docs:

- A more detailed per-function reference is available at `docs/FunctionReference.md` (generated). It contains signatures, short descriptions and source file references.

Regenerate the docs:

Run the generator script to re-scan source files and refresh `docs/FunctionReference.md`:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\generate_function_docs.ps1
```

This script performs a heuristic extraction of functions and nearby comment blocks. It is best-effort — if you want it to include examples from comment-based help, I can extend it to parse advanced comment formats.
