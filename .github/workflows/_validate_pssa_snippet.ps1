# Resolve settings file (if present) and get a plain path string
$settings = Resolve-Path -Path ./.psscriptanalyzersettings.psd1 -ErrorAction SilentlyContinue
if (-not $settings) { Write-Host 'No .psscriptanalyzersettings.psd1 found; continuing with defaults' }
$settingsPath = if ($settings) { $settings.Path } else { $null }

# Detect which parameter the installed Invoke-ScriptAnalyzer supports
$ssaCmd = Get-Command Invoke-ScriptAnalyzer -ErrorAction SilentlyContinue

$files = Get-ChildItem -Path . -Include *.ps1,*.psm1,*.psd1 -Recurse | ForEach-Object { $_.FullName }
if ($files.Count -eq 0) { Write-Host 'No PowerShell files found'; exit 0 }

# Aggregate results so the job doesn't exit on the first file with issues.
$allResults = @()
foreach ($f in $files) {
  Write-Host "Analyzing $f"
  try {
    if ($settingsPath -and $ssaCmd -and $ssaCmd.Parameters.ContainsKey('SettingsPath')) {
      # Newer versions use -SettingsPath
      $res = Invoke-ScriptAnalyzer -Path $f -Recurse -Severity Warning -SettingsPath $settingsPath -ErrorAction SilentlyContinue
    } elseif ($settingsPath -and $ssaCmd -and $ssaCmd.Parameters.ContainsKey('Settings')) {
      # Older versions use -Settings
      $res = Invoke-ScriptAnalyzer -Path $f -Recurse -Severity Warning -Settings $settingsPath -ErrorAction SilentlyContinue
    } else {
      # No settings parameter available (or no settings file) - run without settings
      $res = Invoke-ScriptAnalyzer -Path $f -Recurse -Severity Warning -ErrorAction SilentlyContinue
    }

    if ($res) {
      $allResults += $res
      # Also write a compact line for visibility in the logs
      foreach ($r in $res) {
        Write-Host ("[{0}] {1}:{2} - {3}" -f $r.Severity, $r.ScriptName, $r.Line, $r.RuleName)
      }
    }
  } catch {
    $errText = ($_ | Out-String).Trim()
    Write-Host ("Error running ScriptAnalyzer on {0}: {1}" -f $f, $errText)
    $allResults += @{ Script = $f; Error = $errText }
  }
}

if ($allResults.Count -gt 0) {
  Write-Host "PSScriptAnalyzer found issues: $($allResults.Count) result(s).";
  # Print a short summary block
  $allResults | Select-Object @{Name='File';Expression={if ($_.ScriptName) { $_.ScriptName } else { $_.Script }}}, @{Name='Line';Expression={$_.Line}}, @{Name='Rule';Expression={$_.RuleName}}, @{Name='Severity';Expression={$_.Severity}} | Format-Table -AutoSize
  # Fail the job for testing purposes (comment out in real runs if you don't want local exit)
  # exit 1
} else {
  Write-Host 'No issues found by PSScriptAnalyzer.'
}