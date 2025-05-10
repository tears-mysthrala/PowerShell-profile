# Script to clean orphaned files in PowerShell directory

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage -ForegroundColor $(switch($Level) {
        'Info' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
    })
}

function Get-OrphanedFiles {
    param(
        [string]$PowerShellPath = $env:USERPROFILE + '\OneDrive\Documents\PowerShell'
    )

    $orphanedFiles = @()
    
    # Get all module references from profile
    $profileContent = Get-Content "$PowerShellPath\Microsoft.PowerShell_profile.ps1" -Raw
    $moduleRefs = [regex]::Matches($profileContent, '(?i)Import-Module\s+[''\"](.*?)[''\"]|Register-UnifiedModule\s+[''\"](.*?)[''\"]') |
        ForEach-Object { $_.Groups[1].Value + $_.Groups[2].Value } | Where-Object { $_ }

    # Check Help directory for outdated help files
    Get-ChildItem "$PowerShellPath\Help" -Recurse -File | ForEach-Object {
        $helpFile = $_
        $moduleVersion = $helpFile.Directory.Name
        if ($moduleVersion -match '^\d+\.\d+\.\d+\.\d+$') {
            $currentVersion = (Get-Module -ListAvailable $helpFile.BaseName | Select-Object -First 1).Version
            if (!$currentVersion -or $moduleVersion -lt $currentVersion) {
                $orphanedFiles += $helpFile.FullName
            }
        }
    }

    # Check Modules directory for unused modules
    Get-ChildItem "$PowerShellPath\Modules" -Directory | ForEach-Object {
        $moduleName = $_.Name
        if ($moduleRefs -notcontains $moduleName) {
            $orphanedFiles += $_.FullName
        }
    }

    # Check for temporary files
    $tempPatterns = @('*.tmp', '*.log', '*.old', '*.bak')
    foreach ($pattern in $tempPatterns) {
        Get-ChildItem -Path $PowerShellPath -Recurse -File -Filter $pattern | ForEach-Object {
            $orphanedFiles += $_.FullName
        }
    }

    return $orphanedFiles
}

function Remove-OrphanedFiles {
    param(
        [string]$PowerShellPath = $env:USERPROFILE + '\OneDrive\Documents\PowerShell',
        [switch]$WhatIf
    )

    $orphanedFiles = Get-OrphanedFiles -PowerShellPath $PowerShellPath

    if ($orphanedFiles.Count -eq 0) {
        Write-Log "No orphaned files found." -Level Info
        return
    }

    Write-Log "Found $($orphanedFiles.Count) orphaned files:" -Level Info
    $orphanedFiles | ForEach-Object { Write-Log $_ -Level Info }

    if (!$WhatIf) {
        $confirmation = Read-Host "Do you want to remove these files? (y/N)"
        if ($confirmation -eq 'y') {
            foreach ($file in $orphanedFiles) {
                try {
                    Remove-Item -Path $file -Force -Recurse
                    Write-Log "Removed: $file" -Level Info
                } catch {
                    Write-Log "Failed to remove: $file. Error: $($_.Exception.Message)" -Level Error
                }
            }
            Write-Log "Cleanup completed." -Level Info
        } else {
            Write-Log "Operation cancelled by user." -Level Warning
        }
    } else {
        Write-Log "WhatIf mode: No files were actually removed." -Level Warning
    }
}

# Example usage:
# Remove-OrphanedFiles -WhatIf  # To see what would be removed
# Remove-OrphanedFiles          # To actually remove the files