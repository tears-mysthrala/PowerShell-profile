function Update-WindowsUpdate {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$UseLog
    )
    if ($PSCmdlet.ShouldProcess("Windows updates", "Install")) {
        $logFunction = if ($UseLog) { ${function:Write-Log} } else { ${function:Write-Host} }

        try {
        # Use native Windows Update API via COM objects
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        $SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software'")
        $Updates = $SearchResult.Updates | Where-Object { !$_.IsHidden }

        if ($Updates.Count -gt 0) {
            & $logFunction "Found $($Updates.Count) Windows updates to install."
            $UpdatesToDownload = New-Object -ComObject Microsoft.Update.UpdateColl
            $UpdatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl

            foreach ($Update in $Updates) {
                $UpdatesToDownload.Add($Update) | Out-Null
                $UpdatesToInstall.Add($Update) | Out-Null
            }

            # Download updates
            $Downloader = $UpdateSession.CreateUpdateDownloader()
            $Downloader.Updates = $UpdatesToDownload
            & $logFunction "Downloading Windows updates..."
            $Downloader.Download()

            # Install updates
            $Installer = $UpdateSession.CreateUpdateInstaller()
            $Installer.Updates = $UpdatesToInstall
            & $logFunction "Installing Windows updates..."
            $InstallationResult = $Installer.Install()

            if ($InstallationResult.ResultCode -eq 2) {
                & $logFunction "Windows updates installed successfully. Reboot may be required."
            } else {
                & $logFunction "Some Windows updates failed to install."
            }
        } else {
            & $logFunction "No Windows updates available."
        }
    }
    catch {
        if ($UseLog) {
            Write-ErrorLog "Failed to process Windows updates: $_"
        } else {
            Write-Verbose "Failed to check/install Windows updates: $_" -ForegroundColor Red
        }
    }
}
