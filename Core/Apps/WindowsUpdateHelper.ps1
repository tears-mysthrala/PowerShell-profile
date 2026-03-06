function Update-WindowsUpdate {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("Windows updates", "Install")) {
        # Windows Update COM API requires elevation
        if (-not (Get-Command 'sudo' -ErrorAction SilentlyContinue)) {
            Write-Warning "sudo not available - Windows Update requires elevation. Enable sudo in Windows Settings > Developer Settings."
            return
        }

        try {
            Write-Host "Running Windows Update with elevation..." -ForegroundColor Cyan
            sudo pwsh -NoProfile -Command {
                $UpdateSession = New-Object -ComObject Microsoft.Update.Session
                $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
                $SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software'")
                $Updates = $SearchResult.Updates | Where-Object { !$_.IsHidden }

                if ($Updates.Count -gt 0) {
                    Write-Host "Found $($Updates.Count) Windows updates to install."
                    $UpdatesToDownload = New-Object -ComObject Microsoft.Update.UpdateColl
                    $UpdatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl

                    foreach ($Update in $Updates) {
                        $UpdatesToDownload.Add($Update) | Out-Null
                        $UpdatesToInstall.Add($Update) | Out-Null
                    }

                    $Downloader = $UpdateSession.CreateUpdateDownloader()
                    $Downloader.Updates = $UpdatesToDownload
                    Write-Host "Downloading Windows updates..."
                    $Downloader.Download()

                    $Installer = $UpdateSession.CreateUpdateInstaller()
                    $Installer.Updates = $UpdatesToInstall
                    Write-Host "Installing Windows updates..."
                    $InstallationResult = $Installer.Install()

                    if ($InstallationResult.ResultCode -eq 2) {
                        Write-Host "Windows updates installed successfully. Reboot may be required."
                    } else {
                        Write-Host "Some Windows updates failed to install."
                    }
                } else {
                    Write-Host "No Windows updates available."
                }
            }
        } catch {
            Write-Warning "Failed to check/install Windows updates: $_"
        }
    }
}
