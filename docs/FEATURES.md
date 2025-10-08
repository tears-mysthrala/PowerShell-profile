# Features

This PowerShell environment provides a comprehensive set of utilities, aliases, and functions for enhanced productivity.

## File Operations

- `New-File` (alias: `touch`): Create a new empty file
- `mkcd`: Create a directory and navigate into it
- `find-file`: Search for files by name
- `Find-String` (alias: `grep`): Search for text within files
- `Edit-FileContent` (alias: `sed`): Edit file content with find and replace

### Archive Operations

- `Expand-ZipFile` (alias: `unzip`): Extract zip files
- `Expand-CustomArchive` (alias: `extract`): Extract various archive formats
- `Expand-MultipleArchives` (alias: `extract_multi`): Extract multiple archives

## Navigation and Directory Management

- `..`: Go up one directory
- `...`: Go up two directories
- `.3`, `.4`, `.5`: Go up three, four, or five directories

### Directory listing (using eza if available)

- `l`: Simple listing
- `ll`: Detailed listing
- `ld`: List directories
- `lt`: Tree view
- `llt`: Detailed tree view

## System Operations

- `Get-BatteryReport`: Generate battery health report
- `Get-PubIP`: Get public IP address
- `Get-FormatedUptime` (alias: `uptime`): Display system uptime
- `Clear-DnsCache` (alias: `flushdns`): Clear DNS cache
- `Test-IsAdmin`: Check if running as administrator
- `sysinfo`: Display system information

### Cleanup utilities

- `Clean-RecycleBin`: Empty recycle bin
- `Clean-TempData`: Clean temporary files
- `Clean-Disk`: Run disk cleanup
- `Clean-All`: Run all cleanup operations

## Process Management

- `Stop-ProcessByName` (alias: `pkill`): Stop processes by name
- `Get-ProcessByName` (alias: `pgrep`): Get processes by name

## Clipboard Operations

- `Set-ClipboardContent` (alias: `cpy`): Copy content to clipboard
- `Get-ClipboardContent` (alias: `pst`): Get content from clipboard

## Git Operations

- `g` (alias for `git`)
- `gst`: Git status
- `pull`: Git pull
- `push`: Git push
- `lg` (alias for `lazygit` if installed)

### Git helpers

- `show_git_head`: Show current HEAD
- `pretty_git_log`: Formatted git log
- `pretty_git_branch`: Formatted branch list
- `pretty_git_branch_sorted`: Sorted branch list

## Development Tools

- `chtsh`: Access cheat.sh for command documentation
- `bat`: Enhanced file viewer (replaces `cat` if available)
- `fzf`: Fuzzy finder integration

### Fuzzy finder shortcuts

- `Ctrl+f`: Fuzzy file search
- `Ctrl+g`: Fuzzy git branch selection
- `fdg`: Directory search
- `rgg`: Ripgrep search

## System Updates

- `Update-System`: Update system components
- `Update-PowerShellModules`: Update PowerShell modules
- `Update-AllApps`: Update all package managers and applications

## Package Management

### Chocolatey

- `Get-ChocoApps`: List installed Chocolatey packages
- `Update-ChocoApps`: Update Chocolatey packages
- `Uninstall-ChocoApps`: Remove Chocolatey packages

### Scoop

- `Get-ScoopApps`: List installed Scoop packages
- `Update-ScoopApps`: Update Scoop packages
- `Uninstall-ScoopApps`: Remove Scoop packages

## Module Management

- `Get-AvailableModules` (alias: `modules`): List available modules
- `Register-PSModule`: Register a new PowerShell module
- `Import-PSModule`: Import a registered module
- `Initialize-PSModules`: Initialize startup modules