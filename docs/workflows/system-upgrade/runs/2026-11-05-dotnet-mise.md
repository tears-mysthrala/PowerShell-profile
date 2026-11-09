# .NET managed by mise in Fedora

User requested mise to avoid waiting for Fedora's Microsoft package updates.
Existing mise at /home/Fedora/.local/bin/mise upgraded2026.4.19->2026.11.2 using
its verified self-update. Existing node="latest" global setting preserved.
Global ~/.config/mise/config.toml now also contains dotnet=["lts","9"].
Before-copy: ~/.config/mise/config.toml.before-dotnet-20261105.

Mise core .NET uses Microsoft's official dotnet-install script. Installed SDKs
10.0.403 and9.0.320 into its default shared dotnet-root, with Microsoft.NETCore.App
and Microsoft.AspNetCore.App10.0.14 and9.0.22. SDKs are new additions; prior setup
contained runtimes only. LTS excludes previews according to mise's documented
channel resolver. Branch9 is retained for existing applications; the request
tracks patch releases in9 rather than forcing those applications to another major.

/usr/bin/dotnet, /usr/local/bin/dotnet and /usr/local/sbin/dotnet now point to
/home/Fedora/.local/share/mise/dotnet-root/dotnet. Before replacing links their
expected old destination was verified. Previous manually installed runtime tree
was moved to /opt/dotnet-before-mise-20261105 for rollback, not deleted.

Update-System now invokes Update-WslDotnet after Homebrew using its selected WSL
distribution, HOME working directory and explicit mise binary. It runs
mise upgrade --global dotnet --yes then mise exec -- dotnet --info, with native
exit handling and1800s bound. Only global .NET requests are upgraded, no project
configs changed. Nonzero exit is reported as error. No scheduler was introduced.

Validation executed:
- Live Update-WslDotnet: both .NET requests current and dotnet --info succeeds.
- Compiled/executed isolated console apps with pinned global.json SDK9.0.320 and
  SDK10.0.403. Outputs9.0.22 and10.0.14 respectively. Projects retained at
  /home/Fedora/dotnet-mise-check.n7bk2K; logs mise-build-tests.log in evidence.
- Pester98 passed,0failed/skipped; configured ScriptAnalyzer0; parsing,
  Update-System -WhatIf and git diff --check pass. Added regression tests for
  failed native update, global scope/distribution and WhatIf behavior.
- Bare dotnet --version=10.0.403; absolute /usr/bin/dotnet lists both runtime
  families. dnf check exit0. Windows .NET installations were not changed.

Evidence: C:/Users/unaiu/Documents/Codex/2026-11-05/fedora45/,
mise-validation.log, mise-build-tests.log, migration scripts.
Documentation: https://mise.jdx.dev/lang/dotnet.html and
https://mise.jdx.dev/cli/upgrade.html.
