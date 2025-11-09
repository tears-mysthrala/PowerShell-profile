# Git aliases
Set-Alias -Name g -Value git
function Get-GitStatus { git status }
function Invoke-GitPull { git pull }
function Invoke-GitPush { git push }
Set-Alias -Name gst -Value Get-GitStatus
Set-Alias -Name pull -Value Invoke-GitPull
Set-Alias -Name push -Value Invoke-GitPush

# Docker aliases
Set-Alias -Name d -Value docker
Set-Alias -Name dc -Value docker-compose

# Conditional aliases
if (Get-Command lazygit -ErrorAction SilentlyContinue) {
  Set-Alias -Name lg -Value lazygit
}

# Configure bat if available
if (Get-Command bat -ErrorAction SilentlyContinue) {
  $env:BAT_THEME = 'Nord'
  Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
  Set-Alias -Name cat -Value bat -Force -Option AllScope -Scope Global
}

# Configure eza if available
if (Get-Command eza -ErrorAction SilentlyContinue) {
  function ls_with_eza {
    param([Parameter(ValueFromRemainingArguments = $true)]$params)
    $ezaOutput = $(if ($params) {
        eza --icons --git --color=always --group-directories-first $params
      }
      else {
        eza --icons --git --color=always --group-directories-first
      })
    if (Get-Command bat -ErrorAction SilentlyContinue) {
      $ezaOutput | Out-String | bat --plain --paging=never
    }
    else {
      $ezaOutput
    }
  }
  function ll_with_eza {
    $ezaOutput = eza --icons --git --color=always --group-directories-first --long --header
    if (Get-Command bat -ErrorAction SilentlyContinue) {
      $ezaOutput | Out-String | bat --plain --paging=never
    }
    else {
      $ezaOutput
    }
  }
  Set-Alias -Name ls -Value ls_with_eza -Force -Option AllScope -Scope Global
  Set-Alias -Name ll -Value ll_with_eza -Force -Option AllScope -Scope Global
}
else {
  function ll {
    Get-ChildItem | Format-Table -AutoSize -Property Mode, LastWriteTime, Length, Name
  }
  # Remove the alias if it exists to avoid circular reference
  Remove-Alias -Name ll -ErrorAction SilentlyContinue
}

# Search and find utilities
function find-file($name) {
  Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
    $place_path = $_.directory
    Write-Output "${place_path}\${_}"
  }
}

function Find-String($regex, $dir) {
  if ($dir) {
    Get-ChildItem $dir | Select-String $regex
    return
  }
  $input | Select-String $regex
}
Set-Alias -Name grep -Value Find-String

function Edit-FileContent($file, $find, $replace) {
  (Get-Content $file).replace("$find", $replace) | Set-Content $file
}
Set-Alias -Name sed -Value Edit-FileContent

function Get-CommandPath($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
Set-Alias -Name which -Value Get-CommandPath

function export($name, $value) {
  set-item -force -path "env:$name" -value $value;
}

function pkill($name) {
  Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name) {
  Get-Process $name
}
