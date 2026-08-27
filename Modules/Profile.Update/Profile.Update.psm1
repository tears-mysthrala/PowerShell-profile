$profileRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $profileRoot 'Core\Apps\Updates\SystemUpdater.ps1')
