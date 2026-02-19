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
    $prefixes = @{ Info = '➤'; Success = '✓'; Warning = '⚠'; Error = '✗' }
    Write-Host "$($prefixes[$Status]) $Message" -ForegroundColor $colors[$Status]
}

function Update-Winget {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "📦 Layer 1: Windows Package Managers - Winget"
    
    if ($PSCmdlet.ShouldProcess("Winget packages", "Update")) {
        if (Test-CommandExist 'winget') {
            Write-UpdateStatus "Updating Winget packages (this may take a while)..." -Status Info
            Write-Host "  Running: winget upgrade -rhu" -ForegroundColor DarkGray
            Write-Host ""
            
            & winget upgrade -rhu --accept-source-agreements --accept-package-agreements --disable-interactivity
            
            if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189) {
                Write-UpdateStatus "Winget update completed" -Status Success
            } else {
                Write-UpdateStatus "Winget update finished with exit code: $LASTEXITCODE" -Status Warning
            }
        } else {
            Write-UpdateStatus "Winget not installed, skipping..." -Status Warning
        }
    }
}

function Update-Scoop {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "📦 Layer 1: Windows Package Managers - Scoop"
    
    if ($PSCmdlet.ShouldProcess("Scoop packages", "Update")) {
        if (Test-CommandExist 'scoop') {
            Write-UpdateStatus "Updating Scoop buckets..." -Status Info
            scoop update
            
            Write-UpdateStatus "Updating Scoop apps..." -Status Info
            scoop update *
            
            Write-UpdateStatus "Scoop update completed" -Status Success
        } else {
            Write-UpdateStatus "Scoop not installed, skipping..." -Status Warning
        }
    }
}

function Update-Choco {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "📦 Layer 1: Windows Package Managers - Chocolatey"
    
    if ($PSCmdlet.ShouldProcess("Chocolatey packages", "Update")) {
        if (Test-CommandExist 'choco') {
            Write-UpdateStatus "Updating Chocolatey packages (requires admin)..." -Status Info
            Write-Host "  Running: sudo choco upgrade all -y" -ForegroundColor DarkGray
            Write-Host ""
            
            # Use sudo to run with admin privileges
            if (Test-CommandExist 'sudo') {
                sudo choco upgrade all -y
            } else {
                # Fallback: try to run choco directly (may prompt for elevation)
                & choco upgrade all -y
            }
            
            if ($LASTEXITCODE -eq 0) {
                Write-UpdateStatus "Chocolatey update completed" -Status Success
            } else {
                Write-UpdateStatus "Chocolatey update finished with exit code: $LASTEXITCODE" -Status Warning
            }
        } else {
            Write-UpdateStatus "Chocolatey not installed, skipping..." -Status Warning
        }
    }
}

function Update-Npm {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "🔧 Layer 2: Development Tools - NPM"
    
    if ($PSCmdlet.ShouldProcess("NPM global packages", "Update")) {
        if (Test-CommandExist 'npm') {
            Write-UpdateStatus "Updating NPM global packages..." -Status Info
            Write-Host "  Running: npm update -g" -ForegroundColor DarkGray
            Write-Host ""
            
            & npm update -g
            
            Write-UpdateStatus "NPM update completed" -Status Success
        } else {
            Write-UpdateStatus "NPM not installed, skipping..." -Status Warning
        }
    }
}

function Update-Pipx {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "🔧 Layer 2: Development Tools - Pipx"
    
    if ($PSCmdlet.ShouldProcess("Pipx packages", "Update")) {
        if (Test-CommandExist 'pipx') {
            Write-UpdateStatus "Updating Pipx packages..." -Status Info
            Write-Host "  Running: pipx upgrade-all" -ForegroundColor DarkGray
            Write-Host ""
            
            & pipx upgrade-all
            
            Write-UpdateStatus "Pipx update completed" -Status Success
        } else {
            Write-UpdateStatus "Pipx not installed, skipping..." -Status Warning
        }
    }
}

function Update-Cargo {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "🔧 Layer 2: Development Tools - Cargo"
    
    if ($PSCmdlet.ShouldProcess("Cargo packages", "Update")) {
        if (Test-CommandExist 'cargo') {
            if (Test-CommandExist 'cargo-install-update') {
                Write-UpdateStatus "Updating Cargo packages..." -Status Info
                Write-Host "  Running: cargo install-update -a" -ForegroundColor DarkGray
                Write-Host ""
                
                & cargo install-update -a
                
                Write-UpdateStatus "Cargo update completed" -Status Success
            } else {
                Write-UpdateStatus "cargo-install-update not found. Install with: cargo install cargo-update" -Status Warning
            }
        } else {
            Write-UpdateStatus "Cargo not installed, skipping..." -Status Warning
        }
    }
}

function Update-Uv {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "🔧 Layer 2: Development Tools - Uv"
    
    if ($PSCmdlet.ShouldProcess("Uv tool packages", "Update")) {
        if (Test-CommandExist 'uv') {
            Write-UpdateStatus "Updating Uv tool packages..." -Status Info
            Write-Host "  Running: uv tool upgrade --all" -ForegroundColor DarkGray
            Write-Host ""
            
            & uv tool upgrade --all
            
            Write-UpdateStatus "Uv update completed" -Status Success
        } else {
            Write-UpdateStatus "Uv not installed, skipping..." -Status Warning
        }
    }
}

function Update-PowerShellModule {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "📦 Layer 3: PowerShell Modules"
    
    if ($PSCmdlet.ShouldProcess("PowerShell modules", "Update")) {
        Write-UpdateStatus "Checking for PowerShell module updates..." -Status Info
        
        $modulesToUpdate = @()
        $allModules = Get-Module -ListAvailable | 
            Group-Object Name | 
            ForEach-Object { $_.Group | Sort-Object Version -Descending | Select-Object -First 1 }
        
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
                # Silently continue
            }
        }
        
        if ($modulesToUpdate.Count -eq 0) {
            Write-UpdateStatus "All PowerShell modules are up to date" -Status Success
        } else {
            Write-UpdateStatus "Found $($modulesToUpdate.Count) module(s) to update" -Status Info
            foreach ($mod in $modulesToUpdate) {
                Write-Host "  -> $($mod.Name): $($mod.CurrentVersion) -> $($mod.NewVersion)" -ForegroundColor Gray
                try {
                    Update-Module -Name $mod.Name -Force -ErrorAction Stop
                    Write-UpdateStatus "Updated $($mod.Name)" -Status Success
                } catch {
                    Write-UpdateStatus "Failed to update $($mod.Name): $_" -Status Error
                }
            }
        }
    }
}

function Update-WindowsSystem {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "🪟 Layer 0: Windows System Updates"
    
    if ($PSCmdlet.ShouldProcess("Windows System", "Update")) {
        # Check for PSWindowsUpdate module
        if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
            Write-UpdateStatus "Checking for Windows updates via PSWindowsUpdate..." -Status Info
            try {
                $updates = Get-WindowsUpdate -ErrorAction SilentlyContinue
                if ($updates) {
                    Write-Host "  Found $($updates.Count) update(s)" -ForegroundColor Gray
                    Install-WindowsUpdate -AcceptAll -AutoReboot -IgnoreReboot
                } else {
                    Write-UpdateStatus "No Windows updates available" -Status Success
                }
            } catch {
                Write-UpdateStatus "Windows Update check failed: $_" -Status Error
            }
        } else {
            Write-UpdateStatus "PSWindowsUpdate module not found, using Windows Update client..." -Status Info
            try {
                Write-Host "  Starting Windows Update scan and install..." -ForegroundColor Gray
                Start-Process -FilePath "usoclient" -ArgumentList "StartScan" -Wait -WindowStyle Hidden
                Start-Process -FilePath "usoclient" -ArgumentList "StartInstall" -Wait -WindowStyle Hidden
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
    Write-UpdateHeader "🏪 Layer 3: Microsoft Store Apps"
    
    if ($PSCmdlet.ShouldProcess("Store apps", "Update")) {
        Write-UpdateStatus "Checking for Microsoft Store app updates..." -Status Info
        try {
            if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
                $updates = Get-CimInstance -Namespace 'Root\cimv2' -ClassName 'Win32_AppxUpdateInfo' -ErrorAction SilentlyContinue |
                    Where-Object { $_.UpdateAvailable -eq $true }
                
                if ($updates) {
                    Write-Host "  Found $($updates.Count) Store app update(s)" -ForegroundColor Gray
                    $updates | ForEach-Object { 
                        Write-Host "  -> Updating: $($_.Name)" -ForegroundColor Gray
                        Add-AppxPackage -Path $_.PackageLocation 
                    }
                    Write-UpdateStatus "Store apps updated" -Status Success
                } else {
                    Write-UpdateStatus "No Store app updates available" -Status Success
                }
            }
        } catch {
            Write-UpdateStatus "Store app update failed: $_" -Status Error
        }
    }
}
