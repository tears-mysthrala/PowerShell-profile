# Executed in the elevated child process; native exit status reaches the updater.
$ErrorActionPreference = 'Stop'
try {
    Import-Module PSWindowsUpdate -ErrorAction Stop
    if (Get-WURebootStatus -Silent) {
        Write-Host 'Windows restart required before scanning/installing more updates'
        exit 3010
    }
    $updates = @(Get-WindowsUpdate -ErrorAction Stop)
    if ($updates.Count -eq 0) {
        Write-Host 'No Windows updates available'
        exit 0
    }
    Write-Host "Found $($updates.Count) update(s)"
    $results = @(Install-WindowsUpdate -AcceptAll -IgnoreReboot -ErrorAction Stop)
    $results | Format-Table ComputerName, Result, KB, Size, Title -AutoSize | Out-Host
    $failed = @($results | Where-Object { $_.Result -match 'Failed|Aborted|WithErrors' })
    if ($failed.Count -gt 0) {
        Write-Host "Windows Update reported $($failed.Count) failed operation(s)"
        exit 1
    }
    if (@($results | Where-Object Result -EQ 'Installed').Count -eq 0) {
        Write-Host 'Windows Update returned no confirmed installations; verify Windows Update history'
        exit 1
    }
    if (Get-WURebootStatus -Silent) { Write-Host 'Windows restart required' }
    exit 0
} catch {
    Write-Error $_ -ErrorAction Continue
    exit 1
}
