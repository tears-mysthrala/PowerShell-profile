# Security Policy

## Scope

This repository is a personal PowerShell 7 profile and dotfiles environment. It is not a
supported product, and no versioned releases with security support commitments exist.

## Supported Versions

There are no supported versions. Only the latest state of the `main` branch receives fixes,
on a best-effort basis. No backports, no SLAs.

| Branch | Supported          |
| ------ | ------------------ |
| `main` | :white_check_mark: (best effort) |
| others | :x:                |

## Reporting a Vulnerability

If you find a security issue (for example, a command-injection vector in one of the
helper functions, or a credential accidentally committed):

- For anything sensitive, contact the maintainer privately through the channels listed on
  the [GitHub profile](https://github.com/tears-mysthrala) instead of opening a public issue.
- For low-severity issues, opening a regular issue is fine.

Please do not open public issues for vulnerabilities that could be exploited before a fix
is available.

## Notes for Users

- Review the code before running it. This profile executes installers, package managers,
  and update helpers on your machine.
- Required PowerShell modules are installed from the PowerShell Gallery (PSGallery) by
  `Core/ModuleInstaller.ps1` / `tools/install-dependencies.ps1`; no third-party module
  binaries are vendored in this repository.
- Never commit secrets: the `.gitignore` blocks common credential file patterns, but it
  cannot catch everything.
