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

- **[⚙️ Installation Guide](docs/INSTALLATION.md)** - Setup instructions, requirements & troubleshooting
- **[🔧 Customization Guide](docs/CUSTOMIZATION.md)** - Extend and modify the environment
- **[📖 Function Reference](docs/FunctionReference.md)** - Generated function signatures and source locations
- **[📋 Quick Reference](docs/QuickReference.md)** - Fast lookup table for functions and aliases
- **[🗺️ Roadmap](ROADMAP.md)** - Current state, plans, and explicit non-goals

## Key Features

- **File Operations**: Explicit helpers for file creation, archive extraction, and content search
- **Navigation**: Smart directory navigation with `..`, `...`, and fuzzy finding
- **Git Integration**: Streamlined git operations with aliases and helpers
- **Package Management**: A manual `upgrade` command for system, package-manager, runtime, and development-tool updates
- **Development Tools**: Integration with `bat`, `fzf`, `eza`, and other modern CLI tools
- **Performance Monitoring**: Built-in timing and optimization features

## Performance

Interactive commands and `upgrade` are exposed through PowerShell module autoloading. Their implementation is parsed only on first use. Actual load time depends on the host, installed tools and filesystem; measure it with `$script:profileTiming` or against `pwsh -NoProfile`.

### Optimization Features

- **Command autoloading**: general commands, Chezmoi and `upgrade` live in separate manifests under `Modules/`
- **Early non-interactive exit**: automation avoids aliases, PSReadLine and prompt setup
- **Starship init cache**: Full PowerShell init script cached and auto-invalidated on binary/config changes
- **Deferred integrations**: optional completions run after the first prompt or on first use

**Cache management:**
```powershell
# Clear all caches
Remove-Item Config\*-cache.*
. $PROFILE  # Rebuild on reload
```

## Requirements

- PowerShell 7+
- Optional: `git`, `fzf`, `bat`, `eza`, `lazygit`, `zoxide`

## Contributing

This project uses local validation and documentation generation. Before committing:

1. **Run local checks**:
   - Syntax validation: `pwsh -Command "Get-ChildItem -Recurse *.ps1,*.psm1 | ForEach-Object { try { $null = [scriptblock]::Create((Get-Content $_.FullName -Raw)) } catch { Write-Error \"Syntax error in $($_.Name): $_\" } }"`
   - PSScriptAnalyzer: analyze the PowerShell files returned by `git ls-files`, matching CI
   - Performance test: Load time check manually

2. **Update documentation** (automated via GitHub Actions):
   - Manual generation: `.\tools\generate_function_docs.ps1 -Verbose`
   - Auto-generated every Sunday 6 AM GMT if code changes detected
   - Or trigger manually from GitHub Actions UI

3. **When adding new functions**:
   - Place them in the appropriate implementation file and export them from the corresponding manifest under `Modules/`
   - Add descriptive comments above function definitions

### Adding New Dependencies

When adding new tools or dependencies:

1. Update `tools/install-dependencies.ps1` with the new tool definition
2. Add installation methods for supported package managers (winget, choco, scoop)
3. Update the documentation in `docs/INSTALLATION.md`
4. Test the installation: `Install-Dependencies -Tool <toolname>`


## 📊 Statistics

- **Functions:** 127 across Core/, tools/install-dependencies.ps1, and the main profile
- **Aliases:** 35
- **Categories:** 6
- **Last Updated:** 2026-08-27 17:04:34

## License

Released under the [MIT License](LICENSE).
