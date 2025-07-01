$CLOUDFLAREWARP_SERVICE_NAME = "CloudflareWARP"

function Start-CloudFlareWarp
{
  Write-Host "[INFO] Checking for CloudflareWARP service with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
  $sv = Get-Service -Name $CLOUDFLAREWARP_SERVICE_NAME -ErrorAction SilentlyContinue
  if ($sv)
  {
    Start-Process -filepath "powershell" -Argumentlist "Set-Service -Name $($CLOUDFLAREWARP_SERVICE_NAME) -StartupType Manual; Set-Service -Name $($CLOUDFLAREWARP_SERVICE_NAME) -Status Running -PassThru" -Verb runas
    Start-Sleep 5
    Start-Process "Cloudflare WARP.exe"
    Write-Host "Started CloudflareWARP"
  } else
  {
    Write-Error "No CloudflareWARP service found!"
  }
}

function Stop-CloudFlareWarp 
{
  Write-Host "[INFO] Checking for CloudflareWARP service with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
  $sv = Get-Service -Name $CLOUDFLAREWARP_SERVICE_NAME -ErrorAction SilentlyContinue
  if ($sv)
  {
    Write-Host "[INFO] Stopping Cloudflare WARP process with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
    Stop-Process -Name "Cloudflare WARP" -Force -ErrorAction SilentlyContinue
    Start-Process -filepath "powershell" -Argumentlist "Set-Service -Name $($CLOUDFLAREWARP_SERVICE_NAME) -Status Stopped -PassThru; Set-Service -Name $($CLOUDFLAREWARP_SERVICE_NAME) -StartupType Disabled" -Verb runas
    Write-Host "Stopped CloudflareWARP"
  } else
  {
    Write-Error "No CloudflareWARP service found!"
  }
}