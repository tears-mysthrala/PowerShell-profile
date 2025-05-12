# File system utilities for PowerShell profile

function New-DirectoryAndEnter {
    param([string]$dir)
    New-Item -Path $dir -ItemType Directory -Force | Out-Null
    Set-Location $dir
}

function Extract-Archive {
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
        Write-Host "Extracted '$File' to '$Folder'"
    } else {
        Write-Error "File not found: $File"
    }
}

function Extract-MultipleArchives {
    param([string[]]$Files)
    
    $CurrentDate = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
    $BaseFolder = "extracted_$CurrentDate"
    New-Item -Path $BaseFolder -ItemType Directory | Out-Null
    
    foreach ($File in $Files) {
        Extract-Archive -File $File -Folder "$BaseFolder\$([System.IO.Path]::GetFileNameWithoutExtension($File))"
    }
}

Set-Alias -Name mkcd -Value New-DirectoryAndEnter
Set-Alias -Name extract -Value Extract-Archive
Set-Alias -Name extract-multi -Value Extract-MultipleArchives

Export-ModuleMember -Function * -Alias *
