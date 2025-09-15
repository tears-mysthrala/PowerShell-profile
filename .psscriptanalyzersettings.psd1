@{
    Rules = @{
        # Disable a small set of noisy rules that are intentional in this repo
        'PSAvoidUsingCmdletAliases' = @{ Enable = $false }
        'PSAvoidUsingWriteHost' = @{ Enable = $false }
        'PSUseSingularNouns' = @{ Enable = $false }
    }
}
