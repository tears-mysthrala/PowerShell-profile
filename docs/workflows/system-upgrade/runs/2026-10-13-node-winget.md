# Node and WinGet repair — 2026-10-13

Follow-up evidence: `SystemUpdate_20261012_235332.log` and its transcript.
The earlier run stopped during Chocolatey's dependency resolution. No concurrent
upgrade or installer was active when diagnosis began. Existing profile changes
from the earlier repair and unrelated `powershell.config.json` work were preserved.

## Causes and executed repairs

- `nodejs` 26.11.0 required exactly `nodejs.install` 26.11.0, while the feed offered
  nodejs.install 26.11.1. The discoverability metapackage was backed up and removed
  with script/auto-uninstall disabled; the Node installation was retained. The
  installer package upgraded successfully. `node --version` and a JavaScript smoke
  check returned v26.11.1. `npm --version` returned 12.2.0.
- The WinGet updater excluded HRESULT `0x8A15002B` from failures even for packages
  advertised as outdated. Diagnostics established User/Machine scope mismatches
  for Comfy, Suwayomi, TeamSpeak and Zed. Recovery preserves the existing scope
  using verified official installers and checks registration changes afterwards.
  Zed was updated to 1.23.2 and then 1.23.3 when a new release entered the feed.
  Its CLI reported 1.23.3. Comfy registered 1.1.6 and Suwayomi 2.4.2366.
- Suwayomi's previous MSI registration survived installation. The previous
  product was removed and the verified new installer repaired. Both native MSI
  logs ended with return code 0; one 2.4.2366 registration remained. No application
  database migration, service startup or data removal was performed.
- TeamSpeak was already the exact published 6.0.0-beta4.1 package despite its MSI
  ProductVersion being 5.0.0. The installed and downloaded MSI PackageCode both
  were `{9996AF9B-86B3-477F-BD41-7F0B7460B2A2}`. Main executable SHA256 matched:
  `5938641d3d05596c8f842652b554ec253a55cc34dc62b522d99e91aee95f06ec`.
  The downloaded installer matched WinGet's SHA256:
  `a5a0c6c2cbc4f022dbc61d48597fb1b794d8f4fdc52ed4862a452d2a7b640097`.
  A version-specific verification record prevents repeated false upgrades while
  checking package identity and the executable again on subsequent runs.
- A compact Spanish WinGet table with one space between version headers caused
  the parser to drop Copilot and TeamSpeak rows. Parsing was corrected and tested
  with the actual table. Copilot upgraded to 1.0.96 and its CLI confirmed that version.
- TeamSpeak's Delivery Optimization download had fetched only 6 MiB in over seven
  minutes. That download alone was stopped, WinGet's user downloader setting was
  changed to WinINet, and the replacement finished with a verified hash in about
  40 seconds. No source certificate or hash protection was disabled.
- Chocolatey's old self-update compared its installed version with `choco list`,
  which also reported the installed version. The remote query identified 2.7.4,
  and the corrected updater installed it. Elevating its subsequent queries also
  resolved the observed access failure cleaning up `choco.exe.old`.
- WindowsApps was missing from the user PATH. It was restored after confirming
  the WinGet execution alias existed. Direct `winget --version` resolved correctly.

## Validation and residual state

52 Pester tests passed, all 30 applicable PowerShell scripts parsed without errors,
and repository-configured PSScriptAnalyzer reported zero findings. Diff whitespace
checks passed. Focused live WinGet and Chocolatey updater checks ended with zero
updater warnings/errors. Native CLI version checks for Node, npm, Zed and Copilot ran.
The full system upgrade, GUI application workflows and CI were not executed.

Native WinGet may still advertise TeamSpeak and Zed using inconsistent metadata;
the alias distinguishes these verified current versions from genuine updates.
Miniforge 26.1.0-0 and MSYS2 20251213 remain explicit-upgrade installer entries;
their environments were not replaced. Existing package pins were preserved.
The earlier Bitwarden transitive-dependency deprecation remains vendor-owned.

Primary references:
- [WinGet scope and download settings](https://learn.microsoft.com/en-us/windows/package-manager/winget/settings)
- [Chocolatey metadata-only uninstall](https://docs.chocolatey.org/en-us/choco/commands/uninstall/)
- [Inno Setup installation scope parameters](https://jrsoftware.org/ishelp/topic_setupcmdline.htm)
- [Windows Installer ALLUSERS](https://learn.microsoft.com/en-us/windows/win32/msi/allusers)
