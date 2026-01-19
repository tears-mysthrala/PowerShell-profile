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
- **[📖 Function Reference](docs/FunctionReference.md)** - Complete function signatures and documentation (628 functions)
- **[📋 Quick Reference](docs/QuickReference.md)** - Fast lookup table for functions and aliases

## Key Features

- **File Operations**: Enhanced file manipulation with aliases like `touch`, `grep`, `sed`
- **Navigation**: Smart directory navigation with `..`, `...`, and fuzzy finding
- **Git Integration**: Streamlined git operations with aliases and helpers
- **Package Management**: Support for Chocolatey, Scoop, and system updates
- **Development Tools**: Integration with `bat`, `fzf`, `eza`, and other modern CLI tools
- **Performance Monitoring**: Built-in timing and optimization features

## Performance

**Current load time: ~500-600ms** (optimized with aggressive caching)

### Optimization Features

- **Module caching**: JSON-based cache in `$env:TEMP\PSModuleCache.json` eliminates repeated `Get-Module -ListAvailable` calls
- **Command pre-caching**: Common tools (bat, eza, fd, zoxide, etc.) checked once at startup
- **Starship init cache**: Full PowerShell init script cached and auto-invalidated on binary/config changes
- **Path caching**: Repeated path checks cached in session memory
- **Parallel updates**: Module updates run in parallel using `Start-ThreadJob`

**Cache management:**
```powershell
# Clear all caches
Remove-Item $env:TEMP\PSModuleCache.json
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
   - PSScriptAnalyzer: `Install-Module PSScriptAnalyzer; Invoke-ScriptAnalyzer -Path . -Recurse`
   - Performance test: Load time check manually

2. **Update documentation** (automated via GitHub Actions):
   - Manual generation: `.\tools\generate_function_docs.ps1 -Verbose`
   - Auto-generated every Sunday 6 AM GMT if code changes detected
   - Or trigger manually from GitHub Actions UI

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

