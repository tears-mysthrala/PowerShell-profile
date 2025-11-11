New-Module -Name AppsManage -ScriptBlock {
$CHOCO_APPS_TO_UPGRADE = @(
)

function Update-AllApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("All applications", "Update")) {
        Write-Verbose "Starting system-wide update..." -ForegroundColor Cyan

        # Execute the update script
        try {
            . "$ProfileDir\Scripts\powershell-config\UpdateApps.ps1"
            Write-Verbose "Update completed successfully." -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to update: $_"
        }
    }

  }

  # Export the function
  # Export-ModuleMember -Function Update-AllApp

  $SCOOP_APPS_TO_UPGRADE = @(
    "extras/autohotkey",
    "extras/dockercompletion",
    "extras/lazygit",
    "extras/obs-studio",
    "extras/posh-git",
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

  function Get-ChocoApp {
    $apps = $(choco list --id-only --no-color).Split("\n")
    $apps = $apps[1..($apps.Length - 2)]
    return $apps
  }

  function Get-ScoopApp {
    $apps = $(scoop list | Select-Object -ExpandProperty "Name").Split("\n")
    $apps = $apps[1..($apps.Length - 1)]
    return $apps
  }

  function Select-App {
    param (
      [string[]] $apps
    )
    $apps = $apps | fzf --prompt="Select Apps  " --height=~80% --layout=reverse --border --cycle --margin="2,20" --padding=1 --multi
    return $apps
  }

  function Update-ChocoApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("Chocolatey apps", "Update")) {
      $apps_set = New-Object System.Collections.Generic.HashSet[[String]]
      $installed_apps = Get-ChocoApp
      foreach ($app in Select-App $installed_apps) {
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

  }

  function Update-ScoopApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("Scoop apps", "Update")) {
      $apps_set = New-Object System.Collections.Generic.HashSet[[String]]
      $installed_apps = Get-ScoopApp
      foreach ($app in Select-App $installed_apps) {
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
        Write-Verbose "No app was selected to update"
      }
    }
    function Update-NpmApp {
      [CmdletBinding(SupportsShouldProcess)]
      param()
      if ($PSCmdlet.ShouldProcess("NPM apps", "Update")) {
        $apps_string = $NPM_APPS_TO_UPGRADE -join " "
        npm upgrade $apps_string
      }

    }

  }

  function Update-PipApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("PIP apps", "Update")) {
      $apps_string = $PIP_APPS_TO_UPGRADE -join " "
      pip install --upgrade $apps_string
    }

  }

  function Update-PowershellModule {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("PowerShell modules", "Update")) {
      # Use the variable in the command
      Update-Module -Name $POWERSHELL_MODULES_TO_UPDATE -AcceptLicense -Force
    }


    function Uninstall-ChocoApp {
      $apps = Select-App $(Get-ChocoApp)
      if ($apps.Length -eq 0) {
        Write-Verbose "No app was selected"!
        return
      }
      if (Check-IsAdmin) {
        choco uninstall $apps -y
      }
      else {
        Start-Process -filepath "powershell" -Argumentlist "choco uninstall $($apps) -y" -Verb runas
      }
    }

  }

  function Uninstall-ChocoApp {
    $apps = Select-App $(Get-ScoopApp)
  if ($apps.Length -eq 0) {
    Write-Verbose "No app was selected"!
    return
  }
  scoop uninstall $apps
}

Export-ModuleMember -Function *
} | Import-Module
