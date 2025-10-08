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

- **Chocolatey**: Windows package manager
- **Scoop**: Alternative Windows package manager
- **Winget**: Microsoft's official package manager

## Performance

The profile includes performance monitoring and will display startup timing information for each component when loaded. Components are loaded asynchronously where possible to minimize startup time impact.
