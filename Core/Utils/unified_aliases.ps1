# PowerShell Unified Alias Configuration

# Command existence cache for performance
$script:CommandExistsCache = @{}

function Test-CommandExist {
  param([string]$Command)
    
  if ($script:CommandExistsCache.ContainsKey($Command)) {
    return $script:CommandExistsCache[$Command]
  }
    
  $exists = $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
  $script:CommandExistsCache[$Command] = $exists
  return $exists
}
# Pre-cache common commands to avoid repeated lookups
$commonCommands = @('bat', 'eza', 'lazygit', 'fd', 'nvim', 'code', 'zoxide', 'gh', 'starship')
foreach ($cmd in $commonCommands) {
    Test-CommandExist $cmd | Out-Null
}
# SSH alias for Proxmox
function akkorokamui { ssh -p 54226 tears@192.168.1.100 }
Set-Alias -Name proxmox -Value akkorokamui

# Navigation aliases and utilities
function .. { Set-Location .\.. }
function ... { Set-Location .\..\..\ }
function .3 { Set-Location .\..\..\..\.. }
function .4 { Set-Location .\..\..\..\..\ }
function .5 { Set-Location .\..\..\..\..\..\.. }

# Editor detection and configuration - lazy loaded
function Initialize-Editor {
  if ($script:EditorInitialized) { return }
  $script:EditorInitialized = $true

  $editors = @('nvim', 'code', 'notepad', 'pvim', 'vim', 'vi', 'notepad++', 'sublime_text')
  foreach ($editor in $editors) {
    if (Test-CommandExist $editor) {
      $script:EDITOR = $editor
      if ($editor -eq 'nvim' -and $env:DEFAULT_NVIM_CONFIG -and (Test-Path "$env:LOCALAPPDATA/$env:DEFAULT_NVIM_CONFIG" -PathType Container)) {
        $env:NVIM_APPNAME = $env:DEFAULT_NVIM_CONFIG
      }
      break
    }
  }
}

# Lazy editor alias that initializes on first use
function v {
  if (-not $script:EditorInitialized) { Initialize-Editor }
  if ($script:EDITOR) { & $script:EDITOR @args } else { Write-Verbose "No editor found" }
}

# System aliases
# Note: 'v' alias is now a function that lazy-loads the editor
Set-Alias -Name e -Value explorer.exe
Set-Alias -Name c -Value cls
Set-Alias -Name csl -Value cls
Set-Alias -Name ss -Value Select-String
Set-Alias -Name shutdownnow -Value Stop-Computer
Set-Alias -Name rebootnow -Value Restart-Computer

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
$script:hasLazygit = Test-CommandExist 'lazygit'
if ($script:hasLazygit) {
  Set-Alias -Name lg -Value lazygit
}

# Configure bat if available
$script:hasBat = Test-CommandExist 'bat'
if ($script:hasBat) {
  $env:BAT_THEME = 'Nord'
  Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
  Set-Alias -Name cat -Value bat -Force -Option AllScope -Scope Global
}

# Configure eza if available
$script:hasEza = Test-CommandExist 'eza'
if ($script:hasEza) {
  Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
  function ls_with_eza {
    param([Parameter(ValueFromRemainingArguments = $true)]$params)
    $ezaOutput = $(if ($params) {
        eza --icons --git --color=always --group-directories-first $params
      }
      else {
        eza --icons --git --color=always --group-directories-first
      })
    if ($script:hasBat) {
      $ezaOutput | Out-String | bat --plain --paging=never
    }
    else {
      $ezaOutput
    }
  }
  function ll_with_eza {
    $ezaOutput = eza --icons --git --color=always --group-directories-first --long --header
    if ($script:hasBat) {
      $ezaOutput | Out-String | bat --plain --paging=never
    }
    else {
      $ezaOutput
    }
  }
# this should be the same as ls -al no tree
  function la_with_eza {
    $ezaOutput = eza --icons --git --color=always --group-directories-first --all
    if ($script:hasBat) {
      $ezaOutput | Out-String | bat --plain --paging=never
    }
    else {
      $ezaOutput
    }
  }
  function lt_with_eza {
    eza --icons --git --color=always --group-directories-first --long --header --tree --sort=name
  }
  Set-Alias -Name ls -Value ls_with_eza -Force -Option AllScope -Scope Global
  Set-Alias -Name ll -Value ll_with_eza -Force -Option AllScope -Scope Global
  Set-Alias -Name la -Value la_with_eza -Force -Option AllScope -Scope Global
  Set-Alias -Name lt -Value lt_with_eza -Force -Option AllScope -Scope Global
}
else {
  function ll {
    Get-ChildItem | Format-Table -AutoSize -Property Mode, LastWriteTime, Length, Name
  }
  # Remove the alias if it exists to avoid circular reference
  Remove-Alias -Name ll -ErrorAction SilentlyContinue
}

# File and directory management (mkcd/New-DirectoryAndEnter defined in FileSystemUtils.ps1)
function New-File {
    [CmdletBinding(SupportsShouldProcess)]
    param($file)
    if ($PSCmdlet.ShouldProcess($file, "Create file")) {
        "" | Out-File $file -Encoding ASCII
    }
}
Set-Alias -Name touch -Value New-File

# System information and utilities (Get-PubIP, Get-FormattedUptime defined in CommonUtils.ps1)

function uptime {
  If ($PSVersionTable.PSVersion.Major -eq 5) {
    Get-CimInstance -ClassName Win32_OperatingSystem |
    Select-Object @{EXPRESSION = { $_.ConverttoDateTime($_.lastbootuptime) } } | Format-Table -HideTableHeaders
  }
  Else {
    Get-FormattedUptime
    net statistics workstation | Select-String "since" | foreach-object { $_.ToString().Replace('Statistics since ', 'Since: ') }
  }
}

function Expand-ZipFile($file) {
  Write-Output("Extracting", $file, "to", $pwd)
  $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
  Expand-Archive -Path $fullFile -DestinationPath $pwd
}
Set-Alias -Name unzip -Value Expand-ZipFile

function hb {
  if ($args.Length -eq 0) {
    Write-Error "No file path specified."
    return
  }

  $FilePath = $args[0]

  if (Test-Path $FilePath) {
    $Content = Get-Content $FilePath -Raw
  }
  else {
    Write-Error "File path does not exist."
    return
  }

  $uri = "https://bin.christitus.com/documents"
  try {
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body $Content -TimeoutSec 10 -ErrorAction Stop
    $hasteKey = $response.key
    $url = "https://bin.christitus.com/$hasteKey"
    Write-Output $url
  }
  catch {
    Write-Error "Failed to upload the document. Error: $_"
  }
}

function head {
  param($Path, $n = 10)
  Get-Content $Path -Head $n
}

function tail {
  param($Path, $n = 10)
  Get-Content $Path -Tail $n
}

function ix ($file) {
  curl.exe -m 30 -F "f:1=@$file" ix.io
}

# Test-IsAdmin defined in CommonUtils.ps1

function Restart-BIOS {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("System", "Restart to BIOS")) {
        if (Test-IsAdmin) {
            shutdown /r /fw /f /t 0
        }
        else {
            if (Test-CommandExist sudo) {
                sudo shutdown /r /fw /f /t 0
            }
            else {
                Write-Verbose "Please run with administrator privilege"
            }
        }
    }
}

# Powershell profile from https://github.com/craftzdog/dotfiles-public/blob/master/.config/powershell/user_profile.ps1

[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

Set-Alias -Name extract_multi -Value Expand-MultipleArchives

function Get-Font {
  param (
    $regex
  )
  $AllFonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
  if ($null -ne $regex) {
    $FilteredFonts = $($AllFonts | Select-String -Pattern ".*${regex}.*")
    return $FilteredFonts
  }
  return $AllFonts
}

# Quick Access to System Information
function sysinfo { Get-ComputerInfo }

# Networking Utilities
function Clear-DnsCache { Clear-DnsClientCache }
Set-Alias -Name flushdns -Value Clear-DnsCache

# Clipboard Utilities
function Set-ClipboardContent { 
    [CmdletBinding(SupportsShouldProcess)]
    param($content)
    if ($PSCmdlet.ShouldProcess("Clipboard", "Set content")) {
        Set-Clipboard $content 
    }
}
Set-Alias -Name cpy -Value Set-ClipboardContent

function Get-ClipboardContent { Get-Clipboard }
Set-Alias -Name pst -Value Get-ClipboardContent

# System utilities
function df { get-volume }

function Set-EnvironmentVariable { 
    [CmdletBinding(SupportsShouldProcess)]
    param($name, $value)
    if ($PSCmdlet.ShouldProcess("Environment variable $name", "Set value")) {
        set-item -force -path "env:$name" -value $value 
    }
}
Set-Alias -Name export -Value Set-EnvironmentVariable

function Stop-ProcessByName { 
    [CmdletBinding(SupportsShouldProcess)]
    param($name)
    if ($PSCmdlet.ShouldProcess("Process $name", "Stop")) {
        Get-Process $name -ErrorAction SilentlyContinue | Stop-Process 
    }
}
Set-Alias -Name pkill -Value Stop-ProcessByName

function Get-ProcessByName($name) { Get-Process $name }
Set-Alias -Name pgrep -Value Get-ProcessByName

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

