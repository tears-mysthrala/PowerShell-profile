$profileRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $profileRoot 'Core\System\chezmoi.ps1')
