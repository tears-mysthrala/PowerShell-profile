try {
    Import-Module -Name 'C:\Users\unaiu\OneDrive\Documents\PowerShell\Modules\ProfileCore\ProfileCore.psm1' -Force -ErrorAction Stop -Verbose
    Write-Host 'IMPORT_OK'
} catch {
    Write-Host 'IMPORT_FAILED'
    $_ | Format-List -Force
}
