param([Parameter(Mandatory)][string]$JobPath)

$ErrorActionPreference = 'Stop'
$job = Get-Content -LiteralPath $JobPath -Raw | ConvertFrom-Json
if ($job.Kind -notin @('msi', 'inno', 'nullsoft') -or $job.Hash -notmatch '^[a-fA-F0-9]{64}$') {
    throw 'Invalid verified installer job'
}
if ((Get-FileHash -LiteralPath $job.File -Algorithm SHA256).Hash -ine $job.Hash) {
    throw 'Installer changed after WinGet verification'
}
New-Item -ItemType Directory -Path (Split-Path -Parent $job.Log) -Force | Out-Null
Add-Content -LiteralPath $job.Log -Value "Verified installer SHA256: $($job.Hash)"
$executable = if ($job.Kind -eq 'msi') { Join-Path $env:WINDIR 'System32\msiexec.exe' } else { $job.File }
$process = Start-Process -FilePath $executable -ArgumentList $job.Arguments -WindowStyle Hidden -Wait -PassThru
Add-Content -LiteralPath $job.Log -Value "Installer exit code: $($process.ExitCode)"
[pscustomobject]@{ExitCode=$process.ExitCode;Installer=$job.File;Log=$job.Log} |
    ConvertTo-Json | Set-Content -LiteralPath "$JobPath.result.json"
exit $process.ExitCode
