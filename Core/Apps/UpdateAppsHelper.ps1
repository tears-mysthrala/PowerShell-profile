function Update-Winget {
    [CmdletBinding(SupportsShouldProcess)]
    param([switch]$Silent)
    if ($PSCmdlet.ShouldProcess("Winget packages", "Update")) {
        if (Test-CommandExist 'winget') {
            if ($Silent) {
                winget upgrade -rhu --accept-source-agreements --accept-package-agreements --disable-interactivity
            } else {
                winget upgrade -rhu --accept-source-agreements --accept-package-agreements
            }
        }
    }
}

function Update-Scoop {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("Scoop packages", "Update")) {
        if (Test-CommandExist 'scoop') {
            scoop update
            scoop update *
        }
    }
}

function Update-Choco {
    [CmdletBinding(SupportsShouldProcess)]
    param([switch]$Silent)
    if ($PSCmdlet.ShouldProcess("Chocolatey packages", "Update")) {
        if (Test-CommandExist 'choco') {
            if ($Silent) {
                choco upgrade all -y --no-progress
            } else {
                choco upgrade all -y
            }
        }
    }
}

function Update-Npm {
    [CmdletBinding(SupportsShouldProcess)]
    param([switch]$Silent)
    if ($PSCmdlet.ShouldProcess("NPM global packages", "Update")) {
        if (Test-CommandExist 'npm') {
            if ($Silent) {
                npm update -g --silent
            } else {
                npm update -g
            }
        }
    }
}

function Update-StoreApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("Store apps", "Update")) {
        if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
            Get-CimInstance -Namespace 'Root\cimv2' -ClassName 'Win32_AppxUpdateInfo' |
            Where-Object { $_.UpdateAvailable -eq $true } |
            ForEach-Object { Add-AppxPackage -Path $_.PackageLocation }
        }
    }
}

function Update-PowerShellModule {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("PowerShell modules", "Update")) {
        Get-InstalledModule | ForEach-Object {
            $moduleName = $_.Name
            try {
                Update-Module -Name $moduleName -Force -ErrorAction Stop
            } catch {
                Write-Warning "Failed to update module $moduleName`: $_"
            }
        }
    }
}
