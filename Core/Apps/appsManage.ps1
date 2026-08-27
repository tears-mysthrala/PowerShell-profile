New-Module -Name AppsManage -ArgumentList $PSScriptRoot -ScriptBlock {
param($InitRoot)
$script:ModuleRoot = $InitRoot

$CHOCO_APPS_TO_UPGRADE = @(
)

function Update-AllApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("All applications", "Update")) {
        Write-Host "Starting system-wide update..." -ForegroundColor Cyan

        try {
            Update-System
            Write-Host "Update completed successfully." -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to update: $_"
        }
    }
}

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

function ConvertFrom-ChocoListOutput {
    param([object[]]$Output)

    @(
        $Output |
            ForEach-Object {
                $line = "$_".Trim()
                if ($line -match '^(?<Name>[A-Za-z0-9][A-Za-z0-9._+-]*)\|') {
                    $Matches['Name']
                }
            }
    )
}

function ConvertFrom-ScoopListOutput {
    param([object[]]$Output)

    @(
        $Output |
            ForEach-Object {
                $name = if ($_ -is [string]) { $_.Trim() } else { $_.Name }
                if ($name -ne 'Name' -and $name -match '^[A-Za-z0-9][A-Za-z0-9._+-]*$') {
                    $name
                }
            }
    )
}

function Get-ChocoApp {
    ConvertFrom-ChocoListOutput -Output @(choco list --limit-output --no-color)
}

function Get-ScoopApp {
    ConvertFrom-ScoopListOutput -Output @(scoop list)
}

function Select-App {
    param (
        [string[]] $apps
    )
    $apps = $apps | fzf --prompt="Select Apps  " --height=~80% --layout=reverse --border --cycle --margin="2,20" --padding=1 --multi
    return $apps
}

function Update-ChocoApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("Chocolatey apps", "Update")) {
        $apps_set = New-Object System.Collections.Generic.HashSet[[String]]
        $installed_apps = Get-ChocoApp
        foreach ($app in Select-App $installed_apps) {
            $apps_set.Add($app) | Out-Null
        }
        $include = $(Read-Host "Include predefined apps to update [Y/n]").ToUpper()
        if ($include -eq "Y" -or $include -eq "") {
            foreach ($app in $CHOCO_APPS_TO_UPGRADE) {
                if ($installed_apps -contains $app) {
                    $apps_set.Add($app) | Out-Null
                }
            }
        }
        if ($apps_set.Count) {
            $apps_string = @($apps_set)
            if (Test-IsAdmin) {
                choco upgrade $apps_string -y
            }
            else {
                Start-Process -FilePath "powershell" -ArgumentList "choco upgrade $($apps_string) -y" -Verb RunAs
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
            $apps_set.Add($app) | Out-Null
        }
        $include = $(Read-Host "Include predefined apps to update [Y/n]").ToUpper()
        if ($include -eq "Y" -or $include -eq "") {
            foreach ($app in $SCOOP_APPS_TO_UPGRADE) {
                if ($installed_apps -contains $app) {
                    $apps_set.Add($app) | Out-Null
                }
            }
        }
        if ($apps_set.Count) {
            $apps_string = @($apps_set)
            scoop update $apps_string
        }
        else {
            Write-Host "No app was selected to update"
        }
    }
}

function Update-NpmApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("NPM apps", "Update")) {
        npm upgrade @NPM_APPS_TO_UPGRADE
    }
}

function Update-PipApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("PIP apps", "Update")) {
        pip install --upgrade @PIP_APPS_TO_UPGRADE
    }
}

function Update-PowershellModule {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("PowerShell modules", "Update")) {
        Update-Module -Name $POWERSHELL_MODULES_TO_UPDATE -AcceptLicense -Force
    }
}

function Uninstall-ChocoApp {
    $apps = Select-App $(Get-ChocoApp)
    if ($apps.Length -eq 0) {
        Write-Host "No app was selected"
        return
    }
    if (Test-IsAdmin) {
        choco uninstall $apps -y
    }
    else {
        Start-Process -FilePath "powershell" -ArgumentList "choco uninstall $($apps) -y" -Verb RunAs
    }
}

function Uninstall-ScoopApp {
    $apps = Select-App $(Get-ScoopApp)
    if ($apps.Length -eq 0) {
        Write-Host "No app was selected"
        return
    }
    scoop uninstall $apps
}

Export-ModuleMember -Function *
} | Import-Module
