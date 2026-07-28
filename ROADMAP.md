# Roadmap

Personal PowerShell 7 profile and dotfiles environment for Windows.

- **Purpose:** keep one modular, reproducible shell environment that can be rebuilt on a
  new machine from this repo plus PSGallery/winget/scoop/choco sources.
- **Users:** the author (Kalista / tears-mysthrala). Anyone else is welcome to read and
  borrow ideas, but this is not a supported product and comes with no warranty or
  enterprise support.

## Current state (observed 2026-07-28)

- Profile loads with aggressive caching of environment, module, and tool-init state.
- 145 functions in the profile itself (`Core/` + main profile script), 40 aliases;
  measured with the PowerShell AST parser.
- Third-party PowerShell modules install from PSGallery via `Core/ModuleInstaller.ps1` /
  `tools/install-dependencies.ps1`; no module binaries are vendored in the tree.
- CI (`.github/workflows/ci.yml`) runs on Windows: Parser-based syntax validation of all
  scripts, PSScriptAnalyzer with the repo settings file, and a dot-source smoke test.
  The smoke test does not cover full interactive behavior (prompt, PSReadLine handlers)
  and skips optional CLI tools that are absent on the runner.
- Documentation (`docs/FunctionReference.md`) is auto-generated weekly by
  `.github/workflows/generate-docs.yml`.
- Load time of ~500-600ms is a measurement from the author's machine, not a guarantee.
- No license file exists; usage terms are undecided (human decision pending).

## Now

- Keep docs honest: function counts and performance figures must come from measurement,
  not aspiration. Re-measure after significant changes.
- Keep the tree free of generated artifacts: runtime caches (`Config/*-cache.ps1`,
  `*.clixml`), analysis reports (`pssa_*.json`, `*.sarif`), and installed modules are
  gitignored and untracked.
- Keep CI green; treat new PSScriptAnalyzer errors as blocking.

## Next

- Pester tests for critical functions (update helpers, module installer, cache
  invalidation logic in `Initialize-CachedToolInit`).
- Truly modular installation: allow opting into subsets (`Core/Apps`, `Core/System`,
  update automation) instead of an all-or-nothing profile.
- Local, non-versioned configuration layer (machine-specific overrides loaded from an
  ignored file, with a commented example committed).
- Versioned releases (tags + changelog) so a working state can be pinned and rolled
  back to.

## Optional

- Partial Linux PowerShell (pwsh) compatibility for the platform-independent utilities.
- Interactive installer that asks which components to enable on first run.

## Out of scope

- Supporting Windows PowerShell 5.1 (Desktop edition).
- General-purpose shell distribution / framework for other users.
- Guaranteeing behavior on any specific terminal, OS build, or hardware.

## Abandonment / archival condition

If the author stops using this profile as their daily environment, or no commit lands
for ~12 months, the repo should be archived with a final README note pointing at
whatever replaced it.

## Risks and dependencies

- Depends on external package sources (PSGallery, winget, scoop, Chocolatey); outages or
  package renames can break fresh installs.
- Auto-generated docs workflow commits directly to `main`; failures there can desync
  docs from code.
- Load-time figures depend on the author's hardware and will drift.
