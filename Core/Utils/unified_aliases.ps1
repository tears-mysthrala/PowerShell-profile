# PowerShell Unified Alias Configuration

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
Set-Alias -Name grep -Value Select-String
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

# File and directory management
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }
function New-File($file) { 
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
      sudo pwsh -ExecutionPolicy Bypass -File "$PSScriptRoot\..\Core\Apps\UpdateApps.ps1"
    }
    else {
      # If sudo is not available, use runas
      Write-Verbose "Running with runas..."
      Start-Process pwsh -ArgumentList "-ExecutionPolicy Bypass -File `"$PSScriptRoot\..\Core\Apps\UpdateApps.ps1`"" -Verb RunAs
    }
  }
  else {
    # If running as admin, execute the update script directly
    . "$PSScriptRoot\..\Apps\UpdateApps.ps1"
  }
}
