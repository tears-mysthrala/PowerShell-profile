$files = Get-ChildItem -Path . -Include *.ps1,*.psm1,*.psd1 -Recurse -File
foreach ($f in $files) {
  try {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    $text = Get-Content -Raw -LiteralPath $f.FullName -ErrorAction Stop
    $newText = $text -replace '^(?<indent>\s*)cd(?=\s+|$)', '${indent}Set-Location' -replace "`r?`n", "`r`n"
    if (($newText -ne $text) -or (-not $hasBom)) {
      [System.IO.File]::WriteAllText($f.FullName, $newText, (New-Object System.Text.UTF8Encoding($true)))
      if (-not $hasBom) { Write-Host "Added BOM and/or changes to $($f.FullName)" } else { Write-Host "Applied changes to $($f.FullName)" }
    }
  } catch { Write-Warning "Failed to process $($f.FullName): $($_.Exception.Message)" }
}

# Stage and commit
git add -A
if (-not (git rev-parse --git-dir > $null 2>&1)) { Write-Host 'Not a git repo' ; exit 0 }
$commit = git commit -m 'chore: safe fixes — add UTF-8 BOM, replace leading cd with Set-Location, remove temp artifacts, add CI & archive' 2>&1
if ($LASTEXITCODE -ne 0) { Write-Host 'Commit likely failed or nothing to commit. Output:' ; Write-Host $commit }
else { Write-Host 'Commit created.' }

git rev-parse --abbrev-ref HEAD
git log -1 --pretty=format:'%h %s'
