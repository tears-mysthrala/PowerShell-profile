@{    Network = @(
        @{
            Name = 'CheckWifiPassword';
            Description = 'Network tools';
            Path = 'Utilities\networkTools\checkWifiPassword.ps1'
        },
        @{
            Name = 'CloudflareWARP';
            Description = 'Network tools';
            Path = 'Utilities\networkTools\cloudflareWARP.ps1'
        }
    );
    Development = @(
        @{
            Name = 'Chtsh';
            Description = 'Developer tools';
            Path = 'DevUtilities\chtsh.ps1'
        },
        @{
            Name = 'Stylus';
            Description = 'Development tools';
            Path = 'DevUtilities\tools\stylus.ps1'
        }
    );
    System = @(
        @{
            Name = 'Clean';
            Description = 'System maintenance';
            Path = 'SystemTools\maintenance\clean.ps1'
        },
        @{
            Name = 'SystemUpdater';
            Description = 'System update utilities';
            Path = 'Apps\Updates\SystemUpdater.psd1';
            IsModule = $true
        }
    );    Shell = @(
        @{
            Name = 'LinuxLike';
            Description = 'Shell utilities';
            Path = 'SystemTools\linuxLike.ps1'
        }
    );
    Applications = @(
        @{
            Name = 'AppsManage';
            Description = 'Application management';
            Path = 'appsManage.ps1'
        }
    );
    Security = @(
        @{
            Name = 'Gpg';
            Description = 'Security tools';
            Path = 'Helpers\gpg.ps1'
        }
    )
}
