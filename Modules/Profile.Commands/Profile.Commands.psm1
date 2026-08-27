$profileRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

foreach ($relativePath in @(
    'Core\Utils\unified_aliases.ps1'
    'Core\Utils\CommonUtils.ps1'
    'Core\Utils\FileSystemUtils.ps1'
    'Core\Utils\SearchUtils.ps1'
    'Core\System\linuxLike.ps1'
    'Core\System\clean.ps1'
)) {
    . (Join-Path $profileRoot $relativePath)
}
