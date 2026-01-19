# Installation Guide

## Prerequisites

### Required
- **PowerShell 7.5+** - Core runtime environment
  ```powershell
  winget install Microsoft.PowerShell
  ```

### Recommended
Modern CLI tools for enhanced functionality:

```powershell
# Package managers
winget install Chocolatey.Chocolatey
winget install ScoopInstaller.Scoop

# Essential tools
winget install sharkdp.bat           # Better 'cat'
winget install eza-community.eza     # Better 'ls'
winget install sharkdp.fd            # Better 'find'
winget install ajeetdsouza.zoxide    # Smart directory navigation
winget install Starship.Starship     # Cross-shell prompt
winget install junegunn.fzf          # Fuzzy finder
winget install JesseDuffield.lazygit # Git TUI

# Development
winget install GitHub.cli            # GitHub CLI
```

## Installation

### 1. Clone Repository

```powershell
# Backup existing profile (if any)
if (Test-Path $PROFILE) {
    Copy-Item $PROFILE "$PROFILE.backup-$(Get-Date -Format 'yyyyMMdd')"
}

# Clone into PowerShell documents folder
git clone https://github.com/tears-mysthrala/PowerShell-profile.git `
    "$HOME\Documents\PowerShell"
```

### 2. Install Dependencies (Automated)

```powershell
cd "$HOME\Documents\PowerShell"

# Install all recommended tools
.\tools\install-dependencies.ps1 -All

# Or install selectively
.\tools\install-dependencies.ps1 -Tools bat,eza,fd,fzf
```

### 3. Initialize Profile

```powershell
# Reload profile
. $PROFILE

# Verify installation
Get-Command Test-CommandExist -ErrorAction SilentlyContinue
```

## Performance Optimization

The profile includes aggressive caching optimizations:

- **Module cache**: JSON-based caching in `$env:TEMP\PSModuleCache.json`
- **Command cache**: Pre-cached existence checks for common tools
- **Init cache**: Starship/Zoxide/GH CLI initialization cached and auto-invalidated

**Expected load time:** ~500-600ms on modern hardware

### Cache Management

```powershell
# Clear all caches
Remove-Item $env:TEMP\PSModuleCache.json -ErrorAction SilentlyContinue
Remove-Item Config\*-cache.* -ErrorAction SilentlyContinue

# Rebuild cache on next profile load
. $PROFILE
```

## Troubleshooting

### Profile Not Loading

```powershell
# Check profile path
$PROFILE

# Verify file exists
Test-Path $PROFILE

# Check for syntax errors
pwsh -NoProfile -Command { . $PROFILE }
```

### Missing Commands

```powershell
# Check command availability
Test-CommandExist bat

# Verify PATH
$env:PATH -split ';' | Where-Object { $_ -match 'scoop|chocolatey' }
```

### Slow Load Times

```powershell
# Enable profiling
$env:PROFILE_TIMING = 1
. $PROFILE

# Check cache validity
Get-Item $env:TEMP\PSModuleCache.json | Select-Object LastWriteTime
```

### Module Import Failures

```powershell
# Force cache rebuild
Remove-Item $env:TEMP\PSModuleCache.json
Import-Module "$HOME\Documents\PowerShell\Core\UnifiedModuleManager.ps1" -Force
Initialize-ModuleCache -Force
```

## Verification

```powershell
# Test unified aliases
ll          # Should use 'eza' if available
cat --version  # Should use 'bat' if available

# Test navigation
z docs      # Zoxide navigation
..          # Parent directory

# Test git helpers
gst         # Git status
gl          # Git log

# Check module loading
Get-Module -Name PSFzf,posh-git
```

## Uninstallation

```powershell
# Remove profile
Remove-Item "$HOME\Documents\PowerShell" -Recurse -Force

# Restore backup (if exists)
Get-ChildItem "$HOME\Documents\PowerShell*.backup-*" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 1 | 
    Copy-Item -Destination "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
```

## Next Steps

- [Customize](CUSTOMIZATION.md) your environment
- Review [Function Reference](FunctionReference.md) for available commands
- Check [Quick Reference](QuickReference.md) for aliases
