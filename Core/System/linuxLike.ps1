# Linux-like utility functions for PowerShell

function sha256 {
    Get-FileHash -Algorithm SHA256 $args
}

function n {
    notepad $args
}

# Drive shortcuts
function HKLM: { Set-Location HKLM: }
function HKCU: { Set-Location HKCU: }
function Env: { Set-Location Env: }

# Recursive file listing (equivalent of dir /s /b)
function dirs {
    if ($args.Count -gt 0) {
        Get-ChildItem -Recurse -Include "$args" | ForEach-Object FullName
    } else {
        Get-ChildItem -Recurse | ForEach-Object FullName
    }
}
