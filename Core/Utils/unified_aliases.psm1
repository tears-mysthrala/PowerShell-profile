# PowerShell Unified Alias Configuration

$script:moduleRoot = Split-Path -Parent $PSCommandPath

# Ensure Test-CommandExists is available
function Test-CommandExists {
    param($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    try {
        if (Get-Command $command) {
            return $true
        }
    }
    catch {
        Write-Host "$command does not exist"
        return $false
    }
    finally {
        $ErrorActionPreference = $oldPreference
    }
}

# Navigation aliases and utilities
function Set-LocationUp { Set-Location .\.. }
function Set-LocationUp2 { Set-Location .\..\..\ }
function Set-LocationUp3 { Set-Location .\..\..\..\.. }
function Set-LocationUp4 { Set-Location .\..\..\..\..\.. }
function Set-LocationUp5 { Set-Location .\..\..\..\..\..\.. }

# Create aliases for navigation functions
New-Alias -Name '..' -Value Set-LocationUp
New-Alias -Name '...' -Value Set-LocationUp2
New-Alias -Name '.3' -Value Set-LocationUp3
New-Alias -Name '.4' -Value Set-LocationUp4
New-Alias -Name '.5' -Value Set-LocationUp5

# Editor detection and configuration
function Initialize-EditorConfig {
    if (Test-CommandExists nvim) {
        if (Test-Path "$env:LOCALAPPDATA/$env:DEFAULT_NVIM_CONFIG" -PathType Container) {
            $env:NVIM_APPNAME = $env:DEFAULT_NVIM_CONFIG
        }
        $script:EDITOR = 'nvim'
    }
    elseif (Test-CommandExists code) {
        $script:EDITOR = 'code'
    }
    elseif (Test-CommandExists notepad) {
        $script:EDITOR = 'notepad'
    }
    elseif (Test-CommandExists pvim) {
        $script:EDITOR = 'pvim'
    }
    elseif (Test-CommandExists vim) {
        $script:EDITOR = 'vim'
    }
    elseif (Test-CommandExists vi) {
        $script:EDITOR = 'vi'
    }
    
    Set-Variable -Name EDITOR -Value $script:EDITOR -Scope Global
}

# Create module manifest if it doesn't exist
if (-not (Test-Path "$moduleRoot\unified_aliases.psd1")) {
    New-ModuleManifest -Path "$moduleRoot\unified_aliases.psd1" `
        -RootModule 'unified_aliases.psm1' `
        -ModuleVersion '1.0.0' `
        -Author 'unaiu' `
        -Description 'Unified aliases and utility functions' `
        -FunctionsToExport @(
            'Test-CommandExists',
            'Set-LocationUp',
            'Set-LocationUp2',
            'Set-LocationUp3',
            'Set-LocationUp4',
            'Set-LocationUp5',
            'Initialize-EditorConfig'
        ) `
        -AliasesToExport @('..', '...', '.3', '.4', '.5')
}

# Initialize editor configuration
Initialize-EditorConfig

# Export module members
Export-ModuleMember -Function * -Alias *
