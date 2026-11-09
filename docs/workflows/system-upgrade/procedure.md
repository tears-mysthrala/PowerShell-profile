# System upgrade maintenance

`upgrade` resolves to `Update-System` in `Profile.Update`. Reload the module with
`Import-Module Profile.Update -Force` after changing updater code, or open a new shell.

1. Read the summary log and its adjacent `.transcript.log`. A successful native
   process exit and a completed update are separate from notices in its output.
2. Reproduce only the failed manager first. Dot-source `SystemUpdater.ps1` and
   `UpdateAppsHelper.ps1` for focused troubleshooting; set `CurrentUpdateLogFile`
   to retain command output. Do not start a second upgrade while one is active.
3. Apache HTTP 401 recovery is limited to the main Win64 Fossies manifest. Fetch
   the exact Apache Lounge archive and its published SHA256 over HTTPS. Verify
   the archive before putting it in Scoop's cache, preserve persistent config,
   and restore main-bucket tracking even if the update fails. Never disable hashes.
   Support both `install.json` and `scoop-install.json` metadata layouts.
4. Upgrade uv tools separately. Keep locally installed wheels in a stable artifact
   directory outside a project's disposable `dist/`; do not replace a private
   package with an identically named registry package. A missing source remains
   an error, while the remaining tools can continue updating.
5. npm dot directories are not evidence of corruption. Archive only recognized
   staging directories older than one day, inside the global npm root, when no
   npm process or process referencing the directory is active. Preserve unknown
   dot directories. Retain archives for manual inspection rather than deleting them.
6. Ruby and Conda are optional when absent. An incomplete Ruby installation is
   an error. Discover commands afresh during updates rather than using the
   profile's session-long availability cache.
7. Validate with Pester, the repository's PSScriptAnalyzer settings, tracked-file
   syntax parsing, `upgrade -WhatIf`, and focused live manager checks. Record
   external dependency warnings separately; do not edit vendor dependencies to
   silence notices. Local checks do not establish CI or a full live system upgrade.

## WinGet and Chocolatey follow-up

- A WinGet `0x8A15002B` response is informational only for an empty discovery
  query. For an advertised package update it is a failed attempt until resolved.
  Capture verbose diagnostics and re-query after installation.
- Scope recovery is limited to the inspected Zed, Comfy Desktop, Suwayomi and
  TeamSpeak installers. Download through WinGet with SHA256 verification, preserve
  the existing registration scope, refuse active applications, and wait for the
  native installer. Do not use `--force` or ignore installer hashes.
- TeamSpeak's MSI advertises product version 5.0.0 for its 6.0.0-beta4.1 release.
  A current-package record is valid only for the same advertised release, matching
  registered MSI package identity and SHA256 of the extracted published main
  executable. A new advertised release or changed executable invalidates it.
- Zed may remain listed at an old version by WinGet. Require both its current
  uninstall registration and native executable product version to match the
  advertised version before treating that row as a metadata discrepancy.
- WinGet downloads use WinINet in local user settings after a reproduced slow
  Delivery Optimization download. Preserve unrelated settings and package pins.
- Chocolatey queries the remote `outdated` list, respects pins, updates one package
  at a time and itself last, and checks the list again. Use the authorized sudo
  context for queries too so Chocolatey's post-self-update cleanup has permission.
- The obsolete `nodejs` metapackage was removed while retaining `nodejs.install`.
  Its exact-version dependency blocked patch releases when its feed lagged behind.
  Do not recreate that dependency or modify vendor nuspec constraints.
- Miniforge and MSYS2 remain explicit-upgrade entries. The automatic WinGet layer
  does not reinstall them over existing environments to clear an installer notice.
  Their packages are maintained in place by the Conda and MSYS2 layers. Conda
  discovery includes Miniforge outside PATH and verifies the base prefix and
  post-update dry-run. MSYS2 refuses active processes/database locks, runs two
  separate pacman transactions for core/runtime replacement, then checks `-Qu`.

See [execution records](index.md) for concrete evidence and residual issues.

## Fedora .NET through mise

`Update-WslDotnet` updates only global .NET requests with mise, from the default
WSL user's HOME. The current personal config uses `dotnet = ["lts", "9"]`:
latest supported LTS SDK plus the .NET9 compatibility branch. Microsoft downloads
are installed into mise's shared dotnet-root; project `global.json` still selects
its SDK. No Fedora .NET package feed is involved. Use `mise upgrade --global dotnet`
for a focused update, followed by `dotnet --list-sdks` and `dotnet --list-runtimes`.
Update-System calls this after Homebrew. Do not replace project version requests
or migrate application target frameworks as part of runtime maintenance.

## PowerShell release discovery (2026-10-23)

The runtime layer resolves the official GitHub `releases/latest` HEAD redirect
with a 30-second timeout, validates the repository and stable version tag, and
downloads the versioned win-x64 MSI with a 300-second timeout. It does not use
the anonymous REST API quota. Microsoft Authenticode validation remains required
before installation. Temporary downloads use a unique per-invocation directory.
Validate changes with Pester, ScriptAnalyzer, `Update-System -WhatIf`, and a live
`Get-PowerShellPublishedVersion` check. Use `Update-PowerShellRuntime` alone to
retry this failed layer without repeating all package manager updates.


## Execution reliability (2026-10-20)

- `upgrade` accepts `-NodeProjectPath <roots>` and `-WslDistribution <name>`.
  Node defaults to the current directory only; it never recursively updates
  hidden applications from HOME. Dependency updates disable install scripts,
  re-query compatible pending updates and run `npm audit`. A newer release
  outside a declared range is informational, while a failed compatible update
  or a vulnerable installed dependency remains a warning/error respectively.
- WSL compares its installed runtime with the official stable GitHub release
  redirect before updating. This avoids the anonymous GitHub API quota failure
  when the installed runtime is already current. Runtime and distribution
  results are logged independently, using the explicit FedoraLinux-43 default.
- Homebrew uses its official portable Ruby (the host Ruby lacks Fiddle),
  `--no-ask`, bounded command execution, per-command timing and exit checks.
  Its commands use a scoped PATH with Homebrew first; the user's shell PATH and
  Fedora's system Node remain unchanged.
  Automatic dependency removal is disabled during automated cleanup to preserve
  runtimes needed by tools installed outside Homebrew. Landlock is enabled;
  ABI 7 in the current WSL kernel cannot provide Homebrew's ABI 10 full network
  denial. Preserve and report that warning; do not disable sandboxing to hide it.
- Gemini CLI in Fedora is installed from the official npm package under
  `~/.local`; its command remains accessible via the existing Homebrew bin path.
  The Homebrew layer also updates that specific npm tool. Keep Node and libsecret
  installed explicitly, since Homebrew no longer tracks Gemini's runtime needs.
- The private compliance-watcher wheel now lives at
  `D:/tooling/system-upgrade/artifacts`, with SHA256 verification against the
  retained release manifest. Do not move it into a cache/cleanup directory.
- Global npm updates exclude packages referenced by active processes, and keep
  their pending updates visible. Archive old staging directories with the
  existing process and path checks; never close Codex sessions just to clean them.
- If WinGet advertises a VS Code User update but installs an older binary,
  recovery may use the official VS Code update metadata only for that exact
  version, verifying SHA256 and a valid Microsoft Authenticode signature. It
  preserves User scope and refuses to replace a running User instance.

## Reboot and installer failures (2026-10-25)

- Windows Update runs the elevated `InstallWindowsUpdates.ps1` worker with
  `sudo --inline`. Failed download/install results become a parent error, even
  when PSWindowsUpdate does not throw. A pending reboot returns 3010 and leaves
  Windows updates explicitly pending. Do not reboot automatically.
- Chocolatey 350 means updates remain pending until reboot; stop that manager
  without bypassing its reboot check. Other managers may continue.
- Retry WinGet with elevation only for 0x80073D28, the packaged-service admin
  requirement. Do not elevate all user installers or retry cancellation blindly.
  Inspect Windows Security too: AutoHotkey 2.0.31 setup was detected by Defender
  as Wacatac.B!ml in this run. WinGet's hash check does not settle that detection.
- Read PowerShell's on-disk binary version before downloading an MSI, since
  Windows Update can replace it while the current session remains older. Wait
  for msiexec with `sudo --inline` and verify the installed version afterwards.
