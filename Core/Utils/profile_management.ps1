function Reset-ProfileState {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$Quiet
    )

    if ($PSCmdlet.ShouldProcess("Profile state", "Reset")) {
        try {
            # Clear profile timing information
            $script:profileTiming = @{}

            # Reset preference variables to their defaults
            $global:WarningPreference = 'Continue'
            $global:VerbosePreference = 'SilentlyContinue'
            $global:InformationPreference = 'Continue'
            $global:DebugPreference = 'SilentlyContinue'

            # Force garbage collection
            [System.GC]::Collect()

            if (-not $Quiet) {
                Write-Host "Profile state reset successfully" -ForegroundColor Green
            }
        } catch {
            Write-Error "Failed to reset profile state: $_"
            throw
        }
    }
}
