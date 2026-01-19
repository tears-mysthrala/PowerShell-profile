# PowerShell Environment Configuration [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/tears-mysthrala/PowerShell-profile)

A comprehensive PowerShell environment setup with various utilities, aliases, and functions for enhanced productivity.

## Quick Start

```powershell
# Clone the repository
git clone https://github.com/tears-mysthrala/PowerShell-profile.git $HOME\Documents\PowerShell

# Install all dependencies (optional, but recommended)
.\tools\install-dependencies.ps1 -All

# Initialize the environment
. $PROFILE
```

## Documentation

- **[📋 Features](docs/FEATURES.md)** - Complete list of available functions and aliases
- **[⚙️ Installation & Requirements](docs/INSTALLATION.md)** - Setup instructions and system requirements
- **[🔧 Customization](docs/CUSTOMIZATION.md)** - How to extend and modify the environment
- **[📚 Functions Reference](docs/FUNCTIONS.md)** - Auto-generated function and alias documentation
- **[📖 Function Reference](docs/FunctionReference.md)** - Detailed function signatures and descriptions

## Key Features

- **File Operations**: Enhanced file manipulation with aliases like `touch`, `grep`, `sed`
- **Navigation**: Smart directory navigation with `..`, `...`, and fuzzy finding
- **Git Integration**: Streamlined git operations with aliases and helpers
- **Package Management**: Support for Chocolatey, Scoop, and system updates
- **Development Tools**: Integration with `bat`, `fzf`, `eza`, and other modern CLI tools
- **Performance Monitoring**: Built-in timing and optimization features

## Performance

- Starship prompt initialization is cached: the profile generates the full PowerShell init script once and reuses it on subsequent starts, avoiding a process spawn on each shell load. The cache is automatically invalidated when either the Starship binary or `Config/starship.toml` changes. You can force regeneration by deleting `Config/starship-init-cache.ps1` and `Config/starship-init-cache.meta.clixml`.

## Requirements

- PowerShell 7+
- Optional: `git`, `fzf`, `bat`, `eza`, `lazygit`, `zoxide`

## Contributing

This project uses local validation and documentation generation. Before committing:

1. **Run local checks**:
   - Syntax validation: `pwsh -Command "Get-ChildItem -Recurse *.ps1,*.psm1 | ForEach-Object { try { $null = [scriptblock]::Create((Get-Content $_.FullName -Raw)) } catch { Write-Error \"Syntax error in $($_.Name): $_\" } }"`
   - PSScriptAnalyzer: `Install-Module PSScriptAnalyzer; Invoke-ScriptAnalyzer -Path . -Recurse`
   - Performance test: Load time check manually

2. **Update documentation**:
   - Run the docs generator locally: `.\tools\generate_function_docs.ps1`
   - Or use the prepare script: `.\tools\prepare-commit.bat`

3. **When adding new functions**:
   - Place them in appropriate files under `Core/Utils/`
   - Add descriptive comments above function definitions

### Adding New Dependencies

When adding new tools or dependencies:

1. Update `tools/DependencyInstaller.ps1` with the new tool definition
2. Add installation methods for supported package managers (winget, choco, scoop)
3. Update the documentation in `docs/INSTALLATION.md`
4. Test the installation: `Install-Dependencies -Tool <toolname>`


## 📊 Statistics

- **Functions:** 628
- **Aliases:** 40
- **Categories:** 6
- **Last Updated:** 2026-01-19 20:16:14

