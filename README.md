# PowerShell Environment Configuration [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/tears-mysthrala/PowerShell-profile)

A comprehensive PowerShell environment setup with various utilities, aliases, and functions for enhanced productivity.

## Quick Start

```powershell
# Clone the repository
git clone https://github.com/tears-mysthrala/PowerShell-profile.git $HOME\Documents\PowerShell

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

## Requirements

- PowerShell 7+
- Optional: `git`, `fzf`, `bat`, `eza`, `lazygit`, `zoxide`

## Contributing

This project uses automated documentation generation. When adding new functions:

1. Place them in appropriate files under `Core/Utils/`
2. Add descriptive comments above function definitions
3. Run the docs generator: `.\tools\generate_function_docs.ps1`

The documentation will be automatically updated and committed via GitHub Actions.
