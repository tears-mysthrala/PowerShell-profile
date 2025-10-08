# Installation & Requirements

## Installation

Clone this repository to your PowerShell directory:

```powershell
git clone https://github.com/tears-mysthrala/PowerShell-profile.git $HOME\Documents\PowerShell
```

Initialize the environment:

```powershell
. $PROFILE
```

## Quick Setup (Recommended)

For a new system, you can automatically install all recommended dependencies using the provided installer script:

```powershell
# Install all dependencies (package managers + CLI tools)
.\tools\install-dependencies.ps1 -All

# Or install just package managers first
.\tools\install-dependencies.ps1 -PackageManagers

# Then install CLI tools individually
.\tools\install-dependencies.ps1 -Git -Fzf -Bat -Eza
```

### What Gets Installed

The `-All` option installs:

- **Package Managers**: Chocolatey, Scoop, Winget (checks availability)
- **CLI Tools**: Git, fzf, bat, eza, lazygit, zoxide, ripgrep, fd

### Selective Installation

Install specific tools individually:

```powershell
# Essential tools
.\tools\install-dependencies.ps1 -Git -Fzf

# File utilities
.\tools\install-dependencies.ps1 -Bat -Eza -Ripgrep -Fd

# Git tools
.\tools\install-dependencies.ps1 -Lazygit -Git

# Navigation
.\tools\install-dependencies.ps1 -Zoxide

# Package managers only
.\tools\install-dependencies.ps1 -PackageManagers
```

### Dry Run

See what would be installed without actually installing:

```powershell
.\tools\install-dependencies.ps1 -All -WhatIf
```

## Requirements

### Required

- **PowerShell 7+**: This profile requires PowerShell 7 or higher for full functionality

### Optional but Recommended

- `git`: Version control operations
- `fzf`: Fuzzy finder for enhanced search capabilities
- `bat`: Enhanced file viewer (replaces `cat`)
- `eza`: Modern replacement for `ls` with better formatting
- `lazygit`: Terminal UI for git operations
- `zoxide`: Smarter `cd` command with frecency-based navigation
- `ripgrep` (`rg`): Fast text search tool
- `fd`: Fast alternative to `find`

### Package Managers

The dependency installer supports multiple package managers:

- **Chocolatey**: Windows package manager
- **Scoop**: Alternative Windows package manager
- **Winget**: Microsoft's official package manager (built-in on Windows 10/11)

## Performance

The profile includes performance monitoring and will display startup timing information for each component when loaded. Components are loaded asynchronously where possible to minimize startup time impact.
