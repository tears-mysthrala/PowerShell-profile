@{
    RootModule = 'Profile.Commands.psm1'
    ModuleVersion = '1.0.0'
    GUID = '7ef28a93-25e8-44a4-a0d4-1995508b4f1a'
    Author = 'Clawdia MKDL'
    Description = 'Autoloaded interactive commands for the PowerShell profile.'
    PowerShellVersion = '7.5'
    FunctionsToExport = @(
        'Test-CommandExist', 'Connect-Proxmox', '..', '...', '.4',
        'Initialize-Editor', 'v', 'Invoke-GitPull', 'Invoke-GitPush',
        'ls_with_eza', 'll_with_eza', 'la_with_eza', 'lt_with_eza', 'll',
        'New-File', 'uptime', 'head', 'tail', 'Restart-BIOS', 'Get-Font',
        'sysinfo', 'Clear-DnsCache', 'Set-ClipboardContent', 'Get-ClipboardContent',
        'df', 'Set-EnvironmentVariable', 'Stop-ProcessByName', 'Get-ProcessByName',
        'Find-String', 'Get-CommandPath', 'Test-IsAdmin', 'Get-FormattedUptime',
        'Get-PubIP', 'New-DirectoryAndEnter', 'Expand-CustomArchive',
        'Expand-MultipleArchives', 'Find-File', 'Search-FileContent',
        'Find-PowerShellCommand', 'sha256', 'n', 'HKLM:', 'HKCU:', 'Env:',
        'dirs', 'Clear-RecycleBin', 'Clear-TempData', 'Clear-Disk', 'Clear-All'
    )
    AliasesToExport = @(
        'proxmox', 'e', 'c', 'ss', 'shutdownnow', 'rebootnow', 'g', 'pull',
        'push', 'd', 'dc', 'lg', 'l', 'll', 'la', 'lt', 'touch', 'unzip',
        'flushdns', 'cpy', 'pst', 'export', 'pkill', 'pgrep', 'grep', 'which',
        'ff', 'search', 'find-cmd', 'mkcd', 'extract', 'extract-multi'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
}
