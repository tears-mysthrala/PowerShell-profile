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
      if ($editor -eq 'nvim' -and (Test-Path "$env:LOCALAPPDATA/$env:DEFAULT_NVIM_CONFIG" -PathType Container)) {
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
  function la_with_eza{
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

# File and directory management
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }
function New-File { 
    [CmdletBinding(SupportsShouldProcess)]
    param($file)
    if ($PSCmdlet.ShouldProcess($file, "Create file")) {
        "" | Out-File $file -Encoding ASCII 
    }
}
Set-Alias -Name touch -Value New-File

# System information and utilities
function Get-PubIP { (Invoke-WebRequest http://ifconfig.me/ip ).Content }
function Get-FormatedUptime {
  $bootuptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
  $CurrentDate = Get-Date
  $uptime = $CurrentDate - $bootuptime
  Write-Output "Uptime: $($uptime.Days) Days, $($uptime.Hours) Hours, $($uptime.Minutes) Minutes"
}

function uptime {
  If ($PSVersionTable.PSVersion.Major -eq 5) {
    Get-CimInstance -ClassName Win32_OperatingSystem |
    Select-Object @{EXPRESSION = { $_.ConverttoDateTime($_.lastbootuptime) } } | Format-Table -HideTableHeaders
  }
  Else {
    Get-FormatedUptime
    net statistics workstation | Select-String "since" | foreach-object { $_.ToString().Replace('Statistics since ', 'Since: ') }
  }
}

function Expand-ZipFile($file) {
  Write-Output("Extracting", $file, "to", $pwd)
  $fullFile = Get-ChildItem -Path $pwd -Filter .\cove.zip | ForEach-Object { $_.FullName }
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

  $uri = "http://bin.christitus.com/documents"
  try {
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body $Content -ErrorAction Stop
    $hasteKey = $response.key
    $url = "http://bin.christitus.com/$hasteKey"
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
  curl.exe -F "f:1=@$file" ix.io
}

function Test-IsAdmin {
  return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

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

# Ref: https://gist.github.com/mikepruett3/7ca6518051383ee14f9cf8ae63ba18a7
function Expand-CustomArchive {
  param (
    [string]$File,
    [string]$Folder
  )

  if (-not $Folder) {
    $FileName = [System.IO.Path]::GetFileNameWithoutExtension($File)
    $Folder = Join-Path -Path (Split-Path -Path $File -Parent) -ChildPath "$FileName"
  }

  if (-not (Test-Path -Path $Folder -PathType Container)) {
    New-Item -Path $Folder -ItemType Directory | Out-Null
  }

  if (Test-Path -Path "$File" -PathType Leaf) {
    switch ($File.Split(".") | Select-Object -Last 1) {
      "rar" {
        Start-Process -FilePath "UnRar.exe" -ArgumentList "x", "-op'$Folder'", "-y", "$File" -WorkingDirectory "$Env:ProgramFiles\WinRAR\" -Wait | Out-Null
      }
      "zip" {
        7z x -o"$Folder" -y "$File" | Out-Null
      }
      "7z" {
        7z x -o"$Folder" -y "$File" | Out-Null
      }
      "exe" {
        7z x -o"$Folder" -y "$File" | Out-Null
      }
      Default {
        Write-Error "No way to Extract $File !!!"; return;
      }
    }
    Write-Verbose "Extracted "$FILE" to "$($Folder)""
  }
}
Set-Alias -Name extract -Value Expand-CustomArchive

function Expand-MultipleArchive {
  $CurrentDate = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
  $Folder = "extracted_$($CurrentDate)"
  New-Item -Path $Folder -ItemType Directory | Out-Null
  foreach ($File in $args) {
    Expand-CustomArchive -File $File -Folder "$($Folder)\$([System.IO.Path]::GetFileNameWithoutExtension($File))"
  }
}
Set-Alias -Name extract_multi -Value Expand-MultipleArchive

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

function Upgrade {
  # Function to check if pwsh is installed
  function Get-PwshInstalled {
    return Get-Command pwsh -ErrorAction SilentlyContinue
  }

  # Function to install PowerShell 7 using winget
  function Install-Pwsh {
    Write-Verbose "Installing PowerShell 7..."
    winget install --id Microsoft.Powershell --source winget -y
  }

  # Check if pwsh is installed
  if (-not (Get-PwshInstalled)) {
    Install-Pwsh
    # Optionally, you can exit the function or script here
    Write-Verbose "Please restart your shell to use PowerShell 7."
    return
  }

  # Check if the script is running with administrative privileges
  $isAdmin = [bool](New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

  if (-not $isAdmin) {
    # If not running as admin, try to run with sudo (if available)
    if (Get-Command sudo -ErrorAction SilentlyContinue) {
      Write-Verbose "Running with sudo..."
      sudo pwsh -ExecutionPolicy Bypass -File "$PSScriptRoot\..\Apps\UpdateApps.ps1"
    }
    else {
      # If sudo is not available, use runas
      Write-Verbose "Running with runas..."
      Start-Process pwsh -ArgumentList "-ExecutionPolicy Bypass -File `"$PSScriptRoot\..\Apps\UpdateApps.ps1`"" -Verb RunAs
    }
  }
  else {
    # If running as admin, execute the update script directly
    . "$PSScriptRoot\..\Apps\UpdateApps.ps1"
  }
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
function which($name) { Get-Command $name | Select-Object -ExpandProperty Definition }

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

# SSH Aliases
function akkorokamui { ssh -p 54226 tears@192.168.1.100 }
