@{
    Rules = @{
        # Disable a small set of noisy rules that are intentional in this repo
        'PSAvoidUsingCmdletAliases' = @{ Enable = $false }
            'PSAvoidUsingWriteHost' = @{ Enable = $false }
            'PSUseSingularNouns' = @{ Enable = $false }
            # Repository intentionally uses some empty catch blocks for silent fallbacks;
            # disable until targeted manual triage is performed.
            'PSAvoidUsingEmptyCatchBlock' = @{ Enable = $false }
    }
}
