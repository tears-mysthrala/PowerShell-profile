# Fedora retained packages reconciled, 2026-11-05

User explicitly authorized updating the previously retained PostgreSQL/Perl/Git/
.NET packages, resolving conflicts and preferring current releases for security.
Earlier transaction-only exclusions are now superseded. No persistent exclusions
were added or removed. Evidence folder remains
C:/Users/unaiu/Documents/Codex/2026-11-05/fedora45/.

## Result

- PostgreSQL/client/server/contrib: 18.6-1.fc45. Selected Fedora updates-testing
  temporarily with includepkgs=postgresql*,libpq*; it contains the current stable
  upstream release rebuilt for F45, avoiding the stable repository's18.3 downgrade.
  No broad testing-repository enablement was persisted.
- Perl5.44.0, Git2.56.0 and their dependency group moved to current F45 packages.
  reconcile-update.log records265 upgrades,1 install,265 replacements, exit0.
- Effective Node26.13.0LTS/npm11.20.0 remain Homebrew-managed. Removed all seven
  Fedora Node26.3.1 packages so absolute /usr/bin paths cannot use the older copy.
  /usr/bin and /usr/local/bin node/npm/npx link to Homebrew. Existing updater's
  /usr/bin/npm managed CLI invocation therefore also uses current Node.
- .NET official runtime9.0.22 retained for applications targeting9 and runtime/
  host10.0.14 installed under /opt/dotnet-current. Latest stable upstream releases
  resolved from Microsoft's per-channel release JSON and each archive verified
  against its published SHA512 before extraction. Removed the RPM9.0.21 runtime,
  hostfxr and11RC1 host, with clean_requirements_on_remove=false. Removal plan
  proved no unrelated dependent applications were removed. No SDK existed before
  or was introduced. /usr/bin and /usr/local/bin dotnet link to the official host.
  These official .NET runtimes are not RPM-managed; future runtime updates must
  use the Microsoft release metadata workflow, not just dnf upgrade.

An initial metadata selector chose Microsoft's apphost archive for10.0.14 rather
than the runtime. The missing10 runtime was caught by --list-runtimes, selector
fixed to require dotnet-runtime-* archive name, correct package hash verified and
installed before replacing any old RPM runtime. Both runtimes now enumerate.

## Executed validation

- dnf check exit0; dnf upgrade --assumeno:Nothing to do. rpm -qa '*fc44*':empty.
- dnf updateinfo list --security --available: no advisory rows. This only establishes
  the configured repository metadata has no pending security advisories; it does
  not certify absence of vulnerabilities across the system or applications.
- systemctl --failed:0 units. PostgreSQL service was inactive before and remains
  inactive. Existing databases were not started or migrated.
- postgres-smoke.log: isolated initdb under /var/tmp/pg-update-check.Hqei07,
  postgres18.6 started with TCP disabled, hstore extension created, table written/
  read value45; server stopped cleanly. Fixture retained; real cluster untouched.
- node --version and /usr/bin/node --version:26.13.0; npm11.20.0; Perl5.44.0;
  Git2.56.0; psql18.6; dotnet --info host10.0.14 and runtimes9.0.22/10.0.14.

## Sources

- https://www.postgresql.org/support/security/
- https://dev.perl.org/perl5/
- https://git-scm.com/
- https://dotnet.microsoft.com/en-us/download/dotnet/10.0
- https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/9.0/releases.json
- https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/10.0/releases.json
- https://github.com/nodejs/node/releases

Original Fedora44 recovery VHD remains at C:/WSL-backups/fedora44-20261105.vhdx.
No reboot, registry/name changes, source repository edits, CI or publication in
this follow-up. Earlier95 Pester pass relates to updater code, not these packages.
