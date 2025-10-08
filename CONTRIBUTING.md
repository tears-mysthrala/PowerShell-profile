# Contributing to PowerShell Profile

Thank you for your interest in contributing to this PowerShell profile repository! This document provides guidelines and information for contributors.

## Development Setup

### Prerequisites

- PowerShell 7.0 or later
- Git

### Clone and Setup

```powershell
# Clone the repository
git clone https://github.com/tears-mysthrala/PowerShell-profile.git
cd PowerShell-profile

# Initialize submodules
git submodule update --init --recursive

# Run the profile to initialize
. .\Microsoft.PowerShell_profile.ps1
```

### Development Workflow

1. Create a feature branch: `git checkout -b feature/your-feature-name`
2. Make your changes
3. Test your changes locally
4. Run the validation workflows: `.\.github\workflows\pr-validation.yml`
5. Commit your changes with descriptive messages
6. Push and create a pull request

## Code Quality

### PSScriptAnalyzer

This repository uses PSScriptAnalyzer for code quality. The configuration is in `.psscriptanalyzersettings.psd1`.

Key rules enforced:

- Use approved PowerShell verbs
- Avoid global variables (except in profile context)
- Use proper error handling
- Include comment-based help for public functions

### Testing

Run the cross-platform tests locally:

```powershell
# Test PowerShell syntax
Get-ChildItem -Recurse -Include *.ps1,*.psm1,*.psd1 |
    Where-Object { $_.FullName -notmatch '\\.git\\' } |
    ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        try {
            $null = [scriptblock]::Create($content)
            Write-Host "✓ $($_.Name) - syntax OK"
        } catch {
            Write-Error "✗ $($_.Name) - syntax error: $_"
        }
    }
```

## Project Structure

```text
PowerShell-profile/
├── Microsoft.PowerShell_profile.ps1    # Main profile script
├── Core/                              # Core functionality
│   ├── Utils/                        # Utility functions
│   ├── ModuleInstaller.ps1           # Module management
│   └── UnifiedModuleManager.ps1      # Unified module system
├── Modules/                          # Third-party modules (submodules)
├── Config/                           # Configuration files
├── Functions/                        # Additional functions
├── Scripts/                          # Utility scripts
├── docs/                             # Documentation
│   └── FunctionReference.md          # Auto-generated function docs
└── .github/                          # GitHub Actions and configuration
    ├── workflows/                    # CI/CD workflows
    └── actions/                      # Composite actions
```

## Adding New Features

### Functions

1. Add your function to the appropriate file in `Core/Utils/` or create a new file
2. Include comment-based help with `.SYNOPSIS`, `.DESCRIPTION`, and `.EXAMPLE`
3. Add appropriate error handling
4. Update the function reference documentation

### Modules

1. Use the unified module system in `Core/UnifiedModuleManager.ps1`
2. Register your module with `Register-UnifiedModule`
3. Ensure proper lazy loading if appropriate

### Aliases

1. Add aliases to `Core/Utils/unified_aliases.ps1`
2. Use conditional checks for tool availability
3. Document the alias in the function

## Pull Request Process

1. Ensure all GitHub Actions checks pass
2. Update documentation if needed
3. Follow conventional commit format for PR titles
4. Provide a clear description of changes

## Commit Conventions

This project follows conventional commits:

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes
- `refactor:` - Code refactoring
- `test:` - Testing related changes
- `chore:` - Maintenance tasks

## Security

- Never commit sensitive information
- Use secure practices for any credential handling
- Report security issues privately to maintainers

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project.