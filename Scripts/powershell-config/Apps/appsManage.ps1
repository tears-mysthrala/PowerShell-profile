New-Module -Name AppsManage -ScriptBlock {
$CHOCO_APPS_TO_UPGRADE = @(
)

function Update-AllApps {
    Write-Host "Starting system-wide update..." -ForegroundColor Cyan
    
    # Execute the update script
    try {
        . "$ProfileDir\Scripts\powershell-config\UpdateApps.ps1"
        Write-Host "Update completed successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to update: $_"
    }
}

# Export the function
Export-ModuleMember -Function Update-AllApps

$SCOOP_APPS_TO_UPGRADE = @(
  "extras/autohotkey",
  "extras/dockercompletion",
  "extras/lazygit",
  "extras/obs-studio",
  "extras/posh-git"
  "extras/powertoys",
  "extras/psfzf",
  "extras/psreadline",
  "extras/scoop-completion",
  "extras/vscode",
  "main/actionlint",
  "main/bat",
  "main/delta",
  "main/eza",
  "main/fastfetch",
  "main/fd",
  "main/fzf",
  "main/grep",
  "main/lazydocker",
  "main/lf",
  "main/neovim",
  "main/rclone",
  "main/ripgrep",
  "main/sd",
  "main/sed",
  "main/starship",
  "main/sudo",
  "main/tldr",
  "main/touch",
  "main/zoxide"
)

$PIP_APPS_TO_UPGRADE = @(
  "thefuck",
  "cpplint",
  "ruff"
)

$NPM_APPS_TO_UPGRADE = @(
  "markdownlint",
  "eslint",
  "prettier"
)

$POWERSHELL_MODULES_TO_UPDATE = @(
  "CompletionPredictor",
  "posh-wakatime"
)

function Get-ChocoApps {
  $apps = $(choco list --id-only --no-color).Split("\n")
  $apps = $apps[1..($apps.Length - 2)]
  return $apps
}

function Get-ScoopApps {
  $apps = $(scoop list | Select-Object -ExpandProperty "Name").Split("\n")
  $apps = $apps[1..($apps.Length - 1)]
  return $apps
}

function Select-Apps {
  param (
    [string[]] $apps
  )
  $apps = $apps | fzf --prompt="Select Apps  " --height=~80% --layout=reverse --border --cycle --margin="2,20" --padding=1 --multi
  return $apps
}

function Update-ChocoApps {
  $apps_set = New-Object System.Collections.Generic.HashSet[[String]]
  $installed_apps = Get-ChocoApps
  foreach ($app in Select-Apps $installed_apps) {
    $apps_set.Add($app) >$null
  }
  $include = $(Read-Host "Include predefine apps to update [Y/n]").ToUpper()
  if ($include -eq "Y" -or $include -eq "") {
    foreach ($app in $CHOCO_APPS_TO_UPGRADE) {
      if ($installed_apps -contains $app) {
        $apps_set.Add($app) >$null
      }
    }
  }
  if ($apps_set.Length) {
    $apps_string = ($apps_set -split ",")
    if (Check-IsAdmin) {
      choco upgrade $apps_string -y
    }
    else {
      Start-Process -filepath "powershell" -Argumentlist "choco upgrade $($apps_string) -y" -Verb runas
    }
  }
}

function Update-ScoopApps {
  $apps_set = New-Object System.Collections.Generic.HashSet[[String]]
  $installed_apps = List-ScoopApps
  foreach ($app in Select-Apps $installed_apps) {
    $apps_set.Add($app) >$null
  }
  $include = $(Read-Host "Include predefine apps to update [Y/n]").ToUpper()
  if ($include -eq "Y" -or $include -eq "") {
    foreach ($app in $SCOOP_APPS_TO_UPGRADE) {
      if ($installed_apps -contains $app) {
        $apps_set.Add($app) >$null
      }
    }
  }
  if ($apps_set.Length) {
    $apps_string = ($apps_set -split ",")
    scoop update $apps_string
  }
  else {
    Write-Host "No app was selected to update"
  }
}
function Update-NpmApps {
  $apps_string = $NPM_APPS_TO_UPGRADE -join " "
  npm upgrade $apps_string
}

function Update-PipApps {
  $apps_string = $PIP_APPS_TO_UPGRADE -join " "
  pip install --upgrade $apps_string
}

function Update-PowershellModules {
  # Use the variable in the command
  Update-Module -Name $POWERSHELL_MODULES_TO_UPDATE -AcceptLicense -Force
}


function Uninstall-ChocoApps {
  $apps = Select-Apps $(Get-ChocoApps)
  if ($apps.Length -eq 0) {
    Write-Host "No app was selected"!
    return 
  }
  if (Check-IsAdmin) {
    choco uninstall $apps -y
  }
  else {
    Start-Process -filepath "powershell" -Argumentlist "choco uninstall $($apps) -y" -Verb runas
  }
}

function Uninstall-ScoopApps {
  $apps = Select-Apps $(List-ScoopApps)
  if ($apps.Length -eq 0) {
    Write-Host "No app was selected"!
    return 
  }
  scoop uninstall $apps
}

Export-ModuleMember -Function *
} | Import-Module