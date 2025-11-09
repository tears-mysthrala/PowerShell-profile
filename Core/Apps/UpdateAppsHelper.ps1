function Update-Winget {
    param([switch]$Silent)
    if (Test-CommandExist 'winget') {
        if ($Silent) {
            winget upgrade -rhu --accept-source-agreements --accept-package-agreements --disable-interactivity
        } else {
            winget upgrade -rhu --accept-source-agreements --accept-package-agreements
        }
    }
}

function Update-Scoop {
    if (Test-CommandExist 'scoop') {
        scoop update
        scoop update *
    }
}

function Update-Choco {
    param([switch]$Silent)
    if (Test-CommandExist 'choco') {
        if ($Silent) {
            choco upgrade all -y --no-progress
        } else {
            choco upgrade all -y
        }
    }
}

function Update-Npm {
    param([switch]$Silent)
    if (Test-CommandExist 'npm') {
        if ($Silent) {
            npm update -g --silent
        } else {
            npm update -g
        }
    }
}

function Update-StoreApp {
    if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
        Get-CimInstance -Namespace 'Root\cimv2' -ClassName 'Win32_AppxUpdateInfo' |
        Where-Object { $_.UpdateAvailable -eq $true } |
        ForEach-Object { Add-AppxPackage -Path $_.PackageLocation }
    }
}

function Update-PowerShellModule {
    Get-InstalledModule | ForEach-Object {
        $moduleName = $_.Name
        try {
            Update-Module -Name $moduleName -Force -ErrorAction Stop
        } catch {
            Write-Warning "Failed to update module $moduleName`: $_"
        }
    }
}
