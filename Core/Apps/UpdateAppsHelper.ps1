# Updates can install or remove commands during the same shell session.
function Test-UpdateCommandExist {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

function Test-WingetManagedCommandPath {
    param([string]$CommandPath)

    if ([string]::IsNullOrWhiteSpace($CommandPath)) {
        return $false
    }

    $normalizedPath = $CommandPath -replace '/', '\'
    return $normalizedPath -match '\\Microsoft\\WinGet\\Links\\'
}

function Get-WingetExecutable {
    $command = Get-Command winget -ErrorAction SilentlyContinue
    if ($command -and $command.Source -and (Test-Path -LiteralPath $command.Source)) {
        return $command.Source
    }

    $appInstaller = Get-AppxPackage Microsoft.DesktopAppInstaller -ErrorAction SilentlyContinue |
        Sort-Object Version -Descending |
        Select-Object -First 1
    if ($appInstaller) {
        $fallback = Join-Path $appInstaller.InstallLocation 'winget.exe'
        if (Test-Path -LiteralPath $fallback) {
            return $fallback
        }
    }

    return $null
}

function Test-WingetPackageInstalled {
    param([string]$Id)

    $winget = Get-WingetExecutable
    if (-not $winget) {
        return $false
    }

    $null = & $winget list --id $Id --source winget --exact --accept-source-agreements 2>$null
    return $LASTEXITCODE -eq 0
}

function ConvertFrom-WingetUpgradeOutput {
    [CmdletBinding()]
    param([object[]]$Output)

    $insideMainTable = $false
    $idStart = $null
    $versionStart = $null
    foreach ($item in $Output) {
        $line = ($item -replace "`e\[[0-9;]*m", '').TrimEnd()
        if (-not $insideMainTable) {
            if ($line -match '^(?<NameHeader>.+?)\s{2,}(?<IdHeader>Id)\s{2,}(?<VersionHeader>\S+)\s+') {
                $idStart = $line.IndexOf($Matches['IdHeader'], $Matches['NameHeader'].Length)
                $versionStart = $line.IndexOf($Matches['VersionHeader'], $idStart + $Matches['IdHeader'].Length)
                continue
            }
            if ($line -match '^-{3,}') {
                $insideMainTable = $true
            }
            continue
        }

        if ([string]::IsNullOrWhiteSpace($line)) {
            break
        }

        if ($null -ne $idStart -and $null -ne $versionStart -and $line.Length -gt $versionStart) {
            $name = $line.Substring(0, [Math]::Min($idStart, $line.Length)).Trim()
            $id = $line.Substring($idStart, [Math]::Min($versionStart, $line.Length) - $idStart).Trim()
        }
        else {
            $columns = @($line.Trim() -split '\s{2,}')
            $name = if ($columns.Count -ge 1) { $columns[0] } else { $null }
            $id = if ($columns.Count -ge 2) { $columns[1] } else { $null }
        }

        if ($id -match '^[A-Za-z0-9][A-Za-z0-9._+-]+$') {
            $versions = @()
            if ($null -ne $versionStart -and $line.Length -gt $versionStart) {
                $versions = @($line.Substring($versionStart).Trim() -split '\s+')
            } elseif ($columns.Count -ge 4) {
                $versions = @($columns[2], $columns[3])
            }
            [pscustomobject]@{
                Name = $name
                Id   = $id
                InstalledVersion = if ($versions.Count -ge 1) { $versions[0] } else { $null }
                AvailableVersion = if ($versions.Count -ge 2) { $versions[1] } else { $null }
            }
        }
    }
}

function ConvertFrom-ScoopStatusOutput {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [AllowEmptyString()]
        [object[]]$Output
    )

    begin {
        $lines = @()
    }

    process {
        if ($null -ne $Output) {
            $lines += $Output
        }
    }

    end {
        foreach ($item in $lines) {
            if ($item -isnot [string]) {
                $packageName = $item.Name
                $installedVersion = $item.'Installed Version'
                $latestVersion = $item.'Latest Version'
                if ($packageName -and $latestVersion -match '\d' -and $installedVersion -ne $latestVersion) {
                    [PSCustomObject]@{
                        Name             = $packageName
                        InstalledVersion = $installedVersion
                        LatestVersion    = $latestVersion
                    }
                }
                continue
            }

            $cleanLine = ($item -replace "`e\[[0-9;]*m", '').Trim()
            if ([string]::IsNullOrWhiteSpace($cleanLine)) {
                continue
            }
            if ($cleanLine -match '^(WARN|Name\s+|----|Installed apps:|Latest versions)') {
                continue
            }

            if ($cleanLine -match '^(?<Name>\S+)\s+(?<Installed>\S+)\s+(?<Latest>\S+)(?:\s+.*)?$') {
                $packageName = $Matches['Name']
                $installedVersion = $Matches['Installed']
                $latestVersion = $Matches['Latest']
                if ($latestVersion -match '\d' -and $installedVersion -ne $latestVersion) {
                    [PSCustomObject]@{
                        Name             = $packageName
                        InstalledVersion = $installedVersion
                        LatestVersion    = $latestVersion
                    }
                }
            }
        }
    }
}

function Get-ScoopPackageBlockers {
    param(
        [string]$Name,
        [object[]]$Process = @(Get-Process -ErrorAction SilentlyContinue)
    )

    $knownBlockers = @{
        'erlang'     = @('erl', 'beam.smp', 'epmd', 'inet_gethost')
        'postgresql' = @('postgres', 'pg_ctl')
    }

    $blockerNames = $knownBlockers[$Name.ToLowerInvariant()]
    if (-not $blockerNames) {
        return @()
    }

    @($Process |
        Where-Object { $blockerNames -contains $_.ProcessName } |
        Select-Object -ExpandProperty ProcessName -Unique)
}

function Get-UvSelfUpdateCommandPath {
    param(
        [string]$ActiveCommandPath,
        [string]$LegacyStandalonePath
    )

    if (-not [string]::IsNullOrWhiteSpace($ActiveCommandPath)) {
        return $ActiveCommandPath
    }

    if (-not [string]::IsNullOrWhiteSpace($LegacyStandalonePath) -and
        (Test-Path -LiteralPath $LegacyStandalonePath)) {
        return $LegacyStandalonePath
    }

    return $null
}

# Helper function to write section headers
function Write-UpdateHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
}

# Helper function to write status messages
function Write-UpdateStatus {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Status = 'Info'
    )
    $colors = @{ Info = 'White'; Success = 'Green'; Warning = 'Yellow'; Error = 'Red' }
    $prefixes = @{ Info = '>'; Success = 'OK'; Warning = '!!'; Error = 'XX' }
    $formattedMessage = "[$($prefixes[$Status])] $Message"
    Write-Host $formattedMessage -ForegroundColor $colors[$Status]

    if ($script:CurrentUpdateLogFile) {
        if ($Status -eq 'Warning') { $script:UpdateWarningCount++ }
        if ($Status -eq 'Error') { $script:UpdateErrorCount++ }
    }

    if ($script:CurrentUpdateLogFile -and (Get-Command Write-UpdateLog -ErrorAction SilentlyContinue)) {
        Write-UpdateLog "${Status}: $Message" $script:CurrentUpdateLogFile
    }
}


function Invoke-UpdateCommand {
    param([string]$Command, [string[]]$Arguments, [int]$TimeoutSeconds = 0)

    $PSNativeCommandUseErrorActionPreference = $false
    $ErrorActionPreference = 'Stop'
    $clock = [Diagnostics.Stopwatch]::StartNew()
    $lines = [Collections.Generic.List[string]]::new()
    $exitCode = -1
    if ($TimeoutSeconds -gt 0) {
        $info = [Diagnostics.ProcessStartInfo]::new()
        $info.FileName = (Get-Command $Command -ErrorAction Stop).Source
        foreach ($argument in $Arguments) { $info.ArgumentList.Add($argument) }
        $info.UseShellExecute = $false
        $info.CreateNoWindow = $true
        $info.RedirectStandardOutput = $true
        $info.RedirectStandardError = $true
        $info.RedirectStandardInput = $true
        $process = [Diagnostics.Process]::new()
        $process.StartInfo = $info
        try {
            $null = $process.Start()
            $process.StandardInput.Close()
            $stdout = $process.StandardOutput.ReadToEndAsync()
            $stderr = $process.StandardError.ReadToEndAsync()
            if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
                $process.Kill($true)
                $exitCode = 124
                $lines.Add("Command timed out after ${TimeoutSeconds}s; check remote WSL processes before retrying")
            } else {
                $exitCode = $process.ExitCode
            }
            # A remote child may retain a pipe after its Windows parent exits.
            if ($stdout.Wait(5000)) { foreach ($line in ($stdout.Result -split "`r?`n")) { $lines.Add($line) } }
            if ($stderr.Wait(5000)) { foreach ($line in ($stderr.Result -split "`r?`n")) { $lines.Add($line) } }
        } finally { $process.Dispose() }
    } else {
        & $Command @Arguments 2>&1 | ForEach-Object { $lines.Add($_.ToString()) }
        $exitCode = $LASTEXITCODE
    }
    foreach ($line in $lines) {
        Write-Host $line
        if ($script:CurrentUpdateLogFile -and (Get-Command Write-UpdateLog -ErrorAction SilentlyContinue)) {
            Write-UpdateLog "Output [$Command]: $line" $script:CurrentUpdateLogFile
        }
    }
    $clock.Stop()
    if ($script:CurrentUpdateLogFile -and (Get-Command Write-UpdateLog -ErrorAction SilentlyContinue)) {
        Write-UpdateLog "Command [$Command $($Arguments -join ' ')] exit=$exitCode duration=$($clock.Elapsed)" $script:CurrentUpdateLogFile
    }
    [pscustomobject]@{ ExitCode = $exitCode; Output = $lines.ToArray(); Duration = $clock.Elapsed }
}

function Get-ApacheLoungeManifest {
    param([object]$Manifest, [string]$Checksums)

    $source = [uri]$Manifest.architecture.'64bit'.url
    if ($Manifest.version -notmatch '^\d+(\.\d+)+$' -or $source.Scheme -ne 'https' -or
        $source.Host -ne 'fossies.org' -or $source.AbsolutePath -notmatch '^/windows/www/(?<File>httpd-[\d.]+-\d+-Win64-VS\d+\.zip)$') {
        throw 'Apache fallback only supports the known Fossies Win64 archive layout.'
    }
    $fileName = $Matches.File
    if ($fileName -notlike "httpd-$($Manifest.version)-*") { throw 'Apache archive version does not match the manifest.' }
    $checksumPattern = '(?im)^SHA256-Checksum for: ' + [regex]::Escape($fileName) + ':\s*\r?\n(?<Hash>[a-f0-9]{64})\s*$'
    if ($Checksums -notmatch $checksumPattern) {
        throw 'Apache Lounge did not provide a SHA256 checksum for the exact archive.'
    }
    $hash = $Matches.Hash.ToLowerInvariant()
    $copy = $Manifest | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $copy.architecture.'64bit'.url = "https://www.apachelounge.com/download/VS$($fileName -replace '.*-VS(\d+)\.zip$', '$1')/binaries/$fileName"
    $copy.architecture.'64bit'.hash = $hash
    return $copy
}

function Get-ScoopInstallInfoPath {
    param([string]$Directory)

    $current = Join-Path $Directory 'scoop-install.json'
    if (Test-Path -LiteralPath $current) { return $current }
    return (Join-Path $Directory 'install.json')
}

function Update-ScoopApacheMirror {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $scoopRoot = if ($env:SCOOP) { $env:SCOOP } else { Join-Path $env:USERPROFILE 'scoop' }
    $current = Join-Path $scoopRoot 'apps\apache\current'
    $infoPath = Get-ScoopInstallInfoPath -Directory $current
    $info = Get-Content -LiteralPath $infoPath -Raw | ConvertFrom-Json
    if ($info.bucket -ne 'main' -or $info.architecture -ne '64bit') {
        throw 'Apache mirror recovery only supports the existing main/64bit installation.'
    }
    $manifest = Get-Content -LiteralPath (Join-Path $scoopRoot 'buckets\main\bucket\apache.json') -Raw | ConvertFrom-Json
    $fileName = [IO.Path]::GetFileName(([uri]$manifest.architecture.'64bit'.url).AbsolutePath)
    if ($fileName -notmatch '^httpd-[\d.]+-\d+-Win64-VS(?<VS>\d+)\.zip$') { throw 'Unexpected Apache archive name.' }
    $checksumUri = "https://www.apachelounge.com/download/VS$($Matches.VS)/binaries/$fileName.txt"
    if (-not $PSCmdlet.ShouldProcess('Apache Scoop installation', "Recover using $checksumUri")) { return }
    # The publisher redirects PowerShell's default agent to an HTTP page.
    # Keep HTTPS enforcement and use its browser endpoint instead.
    $checksums = (Invoke-WebRequest -Uri $checksumUri -UserAgent 'Mozilla/5.0' -ErrorAction Stop).Content
    $mirror = Get-ApacheLoungeManifest -Manifest $manifest -Checksums $checksums
    $mirrorDir = Join-Path $env:LOCALAPPDATA 'SystemUpgrade\manifests'
    New-Item -ItemType Directory -Path $mirrorDir -Force | Out-Null
    $mirrorPath = Join-Path $mirrorDir 'apache.json'
    $mirror | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $mirrorPath
    # Download with the same HTTPS browser endpoint as the checksum request.
    # Populate Scoop's own cache only after verifying the publisher checksum.
    $archive = Join-Path $mirrorDir $fileName
    Invoke-WebRequest -Uri $mirror.architecture.'64bit'.url -UserAgent 'Mozilla/5.0' -OutFile $archive -ErrorAction Stop
    if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ine $mirror.architecture.'64bit'.hash) {
        throw 'Apache Lounge archive does not match its published SHA256 checksum.'
    }
    $corePath = (Join-Path $scoopRoot 'apps\scoop\current\lib\core.ps1').Replace("'", "''")
    $cacheCommand = ". '$corePath'; cache_path apache '$($mirror.version)' '$($mirror.architecture.'64bit'.url)'"
    $cacheProbe = Invoke-UpdateCommand -Command 'pwsh' -Arguments @('-NoProfile', '-Command', $cacheCommand)
    if ($cacheProbe.ExitCode -ne 0 -or $cacheProbe.Output.Count -ne 1) { throw 'Cannot resolve the Scoop Apache cache path.' }
    $cachePath = $cacheProbe.Output[0]
    New-Item -ItemType Directory -Path (Split-Path -Parent $cachePath) -Force | Out-Null
    foreach ($partial in @("$cachePath.aria2", (Join-Path (Split-Path -Parent $cachePath) 'apache.txt'))) {
        if (Test-Path -LiteralPath $partial) {
            Move-Item -LiteralPath $partial -Destination (Join-Path $mirrorDir ([IO.Path]::GetFileName($partial) + '-' + [guid]::NewGuid().ToString('N')))
        }
    }
    Copy-Item -LiteralPath $archive -Destination $cachePath -Force
    $temporary = $info | ConvertTo-Json -Depth 10 | ConvertFrom-Json
    $temporary.bucket = $null
    $temporary | Add-Member -NotePropertyName url -NotePropertyValue $mirrorPath -Force
    try {
        $temporary | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $infoPath -ErrorAction Stop
        Write-UpdateStatus 'Retrying Apache from Apache Lounge with its published SHA256 checksum' -Status Info
        Invoke-UpdateCommand -Command 'pwsh' -Arguments @('-NoProfile', '-Command', 'scoop update apache')
    } finally {
        # Restore only source metadata on whichever version Scoop made current.
        # Keep the upstream bucket intact so future versions remain discoverable.
        $restorePath = Get-ScoopInstallInfoPath -Directory $current
        if (Test-Path -LiteralPath $restorePath) {
            $info | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $restorePath -ErrorAction Stop
        }
    }
}

function Get-NpmStagingDirectory {
    param([string]$Root, [datetime]$Before = (Get-Date).AddDays(-1))

    $parents = @(Get-Item -LiteralPath $Root -ErrorAction Stop)
    $parents += @(Get-ChildItem -LiteralPath $Root -Directory -Force | Where-Object Name -Like '@*')
    foreach ($parent in $parents) {
        Get-ChildItem -LiteralPath $parent.FullName -Directory -Force |
            Where-Object { $_.Name -match '^\.[^.].+-[A-Za-z0-9]{8}$' -and $_.LastWriteTime -lt $Before }
    }
}

function Initialize-PowerShellGallery {
    try {
        $nuget = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
        if (-not $nuget -or $nuget.Version -lt [version]'2.8.5.201') {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force -ErrorAction Stop | Out-Null
        }
    }
    catch {
        Write-UpdateStatus "Failed to initialize NuGet provider: $_" -Status Warning
    }

}

function Invoke-RequiredModuleRepair {
    $moduleInstallerPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'ModuleInstaller.ps1'
    if (-not (Test-Path $moduleInstallerPath)) {
        Write-UpdateStatus "Module installer not found, skipping required module repair" -Status Warning
        return
    }

    try {
        Import-Module $moduleInstallerPath -Force -ErrorAction Stop
        Install-RequiredModule
    }
    catch {
        Write-UpdateStatus "Required module repair failed: $_" -Status Warning
    }
}

function Get-WingetScopeRecoveryPolicy {
    param([string]$Id)
    switch ($Id) {
        'ZedIndustries.Zed' { @{Pattern='^Zed$'; Scope='User'; DownloadScope='machine'; Kind='inno'; Process=@('zed')} }
        'Comfy.ComfyUI-Desktop' { @{Pattern='^Comfy Desktop(?: |$)'; Scope='Machine'; DownloadScope='user'; Kind='nullsoft'; Process=@('Comfy Desktop','ComfyUI')} }
        'Suwayomi.Suwayomi-Server' { @{Pattern='^Suwayomi Server$'; Scope='Machine'; DownloadScope='user'; Kind='msi'; Process=@('Suwayomi-Server')} }
        'TeamSpeakSystems.TeamSpeakClient.Beta.6' { @{Pattern='^TeamSpeak$'; Scope='Machine'; DownloadScope='user'; Kind='msi'; Process=@('TeamSpeak','ts3client_win64')} }
    }
}

function Get-WingetScopeRecoveryInstallation {
    param([object]$Policy)
    $roots = if ($Policy.Scope -eq 'User') {
        @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*')
    } else {
        @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')
    }
    @(Get-ItemProperty -Path $roots -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match $Policy.Pattern })
}

function Get-MsiPackageIdentity {
    param([string]$Path)
    $installer = New-Object -ComObject WindowsInstaller.Installer
    $database = $null
    $view = $null
    try {
        $database = $installer.OpenDatabase($Path, 0)
        $summary = $database.SummaryInformation(0)
        $packageCode = $summary.Property(9)
        $view = $database.OpenView('SELECT `Property`, `Value` FROM `Property`')
        $view.Execute()
        $properties = @{}
        while ($record = $view.Fetch()) { $properties[$record.StringData(1)] = $record.StringData(2) }
        [pscustomobject]@{PackageCode=$packageCode;ProductCode=$properties.ProductCode;ProductVersion=$properties.ProductVersion}
    } finally {
        if ($view) { $view.Close(); [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($view) }
        if ($database) { [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($database) }
        [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($installer)
    }
}

function Register-WingetCurrentMsiPackage {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param([string]$Id, [string]$InstallerFile, [string]$Manifest, [string]$Root)
    if ($Id -ne 'TeamSpeakSystems.TeamSpeakClient.Beta.6') { return $false }
    $source = Get-MsiPackageIdentity -Path $InstallerFile
    $installed = @(Get-WingetScopeRecoveryInstallation -Policy (Get-WingetScopeRecoveryPolicy -Id $Id))
    if ($installed.Count -ne 1 -or $installed[0].PSChildName -ne $source.ProductCode) { return $false }
    $windowsInstaller = New-Object -ComObject WindowsInstaller.Installer
    try { $cached = $windowsInstaller.ProductInfo($source.ProductCode, 'LocalPackage') }
    finally { [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($windowsInstaller) }
    $registered = Get-MsiPackageIdentity -Path $cached
    if ($registered.PackageCode -ne $source.PackageCode) { return $false }
    if (-not $PSCmdlet.ShouldProcess($Id, 'Verify and record exact installed MSI package')) { return $false }
    $proofDirectory = Join-Path $Root 'package-proof'
    $extract = Invoke-UpdateCommand -Command (Get-Command 7z -ErrorAction Stop).Source -Arguments @('e', '-y', "-o$proofDirectory", $InstallerFile, 'ExecFile')
    if ($extract.ExitCode -ne 0) { throw 'Cannot extract the verified TeamSpeak main binary' }
    $binary = Join-Path $env:ProgramFiles 'TeamSpeak\TeamSpeak.exe'
    $expected = (Get-FileHash -LiteralPath (Join-Path $proofDirectory 'ExecFile') -Algorithm SHA256).Hash
    if ((Get-FileHash -LiteralPath $binary -Algorithm SHA256).Hash -ine $expected) { return $false }
    if ($Manifest -notmatch '(?m)^PackageVersion: (\S+)\r?$') { throw 'Cannot read the published TeamSpeak version' }
    $version = $Matches[1]
    @{Id=$Id;PublishedVersion=$version;ProductCode=$source.ProductCode;PackageCode=$source.PackageCode;Binary=$binary;BinaryHash=$expected} |
        ConvertTo-Json | Set-Content -LiteralPath (Join-Path $Root 'verified-current.json')
    return $true
}

function Test-WingetVerifiedCurrentPackage {
    param([string]$Id, [string]$AvailableVersion)
    if ($Id -eq 'ZedIndustries.Zed') {
        $installed = @(Get-WingetScopeRecoveryInstallation -Policy (Get-WingetScopeRecoveryPolicy -Id $Id))
        if ($installed.Count -ne 1 -or $installed[0].DisplayVersion -ne $AvailableVersion -or -not $installed[0].InstallLocation) { return $false }
        $binary = Join-Path $installed[0].InstallLocation 'Zed.exe'
        if (-not (Test-Path -LiteralPath $binary)) { return $false }
        $nativeVersion = [Diagnostics.FileVersionInfo]::GetVersionInfo($binary).ProductVersion
        return $nativeVersion -match ('^' + [regex]::Escape($AvailableVersion) + '(?:\.0)?(?:\+[^ ]+)?$')
    }
    if ($Id -ne 'TeamSpeakSystems.TeamSpeakClient.Beta.6') { return $false }
    $statePath = Join-Path $env:LOCALAPPDATA ('SystemUpgrade\winget\' + $Id + '\verified-current.json')
    if (-not (Test-Path -LiteralPath $statePath)) { return $false }
    $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
    $expectedBinary = Join-Path $env:ProgramFiles 'TeamSpeak\TeamSpeak.exe'
    if ($state.Id -ne $Id -or $state.PublishedVersion -ne $AvailableVersion -or $state.Binary -ine $expectedBinary -or
        $state.BinaryHash -notmatch '^[a-fA-F0-9]{64}$') { return $false }
    $policy = Get-WingetScopeRecoveryPolicy -Id $Id
    $installed = @(Get-WingetScopeRecoveryInstallation -Policy $policy)
    if ($installed.Count -ne 1 -or $installed[0].PSChildName -ne $state.ProductCode) { return $false }
    $windowsInstaller = New-Object -ComObject WindowsInstaller.Installer
    try { $cached = $windowsInstaller.ProductInfo($state.ProductCode, 'LocalPackage') }
    finally { [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($windowsInstaller) }
    $package = Get-MsiPackageIdentity -Path $cached
    return $package.PackageCode -eq $state.PackageCode -and
        (Get-FileHash -LiteralPath $state.Binary -Algorithm SHA256).Hash -ieq $state.BinaryHash
}

function Update-WingetScopeMismatch {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Id, [string]$Winget, [string]$DownloadedDirectory)

    $policy = Get-WingetScopeRecoveryPolicy -Id $Id
    if (-not $policy) { throw "No verified installer scope recovery policy for $Id" }
    $installed = @(Get-WingetScopeRecoveryInstallation -Policy $policy)
    if ($installed.Count -ne 1) { throw "Expected one existing $($policy.Scope) installation of $Id" }
    $beforeVersion = $installed[0].DisplayVersion
    $blockers = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $policy.Process -contains $_.ProcessName })
    if ($blockers.Count -gt 0) { throw "Close $($blockers.ProcessName -join ', ') before updating $Id" }
    if (-not $PSCmdlet.ShouldProcess($Id, "Update in existing $($policy.Scope) scope using verified installer")) { return }
    $root = Join-Path $env:LOCALAPPDATA ('SystemUpgrade\winget\' + $Id)
    New-Item -ItemType Directory -Path $root -Force | Out-Null
    if (-not $DownloadedDirectory) {
        $DownloadedDirectory = Join-Path $root ([guid]::NewGuid().ToString('N'))
        $download = Invoke-UpdateCommand -Command $Winget -Arguments @('download', '--id', $Id, '--exact', '--source', 'winget', '--scope', $policy.DownloadScope, '--architecture', 'x64', '--skip-dependencies', '--download-directory', $DownloadedDirectory, '--accept-source-agreements', '--accept-package-agreements', '--disable-interactivity')
        if ($download.ExitCode -ne 0) { throw "WinGet installer download failed for $Id (exit $($download.ExitCode))" }
    }
    $extension = if ($policy.Kind -eq 'msi') { '*.msi' } else { '*.exe' }
    $files = @(Get-ChildItem -LiteralPath $DownloadedDirectory -Filter $extension -File)
    $manifests = @(Get-ChildItem -LiteralPath $DownloadedDirectory -Filter '*.yaml' -File)
    if ($files.Count -ne 1 -or $manifests.Count -ne 1) { throw 'Expected one WinGet installer and its exported manifest' }
    $manifest = Get-Content -LiteralPath $manifests[0].FullName -Raw
    if ($manifest -notmatch ('(?m)^PackageIdentifier: ' + [regex]::Escape($Id) + '\r?$')) { throw 'Downloaded manifest package mismatch' }
    $hashes = [regex]::Matches($manifest, '(?m)^  InstallerSha256: ([a-fA-F0-9]{64})\r?$')
    if ($hashes.Count -ne 1) { throw 'Expected the selected installer SHA256 from WinGet' }
    $hash = $hashes[0].Groups[1].Value
    if ((Get-FileHash -LiteralPath $files[0].FullName -Algorithm SHA256).Hash -ine $hash) { throw 'Downloaded installer checksum mismatch' }
    if (Register-WingetCurrentMsiPackage -Id $Id -InstallerFile $files[0].FullName -Manifest $manifest -Root $root) {
        Write-UpdateStatus "$Id is already the exact published package; its MSI display version is misleading" -Status Info
        return [pscustomobject]@{ExitCode=0;Output=@('Exact installed package and main binary verified')}
    }
    $log = Join-Path $root ('installer-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
    if ($policy.Kind -eq 'msi') {
        $log = Join-Path $env:ProgramData ('SystemUpgrade\Logs\' + $Id + '-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
        $arguments = '/i "' + $files[0].FullName + '" /qn /norestart ALLUSERS=1 /L*v "' + $log + '"'
        if ($Id -eq 'TeamSpeakSystems.TeamSpeakClient.Beta.6') { $arguments += ' REINSTALL=ALL REINSTALLMODE=vomus' }
    } elseif ($policy.Kind -eq 'inno') {
        $location = $installed[0].InstallLocation.TrimEnd('\')
        if (-not $location -or $location -match '["\r\n]' -or -not [IO.Path]::IsPathRooted($location)) { throw 'Cannot preserve the existing Inno install location' }
        $arguments = '/CURRENTUSER /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NOCLOSEAPPLICATIONS /DIR="' + $location + '" /LOG="' + $log + '"'
    } else {
        $uninstall = $installed[0].UninstallString
        if ($uninstall -notmatch '^"([^"]+)"') { throw 'Cannot locate the existing NSIS installation' }
        $location = Split-Path -Parent $Matches[1]
        $arguments = '/S /allusers --updated /D=' + $location
    }
    $jobPath = Join-Path $root ('job-' + [guid]::NewGuid().ToString('N') + '.json')
    @{Kind=$policy.Kind;File=$files[0].FullName;Hash=$hash;Arguments=$arguments;Log=$log} |
        ConvertTo-Json | Set-Content -LiteralPath $jobPath
    $installerScript = Join-Path $PSScriptRoot 'Updates\InstallWingetScope.ps1'
    $hostPath = (Get-Process -Id $PID).Path
    $hostArguments = @('-NoProfile', '-File', $installerScript, '-JobPath', $jobPath)
    Write-UpdateStatus "Updating $Id while preserving its $($policy.Scope) installation; installer log: $log" -Status Info
    if ($policy.Scope -eq 'Machine' -and (Test-UpdateCommandExist 'sudo')) {
        $result = Invoke-UpdateCommand -Command 'sudo' -Arguments (@('--inline', $hostPath) + $hostArguments)
    } else {
        $result = Invoke-UpdateCommand -Command $hostPath -Arguments $hostArguments
    }
    if ($result.ExitCode -notin @(0, 3010)) { throw "Installer failed for $Id (exit $($result.ExitCode)); inspect $log" }
    $after = @(Get-WingetScopeRecoveryInstallation -Policy $policy)
    if ($Id -eq 'TeamSpeakSystems.TeamSpeakClient.Beta.6') {
        if (-not (Register-WingetCurrentMsiPackage -Id $Id -InstallerFile $files[0].FullName -Manifest $manifest -Root $root)) { throw 'Cannot verify the updated TeamSpeak package' }
    } elseif ($after.Count -ne 1 -or $after[0].DisplayVersion -eq $beforeVersion) { throw 'Installer returned success without updating the existing registration' }
    if ($result.ExitCode -eq 3010) { Write-UpdateStatus "$Id updated; Windows restart required" -Status Warning }
    [pscustomobject]@{ExitCode=0;Output=@("$Id updated: $beforeVersion -> $($after[0].DisplayVersion)")}
}

function Test-WingetScopeMismatchLog {
    param([string]$Id, [datetime]$Since)
    $directory = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\DiagOutputDir'
    foreach ($file in @(Get-ChildItem -LiteralPath $directory -Filter '*.log' -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -ge $Since.AddSeconds(-2) } | Sort-Object LastWriteTime -Descending | Select-Object -First 10)) {
        $text = Get-Content -LiteralPath $file.FullName -Raw
        if ($text.Contains("--id $Id ") -and $text.Contains('Installer scope does not match currently installed scope')) { return $true }
    }
    return $false
}


function Update-VSCodeUserPackage {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$AvailableVersion)
    $directory = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code'
    if (-not $PSCmdlet.ShouldProcess($directory, "Repair VS Code User $AvailableVersion")) { return }
    $binary = Join-Path $directory 'Code.exe'
    if (-not (Test-Path -LiteralPath $binary)) { throw 'No existing VS Code User installation to repair' }
    if ((Get-Item -LiteralPath $binary).VersionInfo.ProductVersion -eq $AvailableVersion) { return }
    $running = @(Get-Process -Name Code -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -and $_.Path.StartsWith($directory + '\', [StringComparison]::OrdinalIgnoreCase)
    })
    if ($running.Count -gt 0) { throw 'VS Code User is running; close that copy before repair' }
    $release = Invoke-RestMethod -Uri 'https://update.code.visualstudio.com/api/update/win32-x64-user/stable/latest' -TimeoutSec 30 -ErrorAction Stop
    if ($release.name -ne $AvailableVersion -or $release.sha256hash -notmatch '^[a-fA-F0-9]{64}$' -or
        [IO.Path]::GetFileName(([uri]$release.url).AbsolutePath) -ne "VSCodeUserSetup-x64-$AvailableVersion.exe" -or
        $release.url -notmatch '^https://vscode\.download\.prss\.microsoft\.com/.+/VSCodeUserSetup-x64-[0-9.]+\.exe$') {
        throw 'Official VS Code metadata does not match the advertised version'
    }
    $cache = Join-Path $env:LOCALAPPDATA 'SystemUpgrade\vscode'
    New-Item -ItemType Directory -Path $cache -Force | Out-Null
    $installer = Join-Path $cache "VSCodeUserSetup-x64-$AvailableVersion.exe"
    if (-not (Test-Path -LiteralPath $installer) -or (Get-FileHash -LiteralPath $installer).Hash -ne $release.sha256hash) {
        Invoke-WebRequest -Uri $release.url -OutFile $installer -TimeoutSec 300 -ErrorAction Stop
    }
    if ((Get-FileHash -LiteralPath $installer).Hash -ne $release.sha256hash) { throw 'VS Code installer checksum mismatch' }
    $signature = Get-AuthenticodeSignature -LiteralPath $installer
    if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'O=Microsoft Corporation(?:,|$)') {
        throw 'VS Code installer is not valid Microsoft-signed content'
    }
    $process = Start-Process -FilePath $installer -ArgumentList @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART','/MERGETASKS=!runcode') -WindowStyle Hidden -Wait -PassThru
    if ($process.ExitCode -ne 0) { throw "VS Code installer failed (exit $($process.ExitCode))" }
    if ((Get-Item -LiteralPath $binary).VersionInfo.ProductVersion -ne $AvailableVersion) { throw 'VS Code User version failed post-install verification' }
    Write-UpdateStatus "VS Code User $AvailableVersion installed from verified official metadata" -Status Success
}

function Update-Winget {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 1: Windows Package Managers - Winget"
    
    if ($PSCmdlet.ShouldProcess("Winget packages", "Update")) {
        $winget = Get-WingetExecutable
        if ($winget) {
            Write-UpdateStatus "Updating Winget packages to latest versions (this may take a while)..." -Status Info
            Write-Host "  Discovering Winget upgrades..." -ForegroundColor DarkGray
            Write-Host ""

            # Pinned packages (e.g. Google.CloudSDK) are respected — no --force
            # Packages with unknown versions are skipped — they should be updated
            # by their own tooling (e.g. gcloud components update)
            # Keep winget non-elevated by default: elevated winget cannot upgrade
            # user-scope packages such as chezmoi's WinGet shim.
            $query = Invoke-UpdateCommand -Command $winget -Arguments @('upgrade', '--source', 'winget', '--accept-source-agreements', '--disable-interactivity')
            $upgradeOutput = $query.Output
            $queryExitCode = $query.ExitCode
            $packages = @()
            foreach ($candidate in @(ConvertFrom-WingetUpgradeOutput -Output $upgradeOutput)) {
                if (Test-WingetVerifiedCurrentPackage -Id $candidate.Id -AvailableVersion $candidate.AvailableVersion) {
                    Write-UpdateStatus "$($candidate.Id) already matches published $($candidate.AvailableVersion); installed package independently verified" -Status Info
                } else {
                    $packages += $candidate
                }
            }
            $failedPackages = @()

            foreach ($package in $packages) {
                Write-Host "  Updating: $($package.Name) [$($package.Id)]" -ForegroundColor DarkGray
                $attemptStarted = Get-Date
                $result = Invoke-UpdateCommand -Command $winget -Arguments @('upgrade', '--id', $package.Id, '--exact', '--source', 'winget', '--silent', '--accept-source-agreements', '--accept-package-agreements', '--disable-interactivity', '--verbose-logs')
                # Packaged services require elevation; do not elevate unrelated user installers.
                if ($result.ExitCode -eq -2147009240 -and (Test-UpdateCommandExist 'sudo')) {
                    Write-UpdateStatus "$($package.Id) requires administrator privileges; retrying this package with sudo" -Status Info
                    $result = Invoke-UpdateCommand -Command 'sudo' -Arguments @('--inline', $winget, 'upgrade', '--id', $package.Id, '--exact', '--source', 'winget', '--silent', '--accept-source-agreements', '--accept-package-agreements', '--disable-interactivity', '--verbose-logs')
                }
                if ($result.ExitCode -eq -1978335189 -and (Get-WingetScopeRecoveryPolicy -Id $package.Id) -and
                    (Test-WingetScopeMismatchLog -Id $package.Id -Since $attemptStarted)) {
                    try {
                        $result = Update-WingetScopeMismatch -Id $package.Id -Winget $winget
                    } catch {
                        Write-UpdateStatus "WinGet scope recovery failed for $($package.Id): $_" -Status Error
                    }
                }
                if ($result.ExitCode -ne 0) {
                    $failedPackages += "$($package.Id) ($($result.ExitCode))"
                    Write-UpdateStatus "Winget did not update $($package.Id) (exit code $($result.ExitCode)); see captured output" -Status Error
                }
            }

            if ($packages.Count -gt 0) {
                $verification = Invoke-UpdateCommand -Command $winget -Arguments @('upgrade', '--source', 'winget', '--accept-source-agreements', '--disable-interactivity')
                if ($verification.ExitCode -notin @(0, -1978335189)) {
                    Write-UpdateStatus "Cannot verify remaining WinGet updates (exit $($verification.ExitCode))" -Status Error
                    $failedPackages += 'post-update verification'
                } else {
                    $remaining = @(ConvertFrom-WingetUpgradeOutput -Output $verification.Output)
                    foreach ($pending in $remaining) {
                        if (Test-WingetVerifiedCurrentPackage -Id $pending.Id -AvailableVersion $pending.AvailableVersion) { continue }
                        if ($pending.Id -eq 'Microsoft.VisualStudioCode' -and $pending.Id -in $packages.Id) {
                            try {
                                Update-VSCodeUserPackage -AvailableVersion $pending.AvailableVersion
                                continue
                            } catch {
                                Write-UpdateStatus "VS Code official recovery failed: $_" -Status Error
                            }
                        }
                        if ($pending.Id -in $packages.Id -and -not ($failedPackages -like "$($pending.Id) *")) {
                            $failedPackages += "$($pending.Id) (still outdated)"
                            Write-UpdateStatus "Winget still reports an update for $($pending.Id) after installation" -Status Error
                        }
                    }
                }
            }

            if ($queryExitCode -notin @(0, -1978335189) -and $packages.Count -eq 0) {
                Write-UpdateStatus "Winget could not enumerate upgrades (exit code $queryExitCode): $($upgradeOutput -join ' ')" -Status Error
            } elseif ($packages.Count -eq 0) {
                Write-UpdateStatus "No automatic Winget package updates pending" -Status Info
            } elseif ($failedPackages.Count -eq 0) {
                Write-UpdateStatus "Winget update completed" -Status Success
            } else {
                Write-UpdateStatus "Winget updated the remaining packages, but these require manual handling: $($failedPackages -join ', ')" -Status Warning
            }
        } else {
            Write-UpdateStatus "Winget not installed, skipping..." -Status Warning
        }
    }
}

function Update-Scoop {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 1: Windows Package Managers - Scoop"

    if ($PSCmdlet.ShouldProcess("Scoop packages", "Update")) {
        if (Test-UpdateCommandExist 'scoop') {
            # Run scoop in isolated pwsh processes to avoid .NET type resolution
            # issues caused by prior steps (e.g. sudo winget) contaminating the
            # current session's assembly loader.
            Write-UpdateStatus "Updating Scoop to latest version..." -Status Info
            $sync = Invoke-UpdateCommand -Command 'pwsh' -Arguments @('-NoProfile', '-Command', 'scoop update')
            if ($sync.ExitCode -ne 0) {
                Write-UpdateStatus "Scoop synchronization failed (exit code $($sync.ExitCode))" -Status Error
                return
            }

            Write-UpdateStatus "Updating all unblocked Scoop apps to latest versions..." -Status Info
            $statusOutput = @(pwsh -NoProfile -Command "scoop status" 2>&1)
            if ($LASTEXITCODE -ne 0) {
                Write-UpdateStatus "Scoop status failed: $($statusOutput -join ' ')" -Status Error
                return
            }
            $candidates = @(ConvertFrom-ScoopStatusOutput -Output $statusOutput)
            $processes = @(Get-Process -ErrorAction SilentlyContinue)
            $appsToUpdate = @()

            foreach ($candidate in $candidates) {
                $blockers = @(Get-ScoopPackageBlockers -Name $candidate.Name -Process $processes)
                if ($blockers.Count -gt 0) {
                    Write-UpdateStatus "Skipping Scoop $($candidate.Name) $($candidate.InstalledVersion) -> $($candidate.LatestVersion); running process(es): $($blockers -join ', ')" -Status Warning
                } else {
                    $appsToUpdate += $candidate.Name
                }
            }

            $updatedApps = @()
            $failedApps = @()
            if ($appsToUpdate.Count -gt 0) {
                foreach ($app in $appsToUpdate) {
                    Write-Host "  Running: scoop update $app" -ForegroundColor DarkGray
                    $result = Invoke-UpdateCommand -Command 'pwsh' -Arguments @('-NoProfile', '-Command', "scoop update $app")
                    if ($result.ExitCode -ne 0 -and $app -eq 'apache' -and
                        ($result.Output -join "`n") -match '(401|Authorization failed|HTTP authorization failed)') {
                        try {
                            $result = Update-ScoopApacheMirror
                        } catch {
                            Write-UpdateStatus "Apache mirror recovery failed: $_" -Status Error
                        }
                    }
                    if ($result.ExitCode -eq 0) {
                        $updatedApps += $app
                    } else {
                        $failedApps += $app
                        Write-UpdateStatus "Scoop failed to update $app (exit code $($result.ExitCode)); continuing with other apps" -Status Error
                    }
                }
            } else {
                Write-Host "  No unblocked Scoop app updates found" -ForegroundColor DarkGray
            }

            # Cleanup old versions
            Write-UpdateStatus "Cleaning up old Scoop versions..." -Status Info
            if ($updatedApps.Count -gt 0) {
                $appList = $updatedApps -join ' '
                $cleanup = Invoke-UpdateCommand -Command 'pwsh' -Arguments @('-NoProfile', '-Command', "scoop cleanup $appList")
                if ($cleanup.ExitCode -ne 0) {
                    Write-UpdateStatus "Scoop cleanup failed (exit code $($cleanup.ExitCode))" -Status Error
                }
            } else {
                Write-Host "  No Scoop cleanup needed for skipped updates" -ForegroundColor DarkGray
            }

            if ($failedApps.Count -eq 0) {
                Write-UpdateStatus "Scoop update completed" -Status Success
            } else {
                Write-UpdateStatus "Scoop completed with failed packages: $($failedApps -join ', ')" -Status Warning
            }
        } else {
            Write-UpdateStatus "Scoop not installed, skipping..." -Status Warning
        }
    }
}

function ConvertFrom-ChocoOutdatedOutput {
    param([string[]]$Output)
    foreach ($line in $Output) {
        if ($line -match '^([A-Za-z0-9][A-Za-z0-9._-]*)\|([^|]+)\|([^|]+)\|(true|false)$') {
            [pscustomobject]@{Name=$Matches[1]; Installed=$Matches[2]; Available=$Matches[3]; Pinned=($Matches[4] -eq 'true')}
        }
    }
}

function Invoke-ChocoUpdateCommand {
    param([string]$Path, [string[]]$Arguments)
    if (Test-UpdateCommandExist 'sudo') {
        Invoke-UpdateCommand -Command 'sudo' -Arguments (@('--inline', $Path) + $Arguments)
    } else {
        Invoke-UpdateCommand -Command $Path -Arguments $Arguments
    }
}

function Update-Choco {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader 'Layer 1: Windows Package Managers - Chocolatey'
    if (-not $PSCmdlet.ShouldProcess('Chocolatey packages', 'Update')) { return }
    if (-not (Test-UpdateCommandExist 'choco')) {
        Write-UpdateStatus 'Chocolatey not installed, skipping...' -Status Info
        return
    }
    $chocoPath = (Get-Command choco).Source
    $query = Invoke-ChocoUpdateCommand -Path $chocoPath -Arguments @('outdated', '--limit-output')
    if ($query.ExitCode -eq 350) {
        Write-UpdateStatus 'Chocolatey updates remain pending: restart Windows, then run Update-Choco again (exit 350)' -Status Warning
        return
    }
    if ($query.ExitCode -notin @(0, 2)) {
        Write-UpdateStatus "Chocolatey cannot enumerate updates (exit code $($query.ExitCode))" -Status Error
        return
    }
    $packages = @(ConvertFrom-ChocoOutdatedOutput -Output $query.Output)
    $failed = @()
    # Self-update last, using the remote outdated query rather than local `list`.
    foreach ($package in @($packages | Sort-Object { if ($_.Name -eq 'chocolatey') { 1 } else { 0 } })) {
        if ($package.Pinned) {
            Write-UpdateStatus "Chocolatey package is pinned: $($package.Name)" -Status Info
            continue
        }
        Write-UpdateStatus "Updating Chocolatey $($package.Name): $($package.Installed) -> $($package.Available)" -Status Info
        $arguments = @('upgrade', $package.Name, '-y', '--no-progress', '--execution-timeout=600')
        $result = Invoke-ChocoUpdateCommand -Path $chocoPath -Arguments $arguments
        if ($result.ExitCode -eq 350) {
            Write-UpdateStatus 'Chocolatey updates remain pending: restart Windows, then run Update-Choco again (exit 350)' -Status Warning
            return
        } elseif ($result.ExitCode -eq 3010) {
            Write-UpdateStatus "Chocolatey $($package.Name) updated; Windows restart required" -Status Warning
        } elseif ($result.ExitCode -ne 0) {
            $failed += $package.Name
            Write-UpdateStatus "Chocolatey failed to update $($package.Name) (exit code $($result.ExitCode)); continuing" -Status Error
        }
    }
    if ($packages.Count -gt 0 -and $failed.Count -eq 0) {
        $verification = Invoke-ChocoUpdateCommand -Path $chocoPath -Arguments @('outdated', '--limit-output')
        if ($verification.ExitCode -notin @(0, 2)) {
            $failed += 'post-update verification'
            Write-UpdateStatus 'Cannot verify remaining Chocolatey updates' -Status Error
        } else {
            foreach ($pending in @(ConvertFrom-ChocoOutdatedOutput -Output $verification.Output)) {
                if (-not $pending.Pinned -and $pending.Name -in $packages.Name) {
                    $failed += $pending.Name
                    Write-UpdateStatus "Chocolatey still reports an update for $($pending.Name)" -Status Error
                }
            }
        }
    }
    if ($failed.Count -gt 0) {
        Write-UpdateStatus "Chocolatey completed with failed packages: $($failed -join ', ')" -Status Warning
    } elseif ($packages.Count -eq 0) {
        Write-UpdateStatus 'No Chocolatey package updates available' -Status Info
    } else {
        Write-UpdateStatus 'Chocolatey update completed' -Status Success
    }
}


function Get-NpmGlobalUpdatePackage {
    param([string]$Root, [object[]]$Process)
    foreach ($entry in @(Get-ChildItem -LiteralPath $Root -Directory -ErrorAction Stop)) {
        if ($entry.Name.StartsWith('.')) { continue }
        $directories = if ($entry.Name.StartsWith('@')) {
            @(Get-ChildItem -LiteralPath $entry.FullName -Directory | Where-Object { -not $_.Name.StartsWith('.') })
        } else { @($entry) }
        foreach ($directory in $directories) {
            $manifest = Join-Path $directory.FullName 'package.json'
            if (-not (Test-Path -LiteralPath $manifest)) { continue }
            $name = (Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json -ErrorAction Stop).name
            if (-not $name -or $name -eq 'npm') { continue }
            $prefix = $directory.FullName.TrimEnd('\') + '\'
            $busy = @($Process | Where-Object {
                ($_.ExecutablePath -and $_.ExecutablePath.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) -or
                ($_.CommandLine -and $_.CommandLine.Contains($prefix, [StringComparison]::OrdinalIgnoreCase))
            }).Count -gt 0
            [pscustomobject]@{ Name=$name; Busy=$busy }
        }
    }
}

function Update-Npm {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 2: Development Tools - NPM"

    if ($PSCmdlet.ShouldProcess("NPM global packages", "Update")) {
        if (Test-UpdateCommandExist 'npm') {
            # ============================================================
            # npm leaves staging directories after interrupted package replacement.
            # Archive only recognized, old entries; never delete arbitrary dot folders.
            Write-UpdateStatus "Checking for old npm staging directories..." -Status Info
            $failedSteps = @()
            $rootResult = Invoke-UpdateCommand -Command 'npm' -Arguments @('root', '-g')
            $npmRoot = ($rootResult.Output | Select-Object -Last 1)
            if ($rootResult.ExitCode -ne 0 -or -not $npmRoot -or -not (Test-Path -LiteralPath $npmRoot)) {
                Write-UpdateStatus 'Cannot determine the global npm root' -Status Error
                return
            }
            $processes = @(Get-CimInstance Win32_Process -ErrorAction Stop)
            $npmBusy = @($processes | Where-Object { $_.Name -eq 'node.exe' -and $_.CommandLine -match 'npm-cli\.js' }).Count -gt 0
            foreach ($staging in @(Get-NpmStagingDirectory -Root $npmRoot)) {
                $stagingPath = [IO.Path]::GetFullPath($staging.FullName)
                $resolvedRoot = [IO.Path]::GetFullPath($npmRoot).TrimEnd('\') + '\'
                if (-not $stagingPath.StartsWith($resolvedRoot, [StringComparison]::OrdinalIgnoreCase)) {
                    throw 'npm staging path is outside the global package root'
                }
                $inUse = @($processes | Where-Object {
                    ($_.ExecutablePath -and $_.ExecutablePath.StartsWith($stagingPath + '\', [StringComparison]::OrdinalIgnoreCase)) -or
                    ($_.CommandLine -and $_.CommandLine.Contains($stagingPath, [StringComparison]::OrdinalIgnoreCase))
                }).Count -gt 0
                if ($npmBusy -or $inUse) {
                    Write-UpdateStatus "Keeping npm staging directory in use: $stagingPath" -Status Info
                    continue
                }
                $archiveRoot = Join-Path $env:LOCALAPPDATA 'SystemUpgrade\npm-staging'
                New-Item -ItemType Directory -Path $archiveRoot -Force | Out-Null
                $archivePath = Join-Path $archiveRoot ($staging.Name + '-' + [guid]::NewGuid().ToString('N'))
                try {
                    Move-Item -LiteralPath $stagingPath -Destination $archivePath -ErrorAction Stop
                    Write-UpdateStatus "Archived npm staging directory: $archivePath" -Status Info
                } catch {
                    Write-UpdateStatus "Could not archive npm staging directory $stagingPath : $_" -Status Warning
                }
            }
            if ($npmBusy) {
                Write-UpdateStatus 'Another npm process is running; global updates deferred' -Status Warning
                return
            }
            Write-UpdateStatus "Verifying npm cache integrity..." -Status Info
            $cacheResult = Invoke-UpdateCommand -Command 'npm' -Arguments @('cache', 'verify')
            if ($cacheResult.ExitCode -ne 0) {
                $failedSteps += 'cache verify'
                Write-UpdateStatus "npm cache verification failed (exit code $($cacheResult.ExitCode))" -Status Error
            }

            # STEP 1: Update NPM itself
            # ============================================================
            Write-UpdateStatus "Updating NPM itself to latest version..." -Status Info
            $npmResult = Invoke-UpdateCommand -Command 'npm' -Arguments @('install', '-g', 'npm@latest')
            if ($npmResult.ExitCode -ne 0) { $failedSteps += 'npm install' }
            
            # ============================================================
            # STEP 2: Update all global packages
            # ============================================================
            Write-UpdateStatus "Updating all NPM global packages to latest versions..." -Status Info
            Write-Host "  Running: npm update -g" -ForegroundColor DarkGray
            Write-Host ""
            
            $globalPackages = @(Get-NpmGlobalUpdatePackage -Root $npmRoot -Process $processes)
            $busyPackages = @($globalPackages | Where-Object Busy | Select-Object -ExpandProperty Name)
            $safePackages = @($globalPackages | Where-Object { -not $_.Busy } | Select-Object -ExpandProperty Name)
            foreach ($busyPackage in $busyPackages) {
                Write-UpdateStatus "Keeping active npm package unchanged: $busyPackage" -Status Info
            }
            if ($safePackages.Count -gt 0) {
                $globalResult = Invoke-UpdateCommand -Command 'npm' -Arguments (@('update', '-g') + $safePackages)
                if ($globalResult.ExitCode -ne 0) { $failedSteps += 'npm update' }
                foreach ($notice in @($globalResult.Output | Where-Object { $_ -match '^npm warn' } | Select-Object -Unique)) {
                    Write-UpdateStatus "NPM: $notice" -Status Warning
                }
            }
            
            # ============================================================
            # STEP 3: Upgrade outdated packages
            # ============================================================
            Write-UpdateStatus "Upgrading outdated global packages..." -Status Info
            $outdatedResult = Invoke-UpdateCommand -Command 'npm' -Arguments @('outdated', '-g', '--json')
            $outdated = $null
            if ($outdatedResult.ExitCode -notin @(0, 1)) {
                $failedSteps += 'npm outdated'
            } else {
                try {
                    $outdated = $outdatedResult.Output -join "`n" | ConvertFrom-Json -ErrorAction Stop
                    if ($outdatedResult.ExitCode -eq 1 -and -not $outdated) { $failedSteps += 'npm outdated' }
                } catch {
                    $failedSteps += 'npm outdated JSON'
                }
            }
            if ($outdated) {
                foreach ($packageName in @($outdated.PSObject.Properties.Name | Where-Object { $_ })) {
                    if ($packageName -in $busyPackages) {
                        Write-UpdateStatus "NPM update pending for active package $packageName; retry after its sessions close" -Status Warning
                        $failedSteps += "$packageName (active)"
                        continue
                    }
                    Write-Host "  Upgrading: $packageName" -ForegroundColor DarkGray
                    $packageResult = Invoke-UpdateCommand -Command 'npm' -Arguments @('install', '-g', "$packageName@latest")
                    if ($packageResult.ExitCode -ne 0) { $failedSteps += $packageName }
                }
            }
            
            if ($failedSteps.Count -eq 0) {
                Write-UpdateStatus 'NPM update completed' -Status Success
            } else {
                Write-UpdateStatus "NPM completed with failed steps: $($failedSteps -join ', ')" -Status Error
            }
        } else {
            Write-UpdateStatus "NPM not installed, skipping..." -Status Warning
        }
    }
}

function Update-Pipx {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 2: Development Tools - Pipx"
    
    if ($PSCmdlet.ShouldProcess("Pipx packages", "Update")) {
        if (Test-UpdateCommandExist 'pipx') {
            Write-UpdateStatus "Upgrading Pipx itself to latest version..." -Status Info
            & pipx upgrade pipx 2>$null
            
            Write-UpdateStatus "Upgrading all Pipx packages to latest versions..." -Status Info
            Write-Host "  Running: pipx upgrade-all --include-injected" -ForegroundColor DarkGray
            Write-Host ""
            
            # --include-injected: Also upgrade injected packages
            & pipx upgrade-all --include-injected
            
            Write-UpdateStatus "Pipx update completed" -Status Success
        } else {
            Write-UpdateStatus "Pipx not installed, skipping..." -Status Warning
        }
    }
}

function Update-Cargo {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 2: Development Tools - Cargo"
    
    if ($PSCmdlet.ShouldProcess("Cargo packages", "Update")) {
        if (Test-UpdateCommandExist 'cargo') {
            # Update rustup itself first
            Write-UpdateStatus "Updating Rust toolchain to latest version..." -Status Info
            & rustup update
            
            if (Test-UpdateCommandExist 'cargo-install-update') {
                Write-UpdateStatus "Updating all Cargo packages to latest versions..." -Status Info
                Write-Host "  Running: cargo install-update -a" -ForegroundColor DarkGray
                Write-Host ""
                
                # -a updates all packages that actually have a newer version.
                # Do not force reinstall current packages: it is slow and can
                # collide with binaries that are currently in use.
                & cargo install-update -a
                
                Write-UpdateStatus "Cargo update completed" -Status Success
            } else {
                Write-UpdateStatus "cargo-install-update not found. Install with: cargo install cargo-update" -Status Warning
                Write-UpdateStatus "Attempting to update individual packages..." -Status Info
                # List installed packages and try to update them
                $installed = & cargo install --list 2>$null | Select-String "^\S+" | ForEach-Object { ($_ -split " ")[0] }
                foreach ($pkg in $installed | Select-Object -First 10) {
                    Write-Host "  Updating: $pkg" -ForegroundColor DarkGray
                    & cargo install $pkg --force 2>$null
                }
            }
        } else {
            Write-UpdateStatus "Cargo not installed, skipping..." -Status Warning
        }
    }
}

function Update-Uv {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 2: Development Tools - Uv"
    
    if ($PSCmdlet.ShouldProcess("Uv tool packages", "Update")) {
        if (Test-UpdateCommandExist 'uv') {
            $selfUpdateFailed = $false
            $uvCommand = Get-Command uv -ErrorAction SilentlyContinue
            $uvStandalone = "$env:USERPROFILE\.local\bin\uv.exe"
            $uvSelfUpdatePath = Get-UvSelfUpdateCommandPath -ActiveCommandPath $uvCommand.Source -LegacyStandalonePath $uvStandalone
            Write-UpdateStatus "Updating Uv self to latest version..." -Status Info
            if ($uvSelfUpdatePath) {
                $selfUpdateProbe = @(& $uvSelfUpdatePath self update --dry-run 2>&1)
                if ($LASTEXITCODE -eq 0) {
                    $selfUpdate = Invoke-UpdateCommand -Command $uvSelfUpdatePath -Arguments @('self', 'update')
                    if ($selfUpdate.ExitCode -ne 0) {
                        $selfUpdateFailed = $true
                        Write-UpdateStatus "Uv self update failed (exit code $($selfUpdate.ExitCode))" -Status Error
                    }
                } elseif (($selfUpdateProbe -join "`n") -match 'Self-update is only available') {
                    Write-Host "  Skipping uv self update (current uv was not installed by the standalone updater)" -ForegroundColor DarkGray
                } else {
                    $selfUpdateFailed = $true
                    Write-UpdateStatus "uv self-update check failed: $($selfUpdateProbe -join ' ')" -Status Error
                }
            } else {
                Write-Host "  Skipping uv self update (uv executable not found)" -ForegroundColor DarkGray
            }
            
            Write-UpdateStatus "Updating all Uv tool packages to latest versions..." -Status Info
            $listing = Invoke-UpdateCommand -Command $uvCommand.Source -Arguments @('tool', 'list')
            if ($listing.ExitCode -ne 0) {
                Write-UpdateStatus "Uv tool listing failed (exit code $($listing.ExitCode))" -Status Error
                return
            }
            $failedTools = @()
            foreach ($line in $listing.Output) {
                if ($line -match '^([A-Za-z0-9][A-Za-z0-9._-]*)\s+v\S+') {
                    $tool = $Matches[1]
                    $result = Invoke-UpdateCommand -Command $uvCommand.Source -Arguments @('tool', 'upgrade', $tool)
                    if ($result.ExitCode -ne 0) {
                        $failedTools += $tool
                        Write-UpdateStatus "Uv failed to upgrade $tool (exit code $($result.ExitCode)); see captured output for its source" -Status Error
                    }
                }
            }
            if ($selfUpdateFailed) { $failedTools += 'uv self-update' }
            if ($failedTools.Count -eq 0) {
                Write-UpdateStatus "Uv update completed" -Status Success
            } else {
                Write-UpdateStatus "Uv completed with failed tools: $($failedTools -join ', ')" -Status Warning
            }
        } else {
            Write-UpdateStatus "Uv not installed, skipping..." -Status Warning
        }
    }
}

function Update-PowerShellModule {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 3: PowerShell Modules"
    
    if ($PSCmdlet.ShouldProcess("PowerShell modules", "Update")) {
        Write-UpdateStatus "Repairing required PowerShell modules before update..." -Status Info
        Initialize-PowerShellGallery
        Invoke-RequiredModuleRepair

        if (-not (Get-Command Get-InstalledModule -ErrorAction SilentlyContinue)) {
            Write-UpdateStatus "PowerShellGet is not available, skipping module updates" -Status Warning
            return
        }

        Write-UpdateStatus "Checking installed PowerShell Gallery modules for updates..." -Status Info
        
        $modulesToUpdate = @()
        $allModules = @(Get-InstalledModule -ErrorAction SilentlyContinue |
            Group-Object Name |
            ForEach-Object { $_.Group | Sort-Object Version -Descending | Select-Object -First 1 })

        if ($allModules.Count -eq 0) {
            Write-UpdateStatus "No PowerShell Gallery modules are currently installed" -Status Success
            return
        }
        
        $checked = 0
        $total = $allModules.Count

        foreach ($currentModule in $allModules) {
            $checked++
            if ($checked % 10 -eq 0) {
                Write-Host "  Checking... ($checked/$total)" -ForegroundColor DarkGray
            }
            
            try {
                $online = Find-Module -Name $currentModule.Name -ErrorAction SilentlyContinue
                if ($online -and ($online.Version -gt $currentModule.Version)) {
                    $modulesToUpdate += [PSCustomObject]@{
                        Name = $currentModule.Name
                        CurrentVersion = $currentModule.Version
                        NewVersion = $online.Version
                    }
                }
            } catch {
                Write-UpdateStatus "Failed to query $($currentModule.Name) in PSGallery: $_" -Status Warning
            }
        }
        
        if ($modulesToUpdate.Count -eq 0) {
            Write-UpdateStatus "All PowerShell modules are up to date" -Status Success
        } else {
            Write-UpdateStatus "Found $($modulesToUpdate.Count) module(s) to update" -Status Info
            foreach ($mod in $modulesToUpdate) {
                Write-Host "  -> $($mod.Name): $($mod.CurrentVersion) -> $($mod.NewVersion)" -ForegroundColor Gray
                try {
                    Write-UpdateStatus "Updating $($mod.Name) from $($mod.CurrentVersion) to $($mod.NewVersion)..." -Status Info
                    Update-Module -Name $mod.Name -Force -AcceptLicense -ErrorAction Stop
                    Write-UpdateStatus "Updated $($mod.Name)" -Status Success
                } catch {
                    Write-UpdateStatus "Failed to update $($mod.Name): $_" -Status Error
                }
            }
        }
    }
}

function Get-PowerShellPublishedVersion {
    # The release redirect does not consume the shared anonymous REST API quota.
    $response = Invoke-WebRequest -Uri 'https://github.com/PowerShell/PowerShell/releases/latest' -Method Head -TimeoutSec 30 -ErrorAction Stop
    $uri = $response.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
    if ($uri -notmatch '^https://github\.com/PowerShell/PowerShell/releases/tag/v(?<Version>\d+\.\d+\.\d+)$') {
        throw 'Cannot determine the official stable PowerShell release'
    }
    [version]$Matches.Version
}

function Get-InstalledPowerShellVersion {
    # An existing session keeps its old version after Windows Update replaces the binary.
    $productVersion = (Get-Item -LiteralPath (Join-Path $PSHOME 'pwsh.exe') -ErrorAction Stop).VersionInfo.ProductVersion
    if ($productVersion -notmatch '^(\d+\.\d+\.\d+)(?:\s|\+|$)') { throw 'Cannot determine installed PowerShell binary version' }
    [version]$Matches[1]
}

function Update-PowerShellRuntime {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 5: PowerShell Runtime"

    if (-not $IsWindows) {
        Write-UpdateStatus "PowerShell runtime MSI updater is Windows-only, skipping..." -Status Warning
        return
    }

    if (-not [Environment]::Is64BitOperatingSystem) {
        Write-UpdateStatus "PowerShell runtime updater only handles win-x64, skipping..." -Status Warning
        return
    }

    if (-not $PSCmdlet.ShouldProcess("PowerShell runtime", "Update from official GitHub MSI")) {
        return
    }

    Write-UpdateStatus "Checking latest stable PowerShell release..." -Status Info

    $downloadDir = $null
    try {
        $currentVersion = Get-InstalledPowerShellVersion
        $latestVersion = Get-PowerShellPublishedVersion
        if ($currentVersion -ge $latestVersion) {
            Write-UpdateStatus "PowerShell is already current ($currentVersion)" -Status Success
            return
        }

        Write-UpdateStatus "PowerShell: $currentVersion -> $latestVersion" -Status Info
        $downloadDir = Join-Path $env:TEMP "powershell-$latestVersion-update-$([guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $downloadDir -ErrorAction Stop | Out-Null
        $msiName = "PowerShell-$latestVersion-win-x64.msi"
        $msiPath = Join-Path $downloadDir $msiName
        $msiUri = "https://github.com/PowerShell/PowerShell/releases/download/v$latestVersion/$msiName"

        Write-UpdateStatus "Downloading official PowerShell MSI..." -Status Info
        Invoke-WebRequest -Uri $msiUri -OutFile $msiPath -TimeoutSec 300 -ErrorAction Stop

        $signature = Get-AuthenticodeSignature -FilePath $msiPath
        if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notlike '*Microsoft Corporation*') {
            Write-UpdateStatus "Downloaded MSI signature is not valid Microsoft-signed content; refusing install" -Status Error
            return
        }

        Write-UpdateStatus "MSI signature validated: $($signature.SignerCertificate.Subject)" -Status Success

        if (-not (Test-UpdateCommandExist 'sudo')) {
            Write-UpdateStatus "sudo not available; PowerShell runtime update requires elevation" -Status Warning
            return
        }

        Write-UpdateStatus "Installing PowerShell $latestVersion with msiexec via sudo..." -Status Info
        Write-Host "  Running: sudo msiexec /i $msiPath /qn /norestart" -ForegroundColor DarkGray
        $installation = Invoke-UpdateCommand -Command 'sudo' -Arguments @('--inline', 'msiexec.exe', '/i', $msiPath, '/qn', '/norestart', 'USE_MU=1', 'ENABLE_MU=1', 'ADD_PATH=1', 'REGISTER_MANIFEST=1')
        $installExitCode = $installation.ExitCode

        if ($installExitCode -eq 0 -and (Get-InstalledPowerShellVersion) -ge $latestVersion) {
            Write-UpdateStatus "PowerShell runtime update completed. Restart terminals to use $latestVersion everywhere." -Status Success
        } elseif ($installExitCode -eq 3010) {
            Write-UpdateStatus 'PowerShell installer requires a Windows restart; runtime verification remains pending' -Status Warning
        } else {
            Write-UpdateStatus "PowerShell runtime update not verified (installer exit code: $installExitCode)" -Status Error
        }
    }
    catch {
        Write-UpdateStatus "PowerShell runtime update failed: $_" -Status Error
    }
    finally {
        # Only remove the unique directory created by this invocation.
        if ($downloadDir -and (Test-Path -LiteralPath $downloadDir)) {
            Remove-Item -LiteralPath $downloadDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Update-WindowsSystem {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 0: Windows System Updates"

    if ($PSCmdlet.ShouldProcess("Windows System", "Update")) {
        # Check for PSWindowsUpdate module
        if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
            Write-UpdateStatus "Checking for Windows updates via PSWindowsUpdate..." -Status Info
            try {
                # PSWindowsUpdate requires elevation for both checking and installing
                if (Get-Command 'sudo' -ErrorAction SilentlyContinue) {
                    $worker = Join-Path $PSScriptRoot 'Updates\InstallWindowsUpdates.ps1'
                    $hostPath = (Get-Process -Id $PID).Path
                    $result = Invoke-UpdateCommand -Command 'sudo' -Arguments @('--inline', $hostPath, '-NoProfile', '-File', $worker)
                    if ($result.ExitCode -eq 3010) {
                        Write-UpdateStatus 'Windows updates remain pending until Windows is restarted' -Status Warning
                    } elseif ($result.ExitCode -ne 0) {
                        Write-UpdateStatus "Windows Update did not complete (exit $($result.ExitCode)); inspect captured results and WindowsUpdateClient events" -Status Error
                    } else {
                        Write-UpdateStatus 'Windows Update scan/install completed; see captured results for reboot requirements' -Status Success
                    }
                } else {
                    Write-UpdateStatus "sudo not available - Windows Update requires elevation" -Status Warning
                    Write-UpdateStatus "Enable sudo in Windows Settings > Developer Settings" -Status Info
                }
            } catch {
                Write-UpdateStatus "Windows Update check failed: $_" -Status Error
            }
        } else {
            Write-UpdateStatus "PSWindowsUpdate module not found, using Windows Update client..." -Status Info
            try {
                Write-Host "  Starting Windows Update scan and install..." -ForegroundColor Gray
                if (Get-Command 'sudo' -ErrorAction SilentlyContinue) {
                    sudo usoclient StartScan
                    sudo usoclient StartInstall
                } else {
                    Start-Process -FilePath "usoclient" -ArgumentList "StartScan" -Wait -WindowStyle Hidden
                    Start-Process -FilePath "usoclient" -ArgumentList "StartInstall" -Wait -WindowStyle Hidden
                }
                Write-UpdateStatus "Windows Update triggered successfully" -Status Success
            } catch {
                Write-UpdateStatus "Windows Update via usoclient failed: $_" -Status Error
            }
        }
    }
}

function Update-StoreApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 3: Microsoft Store Apps"
    
    if ($PSCmdlet.ShouldProcess("Store apps", "Update")) {
        $winget = Get-WingetExecutable
        if ($winget) {
            Write-UpdateStatus "Updating Microsoft Store apps..." -Status Info
            try {
                & $winget upgrade --all --source msstore --silent --accept-source-agreements --accept-package-agreements --disable-interactivity
                $exitCode = $LASTEXITCODE
                if ($exitCode -eq -1978335189) {
                    Write-UpdateStatus "No applicable Microsoft Store updates found; unknown versions are not verified" -Status Info
                } elseif ($exitCode -eq 0) {
                    Write-UpdateStatus "Microsoft Store applicable updates completed" -Status Success
                }
                else {
                    Write-UpdateStatus "Microsoft Store app update failed with exit code $exitCode" -Status Warning
                }
            } catch {
                Write-UpdateStatus "Microsoft Store app update failed: $_" -Status Warning
            }
        } else {
            Write-UpdateStatus "Winget not available, skipping Microsoft Store apps..." -Status Warning
        }
    }
}

function Update-Vcpkg {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string[]]$VcpkgRoots = @('C:\vcpkg', 'D:\opt\vcpkg', 'C:\tools\vcpkg')
    )
    Write-UpdateHeader "Layer 2: Development Tools - vcpkg"
    
    if ($PSCmdlet.ShouldProcess("vcpkg", "Update")) {
        # Find vcpkg installation
        $VcpkgRoot = $null
        foreach ($root in $VcpkgRoots) {
            if (Test-Path $root) {
                $VcpkgRoot = $root
                break
            }
        }
        
        if (-not $VcpkgRoot) {
            Write-UpdateStatus "vcpkg directory not found in any standard location, skipping..." -Status Warning
            return
        }
        
        Write-UpdateStatus "Found vcpkg at $VcpkgRoot" -Status Info
        Write-UpdateStatus "Updating vcpkg tool and all packages to latest versions..." -Status Info
            
        try {
            $originalLocation = Get-Location
            Set-Location $VcpkgRoot
            
            Write-Host "  Running: git pull" -ForegroundColor DarkGray
            & git pull
            if ($LASTEXITCODE -ne 0) {
                Write-UpdateStatus "Git pull failed with exit code: $LASTEXITCODE" -Status Warning
            }
            
            # Verificar si vcpkg.exe existe antes del bootstrap
            $vcpkgExePath = Join-Path $VcpkgRoot "vcpkg.exe"
            $vcpkgExeExisted = Test-Path $vcpkgExePath
            
            Write-Host "  Running: bootstrap-vcpkg.bat" -ForegroundColor DarkGray
            $bootstrapExitCode = 0
            try {
                # Aumentar timeout de WinHTTP antes del bootstrap
                $env:WINHTTP_OPTION_CONNECT_TIMEOUT = 120000  # 120 segundos
                $env:WINHTTP_OPTION_SEND_TIMEOUT = 120000
                $env:WINHTTP_OPTION_RECEIVE_TIMEOUT = 120000
                
                if (Test-UpdateCommandExist 'sudo') {
                    $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c bootstrap-vcpkg.bat" -WorkingDirectory $VcpkgRoot -Wait -PassThru -NoNewWindow
                    $bootstrapExitCode = $proc.ExitCode
                } else {
                    $proc = Start-Process -FilePath ".\bootstrap-vcpkg.bat" -WorkingDirectory $VcpkgRoot -Wait -PassThru -NoNewWindow
                    $bootstrapExitCode = $proc.ExitCode
                }
            }
            catch {
                Write-UpdateStatus "Bootstrap execution failed: $_" -Status Warning
                $bootstrapExitCode = 1
            }
            
            if ($bootstrapExitCode -ne 0) {
                Write-UpdateStatus "Bootstrap failed with exit code: $bootstrapExitCode (posible timeout de red)" -Status Warning
                if ($vcpkgExeExisted) {
                    Write-UpdateStatus "Usando vcpkg.exe existente para continuar con la actualizacion..." -Status Info
                } else {
                    Write-UpdateStatus "No se encontro vcpkg.exe y el bootstrap fallo. Omitiendo actualizacion de paquetes." -Status Warning
                    return
                }
            }
            
            # Verificar que vcpkg.exe existe (ya sea el antiguo o el nuevo)
            if (-not (Test-Path $vcpkgExePath)) {
                Write-UpdateStatus "vcpkg.exe no encontrado en $vcpkgExePath" -Status Error
                return
            }
            
            # Agregar al PATH temporalmente si es necesario
            $vcpkgCmd = ".\vcpkg.exe"
            
            Write-Host "  Running: vcpkg upgrade --no-dry-run" -ForegroundColor DarkGray
            & $vcpkgCmd upgrade --no-dry-run
            $upgradeExitCode = $LASTEXITCODE
            
            if ($upgradeExitCode -eq 0) {
                Write-UpdateStatus "vcpkg upgrade completed" -Status Success
            } elseif ($upgradeExitCode -eq 1) {
                # Exit code 1 usualmente significa "no hay nada que actualizar"
                Write-UpdateStatus "vcpkg upgrade: no hay paquetes para actualizar" -Status Success
            } else {
                Write-UpdateStatus "vcpkg upgrade finished with exit code: $upgradeExitCode" -Status Warning
            }
            
            # Remove outdated packages
            Write-Host "  Cleaning up outdated packages..." -ForegroundColor DarkGray
            & $vcpkgCmd remove --outdated --recurse 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-UpdateStatus "Cleanup completed" -Status Success
            }
        }
        catch {
            Write-UpdateStatus "vcpkg update failed: $_" -Status Error
        }
        finally {
            Set-Location $originalLocation
        }
    }
}

# Additional Development Tools

function Get-CondaUpdateExecutable {
    # Miniforge deliberately need not be added to the interactive PATH.
    $command = Get-Command conda -CommandType Application -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    foreach ($root in @($env:CONDA_PREFIX, "$env:USERPROFILE\miniforge3", "$env:USERPROFILE\miniconda3", "$env:ProgramData\miniforge3")) {
        if (-not $root) { continue }
        $candidate = Join-Path $root 'Scripts\conda.exe'
        if (Test-Path -LiteralPath $candidate) { return $candidate }
    }
    return $null
}

function Update-Conda {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 2: Development Tools - Conda/Mamba"
    
    if ($PSCmdlet.ShouldProcess("Conda environments", "Update")) {
        $conda = Get-CondaUpdateExecutable
        if ($conda) {
            Write-UpdateStatus 'Updating Conda base environment...' -Status Info
            try {
                $probe = Invoke-UpdateCommand -Command $conda -Arguments @('info', '--json') -TimeoutSeconds 60
                if ($probe.ExitCode -ne 0) { throw 'Conda cannot start; repair its base environment before updating' }
                $info = ($probe.Output -join "`n") | ConvertFrom-Json -ErrorAction Stop
                if (-not $info.root_prefix) { throw 'Conda did not report its base prefix' }
                $result = Invoke-UpdateCommand -Command $conda -Arguments @('update', '--prefix', $info.root_prefix, '--all', '-y') -TimeoutSeconds 1800
                if ($result.ExitCode -ne 0) { throw "Conda update exited $($result.ExitCode)" }
                $verify = Invoke-UpdateCommand -Command $conda -Arguments @('update', '--prefix', $info.root_prefix, '--all', '--dry-run', '--json') -TimeoutSeconds 180
                if ($verify.ExitCode -ne 0) { throw "Conda verification exited $($verify.ExitCode)" }
                $plan = ($verify.Output -join "`n") | ConvertFrom-Json -ErrorAction Stop
                if (-not $plan.success -or @($plan.actions.LINK | Where-Object { $_ }).Count) {
                    throw 'Conda still has pending changes'
                }
                Write-UpdateStatus 'Conda base update verified' -Status Success
            } catch {
                Write-UpdateStatus "Conda update failed: $_" -Status Error
            }
        } else {
            Write-UpdateStatus "Conda/Mamba not installed, skipping..." -Status Info
        }
    }
}

function Update-Msys2 {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Root = 'C:\msys64')
    Write-UpdateHeader 'Layer 2: Development Tools - MSYS2'
    if (-not $PSCmdlet.ShouldProcess($Root, 'Update MSYS2 packages')) { return }
    $bash = Join-Path $Root 'usr\bin\bash.exe'
    if (-not (Test-Path -LiteralPath $bash)) {
        Write-UpdateStatus 'MSYS2 not installed at the configured root, skipping' -Status Info
        return
    }
    $active = @(Get-Process | Where-Object { $_.Path -and $_.Path.StartsWith($Root.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase) })
    if ($active.Count -or (Test-Path -LiteralPath (Join-Path $Root 'var\lib\pacman\db.lck'))) {
        Write-UpdateStatus 'MSYS2 is in use or its package database is locked; update pending' -Status Warning
        return
    }
    # Core updates close their shell. A fresh process completes remaining packages.
    foreach ($pass in 1..2) {
        $result = Invoke-UpdateCommand -Command $bash -Arguments @('-c', 'export PATH=/usr/bin:/bin; exec pacman -Syu --noconfirm') -TimeoutSeconds 1800
        if ($result.ExitCode -ne 0) {
            Write-UpdateStatus "MSYS2 pass $pass failed (exit $($result.ExitCode))" -Status Error
            return
        }
    }
    $remaining = Invoke-UpdateCommand -Command $bash -Arguments @('-c', 'export PATH=/usr/bin:/bin; exec pacman -Qu') -TimeoutSeconds 60
    # pacman -Qu returns 1 with empty output when no upgrades are available.
    if ($remaining.ExitCode -eq 1 -and -not @($remaining.Output | Where-Object { $_.Trim() }).Count) {
        Write-UpdateStatus 'MSYS2 packages verified current' -Status Success
    } else {
        Write-UpdateStatus 'MSYS2 still has pending updates or verification failed; see command output' -Status Warning
    }
}

function Update-DotnetTool {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 2: Development Tools - .NET Global Tools"
    
    if ($PSCmdlet.ShouldProcess(".NET global tools", "Update")) {
        if (Test-UpdateCommandExist 'dotnet') {
            Write-UpdateStatus "Checking .NET SDK package manager updates..." -Status Info
            # The broad Winget/Chocolatey layers handle SDK packages. Only call
            # this exact WinGet package when it is actually installed via WinGet.
            if (Test-WingetPackageInstalled 'Microsoft.DotNet.SDK.8') {
                $winget = Get-WingetExecutable
                & $winget upgrade --id Microsoft.DotNet.SDK.8 --source winget --exact --silent --accept-source-agreements --accept-package-agreements --disable-interactivity 2>$null
            } else {
                Write-Host "  .NET SDK is not managed by WinGet package Microsoft.DotNet.SDK.8; skipping SDK package step" -ForegroundColor DarkGray
            }
            
            Write-UpdateStatus "Updating all .NET global tools to latest versions..." -Status Info
            try {
                Write-Host "  Running: dotnet tool update --global --all" -ForegroundColor DarkGray
                # First try to update all
                & dotnet tool update --global --all
                
                # List installed tools and force update each one
                $tools = & dotnet tool list --global | Select-Object -Skip 2 | ForEach-Object { ($_ -split "\s+")[0] } | Where-Object { $_ }
                foreach ($tool in $tools) {
                    Write-Host "  Ensuring latest: $tool" -ForegroundColor DarkGray
                    & dotnet tool update --global $tool --version "*-*" 2>$null
                }
                
                Write-UpdateStatus ".NET global tools update completed" -Status Success
            } catch {
                Write-UpdateStatus ".NET tool update failed: $_" -Status Error
            }
        } else {
            Write-UpdateStatus ".NET SDK not installed, skipping..." -Status Warning
        }
    }
}

function Update-Gem {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 2: Development Tools - Ruby Gems"
    
    if ($PSCmdlet.ShouldProcess("Ruby gems", "Update")) {
        if ((Test-UpdateCommandExist 'ruby') -and (Test-UpdateCommandExist 'gem')) {
            $rubyProbe = @(& ruby --version 2>&1)
            $rubyExitCode = $LASTEXITCODE
            $gemProbe = @(& gem --version 2>&1)
            $gemExitCode = $LASTEXITCODE
            if ($rubyExitCode -ne 0 -or $gemExitCode -ne 0) {
                Write-UpdateStatus "Ruby toolchain is broken; ruby: $($rubyProbe -join ' '); gem: $($gemProbe -join ' ')" -Status Error
                return
            }

            Write-UpdateStatus "Updating RubyGems itself to latest version..." -Status Info
            # Updating RubyGems system requires admin privileges (installs to C:/Ruby32-x64)
            if (Test-UpdateCommandExist 'sudo') {
                sudo gem update --system --no-document --silent
            } else {
                & gem update --system --no-document --silent
            }
            $gemSystemExitCode = $LASTEXITCODE
            
            Write-UpdateStatus "Updating all Ruby gems to latest versions..." -Status Info
            try {
                Write-Host "  Running: gem update" -ForegroundColor DarkGray
                # --conservative: Skip updates that downgrade gems
                # But we want latest, so no conservative flag
                if (Test-UpdateCommandExist 'sudo') {
                    sudo gem update --no-document
                } else {
                    & gem update --no-document
                }
                $gemUpdateExitCode = $LASTEXITCODE
                Write-Host "  Running: gem cleanup" -ForegroundColor DarkGray
                if (Test-UpdateCommandExist 'sudo') {
                    sudo gem cleanup
                } else {
                    & gem cleanup
                }
                
                $gemCleanupExitCode = $LASTEXITCODE
                if ($gemSystemExitCode -eq 0 -and $gemUpdateExitCode -eq 0 -and $gemCleanupExitCode -eq 0) {
                    Write-UpdateStatus "Ruby gems update completed" -Status Success
                } else {
                    Write-UpdateStatus "Ruby gems finished with failures (system: $gemSystemExitCode, update: $gemUpdateExitCode, cleanup: $gemCleanupExitCode)" -Status Warning
                }
            } catch {
                Write-UpdateStatus "Ruby gems update failed: $_" -Status Error
            }
        } else {
            if ((Test-UpdateCommandExist 'ruby') -or (Test-UpdateCommandExist 'gem')) {
                Write-UpdateStatus 'Ruby toolchain is incomplete: ruby and gem must both be available' -Status Error
            } else {
                Write-UpdateStatus 'Ruby not installed, skipping Ruby updates' -Status Info
            }
        }
    }
}

function Update-GoTools {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 2: Development Tools - Go Tools"
    
    if ($PSCmdlet.ShouldProcess("Go tools", "Update")) {
        if (Test-UpdateCommandExist 'go') {
            Write-UpdateStatus "Updating Go tools to latest versions..." -Status Info
            try {
                $goBin = & go env GOPATH 2>$null
                if (-not $goBin) {
                    $goBin = Join-Path $env:USERPROFILE "go"
                }
                $goBinPath = Join-Path $goBin "bin"
                
                if (Test-Path $goBinPath) {
                    $tools = Get-ChildItem -Path $goBinPath -Filter "*.exe" | Select-Object -ExpandProperty BaseName
                    if ($tools) {
                        Write-Host "  Found $($tools.Count) Go tool(s) to update" -ForegroundColor DarkGray
                        $updatedCount = 0
                        
                        # Mapa común de tools a sus packages
                        $toolMap = @{
                            'gopls' = 'golang.org/x/tools/gopls@latest'
                            'staticcheck' = 'honnef.co/go/tools/cmd/staticcheck@latest'
                            'gollama' = 'github.com/sammcj/gollama@latest'
                            'velo' = 'github.com/bjarneo/velo@latest'
                            'dlv' = 'github.com/go-delve/delve/cmd/dlv@latest'
                            'gofumpt' = 'mvdan.cc/gofumpt@latest'
                            'gci' = 'github.com/daixiang0/gci@latest'
                            'gosec' = 'github.com/securego/gosec/v2/cmd/gosec@latest'
                            'golint' = 'golang.org/x/lint/golint@latest'
                            'goimports' = 'golang.org/x/tools/cmd/goimports@latest'
                            'goreleaser' = 'github.com/goreleaser/goreleaser@latest'
                            'cobra-cli' = 'github.com/spf13/cobra-cli@latest'
                            'air' = 'github.com/cosmtrek/air@latest'
                            'realize' = 'github.com/oxequa/realize@latest'
                            'reflex' = 'github.com/cespare/reflex@latest'
                            'modd' = 'github.com/cortesi/modd/cmd/modd@latest'
                        }
                        
                        foreach ($tool in $tools) {
                            $pkg = $toolMap[$tool]
                            if ($pkg) {
                                Write-Host "  Updating: $tool from $pkg" -ForegroundColor DarkGray
                                $goOutput = & go install $pkg 2>&1
                                if ($LASTEXITCODE -eq 0) {
                                    Write-Host "    Updated $tool successfully" -ForegroundColor DarkGray
                                    $updatedCount++
                                } else {
                                    Write-UpdateStatus "Failed to update $tool`: $($goOutput -join ' ')" -Status Error
                                }
                            } else {
                                Write-UpdateStatus "Unknown package for: $tool (skipping)" -Status Warning
                            }
                        }
                        $status = if ($updatedCount -eq $tools.Count) { 'Success' } else { 'Warning' }
                        Write-UpdateStatus "Updated $updatedCount/$($tools.Count) Go tool(s)" -Status $status
                    } else {
                        Write-UpdateStatus "No Go tools found in $goBinPath" -Status Success
                    }
                } else {
                    Write-UpdateStatus "Go bin directory not found, skipping..." -Status Warning
                }
            } catch {
                Write-UpdateStatus "Go tools update failed: $_" -Status Error
            }
        } else {
            Write-UpdateStatus "Go not installed, skipping..." -Status Warning
        }
    }
}

function Update-Composer {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 2: Development Tools - Composer"
    
    if ($PSCmdlet.ShouldProcess("Composer packages", "Update")) {
        # Buscar composer en ubicaciones comunes
        $composerFound = $false
        $composerCmd = $null
        
        $composerCmdObj = Get-Command composer -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
        $possiblePaths = @(
            $composerCmdObj
            "$env:ProgramData\Composer\composer.bat"
            "$env:USERPROFILE\Composer\composer.bat"
        )
        
        foreach ($path in $possiblePaths) {
            if ($path -and (Test-Path $path)) {
                $composerFound = $true
                $composerCmd = $path
                break
            }
        }
        
        if ($composerFound) {
            Write-UpdateStatus "Updating Composer itself..." -Status Info
            try {
                Write-Host "  Running: composer self-update" -ForegroundColor DarkGray
                $composerOutput = @(& $composerCmd self-update 2>&1)
                if ($LASTEXITCODE -eq 0) {
                    $composerOutput | ForEach-Object { Write-Host $_ }
                    Write-UpdateStatus "Composer update completed" -Status Success
                    Write-UpdateStatus "Note: Project dependencies not updated (run 'composer update' in project dirs)" -Status Info
                } else {
                    Write-UpdateStatus "Composer self-update failed securely; TLS verification was not disabled: $($composerOutput -join ' ')" -Status Error
                }
            } catch {
                Write-UpdateStatus "Composer update failed: $_" -Status Warning
            }
        } else {
            Write-UpdateStatus "Composer not installed, skipping..." -Status Warning
        }
    }
}

function Update-Gcloud {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 2: Development Tools - Google Cloud SDK"

    if ($PSCmdlet.ShouldProcess("Google Cloud SDK", "Update")) {
        if (Test-UpdateCommandExist 'gcloud') {
            Write-UpdateStatus "Updating Google Cloud SDK components..." -Status Info
            # gcloud requires CLOUDSDK_PYTHON within the same elevated process — set it inline via sudo powershell
            $gcloudPython = & gcloud components copy-bundled-python 2>$null
            Write-Host "  Running: sudo gcloud components update --quiet" -ForegroundColor DarkGray
            Write-Host ""
            if ($gcloudPython) {
                sudo powershell -NoProfile -Command "`$env:CLOUDSDK_PYTHON='$gcloudPython'; gcloud components update --quiet"
            } else {
                sudo gcloud components update --quiet
            }
            if ($LASTEXITCODE -eq 0) {
                Write-UpdateStatus "Google Cloud SDK update completed" -Status Success
            } else {
                Write-UpdateStatus "Google Cloud SDK update finished with exit code: $LASTEXITCODE" -Status Warning
            }
        } else {
            Write-UpdateStatus "Google Cloud SDK not installed, skipping..." -Status Warning
        }
    }
}


function Update-Homebrew {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Distribution = 'fedora')
    Write-UpdateHeader 'Layer 1: Package Managers - Homebrew (WSL)'
    if (-not $PSCmdlet.ShouldProcess("Homebrew in $Distribution", 'Update')) { return }
    if (-not (Test-UpdateCommandExist 'wsl')) { return }
    $brew = '/home/linuxbrew/.linuxbrew/bin/brew'
    $base = @('--distribution', $Distribution, '--exec')
    $probe = Invoke-UpdateCommand -Command 'wsl' -Arguments ($base + @('test', '-x', $brew)) -TimeoutSeconds 30
    if ($probe.ExitCode -ne 0) {
        Write-UpdateStatus "Homebrew unavailable in $Distribution (exit $($probe.ExitCode))" -Status Warning
        return
    }
    # Homebrew's portable Ruby supplies Fiddle for Landlock; the host Ruby may not.
    $prefix = $base + @('/usr/bin/env', 'PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/usr/local/bin:/usr/bin:/bin', 'HOMEBREW_NO_ASK=1', 'HOMEBREW_NO_AUTOREMOVE=1', 'HOMEBREW_FORCE_VENDOR_RUBY=1', $brew)
    foreach ($step in @(@('update'), @('upgrade', '--no-ask'), @('cleanup'))) {
        Write-UpdateStatus "Homebrew: $($step -join ' ')" -Status Info
        $result = Invoke-UpdateCommand -Command 'wsl' -Arguments ($prefix + $step) -TimeoutSeconds 1800
        if ($result.ExitCode -ne 0) {
            Write-UpdateStatus "Homebrew $($step[0]) failed (exit $($result.ExitCode)); see command output" -Status Error
            return
        }
        foreach ($warning in @($result.Output | Where-Object { $_ -match '^Warning:' } | Select-Object -Unique)) {
            Write-UpdateStatus "Homebrew: $warning" -Status Warning
        }
    }
    $remaining = Invoke-UpdateCommand -Command 'wsl' -Arguments ($prefix + @('outdated', '--quiet')) -TimeoutSeconds 120
    if ($remaining.ExitCode -ne 0) {
        Write-UpdateStatus 'Cannot verify remaining Homebrew updates' -Status Error
    } elseif (@($remaining.Output | Where-Object { $_.Trim() }).Count -gt 0) {
        Write-UpdateStatus "Homebrew still has pending updates: $($remaining.Output -join ', ')" -Status Warning
    } else {
        $geminiCommand = 'if test -f "$HOME/.local/lib/node_modules/@google/gemini-cli/package.json"; then /usr/bin/npm update --global --prefix "$HOME/.local" @google/gemini-cli; fi'
        $gemini = Invoke-UpdateCommand -Command 'wsl' -Arguments ($base + @('/bin/sh', '-c', $geminiCommand)) -TimeoutSeconds 600
        if ($gemini.ExitCode -ne 0) {
            Write-UpdateStatus "WSL Gemini CLI npm update failed (exit $($gemini.ExitCode))" -Status Error
        } else {
            foreach ($notice in @($gemini.Output | Where-Object { $_ -match '^npm warn' } | Select-Object -Unique)) {
                Write-UpdateStatus "WSL Gemini CLI: $notice" -Status Warning
            }
            Write-UpdateStatus 'Homebrew and managed WSL CLI updates verified' -Status Success
        }
    }
}

function Update-WslDotnet {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Distribution = 'fedora')
    if (-not $PSCmdlet.ShouldProcess("mise .NET in $Distribution", 'Upgrade global .NET requests')) { return }
    if (-not (Test-UpdateCommandExist 'wsl')) { return }
    $command = 'test -x "$HOME/.local/bin/mise" && "$HOME/.local/bin/mise" upgrade --global dotnet --yes && "$HOME/.local/bin/mise" exec -- dotnet --info'
    $result = Invoke-UpdateCommand -Command 'wsl' -Arguments @('--distribution', $Distribution, '--cd', '~', '--exec', '/bin/sh', '-c', $command) -TimeoutSeconds 1800
    if ($result.ExitCode -ne 0) {
        Write-UpdateStatus "mise .NET update failed in $Distribution (exit $($result.ExitCode)); see command output" -Status Error
        return
    }
    Write-UpdateStatus "mise .NET update verified in $Distribution" -Status Success
}

function Update-Chezmoi {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 4: Dotfiles - Chezmoi"
    
    if ($PSCmdlet.ShouldProcess("Chezmoi dotfiles", "Update")) {
        if (Test-UpdateCommandExist 'chezmoi') {
            Write-UpdateStatus "Updating chezmoi..." -Status Info
            try {
                $chezmoiCommand = Get-Command chezmoi -ErrorAction Stop
                if (Test-WingetManagedCommandPath $chezmoiCommand.Source) {
                    Write-Host "  Chezmoi is managed by WinGet; package updates are handled by the Winget layer" -ForegroundColor DarkGray
                } elseif ($chezmoiCommand.Source -match '\\scoop\\') {
                    Write-Host "  Running: scoop update chezmoi" -ForegroundColor DarkGray
                    & scoop update chezmoi
                } else {
                    Write-Host "  Running: chezmoi upgrade" -ForegroundColor DarkGray
                    & chezmoi upgrade
                }
                Write-UpdateStatus "Chezmoi upgrade completed" -Status Success
            } catch {
                Write-UpdateStatus "Chezmoi upgrade failed: $_" -Status Error
            }
        } else {
            Write-UpdateStatus "Chezmoi not installed, skipping..." -Status Warning
        }
    }
}

function Update-Starship {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 4: Shell Tools - Starship"
    
    if ($PSCmdlet.ShouldProcess("Starship prompt", "Update")) {
        if (Test-UpdateCommandExist 'starship') {
            Write-UpdateStatus "Updating Starship prompt..." -Status Info
            try {
                $winget = Get-WingetExecutable
                if ($winget) {
                    Write-Host "  Attempting update via winget..." -ForegroundColor DarkGray
                    & $winget upgrade Starship.Starship --silent 2>$null
                }
                elseif (Test-UpdateCommandExist 'scoop') {
                    Write-Host "  Attempting update via scoop..." -ForegroundColor DarkGray
                    & scoop update starship 2>$null
                }
                else {
                    Write-Host "  Running: starship upgrade" -ForegroundColor DarkGray
                    & starship upgrade
                }
                Write-UpdateStatus "Starship update completed" -Status Success
            } catch {
                Write-UpdateStatus "Starship update failed: $_" -Status Error
            }
        } else {
            Write-UpdateStatus "Starship not installed, skipping..." -Status Warning
        }
    }
}

function Update-Fzf {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 4: Shell Tools - fzf"
    
    if ($PSCmdlet.ShouldProcess("fzf fuzzy finder", "Update")) {
        if (Test-UpdateCommandExist 'fzf') {
            Write-UpdateStatus "Updating fzf..." -Status Info
            try {
                $fzfDir = Join-Path $env:USERPROFILE ".fzf"
                if (Test-Path $fzfDir) {
                    $originalLocation = Get-Location
                    try {
                        Set-Location $fzfDir
                        Write-Host "  Running: git pull && ./install" -ForegroundColor DarkGray
                        & git pull
                        if (Test-Path ".\install.ps1") {
                            & .\install.ps1 --all
                        }
                    } finally {
                        Set-Location $originalLocation
                    }
                }
                elseif (Test-UpdateCommandExist 'scoop') {
                    Write-Host "  Updating via scoop..." -ForegroundColor DarkGray
                    & scoop update fzf
                }
                elseif (Test-UpdateCommandExist 'choco') {
                    Write-Host "  Updating via choco..." -ForegroundColor DarkGray
                    & choco upgrade fzf -y
                }
                elseif ($winget = Get-WingetExecutable) {
                    Write-Host "  Updating via winget..." -ForegroundColor DarkGray
                    & $winget upgrade junegunn.fzf --silent
                }
                else {
                    Write-UpdateStatus "fzf update method not available" -Status Warning
                    return
                }
                Write-UpdateStatus "fzf update completed" -Status Success
            } catch {
                Write-UpdateStatus "fzf update failed: $_" -Status Error
            }
        } else {
            Write-UpdateStatus "fzf not installed, skipping..." -Status Warning
        }
    }
}

function Update-VSCodeExtension {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 4: VS Code Extensions"
    
    if ($PSCmdlet.ShouldProcess("VS Code extensions", "Update")) {
        $vscodePath = Get-Command 'code' -ErrorAction SilentlyContinue | 
            Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue
        
        if (-not $vscodePath) {
            $possiblePaths = @(
                "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
                "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd",
                "$env:ProgramFiles(x86)\Microsoft VS Code\bin\code.cmd"
            )
            foreach ($possible in $possiblePaths) {
                if (Test-Path $possible) {
                    $vscodePath = $possible
                    break
                }
            }
        }
        
        if ($vscodePath) {
            Write-UpdateStatus "Updating VS Code extensions..." -Status Info
            try {
                $oldNodeNoWarnings = $env:NODE_NO_WARNINGS
                $env:NODE_NO_WARNINGS = '1'
                Write-Host "  Running: code --update-extensions" -ForegroundColor DarkGray
                & $vscodePath --update-extensions
                
                $codeInsiderPath = $vscodePath -replace 'code', 'code-insiders'
                if (Test-Path $codeInsiderPath) {
                    Write-Host "  Running: code-insiders --update-extensions" -ForegroundColor DarkGray
                    & $codeInsiderPath --update-extensions
                }
                
                Write-UpdateStatus "VS Code extensions update completed" -Status Success
            } catch {
                Write-UpdateStatus "VS Code extensions update failed: $_" -Status Error
            } finally {
                if ($null -eq $oldNodeNoWarnings) {
                    Remove-Item Env:NODE_NO_WARNINGS -ErrorAction SilentlyContinue
                } else {
                    $env:NODE_NO_WARNINGS = $oldNodeNoWarnings
                }
            }
        } else {
            Write-UpdateStatus "VS Code not found, skipping..." -Status Warning
        }
    }
}


function Get-WslPublishedVersion {
    # The public API is frequently rate limited. The official release redirect is
    # also usable without a token and avoids inheriting GitHub API's shared quota.
    $response = Invoke-WebRequest -Uri 'https://github.com/microsoft/WSL/releases/latest' -Method Head -TimeoutSec 30 -ErrorAction Stop
    $uri = $response.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
    if ($uri -notmatch '^https://github\.com/microsoft/WSL/releases/tag/(?<Version>\d+\.\d+\.\d+(?:\.\d+)?)$') {
        throw 'Cannot determine the official stable WSL release'
    }
    [version]$Matches.Version
}

function Update-WSL {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Distribution = 'fedora')
    Write-UpdateHeader 'Layer 3: Windows Subsystem for Linux'
    if (-not $PSCmdlet.ShouldProcess("WSL runtime and $Distribution", 'Update')) { return }
    if (-not (Test-UpdateCommandExist 'wsl')) { return }
    try {
        $current = Invoke-UpdateCommand -Command 'wsl' -Arguments @('--version') -TimeoutSeconds 30
        $versionText = ($current.Output -join ' ') -replace "`0", ''
        if ($current.ExitCode -ne 0 -or $versionText -notmatch '(\d+\.\d+\.\d+\.\d+)') {
            throw 'Cannot read the installed WSL runtime version'
        }
        $installed = [version]$Matches[1]
        $published = Get-WslPublishedVersion
        # GitHub tags can omit the fourth (zero) version component.
        $stable = [version]::new($published.Major, $published.Minor, $published.Build, [Math]::Max(0, $published.Revision))
        if ($installed -ge $stable) {
            Write-UpdateStatus "WSL runtime $installed is current (official stable $stable)" -Status Success
        } else {
            $runtime = Invoke-UpdateCommand -Command 'wsl' -Arguments @('--update', '--web-download') -TimeoutSeconds 600
            if ($runtime.ExitCode -ne 0) {
                Write-UpdateStatus "WSL runtime update failed (exit $($runtime.ExitCode))" -Status Error
            } else {
                $after = Invoke-UpdateCommand -Command 'wsl' -Arguments @('--version') -TimeoutSeconds 30
                $afterText = ($after.Output -join ' ') -replace "`0", ''
                if ($after.ExitCode -eq 0 -and $afterText -match '(\d+\.\d+\.\d+\.\d+)' -and [version]$Matches[1] -ge $stable) {
                    Write-UpdateStatus 'WSL runtime updated and version verified' -Status Success
                } else { Write-UpdateStatus 'WSL runtime version did not reach the published release' -Status Error }
            }
        }
    } catch { Write-UpdateStatus "WSL runtime check failed: $_" -Status Error }

    $command = 'if command -v apt-get >/dev/null 2>&1; then sudo -n apt-get update -qq && sudo -n apt-get upgrade -y -qq; elif command -v dnf >/dev/null 2>&1; then sudo -n dnf upgrade -y --quiet; elif command -v pacman >/dev/null 2>&1; then sudo -n pacman -Syu --noconfirm; else echo No supported package manager >&2; exit 127; fi'
    $distro = Invoke-UpdateCommand -Command 'wsl' -Arguments @('--distribution', $Distribution, '--exec', 'sh', '-c', $command) -TimeoutSeconds 600
    if ($distro.ExitCode -eq 0) {
        Write-UpdateStatus "WSL distribution $Distribution updated" -Status Success
    } else {
        Write-UpdateStatus "WSL distribution $Distribution update failed (exit $($distro.ExitCode))" -Status Error
    }
}

function Update-PythonEnvironment {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$CleanCache
    )
    Write-UpdateHeader "Layer 3: Python Virtual Environments"
    
    if ($PSCmdlet.ShouldProcess("Python virtual environments", "Update")) {
        if (Test-UpdateCommandExist 'python') {
            Write-UpdateStatus "Checking for Python virtual environments..." -Status Info
            
            # Limpiar caché de pip si se solicita
            if ($CleanCache) {
                Write-UpdateStatus "Cleaning pip cache..." -Status Info
                & pip cache purge 2>&1 | Out-Null
            }
            
            $venvPaths = @(
                (Join-Path $env:USERPROFILE "venvs"),
                (Join-Path $env:USERPROFILE ".venvs"),
                (Join-Path $env:USERPROFILE "envs"),
                (Join-Path $env:USERPROFILE ".virtualenvs"),
                (Join-Path $PWD "venv"),
                (Join-Path $PWD ".venv")
            )
            
            $foundEnvs = 0
            $updatedEnvs = 0
            
            foreach ($venvPath in $venvPaths) {
                if (Test-Path $venvPath) {
                    $venvs = Get-ChildItem -Path $venvPath -Directory -ErrorAction SilentlyContinue
                    foreach ($venv in $venvs) {
                        $pipPath = Join-Path $venv.FullName "Scripts\pip.exe"
                        $pythonPath = Join-Path $venv.FullName "Scripts\python.exe"
                        
                        if (Test-Path $pipPath) {
                            $foundEnvs++
                            Write-UpdateStatus "Updating venv: $($venv.Name)" -Status Info
                            
                            try {
                                # Primero actualizar pip mismo
                                Write-Host "  Upgrading pip..." -ForegroundColor DarkGray
                                & $pythonPath -m pip install --upgrade pip 2>&1 | Out-Null
                                
                                # Obtener paquetes desactualizados
                                $outdatedJson = & $pipPath list --outdated --format=json 2>$null
                                $outdated = $outdatedJson | ConvertFrom-Json -ErrorAction SilentlyContinue
                                
                                if ($outdated) {
                                    $packages = $outdated | ForEach-Object { $_.name }
                                    Write-Host "  Found $($packages.Count) outdated package(s)" -ForegroundColor DarkGray
                                    
                                    # Actualizar todos de una vez (más rápido)
                                    & $pipPath install --upgrade @packages 2>&1 | ForEach-Object { 
                                        if ($_ -match 'Successfully installed|Requirement already satisfied') { 
                                            Write-Host "    $_" -ForegroundColor DarkGray 
                                        }
                                    }
                                    $updatedEnvs++
                                } else {
                                    Write-Host "  All packages up to date" -ForegroundColor DarkGray
                                }
                                
                                # Limpiar caché del venv si se solicitó
                                if ($CleanCache) {
                                    & $pipPath cache purge 2>&1 | Out-Null
                                }
                                
                            } catch {
                                Write-UpdateStatus "Failed to update venv $($venv.Name): $_" -Status Warning
                            }
                        }
                    }
                }
            }
            
            if ($foundEnvs -eq 0) {
                Write-UpdateStatus "No Python virtual environments found" -Status Success
            } else {
                Write-UpdateStatus "Processed $foundEnvs Python environment(s), updated $updatedEnvs" -Status Success
            }
        } else {
            Write-UpdateStatus "Python not installed, skipping..." -Status Warning
        }
    }
}


function Get-NodeUpdateReport {
    param([string]$Project, [ValidateSet('outdated', 'audit')][string]$Kind)
    $result = Invoke-UpdateCommand -Command 'npm' -Arguments @($Kind, '--json', '--ignore-scripts')
    if ($result.ExitCode -notin @(0, 1)) { throw "npm $Kind failed in $Project (exit $($result.ExitCode))" }
    $report = ($result.Output -join "`n") | ConvertFrom-Json -AsHashtable -ErrorAction Stop
    if ($report -isnot [System.Collections.IDictionary] -or $report.Contains('error')) { throw "Invalid npm $Kind response in $Project" }
    if ($Kind -eq 'audit' -and -not $report.metadata.vulnerabilities.Contains('total')) { throw "Missing npm audit totals in $Project" }
    $report
}

function Update-NodeEnvironment {
    [CmdletBinding(SupportsShouldProcess)]
    param([string[]]$ProjectPath = @($PWD.Path))
    Write-UpdateHeader 'Layer 3: Node.js Projects'
    if (-not (Test-UpdateCommandExist 'npm')) { return }
    $checked = 0
    $clean = 0
    # Project roots must be explicit. Never recurse from HOME into hidden apps.
    foreach ($directory in @($ProjectPath | Sort-Object -Unique)) {
        if (-not (Test-Path -LiteralPath (Join-Path $directory 'package.json'))) { continue }
        if (-not $PSCmdlet.ShouldProcess($directory, 'Update and audit Node.js dependencies')) { continue }
        $checked++
        Push-Location -LiteralPath $directory
        try {
            $before = Get-NodeUpdateReport -Project $directory -Kind outdated
            $actionable = @($before.Keys | Where-Object { $before[$_].current -ne $before[$_].wanted })
            if ($actionable.Count -gt 0) {
                $update = Invoke-UpdateCommand -Command 'npm' -Arguments @('update', '--ignore-scripts')
                if ($update.ExitCode -ne 0) { throw "npm update failed (exit $($update.ExitCode))" }
            }
            $remaining = Get-NodeUpdateReport -Project $directory -Kind outdated
            $audit = Get-NodeUpdateReport -Project $directory -Kind audit
            $vulnerabilities = [int]$audit.metadata.vulnerabilities.total
            if ($vulnerabilities -gt 0) {
                Write-UpdateStatus "$directory has $vulnerabilities vulnerable dependency entries; run npm audit for details" -Status Error
            }
            $pending = @($remaining.Keys | Where-Object { $remaining[$_].current -ne $remaining[$_].wanted })
            $outsideRange = @($remaining.Keys | Where-Object { $remaining[$_].current -eq $remaining[$_].wanted })
            if ($pending.Count -gt 0) {
                Write-UpdateStatus "$directory still has pending dependencies within declared ranges: $($pending -join ', ')" -Status Warning
            }
            if ($outsideRange.Count -gt 0) {
                Write-UpdateStatus "$directory has newer releases outside its declared ranges: $($outsideRange -join ', '); no automatic breaking upgrades" -Status Info
            }
            if ($pending.Count -eq 0 -and $vulnerabilities -eq 0) {
                $clean++
                Write-UpdateStatus "$directory declared dependency ranges satisfied; audit reports zero vulnerabilities" -Status Success
            }
        } catch { Write-UpdateStatus "Node.js project $directory failed verification: $_" -Status Error }
        finally { Pop-Location }
    }
    Write-UpdateStatus "Node.js projects checked: $checked; verified within declared ranges with clean audit: $clean" -Status Info
}
