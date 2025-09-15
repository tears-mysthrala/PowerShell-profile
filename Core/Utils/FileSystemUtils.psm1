# File system utilities for PowerShell profile

$script:moduleRoot = Split-Path -Parent $PSCommandPath

function New-DirectoryAndEnter {
    param([string]$dir)
    New-Item -Path $dir -ItemType Directory -Force | Out-Null
    Set-Location $dir
}

function Expand-CustomArchive {
    param (
        [Parameter(Mandatory=$true)]
        [string]$File,
        [string]$Folder
    )

    if (-not $Folder) {
        $FileName = [System.IO.Path]::GetFileNameWithoutExtension($File)
        $Folder = Join-Path -Path (Split-Path -Path $File -Parent) -ChildPath "$FileName"
    }

    if (-not (Test-Path -Path $Folder -PathType Container)) {
        New-Item -Path $Folder -ItemType Directory | Out-Null
    }

    if (Test-Path -Path "$File" -PathType Leaf) {
        switch ($File.Split(".")[-1].ToLower()) {
            "rar" {
                Start-Process -FilePath "UnRar.exe" -ArgumentList "x", "-op'$Folder'", "-y", "$File" -WorkingDirectory "$Env:ProgramFiles\WinRAR\" -Wait -NoNewWindow
            }
            { $_ -in "zip", "7z", "exe" } {
                7z x -o"$Folder" -y "$File" | Out-Null
            }
            default {
                Write-Error "Unsupported archive format for $File"
                return
            }
        }
        Write-Host "Expanded '$File' to '$Folder'"
    } else {
        Write-Error "File not found: $File"
    }
}

function Expand-CustomArchives {
    param([string[]]$Files)
    
    $CurrentDate = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
    $BaseFolder = "expanded_$CurrentDate"
    New-Item -Path $BaseFolder -ItemType Directory | Out-Null
    
    foreach ($File in $Files) {
        $FileName = [System.IO.Path]::GetFileNameWithoutExtension($File)
        $TargetFolder = Join-Path -Path $BaseFolder -ChildPath $FileName
        Expand-CustomArchive -File $File -Folder $TargetFolder
    }
}

# Create module manifest if it doesn't exist
if (-not (Test-Path "$moduleRoot\FileSystemUtils.psd1")) {
    New-ModuleManifest -Path "$moduleRoot\FileSystemUtils.psd1" `
        -RootModule 'FileSystemUtils.psm1' `
        -ModuleVersion '1.0.0' `
        -Author 'unaiu' `
        -Description 'File system utility functions' `
        -FunctionsToExport @(
            'New-DirectoryAndEnter',
            'Expand-CustomArchive',
            'Expand-CustomArchives'
        )
}

# Export module members
Export-ModuleMember -Function New-DirectoryAndEnter, Expand-CustomArchive, Expand-CustomArchives
