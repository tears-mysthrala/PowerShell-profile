# Helper function to check if a command exists (defined here for self-containment)
function Test-CommandExist {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
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
    Write-Host "[$($prefixes[$Status])] $Message" -ForegroundColor $colors[$Status]
}

function Update-Winget {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 1: Windows Package Managers - Winget"
    
    if ($PSCmdlet.ShouldProcess("Winget packages", "Update")) {
        if (Test-CommandExist 'winget') {
            Write-UpdateStatus "Updating Winget packages to latest versions (this may take a while)..." -Status Info
            Write-Host "  Running: winget upgrade -rhu --include-unknown --force" -ForegroundColor DarkGray
            Write-Host ""
            
            # --include-unknown: Include packages with unknown versions
            # --force: Force upgrade even if hash mismatch
            # Use sudo to ensure admin privileges for system-wide packages
            if (Test-CommandExist 'sudo') {
                sudo winget upgrade -rhu --accept-source-agreements --accept-package-agreements --disable-interactivity --include-unknown --force
            } else {
                & winget upgrade -rhu --accept-source-agreements --accept-package-agreements --disable-interactivity --include-unknown --force
            }
            
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
    Write-UpdateHeader "Layer 1: Windows Package Managers - Scoop"
    
    if ($PSCmdlet.ShouldProcess("Scoop packages", "Update")) {
        if (Test-CommandExist 'scoop') {
            Write-UpdateStatus "Updating Scoop to latest version..." -Status Info
            scoop update
            
            Write-UpdateStatus "Updating all Scoop apps to latest versions..." -Status Info
            # scoop update * updates all installed apps
            # Using -g flag to update global apps as well (requires admin)
            if (Test-CommandExist 'sudo') {
                sudo scoop update * -g
            } else {
                scoop update * -g
            }
            
            # Cleanup old versions
            Write-UpdateStatus "Cleaning up old Scoop versions..." -Status Info
            if (Test-CommandExist 'sudo') {
                sudo scoop cleanup * -g
            } else {
                scoop cleanup * -g
            }
            
            Write-UpdateStatus "Scoop update completed" -Status Success
        } else {
            Write-UpdateStatus "Scoop not installed, skipping..." -Status Warning
        }
    }
}

function Update-Choco {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 1: Windows Package Managers - Chocolatey"
    
    if ($PSCmdlet.ShouldProcess("Chocolatey packages", "Update")) {
        if (Test-CommandExist 'choco') {
            # Clean up cache before updating
            Write-UpdateStatus "Cleaning Chocolatey cache..." -Status Info
            & choco cache remove --all --confirm 2>$null
            
            Write-UpdateStatus "Updating all Chocolatey packages to latest versions (requires admin)..." -Status Info
            Write-Host "  Running: sudo choco upgrade all -y" -ForegroundColor DarkGray
            Write-Host ""
            
            # First update all packages EXCEPT chocolatey itself
            # --except=chocolatey prevents choco.exe from being locked during updates
            if (Test-CommandExist 'sudo') {
                sudo choco upgrade all -y --except=chocolatey
            } else {
                & choco upgrade all -y --except=chocolatey
            }
            
            $allExitCode = $LASTEXITCODE
            
            # Check if chocolatey itself needs update by comparing versions
            Write-UpdateStatus "Checking if Chocolatey needs update..." -Status Info
            $localVersion = (choco --version).Trim()
            try {
                # Get latest version from chocolatey repository (without --source parameter)
                $sourceOutput = choco list chocolatey --exact --limit-output 2>&1
                if ($sourceOutput -match 'chocolatey\|([\d\.]+)') {
                    $remoteVersion = $matches[1]
                    if ($localVersion -eq $remoteVersion) {
                        Write-UpdateStatus "Chocolatey is already at latest version ($localVersion)" -Status Success
                        $chocoExitCode = 0
                    } else {
                        Write-UpdateStatus "Chocolatey: $localVersion -> $remoteVersion" -Status Info
                        # Update chocolatey itself only if needed
                        if (Test-CommandExist 'sudo') {
                            sudo choco upgrade chocolatey -y
                        } else {
                            & choco upgrade chocolatey -y
                        }
                        $chocoExitCode = $LASTEXITCODE
                    }
                } else {
                    # Could not determine remote version, skip to avoid lock issues
                    Write-UpdateStatus "Could not check remote version, skipping chocolatey self-update" -Status Warning
                    $chocoExitCode = 0
                }
            } catch {
                Write-UpdateStatus "Error checking chocolatey version, skipping self-update" -Status Warning
                $chocoExitCode = 0
            }
            
            if ($allExitCode -eq 0 -and $chocoExitCode -eq 0) {
                Write-UpdateStatus "Chocolatey update completed" -Status Success
            } else {
                Write-UpdateStatus "Chocolatey update finished - Packages: $allExitCode, Choco itself: $chocoExitCode" -Status Warning
            }
        } else {
            Write-UpdateStatus "Chocolatey not installed, skipping..." -Status Warning
        }
    }
}

function Update-Npm {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 2: Development Tools - NPM"
    
    if ($PSCmdlet.ShouldProcess("NPM global packages", "Update")) {
        if (Test-CommandExist 'npm') {
            # ============================================================
            # STEP 0: Clean up corrupted npm installations
            # ============================================================
            Write-UpdateStatus "Checking for corrupted npm installations..." -Status Info
            
            $npmRoot = & npm root -g 2>$null
            if ($npmRoot -and (Test-Path $npmRoot)) {
                $corruptedFound = $false
                
                # Get all directories starting with a period (invalid package names)
                $invalidDirs = Get-ChildItem -Path $npmRoot -Directory -Force -ErrorAction SilentlyContinue | 
                    Where-Object { $_.Name -match '^\.' } |
                    Where-Object { $_.Name -ne '.bin' -and $_.Name -ne '.package-lock.json' }
                
                # Also check scoped packages directories (@scope/)
                $scopedDirs = Get-ChildItem -Path $npmRoot -Directory -Force -ErrorAction SilentlyContinue | 
                    Where-Object { $_.Name -match '^@' }
                
                foreach ($scopeDir in $scopedDirs) {
                    $scopeInvalidDirs = Get-ChildItem -Path $scopeDir.FullName -Directory -Force -ErrorAction SilentlyContinue | 
                        Where-Object { $_.Name -match '^\.' }
                    
                    foreach ($invalidDir in $scopeInvalidDirs) {
                        Write-UpdateStatus "Found corrupted package: $($scopeDir.Name)/$($invalidDir.Name)" -Status Warning
                        try {
                            Remove-Item -Path $invalidDir.FullName -Recurse -Force -ErrorAction SilentlyContinue
                            Write-Host "  Removed: $($scopeDir.Name)/$($invalidDir.Name)" -ForegroundColor DarkGray
                            $corruptedFound = $true
                        } catch {
                            Write-UpdateStatus "Failed to remove $($invalidDir.Name): $_" -Status Error
                        }
                    }
                }
                
                # Handle root-level invalid directories
                foreach ($invalidDir in $invalidDirs) {
                    Write-UpdateStatus "Found corrupted package: $($invalidDir.Name)" -Status Warning
                    try {
                        Remove-Item -Path $invalidDir.FullName -Recurse -Force -ErrorAction SilentlyContinue
                        Write-Host "  Removed: $($invalidDir.Name)" -ForegroundColor DarkGray
                        $corruptedFound = $true
                    } catch {
                        Write-UpdateStatus "Failed to remove $($invalidDir.Name): $_" -Status Error
                    }
                }
                
                if (-not $corruptedFound) {
                    Write-Host "  No corrupted installations found" -ForegroundColor DarkGray
                } else {
                    Write-UpdateStatus "Cleaned up corrupted npm installations" -Status Success
                }
                
                # Also clean npm cache if it has issues
                Write-UpdateStatus "Verifying npm cache integrity..." -Status Info
                $cacheVerify = & npm cache verify 2>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-UpdateStatus "Cache issues detected, cleaning npm cache..." -Status Warning
                    & npm cache clean --force 2>&1 | Out-Null
                    Write-Host "  Cache cleaned" -ForegroundColor DarkGray
                } else {
                    Write-Host "  Cache verified successfully" -ForegroundColor DarkGray
                }
            }
            
            # ============================================================
            # STEP 1: Update NPM itself
            # ============================================================
            Write-UpdateStatus "Updating NPM itself to latest version..." -Status Info
            & npm install -g npm@latest
            
            # ============================================================
            # STEP 2: Update all global packages
            # ============================================================
            Write-UpdateStatus "Updating all NPM global packages to latest versions..." -Status Info
            Write-Host "  Running: npm update -g" -ForegroundColor DarkGray
            Write-Host ""
            
            & npm update -g
            
            # ============================================================
            # STEP 3: Upgrade outdated packages
            # ============================================================
            Write-UpdateStatus "Upgrading outdated global packages..." -Status Info
            $outdated = & npm outdated -g --json 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($outdated) {
                $outdated.PSObject.Properties.Name | ForEach-Object {
                    Write-Host "  Upgrading: $_" -ForegroundColor DarkGray
                    & npm install -g $_@latest 2>$null
                }
            }
            
            Write-UpdateStatus "NPM update completed" -Status Success
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
        if (Test-CommandExist 'pipx') {
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
        if (Test-CommandExist 'cargo') {
            # Update rustup itself first
            Write-UpdateStatus "Updating Rust toolchain to latest version..." -Status Info
            & rustup update
            
            if (Test-CommandExist 'cargo-install-update') {
                Write-UpdateStatus "Updating all Cargo packages to latest versions..." -Status Info
                Write-Host "  Running: cargo install-update -a" -ForegroundColor DarkGray
                Write-Host ""
                
                # -a = update all, -f = force
                & cargo install-update -a -f
                
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
        if (Test-CommandExist 'uv') {
            Write-UpdateStatus "Updating Uv self to latest version..." -Status Info
            & uv self update
            
            Write-UpdateStatus "Updating all Uv tool packages to latest versions..." -Status Info
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
    Write-UpdateHeader "Layer 3: PowerShell Modules"
    
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
    Write-UpdateHeader "Layer 0: Windows System Updates"
    
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
    Write-UpdateHeader "Layer 3: Microsoft Store Apps"
    
    if ($PSCmdlet.ShouldProcess("Store apps", "Update")) {
        Write-UpdateStatus "Checking Microsoft Store apps..." -Status Info
        
        if (Test-CommandExist 'winget') {
            Write-Host "  Using winget to check Store apps..." -ForegroundColor DarkGray
            try {
                # winget upgrade -rhu ya incluye apps de msstore
                $outdated = winget upgrade --source msstore --accept-source-agreements 2>$null | 
                    Select-String -Pattern '\S+.*\d+\.\d+.*\d+\.\d+.*msstore'
                
                if ($outdated) {
                    $count = ($outdated | Measure-Object).Count
                    Write-Host "    Found $count Store app(s) with updates available" -ForegroundColor DarkGray
                    Write-Host "    (These will be updated by winget in Layer 1)" -ForegroundColor DarkGray
                } else {
                    Write-Host "    No Store apps need updates" -ForegroundColor DarkGray
                }
                
                Write-UpdateStatus "Microsoft Store apps check completed" -Status Success
            } catch {
                Write-UpdateStatus "Store check failed: $_" -Status Warning
            }
        } else {
            Write-UpdateStatus "Winget not available, skipping Store check..." -Status Warning
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
                
                if (Test-CommandExist 'sudo') {
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

function Update-Conda {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 2: Development Tools - Conda/Mamba"
    
    if ($PSCmdlet.ShouldProcess("Conda environments", "Update")) {
        if (Test-CommandExist 'mamba') {
            Write-UpdateStatus "Updating Mamba and all packages to latest versions..." -Status Info
            try {
                Write-Host "  Running: mamba update -n base --all -y" -ForegroundColor DarkGray
                # Update mamba itself first
                & mamba update -n base mamba -y
                # Then update all packages in base environment
                & mamba update -n base --all -y
                # Clean up
                & mamba clean --all -y 2>$null
                Write-UpdateStatus "Mamba update completed" -Status Success
            } catch {
                Write-UpdateStatus "Mamba update failed: $_" -Status Error
            }
        }
        elseif (Test-CommandExist 'conda') {
            Write-UpdateStatus "Updating Conda and all packages to latest versions..." -Status Info
            try {
                Write-Host "  Running: conda update -n base --all -y" -ForegroundColor DarkGray
                # Update conda itself first
                & conda update -n base conda -y
                # Then update all packages in base environment
                & conda update -n base --all -y
                # Clean up
                & conda clean --all -y 2>$null
                Write-UpdateStatus "Conda update completed" -Status Success
            } catch {
                Write-UpdateStatus "Conda update failed: $_" -Status Error
            }
        } else {
            Write-UpdateStatus "Conda/Mamba not installed, skipping..." -Status Warning
        }
    }
}

function Update-DotnetTool {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 2: Development Tools - .NET Global Tools"
    
    if ($PSCmdlet.ShouldProcess(".NET global tools", "Update")) {
        if (Test-CommandExist 'dotnet') {
            Write-UpdateStatus "Updating .NET SDK to latest version..." -Status Info
            # Try to update .NET SDK via winget if available
            if (Test-CommandExist 'winget') {
                & winget upgrade Microsoft.DotNet.SDK.8 --silent --accept-source-agreements 2>$null
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
        if (Test-CommandExist 'gem') {
            Write-UpdateStatus "Updating RubyGems itself to latest version..." -Status Info
            # Updating RubyGems system requires admin privileges (installs to C:/Ruby32-x64)
            if (Test-CommandExist 'sudo') {
                sudo gem update --system
            } else {
                & gem update --system
            }
            
            Write-UpdateStatus "Updating all Ruby gems to latest versions..." -Status Info
            try {
                Write-Host "  Running: gem update" -ForegroundColor DarkGray
                # --conservative: Skip updates that downgrade gems
                # But we want latest, so no conservative flag
                if (Test-CommandExist 'sudo') {
                    sudo gem update
                    Write-Host "  Running: gem cleanup" -ForegroundColor DarkGray
                    sudo gem cleanup
                } else {
                    & gem update
                    Write-Host "  Running: gem cleanup" -ForegroundColor DarkGray
                    & gem cleanup
                }
                
                Write-UpdateStatus "Ruby gems update completed" -Status Success
            } catch {
                Write-UpdateStatus "Ruby gems update failed: $_" -Status Error
            }
        } else {
            Write-UpdateStatus "Ruby/Gem not installed, skipping..." -Status Warning
        }
    }
}

function Update-GoTools {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 2: Development Tools - Go Tools"
    
    if ($PSCmdlet.ShouldProcess("Go tools", "Update")) {
        if (Test-CommandExist 'go') {
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
                                $result = & go install $pkg 2>&1
                                if ($LASTEXITCODE -eq 0) {
                                    Write-Host "    Updated $tool successfully" -ForegroundColor DarkGray
                                    $updatedCount++
                                } else {
                                    Write-Host "    Failed to update $tool" -ForegroundColor Yellow
                                }
                            } else {
                                Write-Host "  Unknown package for: $tool (skipping)" -ForegroundColor Yellow
                            }
                        }
                        Write-UpdateStatus "Updated $updatedCount/$($tools.Count) Go tool(s)" -Status Success
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
                # Deshabilitar TLS verification temporalmente si OpenSSL no está disponible
                & $composerCmd self-update 2>&1 | ForEach-Object {
                    if ($_ -match "openssl|tls|ssl") {
                        Write-Host "  Note: OpenSSL issue detected, trying with disable-tls..." -ForegroundColor Yellow
                        & $composerCmd self-update --disable-tls 2>$null
                    }
                }
                Write-UpdateStatus "Composer update completed" -Status Success
                Write-UpdateStatus "Note: Project dependencies not updated (run 'composer update' in project dirs)" -Status Info
            } catch {
                Write-UpdateStatus "Composer update failed: $_" -Status Warning
            }
        } else {
            Write-UpdateStatus "Composer not installed, skipping..." -Status Warning
        }
    }
}

function Update-Homebrew {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 1: Package Managers - Homebrew (WSL)"
    
    if ($PSCmdlet.ShouldProcess("Homebrew packages", "Update")) {
        $brewInstalled = $false
        
        # Check in WSL - ejecutar un test simple
        if (Test-CommandExist 'wsl') {
            try {
                # Verificar si el directorio de homebrew existe en WSL
                $wslCheck = & wsl test -d /home/linuxbrew/.linuxbrew 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $brewInstalled = $true
                }
            } catch {
                # No hay brew en WSL
            }
        }
        
        if ($brewInstalled) {
            Write-UpdateStatus "Updating Homebrew in WSL to latest versions..." -Status Info
            try {
                Write-Host "  Running: brew update && brew upgrade --force" -ForegroundColor DarkGray
                # Ejecutar brew directamente con el path completo, sin usar shellenv
                # para evitar problemas con caracteres especiales en PATH
                & wsl /home/linuxbrew/.linuxbrew/bin/brew update
                & wsl /home/linuxbrew/.linuxbrew/bin/brew upgrade --force
                # Cleanup old versions
                & wsl /home/linuxbrew/.linuxbrew/bin/brew cleanup --prune=all 2>$null
                Write-UpdateStatus "Homebrew update completed" -Status Success
            } catch {
                Write-UpdateStatus "Homebrew update failed: $_" -Status Error
            }
        } else {
            Write-UpdateStatus "Homebrew not installed in WSL, skipping..." -Status Warning
        }
    }
}

function Update-Chezmoi {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 4: Dotfiles - Chezmoi"
    
    if ($PSCmdlet.ShouldProcess("Chezmoi dotfiles", "Update")) {
        if (Test-CommandExist 'chezmoi') {
            Write-UpdateStatus "Updating chezmoi..." -Status Info
            try {
                Write-Host "  Running: chezmoi upgrade" -ForegroundColor DarkGray
                & chezmoi upgrade
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
        if (Test-CommandExist 'starship') {
            Write-UpdateStatus "Updating Starship prompt..." -Status Info
            try {
                if (Test-CommandExist 'winget') {
                    Write-Host "  Attempting update via winget..." -ForegroundColor DarkGray
                    & winget upgrade Starship.Starship --silent 2>$null
                }
                elseif (Test-CommandExist 'scoop') {
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
        if (Test-CommandExist 'fzf') {
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
                elseif (Test-CommandExist 'scoop') {
                    Write-Host "  Updating via scoop..." -ForegroundColor DarkGray
                    & scoop update fzf
                }
                elseif (Test-CommandExist 'choco') {
                    Write-Host "  Updating via choco..." -ForegroundColor DarkGray
                    & choco upgrade fzf -y
                }
                elseif (Test-CommandExist 'winget') {
                    Write-Host "  Updating via winget..." -ForegroundColor DarkGray
                    & winget upgrade junegunn.fzf --silent
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

function Update-GitSubmodule {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Path = $PWD
    )
    Write-UpdateHeader "Layer 4: Git Submodules"
    
    if ($PSCmdlet.ShouldProcess("Git submodules in $Path", "Update")) {
        if (Test-CommandExist 'git') {
            $repos = Get-ChildItem -Path $Path -Directory -Force | Where-Object {
                Test-Path (Join-Path $_.FullName ".git")
            }
            
            if (-not $repos) {
                Write-UpdateStatus "No git repositories found in $Path" -Status Warning
                return
            }
            
            $updatedCount = 0
            foreach ($repo in $repos) {
                $gitmodulesPath = Join-Path $repo.FullName ".gitmodules"
                if (Test-Path $gitmodulesPath) {
                    Write-UpdateStatus "Updating submodules in: $($repo.Name)" -Status Info
                    try {
                        $originalLocation = Get-Location
                        Set-Location $repo.FullName
                        
                        Write-Host "  Running: git submodule update --remote" -ForegroundColor DarkGray
                        & git submodule update --remote --merge
                        
                        if ($LASTEXITCODE -eq 0) {
                            $updatedCount++
                            Write-UpdateStatus "Updated submodules in $($repo.Name)" -Status Success
                        }
                        
                        Set-Location $originalLocation
                    } catch {
                        Write-UpdateStatus "Failed to update submodules in $($repo.Name): $_" -Status Error
                    }
                }
            }
            
            if ($updatedCount -eq 0) {
                Write-UpdateStatus "No repositories with submodules found" -Status Success
            }
        } else {
            Write-UpdateStatus "Git not installed, skipping..." -Status Warning
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
            }
        } else {
            Write-UpdateStatus "VS Code not found, skipping..." -Status Warning
        }
    }
}

function Update-WSL {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-UpdateHeader "Layer 3: Windows Subsystem for Linux"
    
    if ($PSCmdlet.ShouldProcess("WSL distros", "Update")) {
        if (Test-CommandExist 'wsl') {
            Write-UpdateStatus "Updating WSL..." -Status Info
            try {
                # Update WSL itself
                Write-Host "  Running: wsl --update" -ForegroundColor DarkGray
                & wsl --update
                
                Write-UpdateStatus "Updating default WSL distribution..." -Status Info
                
                # Just update the default distro - simpler and more reliable
                Write-Host "  Updating default WSL distro..." -ForegroundColor DarkGray
                
                # Use wsl.exe directly without specifying distro (uses default)
                $psi = New-Object System.Diagnostics.ProcessStartInfo
                $psi.FileName = "wsl.exe"
                $psi.Arguments = '-e sh -c "if command -v apt-get >/dev/null 2>&1; then sudo apt-get update && sudo apt-get upgrade -y; elif command -v dnf >/dev/null 2>&1; then sudo dnf upgrade -y; elif command -v pacman >/dev/null 2>&1; then sudo pacman -Syu --noconfirm; else echo No package manager found; fi"'
                $psi.RedirectStandardOutput = $true
                $psi.RedirectStandardError = $true
                $psi.UseShellExecute = $false
                $psi.CreateNoWindow = $true
                
                $process = New-Object System.Diagnostics.Process
                $process.StartInfo = $psi
                $process.Start() | Out-Null
                $stdout = $process.StandardOutput.ReadToEnd()
                $stderr = $process.StandardError.ReadToEnd()
                $process.WaitForExit()
                
                if ($process.ExitCode -eq 0) {
                    Write-UpdateStatus "Default WSL distro updated successfully" -Status Success
                } else {
                    Write-UpdateStatus "WSL update completed (some distros may need manual update)" -Status Warning
                    if ($stderr -and ($stderr -notmatch 'Could not resolve')) {
                        Write-Host "  Note: $($stderr.Trim())" -ForegroundColor DarkGray
                    }
                }
            } catch {
                Write-UpdateStatus "WSL update error: $_" -Status Error
            }
        } else {
            Write-UpdateStatus "WSL not installed, skipping..." -Status Warning
        }
    }
}

function Update-PythonEnvironment {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$CleanCache
    )
    Write-UpdateHeader "Layer 3: Python Virtual Environments"
    
    if ($PSCmdlet.ShouldProcess("Python virtual environments", "Update")) {
        if (Test-CommandExist 'python') {
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
                                    $pkgList = $packages -join ' '
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

function Update-NodeEnvironment {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$CleanCache,
        [switch]$ForceReinstall
    )
    Write-UpdateHeader "Layer 3: Node.js Projects"
    
    if ($PSCmdlet.ShouldProcess("Node.js projects", "Update")) {
        if (Test-CommandExist 'npm') {
            Write-UpdateStatus "Checking for Node.js projects with outdated packages..." -Status Info
            
            # Limpiar caché global de npm si se solicita
            if ($CleanCache) {
                Write-UpdateStatus "Cleaning npm cache..." -Status Info
                & npm cache clean --force 2>&1 | Out-Null
            }
            
            $projectDirs = @(
                (Join-Path $env:USERPROFILE "projects"),
                (Join-Path $env:USERPROFILE "dev"),
                (Join-Path $env:USERPROFILE "source"),
                (Join-Path $env:USERPROFILE "src"),
                $PWD
            )
            
            $foundProjects = 0
            $updatedProjects = 0
            
            foreach ($baseDir in $projectDirs) {
                if (Test-Path $baseDir) {
                    $packageJsonFiles = Get-ChildItem -Path $baseDir -Filter "package.json" -Recurse -Depth 2 -ErrorAction SilentlyContinue | 
                        Where-Object { $_.DirectoryName -notmatch 'node_modules' -and -not $_.Directory.Name.StartsWith('.') }
                    
                    foreach ($pkgFile in $packageJsonFiles | Select-Object -First 5) {
                        $foundProjects++
                        $projectDir = $pkgFile.DirectoryName
                        $projectName = $pkgFile.Directory.Name
                        
                        Write-UpdateStatus "Processing project: $projectName" -Status Info
                        Write-Host "  Location: $projectDir" -ForegroundColor DarkGray
                        
                        Push-Location $projectDir
                        try {
                            # Verificar si tiene node_modules
                            $hasNodeModules = Test-Path "node_modules"
                            
                            if ($ForceReinstall -and $hasNodeModules) {
                                Write-Host "  Removing node_modules..." -ForegroundColor DarkGray
                                Remove-Item -Recurse -Force "node_modules" -ErrorAction SilentlyContinue
                                $hasNodeModules = $false
                            }
                            
                            # Verificar actualizaciones disponibles
                            $outdated = & npm outdated --json 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
                            
                            if ($outdated) {
                                $outdatedCount = ($outdated.PSObject.Properties | Measure-Object).Count
                                Write-Host "  Found $outdatedCount outdated package(s)" -ForegroundColor DarkGray
                                
                                # Actualizar paquetes
                                & npm update 2>&1 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
                                
                                if ($LASTEXITCODE -eq 0) {
                                    $updatedProjects++
                                    Write-Host "  Updated successfully" -ForegroundColor DarkGray
                                } else {
                                    Write-Host "  Update had issues, trying fresh install..." -ForegroundColor Yellow
                                    if (-not $hasNodeModules) {
                                        & npm install 2>&1 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
                                    }
                                }
                            } else {
                                Write-Host "  All packages up to date" -ForegroundColor DarkGray
                            }
                        } catch {
                            Write-UpdateStatus "Failed to update $projectName`: $_" -Status Warning
                        } finally {
                            Pop-Location
                        }
                    }
                }
            }
            
            if ($foundProjects -eq 0) {
                Write-UpdateStatus "No Node.js projects found (searching common directories)" -Status Success
            } else {
                Write-UpdateStatus "Updated $updatedProjects/$foundProjects Node.js project(s)" -Status Success
            }
        } else {
            Write-UpdateStatus "Node.js/npm not installed, skipping..." -Status Warning
        }
    }
}
