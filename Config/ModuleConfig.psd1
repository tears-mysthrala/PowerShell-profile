@{
    Network = @(
        @{
            Name = 'CheckWifiPassword'
            Description = 'Network tools'
            Path = 'Scripts\System\checkWifiPassword.ps1'
        }
        @{
            Name = 'CloudflareWARP'
            Description = 'Network tools'
            Path = 'Scripts\System\cloudflareWARP.ps1'
        }
    )
    Development = @(
        @{
            Name = 'Chtsh'
            Description = 'Developer tools'
            Path = 'Scripts\Dev\chtsh.ps1'
        }
        @{
            Name = 'Stylus'
            Description = 'Development tools'
            Path = 'Scripts\Apps\Configurations\stylus.ps1'
        }
    )
    System = @(
        @{
            Name = 'Clean'
            Description = 'System maintenance'
            Path = 'Scripts\System\clean.ps1'
        }
        @{
            Name = 'SystemUpdater'
            Description = 'System update utilities'
            Path = 'Scripts\Apps\Updates\SystemUpdater.psd1'
            IsModule = $true
        }
    )
    Shell = @(
        @{
            Name = 'LinuxLike'
            Description = 'Shell utilities'
            Path = 'Scripts\System\linuxLike.ps1'
        }
    )
    Applications = @(
        @{
            Name = 'AppsManage'
            Description = 'Application management'
            Path = 'Scripts\Apps\appsManage.ps1'
        }
    )
    Security = @(
        @{
            Name = 'Gpg'
            Description = 'Security tools'
            Path = 'Scripts\Dev\gpg.ps1'
        }
    )
}
