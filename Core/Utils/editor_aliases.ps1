# Editor detection and configuration - lazy loaded
function Initialize-Editor {
    if ($script:EditorInitialized) { return }
    $script:EditorInitialized = $true

    $editors = @('nvim', 'code', 'notepad', 'pvim', 'vim', 'vi', 'notepad++', 'sublime_text')
    foreach ($editor in $editors) {
        if (Test-CommandExists $editor) {
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
    if ($script:EDITOR) { & $script:EDITOR @args } else { Write-Host "No editor found" }
}
