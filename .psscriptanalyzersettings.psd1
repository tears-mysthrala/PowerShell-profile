@{
    # PSScriptAnalyzer settings for PowerShell Profile repository
    # Based on PowerShell Best Practices and community standards

    Rules = @{
        # Disable noisy rules that are acceptable in profile scripts
        'PSAvoidUsingCmdletAliases' = @{ Enable = $false }  # Aliases are common in profiles
        'PSAvoidUsingWriteHost' = @{ Enable = $false }     # Write-Host is acceptable in interactive scripts
        'PSUseSingularNouns' = @{ Enable = $false }        # Some function names use plural forms intentionally

        # Repository intentionally uses some empty catch blocks for silent fallbacks
        'PSAvoidUsingEmptyCatchBlock' = @{ Enable = $false }

        # Allow global variables in profile context
        'PSAvoidGlobalVars' = @{ Enable = $false }

        # Allow using Invoke-Expression in controlled contexts
        'PSAvoidUsingInvokeExpression' = @{ Enable = $false }

        # Allow positional parameters in profile scripts
        'PSAvoidUsingPositionalParameters' = @{ Enable = $false }

        # Allow using ConvertTo-SecureString with plain text in development/demo contexts
        'PSAvoidUsingConvertToSecureStringWithPlainText' = @{ Enable = $false }

        # Allow using plain text passwords in development contexts (with warnings)
        'PSAvoidUsingPlainTextForPassword' = @{ Enable = $false }

        # Allow using WMIC (deprecated but still functional)
        'PSAvoidUsingWMIC' = @{ Enable = $false }

        # Allow using ComputerName parameter (may be deprecated in some contexts)
        'PSAvoidUsingComputerNameHardcoded' = @{ Enable = $false }
    }

    # Include additional rule modules
    IncludeRules = @(
        'PSAvoidDefaultValueSwitchParameter',
        'PSAvoidMultipleTypeAttributes',
        'PSAvoidSemicolonsAsLineTerminators',
        'PSAvoidShouldContinueWithoutForce',
        'PSAvoidUsingDeprecatedManifestFields',
        'PSAvoidUsingEmptyCatchBlock',
        'PSAvoidUsingInvokeExpression',
        'PSAvoidUsingPositionalParameters',
        'PSAvoidUsingUserNameAndPasswordParams',
        'PSMisleadingBacktick',
        'PSMissingModuleManifestField',
        'PSPossibleIncorrectComparisonWithNull',
        'PSPossibleIncorrectUsageOfAssignmentOperator',
        'PSPossibleIncorrectUsageOfRedirectionOperator',
        'PSProvideCommentHelp',
        'PSReservedCmdletChar',
        'PSReservedParams',
        'PSShouldProcess',
        'PSUseApprovedVerbs',
        'PSUseCmdletCorrectly',
        'PSUseCompatibleCmdlets',
        'PSUseCompatibleSyntax',
        'PSUseCompatibleTypes',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSUseLiteralInitializerForHashtable',
        'PSUseOutputTypeCorrectly',
        'PSUseProcessBlockForPipelineCommand',
        'PSUsePSCredentialType',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseSupportsShouldProcess',
        'PSUseToExportFieldsInManifest',
        'PSUseUTF8EncodingForHelpFile'
    )

    # Exclude problematic rules for profile scripts
    ExcludeRules = @(
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingWriteHost',
        'PSUseSingularNouns',
        'PSAvoidGlobalVars',
        'PSAvoidUsingInvokeExpression',
        'PSAvoidUsingPositionalParameters',
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        'PSAvoidUsingPlainTextForPassword',
        'PSAvoidUsingWMIC',
        'PSAvoidUsingComputerNameHardcoded'
    )
}
