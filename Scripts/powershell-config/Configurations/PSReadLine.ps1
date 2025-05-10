Import-Module Catppuccin

$Flavor = $Catppuccin['Mocha']

$ScriptBlock = {
  Param([string]$line)
  if ($line -like " *")
  {
    return $false
  }
  $ignore_psreadline = @("user", "pass", "account")
  foreach ($ignore in $ignore_psreadline)
  {
    if ($line -match $ignore)
    {
      return $false
    }
  }
  return $true
}

# Ref: https://github.com/catppuccin/powershell#profile-usage
$Colors = @{
  # Largely based on the Code Editor style guide
  # Emphasis, ListPrediction and ListPredictionSelected are inspired by the Catppuccin fzf theme
	
  # Powershell colours
  ContinuationPrompt     = $Flavor.Teal.Foreground()
  Emphasis               = $Flavor.Red.Foreground()
  Selection              = $Flavor.Surface0.Background()
	
  # PSReadLine prediction colours
  InlinePrediction       = $Flavor.Overlay0.Foreground()
  ListPrediction         = $Flavor.Mauve.Foreground()
  ListPredictionSelected = $Flavor.Surface0.Background()

  # Syntax highlighting
  Command                = $Flavor.Blue.Foreground()
  Comment                = $Flavor.Overlay0.Foreground()
  Default                = $Flavor.Text.Foreground()
  Error                  = $Flavor.Red.Foreground()
  Keyword                = $Flavor.Mauve.Foreground()
  Member                 = $Flavor.Rosewater.Foreground()
  Number                 = $Flavor.Peach.Foreground()
  Operator               = $Flavor.Sky.Foreground()
  Parameter              = $Flavor.Pink.Foreground()
  String                 = $Flavor.Green.Foreground()
  Type                   = $Flavor.Yellow.Foreground()
  Variable               = $Flavor.Lavender.Foreground()
}

$PSReadLineOptions = @{
  EditMode = "emacs"
  AddToHistoryHandler = $ScriptBlock
  Color = $Colors
  ExtraPromptLineCount = $true
  HistoryNoDuplicates = $true
  MaximumHistoryCount = 5000
  PredictionSource = "HistoryAndPlugin"
  PredictionViewStyle = "ListView"
  ShowToolTips = $true
  BellStyle = "None"
}

Set-PSReadLineOption @PSReadLineOptions

Set-PSReadLineKeyHandler -Key "Ctrl+p" -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key "Ctrl+n" -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key "Ctrl+w" -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Key "Ctrl+RightArrow" -Function ForwardWord
Set-PSReadLineKeyHandler -Key "Ctrl+LeftArrow" -Function BackwardWord

# https://ianmorozoff.com/2023/01/10/predictive-intellisense-on-by-default-in-powershell-7-3/#keybinding
$parameters = @{
  Key = 'F4'
  BriefDescription = 'Toggle PSReadLineOption PredictionSource'
  LongDescription = 'Toggles the PSReadLineOption PredictionSource option between "None" and "HistoryAndPlugin".'
  ScriptBlock = {

    # Get current state of PredictionSource
    $state = (Get-PSReadLineOption).PredictionSource

    # Toggle between None and HistoryAndPlugin
    switch ($state)
    {
      "None"
      {Set-PSReadLineOption -PredictionSource HistoryAndPlugin
      } 
      "History"
      {Set-PSReadLineOption -PredictionSource None
      }
      "Plugin"
      {Set-PSReadLineOption -PredictionSource None
      }
      "HistoryAndPlugin"
      {Set-PSReadLineOption -PredictionSource None
      }
      Default
      {Write-Host "Current PSReadLineOption PredictionSource is Unknown"
      }
    }

    # Trigger autocomplete to appear or disappear while preserving the current input
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')
    [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar()

  }
}
Set-PSReadLineKeyHandler @parameters

# Clear PSReadLine history
function Clear-PSReadLineHistory
{
  Get-PSReadlineOption | Select-Object -expand HistorySavePath | Remove-Item
}