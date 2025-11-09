# Git aliases
Set-Alias -Name g -Value git
function git-status { git status }
function git-pull { git pull }
function git-push { git push }
Set-Alias -Name gst -Value git-status
Set-Alias -Name pull -Value git-pull
Set-Alias -Name push -Value git-push

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

# Configure exa if available
if (Get-Command exa -ErrorAction SilentlyContinue) {
  function ls_with_exa {
    param([Parameter(ValueFromRemainingArguments = $true)]$params)
    $exaOutput = $(if ($params) {
        exa --icons --git --color=always --group-directories-first $params
      }
      else {
        exa --icons --git --color=always --group-directories-first
      })
    if (Get-Command bat -ErrorAction SilentlyContinue) {
      $exaOutput | Out-String | bat --plain --paging=never
    }
    else {
      $exaOutput
    }
  }
  function ll_with_exa {
    $exaOutput = exa --icons --git --color=always --group-directories-first --long --header
    if (Get-Command bat -ErrorAction SilentlyContinue) {
      $exaOutput | Out-String | bat --plain --paging=never
    }
    else {
      $exaOutput
    }
  }
  Set-Alias -Name ls -Value ls_with_exa -Force -Option AllScope -Scope Global
  Set-Alias -Name ll -Value ll_with_exa -Force -Option AllScope -Scope Global
}
else {
  function ll {
    Get-ChildItem | Format-Table -AutoSize -Property Mode, LastWriteTime, Length, Name
  }
  Set-Alias -Name ll -Value ll -Force -Option AllScope -Scope Global
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
