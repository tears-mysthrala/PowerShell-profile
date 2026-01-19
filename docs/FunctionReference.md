# Function Reference

> **Auto-generated documentation**
> Last updated: 2026-01-19 20:16:14
> Total functions: 628

## Table of Contents

- [Applications](#applications)
- [Core](#core)
- [Modules](#modules)
- [Other](#other)
- [System](#system)
- [Utilities](#utilities)

## Applications

### `Get-ChocoApp`

**Signature:**
```powershell
function Get-ChocoApp {
    $apps = $(choco list --id-only --no-color).Split("\n")
    $apps = $apps[1..($apps.Length - 2)]
    return $apps
  }

  function Get-ScoopApp {
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Get-ScoopApp`

**Signature:**
```powershell
function Get-ScoopApp {
    $apps = $(scoop list | Select-Object -ExpandProperty "Name").Split("\n")
    $apps = $apps[1..($apps.Length - 1)]
    return $apps
  }

  function Select-App {
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Initialize-UpdateLog`

**Signature:**
```powershell
function Initialize-UpdateLog {
    $logFile = Join-Path $env:TEMP "SystemUpdate_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    return $logFile
}

# Logging function
function Write-UpdateLog {
```

**Description:**

Initialize logging

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

### `Select-App`

**Signature:**
```powershell
function Select-App {
    param (
      [string[]] $apps
    )
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Uninstall-ChocoApp`

**Signature:**
```powershell
function Uninstall-ChocoApp {
      $apps = Select-App $(Get-ChocoApp)
      if ($apps.Length -eq 0) {
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Update-AllApp`

**Signature:**
```powershell
function Update-AllApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Update-Choco`

**Signature:**
```powershell
function Update-Choco {
    [CmdletBinding(SupportsShouldProcess)]
    param([switch]$Silent)
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-ChocoApp`

**Signature:**
```powershell
function Update-ChocoApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Update-Npm`

**Signature:**
```powershell
function Update-Npm {
    [CmdletBinding(SupportsShouldProcess)]
    param([switch]$Silent)
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-NpmApp`

**Signature:**
```powershell
function Update-NpmApp {
      [CmdletBinding(SupportsShouldProcess)]
      param()
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Update-PipApp`

**Signature:**
```powershell
function Update-PipApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Update-PowerShellModule`

**Signature:**
```powershell
function Update-PowerShellModule {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

**Description:**

PowerShell module update function with parallel checking

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

### `Update-Scoop`

**Signature:**
```powershell
function Update-Scoop {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-ScoopApp`

**Signature:**
```powershell
function Update-ScoopApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

<sub>**Source:** `Core\Apps\appsManage.ps1`</sub>

### `Update-StoreApp`

**Signature:**
```powershell
function Update-StoreApp {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Update-System`

**Signature:**
```powershell
function Update-System {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

**Description:**

Main update function with progress display

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

### `Update-WindowsUpdate`

**Signature:**
```powershell
function Update-WindowsUpdate {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$UseLog
    )
```

<sub>**Source:** `Core\Apps\WindowsUpdateHelper.ps1`</sub>

### `Update-Winget`

**Signature:**
```powershell
function Update-Winget {
    [CmdletBinding(SupportsShouldProcess)]
    param([switch]$Silent)
```

<sub>**Source:** `Core\Apps\UpdateAppsHelper.ps1`</sub>

### `Write-AppLog`

**Signature:**
```powershell
function Write-AppLog {
    param($Message)
```

<sub>**Source:** `Core\Apps\UpdateApps.ps1`</sub>

### `Write-ErrorLog`

**Signature:**
```powershell
function Write-ErrorLog {
    param($ErrorMessage)
```

**Description:**

Function to handle errors

<sub>**Source:** `Core\Apps\UpdateApps.ps1`</sub>

### `Write-UpdateErrorLog`

**Signature:**
```powershell
function Write-UpdateErrorLog {
    param($ErrorMessage, $Source, $LogFile)
```

**Description:**

Error handling function

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

### `Write-UpdateLog`

**Signature:**
```powershell
function Write-UpdateLog {
    param($Message, $LogFile)
```

**Description:**

Logging function

<sub>**Source:** `Core\Apps\Updates\SystemUpdater.ps1`</sub>

## Core

### `Get-CachedModuleInfo`

**Signature:**
```powershell
function Get-CachedModuleInfo {
    param([string]$Name)
```

**Description:**

Get module info from cache or scan

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Get-UnifiedModuleStatus`

**Signature:**
```powershell
function Get-UnifiedModuleStatus {
    $script:moduleRegistry.GetEnumerator() | ForEach-Object {
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Get-UnifiedToolStatus`

**Signature:**
```powershell
function Get-UnifiedToolStatus {
    $script:loadedTools.GetEnumerator() | ForEach-Object {
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Import-LazyModule`

**Signature:**
```powershell
function Import-LazyModule {
    param([string]$Name)
```

**Description:**

Lazy loading functionality from LazyModuleManager

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Import-ModuleWithDependency`

**Signature:**
```powershell
function Import-ModuleWithDependency {
    param(
        [string]$ModuleName,
        [switch]$Force
    )
```

<sub>**Source:** `Core\ModuleDependencyManager.ps1`</sub>

### `Import-ModuleWithVersion`

**Signature:**
```powershell
function Import-ModuleWithVersion {
    param(
        [string]$ModuleName,
        [int]$MaxAttempts = 3,
        [switch]$Force
    )
```

<sub>**Source:** `Core\ModuleVersionManager.ps1`</sub>

### `Import-UnifiedModule`

**Signature:**
```powershell
function Import-UnifiedModule {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Name,
        [switch]$Force
    )
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Import-UnifiedTool`

**Signature:**
```powershell
function Import-UnifiedTool {
    param([string]$Name)
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Initialize-ModuleCache`

**Signature:**
```powershell
function Initialize-ModuleCache {
    if (Test-Path $script:moduleCachePath) {
```

**Description:**

Initialize module cache from disk

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Initialize-StartupModule`

**Signature:**
```powershell
function Initialize-StartupModule {
    [CmdletBinding(SupportsShouldProcess)]
    $startupModules = $script:moduleRegistry.GetEnumerator() |
    Where-Object { $_.Value.LoadOnStartup } |
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Initialize-StartupTool`

**Signature:**
```powershell
function Initialize-StartupTool {
    # Mantener compatibilidad pero evitar trabajo innecesario: solo
    # se inicializarán herramientas marcadas explícitamente como LoadOnStartup.
    $script:toolRegistry.GetEnumerator() |
    Where-Object { $_.Value.LoadOnStartup } |
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Install-RequiredModule`

**Signature:**
```powershell
function Install-RequiredModule {
    [CmdletBinding()]
    param()
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

### `Register-ChocolateyProfile`

**Signature:**
```powershell
function Register-ChocolateyProfile {
    $chocoModule = "chocolatey-profile"
    $chocoPath = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

    if (-not $env:ChocolateyInstall) {
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Register-ModuleDependency`

**Signature:**
```powershell
function Register-ModuleDependency {
    param(
        [string]$ModuleName,
        [string]$MinVersion,
        [string[]]$Dependencies = @(),
        [scriptblock]$OnFailure
    )
```

<sub>**Source:** `Core\ModuleDependencyManager.ps1`</sub>

### `Register-ModuleVersion`

**Signature:**
```powershell
function Register-ModuleVersion {
    param(
        [string]$ModuleName,
        [string]$RequiredVersion,
        [scriptblock]$OnVersionMismatch
    )
```

<sub>**Source:** `Core\ModuleVersionManager.ps1`</sub>

### `Register-UnifiedModule`

**Signature:**
```powershell
function Register-UnifiedModule {
    [CmdletBinding()]
    param(
        [string]$Name,
        [string]$MinVersion,
        [string]$RequiredVersion,
        [string[]]$Dependencies = @(),
        [scriptblock]$InitializerBlock,
        [scriptblock]$OnFailure,
        [scriptblock]$OnVersionMismatch,
        [bool]$LoadOnStartup = $false,
        [int]$MaxAttempts = 3,
        [switch]$IgnoreIfMissing,
        [string]$ModulePath
    )
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Register-UnifiedTool`

**Signature:**
```powershell
function Register-UnifiedTool {
    param(
        [string]$Name,
        [scriptblock]$InitializerBlock,
        [bool]$LoadOnStartup = $false
    )
```

**Description:**

Tool management functionality from LazyToolManager

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Save-ModuleCache`

**Signature:**
```powershell
function Save-ModuleCache {
    try {
```

**Description:**

Save module cache to disk

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

### `Test-ModuleInstalled`

**Signature:**
```powershell
function Test-ModuleInstalled {
    param(
        [string]$ModuleName,
        [string]$MinVersion
    )
```

<sub>**Source:** `Core\ModuleInstaller.ps1`</sub>

### `Test-ModuleRequirement`

**Signature:**
```powershell
function Test-ModuleRequirement {
    param([string]$ModuleName)
```

<sub>**Source:** `Core\ModuleDependencyManager.ps1`</sub>

### `Test-ModuleVersion`

**Signature:**
```powershell
function Test-ModuleVersion {
    param([string]$ModuleName)
```

<sub>**Source:** `Core\ModuleVersionManager.ps1`</sub>

### `Test-UnifiedModuleRequirement`

**Signature:**
```powershell
function Test-UnifiedModuleRequirement {
    [CmdletBinding()]
    param([string]$Name)
```

<sub>**Source:** `Core\UnifiedModuleManager.ps1`</sub>

## Modules

### `Add-AssertionDynamicParameterSet`

**Signature:**
```powershell
function Add-AssertionDynamicParameterSet {
    param (
        [object] $AssertionEntry
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Add-DataToContext`

**Signature:**
```powershell
function Add-DataToContext ($Destination, $Data) {
    # works as Merge-Hashtable, but additionally adds _
    # which will become $_, and checks if the Data is
    # expandable, otherwise it just defines $_

    if (-not $Destination.ContainsKey("_")) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Add-Dependency`

**Signature:**
```powershell
function Add-Dependency {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Dependency,
        [Parameter(Mandatory = $true)]
        [Management.Automation.SessionState] $SessionState
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Add-FrameworkDependency`

**Signature:**
```powershell
function Add-FrameworkDependency {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Dependency
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Add-JaCoCoCounter`

**Signature:**
```powershell
function Add-JaCoCoCounter {
    param (
        [parameter(Mandatory = $true)] [ValidateSet('Instruction', 'Line', 'Method', 'Class')] [string] $Type,
        [parameter(Mandatory = $true)] [System.Collections.IDictionary] $Data,
        [parameter(Mandatory = $true)] [System.Xml.XmlNode] $Parent
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Add-MissingContainerParameters`

**Signature:**
```powershell
function Add-MissingContainerParameters ($RootBlock, $Container, $CallingFunction) {
    # Adds default values for container parameters not provided by the user.
    # Also adds real parameter name as variable in Run-phase when alias was used, just like normal PowerShell will.

    # Using AST to get parameter-names as $PSCmdLet.MyInvocation.MyCommand only works for advanced functions/scripts/cmdlets.
    # No need to filter on parameter sets OR whether default values are set because Powershell adds all parameters (not aliases) as variables
    # with default value or $null if not specified (probably to avoid error caused by inheritance).
    $Ast = switch ($Container.Type) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Add-MockBehavior`

**Signature:**
```powershell
function Add-MockBehavior {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Behaviors,
        [Parameter(Mandatory)]
        $Behavior
    )
```

**Description:**

file src\functions\Mock.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Add-Numbers`

**Signature:**
```powershell
function Add-Numbers($a, $b) {
            return $a + $b
        }
    }

    Describe 'Add-Numbers' {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Add-RSpecBlockObjectProperties`

**Signature:**
```powershell
function Add-RSpecBlockObjectProperties ($BlockObject) {
    foreach ($e in $BlockObject.ErrorRecord) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Add-RSpecTestObjectProperties`

**Signature:**
```powershell
function Add-RSpecTestObjectProperties {
    param ($TestObject)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Add-ShouldOperator`

**Signature:**
```powershell
function Add-ShouldOperator {
    <#
    .SYNOPSIS
    Register a Should Operator with Pester
    .DESCRIPTION
    This function allows you to create custom Should assertions.
    .PARAMETER Name
    The name of the assertion. This will become a Named Parameter of Should.
    .PARAMETER Test
    The test function. The function must return a PSObject with a [Bool]succeeded and a [string]failureMessage property.
    .PARAMETER Alias
    A list of aliases for the Named Parameter.
    .PARAMETER SupportsArrayInput
    Does the test function support the passing an array of values to test.
    .PARAMETER InternalName
    If -Name is different from the actual function name, record the actual function name here.
    Used by Get-ShouldOperator to pull function help.
    .EXAMPLE
    ```powershell
    function BeAwesome($ActualValue, [switch] $Negate) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Add-SpaceToNonEmptyString`

**Signature:**
```powershell
function Add-SpaceToNonEmptyString ([string]$Value) {
    if ($Value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Add-XmlAttribute`

**Signature:**
```powershell
function Add-XmlAttribute {
    param(
        [parameter(Mandatory = $true)] [System.Xml.XmlNode] $Element,
        [parameter(Mandatory = $true)] [System.Collections.IDictionary] $Attributes
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Add-XmlElement`

**Signature:**
```powershell
function Add-XmlElement {
    param (
        [parameter(Mandatory = $true)] [System.Xml.XmlNode] $Parent,
        [parameter(Mandatory = $true)] [string] $Name,
        [System.Collections.IDictionary] $Attributes
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `AfterAll`

**Signature:**
```powershell
function AfterAll {
    <#
    .SYNOPSIS
        Defines a series of steps to perform at the end of the current container,
        Context or Describe block.

    .DESCRIPTION
        AfterAll is used to share teardown after all the tests in a container, Describe
        or Context including all child blocks and tests. AfterAll runs during Run phase
        and runs only once in the current block. It's guaranteed to run even if tests
        fail.

        The typical usage is to clean up state or temporary used in tests.

        BeforeAll and AfterAll are unique in that they apply to the entire container,
        Context or Describe block regardless of the order of the statements compared to
        other Context or Describe blocks at the same level.

    .PARAMETER ScriptBlock
        A scriptblock with steps to be executed during teardown.

    .EXAMPLE
        ```powershell
        Describe "Validate important file" {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `AfterEach`

**Signature:**
```powershell
function AfterEach {
    <#
    .SYNOPSIS
        Defines a series of steps to perform at the end of every It block within
        the current Context or Describe block.

    .DESCRIPTION
        AfterEach runs once after every test in the current or any child blocks.
        Typically this is used to clean up resources created by the test or its setups.
        AfterEach runs in a finally block, and is guaranteed to run even if the test
        (or setup) fails.

        BeforeEach and AfterEach are unique in that they apply to the entire Context
        or Describe block, regardless of the order of the statements in the
        Context or Describe.

    .PARAMETER ScriptBlock
        A scriptblock with steps to be executed during teardown.

    .EXAMPLE
        ```powershell
        Describe "Testing export formats" {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `any`

**Signature:**
```powershell
function any ($InputObject) {
    # inlining version
    $(<# any #> if (-not ($s = $InputObject)) { return $false } else { @($s).Length -gt 0 })
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Anywhere`

**Signature:**
```powershell
function Anywhere {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ArrayOrSingleElementIsNullOrEmpty`

**Signature:**
```powershell
function ArrayOrSingleElementIsNullOrEmpty {
    param ([object[]] $Array)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ArraysAreEqual`

**Signature:**
```powershell
function ArraysAreEqual {
    param (
        [object[]] $First,
        [object[]] $Second,
        [switch] $CaseSensitive,
        [int] $RecursionDepth = 0,
        [int] $RecursionLimit = 100
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Assert-AssertionOperatorNameIsUnique`

**Signature:**
```powershell
function Assert-AssertionOperatorNameIsUnique {
    param (
        [string[]] $Name
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Assert-DescribeInProgress`

**Signature:**
```powershell
function Assert-DescribeInProgress {
    # TODO: Enforce block structure in the Runtime.Pester if needed, in the meantime this is just a placeholder
}
# file src\functions\Environment.ps1
function GetPesterPsVersion {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Assert-MockCalled`

**Signature:**
```powershell
function Assert-MockCalled {
    <#
    .SYNOPSIS
    Checks if a Mocked command has been called a certain number of times
    and throws an exception if it has not.

    THIS COMMAND IS OBSOLETE AND WILL BE REMOVED SOMEWHERE DURING v5 LIFETIME,
    USE Should -Invoke INSTEAD.

    .LINK
    https://pester.dev/docs/v5/commands/Assert-MockCalled
    #>
    [CmdletBinding(DefaultParameterSetName = 'ParameterFilter')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$CommandName,

        [Parameter(Position = 1)]
        [int]$Times = 1,

        [ScriptBlock]$ParameterFilter = { $True },

        [Parameter(ParameterSetName = 'ExclusiveFilter', Mandatory = $true)]
        [scriptblock] $ExclusiveFilter,

        [string] $ModuleName,

        [string] $Scope = 0,
        [switch] $Exactly
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Assert-RunInProgress`

**Signature:**
```powershell
function Assert-RunInProgress {
    param(
        [Parameter(Mandatory)]
        [String] $CommandName
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Assert-Success`

**Signature:**
```powershell
function Assert-Success {
    # [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSObject[]] $InvocationResult,
        [String] $Message = "Invocation failed"
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Assert-ValidAssertionAlias`

**Signature:**
```powershell
function Assert-ValidAssertionAlias {
    param([string[]]$Alias)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Assert-ValidAssertionName`

**Signature:**
```powershell
function Assert-ValidAssertionName {
    param([string]$Name)
```

**Description:**

file src\Main.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Assert-VerifiableMock`

**Signature:**
```powershell
function Assert-VerifiableMock {
    <#
    .SYNOPSIS
    Checks if all verifiable Mocks has been called at least once.

    THIS COMMAND IS OBSOLETE AND WILL BE REMOVED SOMEWHERE DURING v5 LIFETIME,
    USE Should -InvokeVerifiable INSTEAD.

    .LINK
    https://pester.dev/docs/v5/commands/Assert-VerifiableMock
    #>

    # Should does not accept a session state, so invoking it directly would
    # make the assertion run from inside of Pester module, we move it to the
    # user scope instead an run it from there to keep the scoping correct
    # for this compatibility adapter
    [CmdletBinding()]param()
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `BeAwesome`

**Signature:**
```powershell
function BeAwesome($ActualValue, [switch] $Negate) {
        [bool] $succeeded = $ActualValue -eq 'Awesome'
        if ($Negate) { $succeeded = -not $succeeded }
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `BeforeAll`

**Signature:**
```powershell
function BeforeAll {
    <#
    .SYNOPSIS
        Defines a series of steps to perform at the beginning of the current container,
        Context or Describe block.

    .DESCRIPTION
        BeforeAll is used to share setup among all the tests in a container, Describe
        or Context including all child blocks and tests. BeforeAll runs during Run phase
        and runs only once in the current level.

        The typical usage is to setup the whole test script, most commonly to
        import the tested function, by dot-sourcing the script file that contains it.

        BeforeAll and AfterAll are unique in that they apply to the entire container,
        Context or Describe block regardless of the order of the statements compared to
        other Context or Describe blocks at the same level.

    .PARAMETER ScriptBlock
        A scriptblock with steps to be executed during setup.

    .EXAMPLE
        ```powershell
        BeforeAll {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `BeforeDiscovery`

**Signature:**
```powershell
function BeforeDiscovery {
    <#
    .SYNOPSIS
    Runs setup code that is used during Discovery phase.

    .DESCRIPTION
    Runs your code as is, in the place where this function is defined. This is a semantic block to allow you
    to be explicit about code that you need to run during Discovery, instead of just
    putting code directly inside of Describe / Context.

    .PARAMETER ScriptBlock
    The ScriptBlock to run.

    .EXAMPLE
    ```powershell
    BeforeDiscovery {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `BeforeEach`

**Signature:**
```powershell
function BeforeEach {
    <#
    .SYNOPSIS
        Defines a series of steps to perform at the beginning of every It block within
        the current Context or Describe block.

    .DESCRIPTION
        BeforeEach runs once before every test in the current or any child blocks.
        Typically this is used to create all the prerequisites for the current test,
        such as writing content to a file.

        BeforeEach and AfterEach are unique in that they apply to the entire Context
        or Describe block, regardless of the order of the statements in the
        Context or Describe.

    .PARAMETER ScriptBlock
        A scriptblock with steps to be executed during setup.

    .EXAMPLE
        ```powershell
        Describe "File parsing" {
```

**Description:**

file src\functions\SetupTeardown.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `branches`

**Signature:**
```powershell
function branches() {
    param($All = "")
```

<sub>**Source:** `Modules\PSFzf\2.7.2\helpers\PSFzfGitBranches.ps1`</sub>

### `CheckFzfTrigger`

**Signature:**
```powershell
function CheckFzfTrigger {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $cursorPosition, $action)
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.psm1`</sub>

### `Clean`

**Signature:**
```powershell
function Clean {
        throw [NotImplementedException]'Clean is not implemented.'
    }
    ```

    The script containing the example test .\Clean.Tests.ps1:

    ```powershell
    BeforeAll {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Clear-TestDrive`

**Signature:**
```powershell
function Clear-TestDrive {
    param(
        [String[]] $Exclude,
        [string] $TestDrivePath
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Clear-TestRegistry`

**Signature:**
```powershell
function Clear-TestRegistry {
    param(
        [String[]] $Exclude,
        [string] $TestRegistryPath
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `combineNonNull`

**Signature:**
```powershell
function combineNonNull ($Array) {
    foreach ($i in $Array) {
```

**Description:**

combines collections that are not null or empty, but does not remove null values from collections so e.g. combineNonNull @(@(1,$null), @(1,2,3), $null, $null, 10) returns 1, $null, 1, 2, 3, 10

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Contain-AnyStringLike`

**Signature:**
```powershell
function Contain-AnyStringLike ($Filter, $Collection) {
    foreach ($item in $Collection) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Context`

**Signature:**
```powershell
function Context {
    <#
    .SYNOPSIS
    Provides logical grouping of It blocks within a single Describe block.

    .DESCRIPTION
    Provides logical grouping of It blocks within a single Describe block.
    Any Mocks defined inside a Context are removed at the end of the Context scope,
    as are any files or folders added to the TestDrive during the Context block's
    execution. Any BeforeEach or AfterEach blocks defined inside a Context also only
    apply to tests within that Context .

    .PARAMETER Name
    The name of the Context. This is a phrase describing a set of tests within a describe.

    .PARAMETER Tag
    Optional parameter containing an array of strings. When calling Invoke-Pester,
    it is possible to specify a -Tag parameter which will only execute Context blocks
    containing the same Tag.

    .PARAMETER Fixture
    Script that is executed. This may include setup specific to the context
    and one or more It blocks that validate the expected outcomes.

    .PARAMETER Skip
    Use this parameter to explicitly mark the block to be skipped. This is preferable to temporarily
    commenting out a block, because it remains listed in the output.

    .PARAMETER ForEach
    Allows data driven tests to be written.
    Takes an array of data and generates one block for each item in the array, and makes the item
    available as $_ in all child blocks. When the array is an array of hashtables, it additionally
    defines each key in the hashtable as variable.

    .EXAMPLE
    ```powershell
    BeforeAll {
```

**Description:**

file src\functions\Context.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Convert-PesterLegacyParameterSet`

**Signature:**
```powershell
function Convert-PesterLegacyParameterSet ($BoundParameters) {
    $Configuration = [PesterConfiguration]::Default

    $migrations = @{
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Convert-PesterSimpleParameterSet`

**Signature:**
```powershell
function Convert-PesterSimpleParameterSet ($BoundParameters) {
    $Configuration = [PesterConfiguration]::Default

    $migrations = @{
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Convert-TimeSpan`

**Signature:**
```powershell
function Convert-TimeSpan {
    param (
        [Parameter(ValueFromPipeline = $true)]
        $TimeSpan
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Convert-UnknownValueToInt`

**Signature:**
```powershell
function Convert-UnknownValueToInt {
    param ([object] $Value, [int] $DefaultValue = 0)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ConvertTo-DiscoveredBlockContainer`

**Signature:**
```powershell
function ConvertTo-DiscoveredBlockContainer {
    param (
        [Parameter(Mandatory = $true)]
        $Block
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ConvertTo-ExecutedBlockContainer`

**Signature:**
```powershell
function ConvertTo-ExecutedBlockContainer {
    param (
        [Parameter(Mandatory = $true)]
        $Block
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ConvertTo-FailureLines`

**Signature:**
```powershell
function ConvertTo-FailureLines {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $ErrorRecord,
        [switch] $ForceFullError
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ConvertTo-HumanTime`

**Signature:**
```powershell
function ConvertTo-HumanTime {
    param ([TimeSpan]$TimeSpan)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ConvertTo-JUnitReport`

**Signature:**
```powershell
function ConvertTo-JUnitReport {
    <#
    .SYNOPSIS
    Converts a Pester result-object to an JUnit-compatible XML report

    .DESCRIPTION
    Pester can generate a result-object containing information about all
    tests that are processed in a run. This objects can then be converted to an
    NUnit-compatible XML-report using this function. The report is generated
    using the JUnit 4-schema.

    The function can convert to both XML-object or a string containing the XML.
    This can be useful for further processing or publishing of test results,
    e.g. as part of a CI/CD pipeline.

    .PARAMETER Result
    Result object from a Pester-run. This can be retrieved using Invoke-Pester
    -Passthru or by using the Run.PassThru configuration-option.

    .PARAMETER AsString
    Returns the XML-report as a string.

    .EXAMPLE
    ```powershell
    $p = Invoke-Pester -Passthru
    $p | ConvertTo-JUnitReport
    ```

    This example runs Pester using the Passthru option to retrieve the result-object and
    converts it to an JUnit 4-compatible XML-report. The report is returned as an XML-object.

    .EXAMPLE
    ```powershell
    $p = Invoke-Pester -Passthru
    $p | ConvertTo-JUnitReport -AsString
    ```

    This example runs Pester using the Passthru option to retrieve the result-object and
    converts it to an JUnit 4-compatible XML-report. The returned object is a string.

    .LINK
    https://pester.dev/docs/v5/commands/ConvertTo-JUnitReport

    .LINK
    https://pester.dev/docs/v5/commands/Invoke-Pester
    #>
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Pester.Run] $Result,
        [Switch] $AsString
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ConvertTo-NUnitReport`

**Signature:**
```powershell
function ConvertTo-NUnitReport {
    <#
    .SYNOPSIS
    Converts a Pester result-object to an NUnit 2.5 or 3-compatible XML-report

    .DESCRIPTION
    Pester can generate a result-object containing information about all
    tests that are processed in a run. This objects can then be converted to an
    NUnit-compatible XML-report using this function. The report is generated
    using either the NUnit 2.5 or 3-schema.

    The function can convert to both XML-object or a string containing the XML.
    This can be useful for further processing or publishing of test results,
    e.g. as part of a CI/CD pipeline.

    .PARAMETER Result
    Result object from a Pester-run. This can be retrieved using Invoke-Pester
    -Passthru or by using the Run.PassThru configuration-option.

    .PARAMETER AsString
    Returns the XML-report as a string.

    .PARAMETER Format
    Specifies the NUnit-schema to be used.

    .EXAMPLE
    ```powershell
    $p = Invoke-Pester -Passthru
    $p | ConvertTo-NUnitReport
    ```

    This example runs Pester using the Passthru option to retrieve the result-object and
    converts it to an NUnit 2.5-compatible XML-report. The report is returned as an XML-object.

    .EXAMPLE
    ```powershell
    $p = Invoke-Pester -Passthru
    $p | ConvertTo-NUnitReport -Format NUnit3
    ```

    This example runs Pester using the Passthru option to retrieve the result-object and
    converts it to an NUnit 3-compatible XML-report. The report is returned as an XML-object.

    .EXAMPLE
    ```powershell
    $p = Invoke-Pester -Passthru
    $p | ConvertTo-NUnitReport -AsString
    ```

    This example runs Pester using the Passthru option to retrieve the result-object and
    converts it to an NUnit 2.5-compatible XML-report. The returned object is a string.

    .LINK
    https://pester.dev/docs/v5/commands/ConvertTo-NUnitReport

    .LINK
    https://pester.dev/docs/v5/commands/Invoke-Pester
    #>
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Pester.Run] $Result,
        [Switch] $AsString,

        [ValidateSet('NUnit2.5', 'NUnit3')]
        [string] $Format = 'NUnit2.5'
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ConvertTo-Pester4Result`

**Signature:**
```powershell
function ConvertTo-Pester4Result {
    <#
    .SYNOPSIS
    Converts a Pester 5 result-object to an Pester 4-compatible object

    .DESCRIPTION
    Pester 5 uses a new format for it's result-object compared to previous
    versions of Pester. This function is provided as a way to convert the
    result-object into an object using the previous format. This can be
    useful as a temporary measure to easier migrate to Pester 5 without
    having to redesign complex CI/CD-pipelines.

    .PARAMETER PesterResult
    Result object from a Pester 5-run. This can be retrieved using Invoke-Pester
    -Passthru or by using the Run.PassThru configuration-option.

    .EXAMPLE
    ```powershell
    $pester5Result = Invoke-Pester -Passthru
    $pester4Result = $pester5Result | ConvertTo-Pester4Result
    ```

    This example runs Pester using the Passthru option to retrieve a result-object
    in the Pester 5 format and converts it to a new Pester 4-compatible result-object.

    .LINK
    https://pester.dev/docs/v5/commands/ConvertTo-Pester4Result

    .LINK
    https://pester.dev/docs/v5/commands/Invoke-Pester
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $PesterResult
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ConvertTo-PesterResult`

**Signature:**
```powershell
function ConvertTo-PesterResult {
    param(
        [String] $Name,
        [Nullable[TimeSpan]] $Time,
        [System.Management.Automation.ErrorRecord] $ErrorRecord
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ConvertTo-XmlElement`

**Signature:**
```powershell
function ConvertTo-XmlElement {
    param(
        [parameter(Mandatory = $true)] [object] $Node
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Count-Scopes`

**Signature:**
```powershell
function Count-Scopes {
    param(
        [Parameter(Mandatory = $true)]
        $ScriptBlock)
```

**Description:**

file src\functions\Pester.Debugging.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Create-File`

**Signature:**
```powershell
function Create-File {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('Pester.BuildAnalyzerRules\Measure-SafeCommands', 'Write-Warning', Justification = 'Mocked in unit test for New-Fixture.')]
    param($Path, $Name, $Content)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Create-MockHook`

**Signature:**
```powershell
function Create-MockHook ($contextInfo, $InvokeMockCallback) {
    $commandName = $contextInfo.Command.Name
    $moduleName = $contextInfo.TargetModule
    $metadata = $contextInfo.CommandMetadata
    $cmdletBinding = ''
    $paramBlock = ''
    $dynamicParamBlock = ''
    $dynamicParamScriptBlock = $null

    if ($contextInfo.Command.psobject.Properties['ScriptBlock'] -or $contextInfo.Command.CommandType -eq 'Cmdlet') {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `defined`

**Signature:**
```powershell
function defined {
    param(
        [Parameter(Mandatory)]
        [String] $Name
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Describe`

**Signature:**
```powershell
function Describe {
    <#
    .SYNOPSIS
    Creates a logical group of tests.

    .DESCRIPTION
    Creates a logical group of tests. All Mocks, TestDrive and TestRegistry contents
    defined within a Describe block are scoped to that Describe; they
    will no longer be present when the Describe block exits.  A Describe
    block may contain any number of Context and It blocks.

    .PARAMETER Name
    The name of the test group. This is often an expressive phrase describing
    the scenario being tested.

    .PARAMETER Fixture
    The actual test script. If you are following the AAA pattern (Arrange-Act-Assert),
    this typically holds the arrange and act sections. The Asserts will also lie
    in this block but are typically nested each in its own It block. Assertions are
    typically performed by the Should command within the It blocks.

    .PARAMETER Tag
    Optional parameter containing an array of strings. When calling Invoke-Pester,
    it is possible to specify a -Tag parameter which will only execute Describe blocks
    containing the same Tag.

    .PARAMETER Skip
    Use this parameter to explicitly mark the block to be skipped. This is preferable to temporarily
    commenting out a block, because it remains listed in the output.

    .PARAMETER ForEach
    Allows data driven tests to be written.
    Takes an array of data and generates one block for each item in the array, and makes the item
    available as $_ in all child blocks. When the array is an array of hashtables, it additionally
    defines each key in the hashtable as variable.

    .EXAMPLE
    ```powershell
    BeforeAll {
```

**Description:**

file src\functions\Describe.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Discover-Test`

**Signature:**
```powershell
function Discover-Test {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSObject[]] $BlockContainer,
        [Parameter(Mandatory = $true)]
        [Management.Automation.SessionState] $SessionState,
        $Filter
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Enable-PsFzfAliases`

**Signature:**
```powershell
function Enable-PsFzfAliases() {
    # set aliases:
    if (-not $DisableAliases) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Functions.ps1`</sub>

### `Enter-CoverageAnalysis`

**Signature:**
```powershell
function Enter-CoverageAnalysis {
    [CmdletBinding()]
    param (
        [object[]] $CodeCoverage,
        [ScriptBlock] $Logger,
        [bool] $UseSingleHitBreakpoints = $true,
        [bool] $UseBreakpoints = $true
    )
```

**Description:**

file src\functions\Coverage.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `EscapeSingleQuotedStringContent`

**Signature:**
```powershell
function EscapeSingleQuotedStringContent ($Content) {
    if ($global:PSVersionTable.PSVersion.Major -ge 5) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ExecuteBehavior`

**Signature:**
```powershell
function ExecuteBehavior {
    param (
        $Behavior,
        $Hook,
        [hashtable] $BoundParameters = @{ },
        [object[]] $ArgumentList = @()
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Exit-CoverageAnalysis`

**Signature:**
```powershell
function Exit-CoverageAnalysis {
    param ([object] $CommandCoverage)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Expand-FileDirectoryPath`

**Signature:**
```powershell
function Expand-FileDirectoryPath($lastWord) {
    # find dir and file pattern connected to the trigger:
    $lastWord = $lastWord.Substring(0, $lastWord.Length - 2)
    if ($lastWord.EndsWith('\')) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.psm1`</sub>

### `Expand-GitCommandPsFzf`

**Signature:**
```powershell
function Expand-GitCommandPsFzf($lastWord) {
    if ([string]::IsNullOrWhiteSpace($env:FZF_COMPLETION_TRIGGER)) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.psm1`</sub>

### `Expand-GitWithFzf`

**Signature:**
```powershell
function Expand-GitWithFzf($lastBlock) {
    $gitResults = Expand-GitCommand $lastBlock
    # if no results, invoke filesystem completion:
    if ($null -eq $gitResults) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.psm1`</sub>

### `Expand-SpecialCharacters`

**Signature:**
```powershell
function Expand-SpecialCharacters {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [string[]]$InputObject)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Export-JUnitReport`

**Signature:**
```powershell
function Export-JUnitReport {
    <#
    .SYNOPSIS
    Exports a Pester result-object to an JUnit-compatible XML-report

    .DESCRIPTION
    Pester can generate a result-object containing information about all
    tests that are processed in a run. This object can then be exported to an
    JUnit-compatible XML-report using this function. The report is generated
    using the JUnit 4-schema.

    This can be useful for further processing or publishing of test results,
    e.g. as part of a CI/CD pipeline.

    .PARAMETER Result
    Result object from a Pester-run. This can be retrieved using Invoke-Pester
    -Passthru or by using the Run.PassThru configuration-option.

    .PARAMETER Path
    The path where the XML-report should be saved.

    .EXAMPLE
    ```powershell
    $p = Invoke-Pester -Passthru
    $p | Export-JUnitReport -Path TestResults.xml
    ```

    This example runs Pester using the Passthru option to retrieve the result-object and
    exports it as an JUnit 4-compatible XML-report.

    .LINK
    https://pester.dev/docs/v5/commands/Export-JUnitReport

    .LINK
    https://pester.dev/docs/v5/commands/Invoke-Pester
    #>
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Pester.Run] $Result,

        [parameter(Mandatory = $true)]
        [String] $Path
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Export-NUnitReport`

**Signature:**
```powershell
function Export-NUnitReport {
    <#
    .SYNOPSIS
    Exports a Pester result-object to an NUnit-compatible XML-report

    .DESCRIPTION
    Pester can generate a result-object containing information about all
    tests that are processed in a run. This object can then be exported to an
    NUnit-compatible XML-report using this function. The report is generated
    using the NUnit 2.5-schema (default) or NUnit3-compatible format.

    This can be useful for further processing or publishing of test results,
    e.g. as part of a CI/CD pipeline.

    .PARAMETER Result
    Result object from a Pester-run. This can be retrieved using Invoke-Pester
    -Passthru or by using the Run.PassThru configuration-option.

    .PARAMETER Path
    The path where the XML-report should be saved.

    .PARAMETER Format
    Specifies the NUnit-schema to be used.

    .EXAMPLE
    ```powershell
    $p = Invoke-Pester -Passthru
    $p | Export-NUnitReport -Path TestResults.xml
    ```

    This example runs Pester using the Passthru option to retrieve the result-object and
    exports it as an NUnit 2.5-compatible XML-report.

    .LINK
    https://pester.dev/docs/v5/commands/Export-NUnitReport

    .LINK
    https://pester.dev/docs/v5/commands/Invoke-Pester
    #>
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Pester.Run] $Result,

        [parameter(Mandatory = $true)]
        [String] $Path,

        [ValidateSet('NUnit2.5', 'NUnit3')]
        [string] $Format = 'NUnit2.5'
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Export-PesterResult`

**Signature:**
```powershell
function Export-PesterResult {
    param (
        [Pester.Run] $Result,
        [string] $Path,
        [string] $Format
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Export-XmlReport`

**Signature:**
```powershell
function Export-XmlReport {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Pester.Run] $Result,

        [parameter(Mandatory = $true)]
        [String] $Path,

        [parameter(Mandatory = $true)]
        [ValidateSet('NUnitXml', 'NUnit2.5', 'NUnit3', 'JUnitXml')]
        [string] $Format
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Exported`

**Signature:**
```powershell
function Exported { Hidden }

        Export-ModuleMember -Function Exported
    } | Import-Module -Force

    Describe "ModuleMockExample" {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Filter-Excluded`

**Signature:**
```powershell
function Filter-Excluded ($Files, $ExcludePath) {
    if ($null -eq $ExcludePath -or @($ExcludePath).Length -eq 0) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Find-CurrentPath`

**Signature:**
```powershell
function Find-CurrentPath {
	param([string]$line, [int]$cursor, [ref]$leftCursor, [ref]$rightCursor)
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `Find-Test`

**Signature:**
```powershell
function Find-Test {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSObject[]] $BlockContainer,
        $Filter,
        [Parameter(Mandatory = $true)]
        [Management.Automation.SessionState] $SessionState
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `FindFzf`

**Signature:**
```powershell
function FindFzf() {
	if ($script:IsWindows) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `FindMatchingBehavior`

**Signature:**
```powershell
function FindMatchingBehavior {
    param (
        [Parameter(Mandatory)]
        $Behaviors,
        [hashtable] $BoundParameters = @{ },
        [object[]] $ArgumentList = @(),
        [Parameter(Mandatory)]
        [Management.Automation.SessionState] $SessionState,
        $Hook
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `FindMock`

**Signature:**
```powershell
function FindMock {
    param (
        [Parameter(Mandatory)]
        [String] $CommandName,
        $ModuleName,
        [Parameter(Mandatory)]
        [HashTable] $MockTable
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `FindToken`

**Signature:**
```powershell
function FindToken
    {
```

<sub>**Source:** `Modules\PSReadLine\2.4.5\SamplePSReadLineProfile.ps1`</sub>

### `FixCompletionResult`

**Signature:**
```powershell
function FixCompletionResult($str) {
	if ([string]::IsNullOrEmpty($str)) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `flattenBlock`

**Signature:**
```powershell
function flattenBlock ($Block, $Accumulator) {
    $Accumulator.Add($Block)
    if ($Block.Blocks.Count -eq 0) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Fold-Block`

**Signature:**
```powershell
function Fold-Block {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $Block,
        $OnBlock = {},
        $OnTest = {},
        $Accumulator
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Fold-Container`

**Signature:**
```powershell
function Fold-Container {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $Container,
        $OnContainer = {},
        $OnBlock = {},
        $OnTest = {},
        $Accumulator
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Fold-Run`

**Signature:**
```powershell
function Fold-Run {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $Run,
        $OnRun = {},
        $OnContainer = {},
        $OnBlock = {},
        $OnTest = {},
        $Accumulator
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-AsExcerpt`

**Signature:**
```powershell
function Format-AsExcerpt {
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $InputObject,
        [Parameter(Mandatory = $true)]
        [int] $DifferenceIndex,
        [Parameter(Mandatory = $true)]
        [int] $LineLength,
        [Parameter(Mandatory = $true)]
        [string] $ExcerptMarker,
        [Parameter(Mandatory = $true)]
        [int] $ContextLength
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-Because`

**Signature:**
```powershell
function Format-Because ([string] $Because) {
    if ($null -eq $Because) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-Boolean`

**Signature:**
```powershell
function Format-Boolean ($Value) {
    '$' + $Value.ToString().ToLower()
}

function Format-ScriptBlock ($Value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-CIErrorMessage`

**Signature:**
```powershell
function Format-CIErrorMessage {
    [OutputType([System.Collections.Generic.List[string]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('AzureDevops', 'GithubActions', IgnoreCase)]
        [string] $CIFormat,

        [Parameter(Mandatory)]
        [ValidateSet('Error', 'Warning', IgnoreCase)]
        [string] $CILogLevel,

        [Parameter(Mandatory)]
        [string] $Header,

        # [Parameter(Mandatory)]
        # Do not make this mandatory, just providing a string array is not enough for the
        # mandatory check to pass, it also throws when any item in the array is empty or null.
        [string[]] $Message
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-Collection`

**Signature:**
```powershell
function Format-Collection ($Value, [switch]$Pretty) {
    $Limit = 10
    $separator = ', '
    if ($Pretty) {
```

**Description:**

file src\Format.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-Date`

**Signature:**
```powershell
function Format-Date ($Value) {
    $Value.ToString('o')
}

function Format-Boolean ($Value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-Dictionary`

**Signature:**
```powershell
function Format-Dictionary ($Value) {
    $head = 'Dictionary{'
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-ErrorMessage`

**Signature:**
```powershell
function Format-ErrorMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Err,
        [string] $ErrorMargin,
        [string] $StackTraceVerbosity = [PesterConfiguration]::Default.Output.StackTraceVerbosity.Value
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-Hashtable`

**Signature:**
```powershell
function Format-Hashtable ($Value) {
    $head = '@{'
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-Nicely`

**Signature:**
```powershell
function Format-Nicely ($Value, [switch]$Pretty) {
    if ($null -eq $Value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-Null`

**Signature:**
```powershell
function Format-Null {
    '$null'
}

function Format-String ($Value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-Number`

**Signature:**
```powershell
function Format-Number ($Value) {
    [string]$Value
}

function Format-Hashtable ($Value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-Object`

**Signature:**
```powershell
function Format-Object ($Value, $Property, [switch]$Pretty) {
    if ($null -eq $Property) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-PesterPath`

**Signature:**
```powershell
function Format-PesterPath ($Path, [String]$Delimiter) {
    # -is check is not enough for the arrays, the incoming value will likely be object[]
    # so we have to check if we can upcast to our required type

    if ($null -eq $Path) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-ScriptBlock`

**Signature:**
```powershell
function Format-ScriptBlock ($Value) {
    '{' + $Value + '}'
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-String`

**Signature:**
```powershell
function Format-String ($Value) {
    if ('' -eq $Value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Format-Type`

**Signature:**
```powershell
function Format-Type ([Type]$Value) {
    if ($null -eq $Value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-AllMockBehaviors`

**Signature:**
```powershell
function Get-AllMockBehaviors {
    param(
        [Parameter(Mandatory)]
        [String] $CommandName
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-ArgumentCompleter`

**Signature:**
```powershell
function Get-ArgumentCompleter {
        <#
        .SYNOPSIS
            Get custom argument completers registered in the current session.
        .DESCRIPTION
            Get custom argument completers registered in the current session.

            By default Get-ArgumentCompleter lists all of the completers registered in the session.
        .EXAMPLE
            Get-ArgumentCompleter

            Get all of the argument completers for PowerShell commands in the current session.
        .EXAMPLE
            Get-ArgumentCompleter -CommandName Invoke-ScriptAnalyzer

            Get all of the argument completers used by the Invoke-ScriptAnalyzer command.
        .EXAMPLE
            Get-ArgumentCompleter -Native

            Get all of the argument completers for native commands in the current session.
        .NOTES
            Author: Chris Dent
        #>
        [CmdletBinding()]
        param (
            # Filter results by command name.
            [Parameter(Mandatory = $true)]
            [String]$CommandName,

            # Filter results by parameter name.
            [Parameter(Mandatory = $true)]
            [String]$ParameterName
        )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-AssertionDynamicParams`

**Signature:**
```powershell
function Get-AssertionDynamicParams {
    return $script:AssertionDynamicParams
}

function Has-Flag {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-AssertionOperatorEntry`

**Signature:**
```powershell
function Get-AssertionOperatorEntry([string] $Name) {
    return $script:AssertionOperators[$Name]
}

function Get-AssertionDynamicParams {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-AssertMockTable`

**Signature:**
```powershell
function Get-AssertMockTable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Frame,
        [Parameter(Mandatory)]
        [String] $CommandName,
        [String] $ModuleName
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-CoberturaReportXml`

**Signature:**
```powershell
function Get-CoberturaReportXml {
    param (
        [parameter(Mandatory = $true)]
        [object] $CoverageReport,
        [parameter(Mandatory = $true)]
        [long] $TotalMilliseconds
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-CodeCoverageFilePaths`

**Signature:**
```powershell
function Get-CodeCoverageFilePaths {
    param (
        [string[]]$Paths,
        [bool]$IncludeTests,
        [bool]$RecursePaths
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-ColorAlways`

**Signature:**
```powershell
function Get-ColorAlways($setting = ' --color=always') {
    if ($AnsiCompatible -or -not $IsWindowsCheck) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Git.ps1`</sub>

### `Get-CommandsInFile`

**Signature:**
```powershell
function Get-CommandsInFile {
    param ([string] $Path)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-CommonParentPath`

**Signature:**
```powershell
function Get-CommonParentPath {
    param ([string[]] $Path)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-CompareStringMessage`

**Signature:**
```powershell
function Get-CompareStringMessage {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [String]$ExpectedValue,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [String]$Actual,
        [switch]$CaseSensitive,
        $Because,
        # this is here for testing, we normally would fallback to the buffer size
        $MaximumLineLength,
        $ContextLength
    )
```

**Description:**

common functions

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-CompatibleModule`

**Signature:**
```powershell
function Get-CompatibleModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ModuleName
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-ConflictingParameterNames`

**Signature:**
```powershell
function Get-ConflictingParameterNames {
    $script:ConflictingParameterNames
}

function Get-ScriptBlockAST {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-ContextToDefine`

**Signature:**
```powershell
function Get-ContextToDefine {
    param (
        [System.Collections.IDictionary] $BoundParameters,
        [System.Management.Automation.CommandMetadata] $Metadata
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-CoverageBreakpoints`

**Signature:**
```powershell
function Get-CoverageBreakpoints {
    [CmdletBinding()]
    param (
        [object[]] $CoverageInfo,
        [ScriptBlock]$Logger
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-CoverageCommandText`

**Signature:**
```powershell
function Get-CoverageCommandText {
    param ([System.Management.Automation.Language.Ast] $Ast)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-CoverageHitCommands`

**Signature:**
```powershell
function Get-CoverageHitCommands {
    param ([object[]] $CommandCoverage)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-CoverageInfoFromDictionary`

**Signature:**
```powershell
function Get-CoverageInfoFromDictionary {
    param ([System.Collections.IDictionary] $Dictionary)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-CoverageInfoFromUserInput`

**Signature:**
```powershell
function Get-CoverageInfoFromUserInput {
    param (
        [Parameter(Mandatory = $true)]
        [object]
        $InputObject,
        $Logger
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-CoverageMissedCommands`

**Signature:**
```powershell
function Get-CoverageMissedCommands {
    param ([object[]] $CommandCoverage)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-CoveragePlugin`

**Signature:**
```powershell
function Get-CoveragePlugin {
    # Validate configuration
    Resolve-CodeCoverageConfiguration

    $p = @{
```

**Description:**

file src\functions\Coverage.Plugin.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-CoverageReport`

**Signature:**
```powershell
function Get-CoverageReport {
    # make sure this is an array, otherwise the counts start failing
    # on powershell 3
    param ([object[]] $CommandCoverage, $Measure)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-CurrentBlock`

**Signature:**
```powershell
function Get-CurrentBlock {
    [CmdletBinding()]
    param()
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-CurrentTest`

**Signature:**
```powershell
function Get-CurrentTest {
    [CmdletBinding()]
    param()
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-DefaultValue`

**Signature:**
```powershell
function Get-DefaultValue {
        param($DefaultValue)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-DictionaryValueFromFirstKeyFound`

**Signature:**
```powershell
function Get-DictionaryValueFromFirstKeyFound {
    param ([System.Collections.IDictionary] $Dictionary, [object[]] $Key)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-DisplayProperty`

**Signature:**
```powershell
function Get-DisplayProperty ($Value) {
    Sort-Property -InputObject $Value -SignificantProperties 'id', 'name'
}

function Get-ShortType ($Value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-DoValuesMatch`

**Signature:**
```powershell
function Get-DoValuesMatch($ActualValue, $ExpectedValue) {
    #user did not specify any message filter, so any message matches
    if ($null -eq $ExpectedValue) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-DynamicParamBlock`

**Signature:**
```powershell
function Get-DynamicParamBlock {
    param (
        [scriptblock] $ScriptBlock
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-DynamicParametersForCmdlet`

**Signature:**
```powershell
function Get-DynamicParametersForCmdlet {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $CmdletName,

        [ValidateScript( {
                if ($PSVersionTable.PSVersion.Major -ge 3 -and
                    $null -ne $_ -and
                    $_.GetType().FullName -ne 'System.Management.Automation.PSBoundParametersDictionary') {
                    throw 'The -Parameters argument must be a PSBoundParametersDictionary object ($PSBoundParameters).'
                }

                return $true
            })]
        [System.Collections.IDictionary] $Parameters
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-DynamicParametersForMockedFunction`

**Signature:**
```powershell
function Get-DynamicParametersForMockedFunction {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $DynamicParamScriptBlock,

        [System.Collections.IDictionary]
        $Parameters,

        [object]
        $Cmdlet
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-EditorLaunch`

**Signature:**
```powershell
function Get-EditorLaunch() {
    param($FileList, $LineNum = 0)
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Functions.ps1`</sub>

### `Get-ErrorForXmlReport`

**Signature:**
```powershell
function Get-ErrorForXmlReport ($TestResult) {
    $failureMessage = if (($TestResult.ShouldRun -and -not $TestResult.Executed)) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-ExceptionLineInfo`

**Signature:**
```powershell
function Get-ExceptionLineInfo($info) {
    # $info.PositionMessage has a leading blank line that we need to account for in PowerShell 2.0
    $positionMessage = $info.PositionMessage -split '\r?\n' -match '\S' -join [System.Environment]::NewLine
    return ($positionMessage -replace "^At ", "from ")
}

function ShouldThrowFailureMessage {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-FailureMessage`

**Signature:**
```powershell
function Get-FailureMessage($assertionEntry, $negate, $value, $expected) {
    if ($negate) {
```

**Description:**

file src\functions\assertions\Should.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-FileSystemCmd`

**Signature:**
```powershell
function Get-FileSystemCmd {
	param($dir, [switch]$dirOnly = $false)
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `Get-GitFzfArguments`

**Signature:**
```powershell
function Get-GitFzfArguments() {
    # take from https://github.com/junegunn/fzf-git.sh/blob/f72ebd823152fa1e9b000b96b71dd28717bc0293/fzf-git.sh#L89
    return @{
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Git.ps1`</sub>

### `Get-GroupResult`

**Signature:**
```powershell
function Get-GroupResult ($InputObject) {
    #I am not sure about the result precedence, and can't find any good source
    #TODO: Confirm this is the correct order of precedence
    if ($inputObject.FailedCount -gt 0) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-HeaderStrings`

**Signature:**
```powershell
function Get-HeaderStrings() {
    $header = "CTRL-A (Select all) / CTRL-D (Deselect all) / CTRL-T (Toggle all)"
    $keyBinds = 'ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all'
    return $Header, $keyBinds
}

function Update-CmdLine($result) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Git.ps1`</sub>

### `Get-HumanTime`

**Signature:**
```powershell
function Get-HumanTime {
    param( [TimeSpan] $TimeSpan)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-JaCoCoReportXml`

**Signature:**
```powershell
function Get-JaCoCoReportXml {
    param (
        [parameter(Mandatory = $true)]
        $CommandCoverage,
        [parameter(Mandatory = $true)]
        [object] $CoverageReport,
        [parameter(Mandatory = $true)]
        [long] $TotalMilliseconds,
        [string] $Format
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-KeyValuePairText`

**Signature:**
```powershell
function Get-KeyValuePairText {
    param (
        [System.Management.Automation.Language.HashtableAst] $HashtableAst,
        [System.Management.Automation.Language.Ast] $ChildAst
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-LineRate`

**Signature:**
```powershell
function Get-LineRate {
    param(
        [parameter(Mandatory = $true)] [int] $CoveredLines,
        [parameter(Mandatory = $true)] [int] $TotalLines
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-MockDataForCurrentScope`

**Signature:**
```powershell
function Get-MockDataForCurrentScope {
    [CmdletBinding()]
    param(
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-MockDynamicParameter`

**Signature:**
```powershell
function Get-MockDynamicParameter {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Cmdlet')]
        [string] $CmdletName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Function')]
        [string] $FunctionName,

        [Parameter(ParameterSetName = 'Function')]
        [string] $ModuleName,

        [System.Collections.IDictionary] $Parameters,

        [object] $Cmdlet,

        [Parameter(ParameterSetName = "Function")]
        $DynamicParamScriptBlock
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-MockPlugin`

**Signature:**
```powershell
function Get-MockPlugin () {
    New-PluginObject -Name "Mock" `
        -ContainerRunStart {
```

**Description:**

file src\functions\Pester.SessionState.Mock.ps1 session state bound functions that act as endpoints, so the internal functions can make their session state consumption explicit and are testable (also prevents scrolling past the whole documentation :D )

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-NUnit3NodeId`

**Signature:**
```powershell
function Get-NUnit3NodeId {
    # depends on inhertied $reportIds created in Write-NUnit3TestRunChildNode
    if ($null -eq $reportIds) { return '' }
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-NUnit3ParameterizedFixtureSuiteInfo`

**Signature:**
```powershell
function Get-NUnit3ParameterizedFixtureSuiteInfo {
    param([Microsoft.PowerShell.Commands.GroupInfo] $TestSuiteGroup, [string] $ParentPath)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-NUnit3ParameterizedMethodSuiteInfo`

**Signature:**
```powershell
function Get-NUnit3ParameterizedMethodSuiteInfo {
    param([Microsoft.PowerShell.Commands.GroupInfo] $TestSuiteGroup, [string] $ParentPath)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-NUnit3ParamString`

**Signature:**
```powershell
function Get-NUnit3ParamString ($Node) {
    if ($Node.Data -isnot [System.Collections.IDictionary]) { return }
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-NUnit3Result`

**Signature:**
```powershell
function Get-NUnit3Result ($InputObject) {
    if ($InputObject.TotalCount -eq $InputObject.NotRunCount) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-NUnit3Site`

**Signature:**
```powershell
function Get-NUnit3Site ($Node) {
    $block = if ($TestSuite -is [Pester.Container] -and $TestSuite.Blocks.Count -gt 0) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-NUnit3TestSuiteInfo`

**Signature:**
```powershell
function Get-NUnit3TestSuiteInfo {
    param($TestSuite, [string] $SuiteType, [string] $ParentPath)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-ParameterInfo`

**Signature:**
```powershell
function Get-ParameterInfo {
        param (
            [Parameter(Mandatory = $true)]
            [Management.Automation.CommandInfo]$Command,
            [Parameter(Mandatory = $true)]
            [string] $Name
        )
```

**Description:**

region HelperFunctions

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-ParameterizedTestSuiteInfo`

**Signature:**
```powershell
function Get-ParameterizedTestSuiteInfo {
    param([Microsoft.PowerShell.Commands.GroupInfo] $TestSuiteGroup)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-ParentClassName`

**Signature:**
```powershell
function Get-ParentClassName {
    param ([System.Management.Automation.Language.Ast] $Ast)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-ParentFunctionName`

**Signature:**
```powershell
function Get-ParentFunctionName {
    param ([System.Management.Automation.Language.Ast] $Ast)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-ParentNonPipelineAst`

**Signature:**
```powershell
function Get-ParentNonPipelineAst {
    param ([System.Management.Automation.Language.Ast] $Ast)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-PickedHistory`

**Signature:**
```powershell
function Get-PickedHistory($Query = '', [switch]$UsePSReadLineHistory) {
	try {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `Get-PSConsoleReadLineBufferState`

**Signature:**
```powershell
function Get-PSConsoleReadLineBufferState {
    [CmdletBinding()]
    param()
```

**Description:**

PSConsoleReadLineWrappers.ps1

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.PSConsoleReadLineWrappers.ps1`</sub>

### `Get-RelativePath`

**Signature:**
```powershell
function Get-RelativePath {
    param ( [string] $Path, [string] $RelativeTo )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-RSpecObjectDecoratorPlugin`

**Signature:**
```powershell
function Get-RSpecObjectDecoratorPlugin () {
    New-PluginObject -Name "RSpecObjectDecoratorPlugin" `
        -EachTestTeardownEnd {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-RunTimeEnvironment`

**Signature:**
```powershell
function Get-RunTimeEnvironment {
    # based on what we found during startup, use the appropriate cmdlet
    $computerName = $env:ComputerName
    $userName = $env:Username
    if ($null -ne $SafeCommands['Get-CimInstance']) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-ScriptBlockAST`

**Signature:**
```powershell
function Get-ScriptBlockAST {
    param (
        [scriptblock]
        $ScriptBlock
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-ScriptBlockHint`

**Signature:**
```powershell
function Get-ScriptBlockHint {
    param(
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-ScriptBlockScope`

**Signature:**
```powershell
function Get-ScriptBlockScope {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-SessionStateHint`

**Signature:**
```powershell
function Get-SessionStateHint {
    param(
        [Parameter(Mandatory = $true)]
        [Management.Automation.SessionState] $SessionState
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-ShortType`

**Signature:**
```powershell
function Get-ShortType ($Value) {
    if ($null -ne $value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-ShouldOperator`

**Signature:**
```powershell
function Get-ShouldOperator {
    <#
    .SYNOPSIS
    Display the assertion operators available for use with Should.

    .DESCRIPTION
    Get-ShouldOperator returns a list of available Should parameters,
    their aliases, and examples to help you craft the tests you need.

    Get-ShouldOperator will list all available operators,
    including any registered by the user with Add-ShouldOperator.

    .NOTES
    Pester uses dynamic parameters to populate Should arguments.

    This limits the user's ability to discover the available assertions via
    standard PowerShell discovery patterns (like `Get-Help Should -Parameter *`).

    .EXAMPLE
    Get-ShouldOperator

    Return all available Should assertion operators and their aliases.

    .EXAMPLE
    Get-ShouldOperator -Name Be

    Return help examples for the Be assertion operator.
    -Name is a dynamic parameter that tab completes all available options.

    .LINK
    https://pester.dev/docs/v5/commands/Get-ShouldOperator

    .LINK
    https://pester.dev/docs/v5/commands/Should
    #>
    [CmdletBinding()]
    param ()
```

**Description:**

file src\functions\Get-ShouldOperator.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-SkipRemainingOnFailurePlugin`

**Signature:**
```powershell
function Get-SkipRemainingOnFailurePlugin {
    # Validate configuration
    Resolve-SkipRemainingOnFailureConfiguration

    # Create plugin
    $p = @{
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-StringOptionErrorMessage`

**Signature:**
```powershell
function Get-StringOptionErrorMessage {
    param (
        [Parameter(Mandatory)]
        [string] $OptionPath,
        [string[]] $SupportedValues = @(),
        [string] $Value
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-TempDirectory`

**Signature:**
```powershell
function Get-TempDirectory {
    if ((GetPesterOs) -eq 'macOS') {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-TempRegistry`

**Signature:**
```powershell
function Get-TempRegistry {
    # The Pester root key is created once and then stays in place.
    # In TestDrive we use system Temp folder, but such key exists for registry so we create our own.
    # Removing it would cleanup remaining keys from cancelled runs, but could break parallell or nested runs, so leaving it

    $pesterTempRegistryRoot = 'Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Pester'
    try {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-TestDriveChildItem`

**Signature:**
```powershell
function Get-TestDriveChildItem ($TestDrivePath) {
    if ([IO.Directory]::Exists($TestDrivePath)) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-TestDrivePlugin`

**Signature:**
```powershell
function Get-TestDrivePlugin {
    $p = @{
```

**Description:**

file src\functions\TestDrive.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-TestRegistryChildItem`

**Signature:**
```powershell
function Get-TestRegistryChildItem ([string]$TestRegistryPath) {
    & $SafeCommands['Get-ChildItem'] -Recurse -Path $TestRegistryPath |
        & $SafeCommands['Select-Object'] -ExpandProperty PSPath
}

function New-RandomTempRegistry {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-TestRegistryPlugin`

**Signature:**
```powershell
function Get-TestRegistryPlugin {
    $p = @{
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-TestResultPlugin`

**Signature:**
```powershell
function Get-TestResultPlugin {
    # Validate configuration
    Resolve-TestResultConfiguration

    $p = @{
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-TestSuiteInfo`

**Signature:**
```powershell
function Get-TestSuiteInfo {
    param($TestSuite, $Path)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-TestTime`

**Signature:**
```powershell
function Get-TestTime($tests) {
    [TimeSpan]$totalTime = 0;
    if ($tests) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-TracerHitLocation`

**Signature:**
```powershell
function Get-TracerHitLocation ($command) {

    if (-not $env:PESTER_CC_DEBUG) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-UTCTimeString`

**Signature:**
```powershell
function Get-UTCTimeString ([datetime]$DateTime) {
    $DateTime.ToUniversalTime().ToString('o')
}

function Get-ErrorForXmlReport ($TestResult) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-VerifiableBehaviors`

**Signature:**
```powershell
function Get-VerifiableBehaviors {
    [CmdletBinding()]
    param(
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Get-WriteScreenPlugin`

**Signature:**
```powershell
function Get-WriteScreenPlugin ($Verbosity) {
    # add -FrameworkSetup Write-PesterStart $pester $Script and -FrameworkTeardown { $pester | Write-PesterReport }
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `GetFullPath`

**Signature:**
```powershell
function GetFullPath ([string]$Path) {
    $Folder = & $SafeCommands['Split-Path'] -Path $Path -Parent
    $File = & $SafeCommands['Split-Path'] -Path $Path -Leaf

    if ( -not ([String]::IsNullOrEmpty($Folder))) {
```

**Description:**

file src\functions\TestResults.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `getOrUpdateValue`

**Signature:**
```powershell
function getOrUpdateValue {
    [CmdletBinding()]
    param(
        $Hashtable,
        $Key,
        $DefaultValue
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `GetPesterOs`

**Signature:**
```powershell
function GetPesterOs {
    # Prior to v6, PowerShell was solely on Windows. In v6, the $IsWindows variable was introduced.
    if ((GetPesterPsVersion) -lt 6) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `GetPesterPsVersion`

**Signature:**
```powershell
function GetPesterPsVersion {
    # accessing the value indirectly so it can be mocked
    (& $SafeCommands['Get-Variable'] 'PSVersionTable' -ValueOnly).PSVersion.Major
}

function GetPesterOs {
```

**Description:**

file src\functions\Environment.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `GetProcessesList`

**Signature:**
```powershell
function GetProcessesList() {
    Get-Process | `
        Where-Object { ![string]::IsNullOrEmpty($_.ProcessName) } | `
```

<sub>**Source:** `Modules\PSFzf\2.7.2\helpers\GetProcessesList.ps1`</sub>

### `GetProcessSelection`

**Signature:**
```powershell
function GetProcessSelection() {
    param(
        [scriptblock]
        $ResultAction
    )
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Functions.ps1`</sub>

### `GetServiceSelection`

**Signature:**
```powershell
function GetServiceSelection() {
    param(
        [scriptblock]
        $ResultAction
    )
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.psm1`</sub>

### `Has-Flag`

**Signature:**
```powershell
function Has-Flag {
    param
    (
        [Parameter(Mandatory = $true)]
        [Pester.OutputTypes]
        $Setting,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Pester.OutputTypes]
        $Value
    )

    0 -ne ($Setting -band $Value)
}

function Invoke-Pester {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Hidden`

**Signature:**
```powershell
function Hidden { "Internal Module Function" }
        function Exported { Hidden }
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Import-Dependency`

**Signature:**
```powershell
function Import-Dependency {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Dependency,
        # [Parameter(Mandatory=$true)]
        [Management.Automation.SessionState] $SessionState
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `In`

**Signature:**
```powershell
function In {
    <#
    .SYNOPSIS
    A convenience function that executes a script from a specified path.

    .DESCRIPTION
    Before the script block passed to the execute parameter is invoked,
    the current location is set to the path specified. Once the script
    block has been executed, the location will be reset to the location
    the script was in prior to calling In.

    .PARAMETER Path
    The path that the execute block will be executed in.

    .PARAMETER ScriptBlock
    The script to be executed in the path provided.

    .LINK
    https://github.com/pester/Pester/wiki/In
    #>
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory, ParameterSetName = "Default", Position = 0)]
        [String] $Path,
        [Parameter(Mandatory, ParameterSetName = "TestDrive", Position = 0)]
        [Switch] $TestDrive,
        [Parameter(Mandatory, Position = 1)]
        [Alias("Execute")]
        [ScriptBlock] $ScriptBlock
    )
```

**Description:**

file src\functions\In.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `InModuleScope`

**Signature:**
```powershell
function InModuleScope {
    <#
    .SYNOPSIS
    Allows you to execute parts of a test script within the
    scope of a PowerShell script or manifest module.
    .DESCRIPTION
    By injecting some test code into the scope of a PowerShell
    script or manifest module, you can use non-exported functions, aliases
    and variables inside that module, to perform unit tests on
    its internal implementation.

    InModuleScope may be used anywhere inside a Pester script,
    either inside or outside a Describe block.
    .PARAMETER ModuleName
    The name of the module into which the test code should be
    injected. This module must already be loaded into the current
    PowerShell session.
    .PARAMETER ScriptBlock
    The code to be executed within the script or manifest module.
    .PARAMETER Parameters
    A optional hashtable of parameters to be passed to the scriptblock.
    Parameters are automatically made available as variables in the scriptblock.
    .PARAMETER ArgumentList
    A optional list of arguments to be passed to the scriptblock.

    .EXAMPLE
    ```powershell
    # The script module:
    function PublicFunction {
```

**Description:**

file src\functions\InModuleScope.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Insert-PSConsoleReadLineText`

**Signature:**
```powershell
function Insert-PSConsoleReadLineText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $TextToInsert
    )
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.PSConsoleReadLineWrappers.ps1`</sub>

### `Invoke-Assertion`

**Signature:**
```powershell
function Invoke-Assertion {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]
        $AssertionEntry,

        [Parameter(Mandatory)]
        [System.Collections.IDictionary]
        $BoundParameters,

        [string]
        $File,

        [Parameter(Mandatory)]
        [int]
        $LineNumber,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LineText,

        [Parameter(Mandatory)]
        [Management.Automation.SessionState]
        $CallerSessionState,

        [Parameter()]
        [switch]
        $Negate,

        [Parameter()]
        [AllowNull()]
        [object]
        $ValueToTest,

        [Parameter()]
        [boolean]
        $ShouldThrow,

        [ScriptBlock]
        $AddErrorCallback
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Invoke-Block`

**Signature:**
```powershell
function Invoke-Block ($previousBlock) {
    Switch-Timer -Scope Framework
    $overheadStartTime = $state.FrameworkStopWatch.Elapsed
    $blockStartTime = $state.UserCodeStopWatch.Elapsed

    if ($PesterPreference.Debug.WriteDebugMessages.Value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Invoke-BlockContainer`

**Signature:**
```powershell
function Invoke-BlockContainer {
    param (
        [Parameter(Mandatory)]
        $BlockContainer,
        [Parameter(Mandatory = $true)]
        [Management.Automation.SessionState] $SessionState
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Invoke-File`

**Signature:**
```powershell
function Invoke-File {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $Path,
        [Parameter(Mandatory = $true)]
        [Management.Automation.SessionState] $SessionState,
        [Collections.IDictionary] $Data = @{}
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Invoke-FuzzyEdit`

**Signature:**
```powershell
function Invoke-FuzzyEdit() {
    param($Directory = ".", [switch]$Wait)
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Functions.ps1`</sub>

### `Invoke-FuzzyFasd`

**Signature:**
```powershell
function Invoke-FuzzyFasd() {
    $result = $null
    try {
```

**Description:**

.ExternalHelp PSFzf.psm1-help.xml

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Functions.ps1`</sub>

### `Invoke-FuzzyGitStatus`

**Signature:**
```powershell
function Invoke-FuzzyGitStatus() {
    Invoke-PsFzfGitFiles
}

function Invoke-PsFzfRipgrep() {
```

**Description:**

.ExternalHelp PSFzf.psm1-help.xml

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Functions.ps1`</sub>

### `Invoke-FuzzyHistory`

**Signature:**
```powershell
function Invoke-FuzzyHistory() {
    $result = Get-PickedHistory -UsePSReadLineHistory:$($null -ne $(Get-Command Get-PSReadLineOption -ErrorAction Ignore))
    if ($null -ne $result) {
```

**Description:**

.ExternalHelp PSFzf.psm1-help.xml

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Functions.ps1`</sub>

### `Invoke-FuzzyKillProcess`

**Signature:**
```powershell
function Invoke-FuzzyKillProcess() {
    GetProcessSelection -ResultAction {
```

**Description:**

.ExternalHelp PSFzf.psm1-help.xml

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Functions.ps1`</sub>

### `Invoke-FuzzyScoop`

**Signature:**
```powershell
function Invoke-FuzzyScoop() {
    param(
        [string]$subcommand = "install",
        [string]$subcommandflags = ""
    )
```

**Description:**

.ExternalHelp PSFzf.psm1-help.xml

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Functions.ps1`</sub>

### `Invoke-FuzzySetLocation`

**Signature:**
```powershell
function Invoke-FuzzySetLocation() {
    param($Directory = $null)
```

**Description:**

.ExternalHelp PSFzf.psm1-help.xml

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Functions.ps1`</sub>

### `Invoke-FuzzyZLocation`

**Signature:**
```powershell
function Invoke-FuzzyZLocation() {
    param(
        [string]$Query = $null
    )
```

**Description:**

.ExternalHelp PSFzf.psm1-help.xml

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Functions.ps1`</sub>

### `Invoke-Fzf`

**Signature:**
```powershell
function Invoke-Fzf {
	param(
		# Search
		[Alias("x")]
		[switch]$Extended,
		[Alias('e')]
		[switch]$Exact,
		[Alias('i')]
		[switch]$CaseInsensitive,
		[switch]$CaseSensitive,
		[ValidateSet('default', 'path', 'history')]
		[string]
		$Scheme = $null,
		[Alias('d')]
		[string]$Delimiter,
		[switch]$NoSort,
		[Alias('tac')]
		[switch]$ReverseInput,
		[switch]$Phony,
		[ValidateSet('length', 'begin', 'end', 'index')]
		[string]
		$Tiebreak = $null,
		[switch]$Disabled,

		# Interface
		[Alias('m')]
		[switch]$Multi,
		[switch]$HighlightLine,
		[switch]$NoMouse,
		[string[]]$Bind,
		[switch]$Cycle,
		[switch]$KeepRight,
		[switch]$NoHScroll,
		[switch]$FilepathWord,

		# Layout
		[ValidatePattern("^[1-9]+[0-9]+$|^[1-9][0-9]?%?$|^100%?$")]
		[string]$Height,
		[ValidateRange(1, [int]::MaxValue)]
		[int]$MinHeight,
		[ValidateSet('default', 'reverse', 'reverse-list')]
		[string]$Layout = $null,
		[switch]$Border,
		[ValidateSet('rounded', 'sharp', 'bold', 'block', 'double', 'horizontal', 'vertical', 'top', 'bottom', 'left', 'right', 'none')]
		[string]$BorderStyle,
		[string]$BorderLabel,
		[ValidateSet('default', 'inline', 'hidden')]
		[string]$Info = $null,
		[string]$Prompt,
		[string]$Pointer,
		[string]$Marker,
		[string]$Header,
		[int]$HeaderLines = -1,

		# Display
		[switch]$Read0,
		[switch]$Ansi,
		[int]$Tabstop = 8,
		[string]$Color,
		[switch]$NoBold,

		# History
		[string]$History,
		[int]$HistorySize = -1,

		#Preview
		[string]$Preview,
		[string]$PreviewWindow,

		# Scripting
		[Alias('q')]
		[string]$Query,
		[Alias('s1')]
		[switch]$Select1,
		[Alias('e0')]
		[switch]$Exit0,
		[Alias('f')]
		[string]$Filter,
		[switch]$PrintQuery,
		[string]$Expect,

		[Parameter(ValueFromPipeline = $True)]
		[object[]]$Input
	)
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `Invoke-FzfDefaultSystem`

**Signature:**
```powershell
function Invoke-FzfDefaultSystem {
	param($ProviderPath, $DefaultOpts)
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `Invoke-FzfPsReadlineHandlerHistory`

**Signature:**
```powershell
function Invoke-FzfPsReadlineHandlerHistory {
	$result = $null
	$bufferState = Get-PSConsoleReadLineBufferState
	$line = $bufferState.Line
	$cursor = $bufferState.Cursor

	$result = Get-PickedHistory -Query $line -UsePSReadLineHistory

	InvokePromptHack

	if (-not [string]::IsNullOrEmpty($result)) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `Invoke-FzfPsReadlineHandlerHistoryArgs`

**Signature:**
```powershell
function Invoke-FzfPsReadlineHandlerHistoryArgs {
	$result = @()
	try {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `Invoke-FzfPsReadlineHandlerProvider`

**Signature:**
```powershell
function Invoke-FzfPsReadlineHandlerProvider {
	$leftCursor = $null
	$rightCursor = $null
	$bufferState = Get-PSConsoleReadLineBufferState
	$line = $bufferState.Line
	$cursor = $bufferState.Cursor
	$currentPath = Find-CurrentPath $line $cursor ([ref]$leftCursor) ([ref]$rightCursor)
	$addSpace = $null -ne $currentPath -and $currentPath.StartsWith(" ")
	if ([String]::IsNullOrWhitespace($currentPath) -or !(Test-Path $currentPath)) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `Invoke-FzfPsReadlineHandlerSetLocation`

**Signature:**
```powershell
function Invoke-FzfPsReadlineHandlerSetLocation {
	$result = $null
	try {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `Invoke-FzfTabCompletion`

**Signature:**
```powershell
function Invoke-FzfTabCompletion() {
    $script:continueCompletion = $true
    do {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.psm1`</sub>

### `Invoke-InMockScope`

**Signature:**
```powershell
function Invoke-InMockScope {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SessionState]
        $SessionState,

        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock,

        [Parameter(Mandatory = $true)]
        $Arguments,

        [Switch]
        $NoNewScope
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Invoke-InNewScriptScope`

**Signature:**
```powershell
function Invoke-InNewScriptScope ([ScriptBlock] $ScriptBlock, $SessionState) {
    # running in a script file will push a new script scope up the stack in the provided
    # session state. To do this from a module we need to transport the file invocation into the
    # correct session state, and then invoke the file. We can also pass a script block tied
    # to the current module to invoke internal function in the newly pushed script scope.

    $Path = "$PSScriptRoot/Pester.ps1"
    $Data = @{ ScriptBlock = $ScriptBlock }
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Invoke-Interactively`

**Signature:**
```powershell
function Invoke-Interactively ($CommandUsed, $ScriptName, $SessionState, $BoundParameters) {
    # interactive execution (by F5 in an editor, by F8 on selection, or by pasting to console)
    # do not run interactively in non-saved files
    # (vscode will use path like "untitled:Untitled-*" so we check if the path is rooted)
    if (-not [String]::IsNullOrEmpty($ScriptName) -and [IO.Path]::IsPathRooted($ScriptName)) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Invoke-Mock`

**Signature:**
```powershell
function Invoke-Mock {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $CommandName,

        [Parameter(Mandatory = $true)]
        [hashtable] $MockCallState,

        [string]
        $ModuleName,

        [hashtable]
        $BoundParameters = @{},

        [object[]]
        $ArgumentList = @(),

        [object] $CallerSessionState,

        [ValidateSet('Begin', 'Process', 'End')]
        [string] $FromBlock,

        [object] $InputObject,

        $Hook
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Invoke-MockInternal`

**Signature:**
```powershell
function Invoke-MockInternal {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $CommandName,

        [Parameter(Mandatory = $true)]
        [hashtable] $MockCallState,

        [string]
        $ModuleName,

        [hashtable]
        $BoundParameters = @{ },

        [object[]]
        $ArgumentList = @(),

        [object] $CallerSessionState,

        [ValidateSet('Begin', 'Process', 'End')]
        [string] $FromBlock,

        [object] $InputObject,

        [Parameter(Mandatory)]
        $Behaviors,

        [Parameter(Mandatory)]
        [HashTable]
        $CallHistory,

        [Parameter(Mandatory)]
        $Hook
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Invoke-Pester`

**Signature:**
```powershell
function Invoke-Pester {
    <#
    .SYNOPSIS
    Runs Pester tests

    .DESCRIPTION
    The Invoke-Pester function runs Pester tests, including *.Tests.ps1 files and
    Pester tests in PowerShell scripts.

    You can run scripts that include Pester tests just as you would any other
    Windows PowerShell script, including typing the full path at the command line
    and running in a script editing program. Typically, you use Invoke-Pester to run
    all Pester tests in a directory, or to use its many helpful parameters,
    including parameters that generate custom objects or XML files.

    By default, Invoke-Pester runs all *.Tests.ps1 files in the current directory
    and all subdirectories recursively. You can use its parameters to select tests
    by file name, test name, or tag.

    To run Pester tests in scripts that take parameter values, use the Script
    parameter with a hash table value.

    Also, by default, Pester tests write test results to the console host, much like
    Write-Host does, but you can use the Show parameter set to None to suppress the host
    messages, use the PassThru parameter to generate a custom object
    (PSCustomObject) that contains the test results, use the OutputXml and
    OutputFormat parameters to write the test results to an XML file, and use the
    EnableExit parameter to return an exit code that contains the number of failed
    tests.

    You can also use the Strict parameter to fail all pending and skipped tests.
    This feature is ideal for build systems and other processes that require success
    on every test.

    To help with test design, Invoke-Pester includes a CodeCoverage parameter that
    lists commands, classes, functions, and lines of code that did not run during test
    execution and returns the code that ran as a percentage of all tested code.

    Invoke-Pester, and the Pester module that exports it, are products of an
    open-source project hosted on GitHub. To view, comment, or contribute to the
    repository, see https://github.com/Pester.

    .PARAMETER CI
    (Introduced v5)
    Enable Test Results and Exit after Run.

    Replace with ConfigurationProperty
        TestResult.Enabled = $true
        Run.Exit = $true

    Since 5.2.0, this option no longer enables CodeCoverage.
    To also enable CodeCoverage use this configuration option:
        CodeCoverage.Enabled = $true

    .PARAMETER CodeCoverage
    (Deprecated v4)
    Replace with ConfigurationProperty CodeCoverage.Enabled = $true
    Adds a code coverage report to the Pester tests. Takes strings or hash table values.
    A code coverage report lists the lines of code that did and did not run during
    a Pester test. This report does not tell whether code was tested; only whether
    the code ran during the test.
    By default, the code coverage report is written to the host program
    (like Write-Host). When you use the PassThru parameter, the custom object
    that Invoke-Pester returns has an additional CodeCoverage property that contains
    a custom object with detailed results of the code coverage test, including lines
    hit, lines missed, and helpful statistics.
    However, NUnitXml and JUnitXml output (OutputXML, OutputFormat) do not include
    any code coverage information, because it's not supported by the schema.
    Enter the path to the files of code under test (not the test file).
    Wildcard characters are supported. If you omit the path, the default is local
    directory, not the directory specified by the Script parameter. Pester test files
    are by default excluded from code coverage when a directory is provided. When you
    provide a test file directly using string, code coverage will be measured. To include
    tests in code coverage of a directory, use the dictionary syntax and provide
    IncludeTests = $true option, as shown below.
    To run a code coverage test only on selected classes, functions or lines in a script,
    enter a hash table value with the following keys:
    -- Path (P)(mandatory) <string>: Enter one path to the files. Wildcard characters
    are supported, but only one string is permitted.
    -- IncludeTests <bool>: Includes code coverage for Pester test files (*.tests.ps1).
    Default is false.
    One of the following: Class/Function or StartLine/EndLine
    -- Class (C) <string>: Enter the class name. Wildcard characters are
    supported, but only one string is permitted. Default is *.
    -- Function (F) <string>: Enter the function name. Wildcard characters are
    supported, but only one string is permitted. Default is *.
    -or-
    -- StartLine (S): Performs code coverage analysis beginning with the specified
    line. Default is line 1.
    -- EndLine (E): Performs code coverage analysis ending with the specified line.
    Default is the last line of the script.

    .PARAMETER CodeCoverageOutputFile
    (Deprecated v4)
    Replace with ConfigurationProperty CodeCoverage.OutputPath
    The path where Invoke-Pester will save formatted code coverage results file.
    The path must include the location and name of the folder and file name with
    a required extension (usually the xml).
    If this path is not provided, no file will be generated.
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Invoke-PluginStep`

**Signature:**
```powershell
function Invoke-PluginStep {
    # [CmdletBinding()]
    param (
        [PSObject[]] $Plugins,
        [Parameter(Mandatory)]
        [ValidateSet('Start', 'DiscoveryStart', 'ContainerDiscoveryStart', 'BlockDiscoveryStart', 'TestDiscoveryStart', 'TestDiscoveryEnd', 'BlockDiscoveryEnd', 'ContainerDiscoveryEnd', 'DiscoveryEnd', 'RunStart', 'ContainerRunStart', 'OneTimeBlockSetupStart', 'EachBlockSetupStart', 'OneTimeTestSetupStart', 'EachTestSetupStart', 'EachTestTeardownEnd', 'OneTimeTestTeardownEnd', 'EachBlockTeardownEnd', 'OneTimeBlockTeardownEnd', 'ContainerRunEnd', 'RunEnd', 'End')]
        [String] $Step,
        $Context = @{ },
        [Switch] $ThrowOnFailure
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Invoke-PSConsoleReadLineAcceptLine`

**Signature:**
```powershell
function Invoke-PSConsoleReadLineAcceptLine {
    [CmdletBinding()]
    param()
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.PSConsoleReadLineWrappers.ps1`</sub>

### `Invoke-PSConsoleReadLinePrompt`

**Signature:**
```powershell
function Invoke-PSConsoleReadLinePrompt {
    [CmdletBinding()]
    param()
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.PSConsoleReadLineWrappers.ps1`</sub>

### `Invoke-PsFzfGitBranches`

**Signature:**
```powershell
function Invoke-PsFzfGitBranches() {
    if (-not (IsInGitRepo)) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Git.ps1`</sub>

### `Invoke-PsFzfGitFiles`

**Signature:**
```powershell
function Invoke-PsFzfGitFiles() {
    if (-not (IsInGitRepo)) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Git.ps1`</sub>

### `Invoke-PsFzfGitHashes`

**Signature:**
```powershell
function Invoke-PsFzfGitHashes() {
    if (-not (IsInGitRepo)) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Git.ps1`</sub>

### `Invoke-PsFzfGitPullRequests`

**Signature:**
```powershell
function Invoke-PsFzfGitPullRequests() {
    if (-not (IsInGitRepo)) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Git.ps1`</sub>

### `Invoke-PsFzfGitStashes`

**Signature:**
```powershell
function Invoke-PsFzfGitStashes() {
    if (-not (IsInGitRepo)) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Git.ps1`</sub>

### `Invoke-PsFzfGitTags`

**Signature:**
```powershell
function Invoke-PsFzfGitTags() {
    if (-not (IsInGitRepo)) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Git.ps1`</sub>

### `Invoke-PsFzfRipgrep`

**Signature:**
```powershell
function Invoke-PsFzfRipgrep() {
    # this function is adapted from https://github.com/junegunn/fzf/blob/master/ADVANCED.md#switching-between-ripgrep-mode-and-fzf-mode
    param([Parameter(Mandatory)]$SearchString, [switch]$NoEditor)
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Functions.ps1`</sub>

### `Invoke-ScriptBlock`

**Signature:**
```powershell
function Invoke-ScriptBlock {
    param(
        [ScriptBlock] $ScriptBlock,
        [ScriptBlock[]] $OuterSetup,
        [ScriptBlock[]] $Setup,
        [ScriptBlock[]] $Teardown,
        [ScriptBlock[]] $OuterTeardown,
        $Context = @{ },
        # define data to be shared in only in the inner scope where e.g eachTestSetup + test run but not
        # in the scope where OneTimeTestSetup runs, on the other hand, plugins want context
        # in all scopes
        [Switch] $ReduceContextToInnerScope,
        # # setup, body and teardown will all run (be-dotsourced into)
        # # the same scope
        # [Switch] $SameScope,
        # will dot-source the wrapper scriptblock instead of invoking it
        # so in combination with the SameScope switch we are effectively
        # running the code in the current scope
        [Switch] $NoNewScope,
        [Switch] $MoveBetweenScopes,
        [ScriptBlock] $OnUserScopeTransition = $null,
        [ScriptBlock] $OnFrameworkScopeTransition = $null,
        $Configuration
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Invoke-Test`

**Signature:**
```powershell
function Invoke-Test {
    #[CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSObject[]] $BlockContainer,
        [Parameter(Mandatory = $true)]
        [Management.Automation.SessionState] $SessionState,
        $Filter,
        $Plugin,
        $PluginConfiguration,
        $PluginData,
        $Configuration
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Invoke-TestItem`

**Signature:**
```powershell
function Invoke-TestItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Test
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `InvokePromptHack`

**Signature:**
```powershell
function InvokePromptHack() {
	$previousOutputEncoding = [Console]::OutputEncoding
	[Console]::OutputEncoding = [Text.Encoding]::UTF8

	try {
```

**Description:**

HACK: workaround for fact that PSReadLine seems to clear screen after keyboard shortcut action is executed, and to work around a UTF8 PSReadLine issue (GitHub PSFZF issue #71)

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `Is-Collection`

**Signature:**
```powershell
function Is-Collection ($Value) {
    # check for value types and strings explicitly
    # because otherwise it does not work for decimal
    # so let's skip all values we definitely know
    # are not collections
    if ($Value -is [ValueType] -or $Value -is [string]) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Is-DecimalNumber`

**Signature:**
```powershell
function Is-DecimalNumber ($Value) {
    $Value -is [float] -or $Value -is [single] -or $Value -is [double] -or $Value -is [decimal]
}

function Is-Hashtable ($Value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Is-Dictionary`

**Signature:**
```powershell
function Is-Dictionary ($Value) {
    $Value -is [System.Collections.IDictionary]
}


function Is-Object ($Value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Is-Discovery`

**Signature:**
```powershell
function Is-Discovery {
    $state.Discovery
}

function Discover-Test {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Is-Hashtable`

**Signature:**
```powershell
function Is-Hashtable ($Value) {
    $Value -is [hashtable]
}

function Is-Dictionary ($Value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Is-Object`

**Signature:**
```powershell
function Is-Object ($Value) {
    # here we need to approximate that that object is not value
    # or any special category of object, so other checks might
    # need to be added

    -not ($null -eq $Value -or (Is-Value -Value $Value) -or (Is-Collection -Value $Value))
}
# file src\Format.ps1

function Format-Collection ($Value, [switch]$Pretty) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Is-ScriptBlock`

**Signature:**
```powershell
function Is-ScriptBlock ($Value) {
    $Value -is [ScriptBlock]
}

function Is-DecimalNumber ($Value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Is-Value`

**Signature:**
```powershell
function Is-Value ($Value) {
    $Value = $($Value)
    $Value -is [ValueType] -or $Value -is [string] -or $value -is [scriptblock]
}

function Is-Collection ($Value) {
```

**Description:**

file src\TypeClass.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `IsArray`

**Signature:**
```powershell
function IsArray {
    param ([object] $InputObject)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `IsChildOfHashtableDynamicKeyword`

**Signature:**
```powershell
function IsChildOfHashtableDynamicKeyword {
    param ([System.Management.Automation.Language.Ast] $Command)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `IsClosingLoopCondition`

**Signature:**
```powershell
function IsClosingLoopCondition {
    param ([System.Management.Automation.Language.Ast] $Command)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `IsCommonParameter`

**Signature:**
```powershell
function IsCommonParameter {
    param (
        [string] $Name,
        [System.Management.Automation.CommandMetadata] $Metadata
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `IsIgnoredCommand`

**Signature:**
```powershell
function IsIgnoredCommand {
    param ([System.Management.Automation.Language.Ast] $Command)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `IsInGitRepo`

**Signature:**
```powershell
function IsInGitRepo() {
    git rev-parse HEAD 2>&1 | Out-Null
    return $?
}

function Get-ColorAlways($setting = ' --color=always') {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Git.ps1`</sub>

### `It`

**Signature:**
```powershell
function It {
    <#
    .SYNOPSIS
    Validates the results of a test inside of a Describe block.

    .DESCRIPTION
    The It command is intended to be used inside of a Describe or Context Block.
    If you are familiar with the AAA pattern (Arrange-Act-Assert), the body of
    the It block is the appropriate location for an assert. The convention is to
    assert a single expectation for each It block. The code inside of the It block
    should throw a terminating error if the expectation of the test is not met and
    thus cause the test to fail. The name of the It block should expressively state
    the expectation of the test.

    In addition to using your own logic to test expectations and throw exceptions,
    you may also use Pester's Should command to perform assertions in plain language.

    You can intentionally mark It block result as inconclusive by using Set-ItResult -Inconclusive
    command as the first tested statement in the It block.

    .PARAMETER Name
    An expressive phrase describing the expected test outcome.

    .PARAMETER Test
    The script block that should throw an exception if the
    expectation of the test is not met.If you are following the
    AAA pattern (Arrange-Act-Assert), this typically holds the
    Assert.

    .PARAMETER Pending
    Use this parameter to explicitly mark the test as work-in-progress/not implemented/pending when you
    need to distinguish a test that fails because it is not finished yet from a tests
    that fail as a result of changes being made in the code base. An empty test, that is a
    test that contains nothing except whitespace or comments is marked as Pending by default.

    .PARAMETER Skip
    Use this parameter to explicitly mark the test to be skipped. This is preferable to temporarily
    commenting out a test, because the test remains listed in the output.

    .PARAMETER ForEach
    (Formerly called TestCases.) Optional array of hashtable (or any IDictionary) objects.
    If this parameter is used, Pester will call the test script block once for each table in
    the ForEach array, splatting the dictionary to the test script block as input.  If you want
    the name of the test to appear differently for each test case, you can embed tokens into the Name
    parameter with the syntax 'Adds numbers <A> and <B>' (assuming you have keys named A and B
    in your ForEach hashtables.)

    .PARAMETER Tag
    Optional parameter containing an array of strings. When calling Invoke-Pester,
    it is possible to include or exclude tests containing the same Tag.

    .EXAMPLE
    ```powershell
    BeforeAll {
```

**Description:**

file src\functions\It.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Join-And`

**Signature:**
```powershell
function Join-And ($Items, $Threshold = 2) {
    Join-With -Items $Items -Threshold $Threshold -Separator ', ' -LastSeparator ' and '
}

function Join-Or ($Items, $Threshold = 2) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Join-Or`

**Signature:**
```powershell
function Join-Or ($Items, $Threshold = 2) {
    Join-With -Items $Items -Threshold $Threshold -Separator ', ' -LastSeparator ' or '
}

function Add-SpaceToNonEmptyString ([string]$Value) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Join-With`

**Signature:**
```powershell
function Join-With ($Items, $Threshold = 2, $Separator = ', ', $LastSeparator = ' and ') {
    if ($null -eq $items -or $items.count -lt $Threshold) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `LastThat`

**Signature:**
```powershell
function LastThat {
    param (
        $Collection,
        $Predicate
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Merge-CommandCoverage`

**Signature:**
```powershell
function Merge-CommandCoverage {
    param ([object[]] $CommandCoverage)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Merge-Hashtable`

**Signature:**
```powershell
function Merge-Hashtable ($Source, $Destination) {
    # only add non-existing keys so in case of conflict
    # the framework name wins, as if we had explicit parameters
    # on a scriptblock, then the parameter would also win
    foreach ($p in $Source.GetEnumerator()) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Merge-HashtableOrObject`

**Signature:**
```powershell
function Merge-HashtableOrObject ($Source, $Destination) {
    if ($Source -isnot [Collections.IDictionary] -and $Source -isnot [PSObject]) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Mock`

**Signature:**
```powershell
function Mock {
    <#
    .SYNOPSIS
    Mocks the behavior of an existing command with an alternate
    implementation.

    .DESCRIPTION
    This creates new behavior for any existing command within the scope of a
    Describe or Context block. The function allows you to specify a script block
    that will become the command's new behavior.

    Optionally, you may create a Parameter Filter which will examine the
    parameters passed to the mocked command and will invoke the mocked
    behavior only if the values of the parameter values pass the filter. If
    they do not, the original command implementation will be invoked instead
    of a mock.

    You may create multiple mocks for the same command, each using a different
    ParameterFilter. ParameterFilters will be evaluated in reverse order of
    their creation. The last one created will be the first to be evaluated.
    The mock of the first filter to pass will be used. The exception to this
    rule are Mocks with no filters. They will always be evaluated last since
    they will act as a "catch all" mock.

    Mocks can be marked Verifiable. If so, the Should -InvokeVerifiable command
    can be used to check if all Verifiable mocks were actually called. If any
    verifiable mock is not called, Should -InvokeVerifiable will throw an
    exception and indicate all mocks not called.

    If you wish to mock commands that are called from inside a script or manifest
    module, you can do so by using the -ModuleName parameter to the Mock command.
    This injects the mock into the specified module. If you do not specify a
    module name, the mock will be created in the same scope as the test script.
    You may mock the same command multiple times, in different scopes, as needed.
    Each module's mock maintains a separate call history and verified status.

    .PARAMETER CommandName
    The name of the command to be mocked.

    .PARAMETER MockWith
    A ScriptBlock specifying the behavior that will be used to mock CommandName.
    The default is an empty ScriptBlock.
    NOTE: Do not specify param or dynamicparam blocks in this script block.
    These will be injected automatically based on the signature of the command
    being mocked, and the MockWith script block can contain references to the
    mocked commands parameter variables.

    .PARAMETER Verifiable
    When this is set, the mock will be checked when Should -InvokeVerifiable is
    called.

    .PARAMETER ParameterFilter
    An optional filter to limit mocking behavior only to usages of
    CommandName where the values of the parameters passed to the command
    pass the filter.

    This ScriptBlock must return a boolean value. See examples for usage.

    .PARAMETER ModuleName
    Optional string specifying the name of the module where this command
    is to be mocked.  This should be a module that _calls_ the mocked
    command; it doesn't necessarily have to be the same module which
    originally implemented the command.

    .PARAMETER RemoveParameterType
    Optional list of parameter names that should use Object as the parameter
    type instead of the parameter type defined by the function. This relaxes the
    type requirements and allows some strongly typed functions to be mocked
    more easily.

    .PARAMETER RemoveParameterValidation
    Optional list of parameter names in the original command
    that should not have any validation rules applied. This relaxes the
    validation requirements, and allows functions that are strict about their
    parameter validation to be mocked more easily.

    .EXAMPLE
    Mock Get-ChildItem { return @{FullName = "A_File.TXT"} }
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-Block`

**Signature:**
```powershell
function New-Block {
    param (
        [Parameter(Mandatory = $true)]
        [String] $Name,
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock,
        [int] $StartLine = $MyInvocation.ScriptLineNumber,
        [String[]] $Tag = @(),
        [HashTable] $FrameworkData = @{ },
        [Switch] $Focus,
        [String] $GroupId,
        [Switch] $Skip,
        $Data
    )
```

**Description:**

endpoint for adding a block that contains tests or other blocks

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-BlockContainerObject`

**Signature:**
```powershell
function New-BlockContainerObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ParameterSetName = 'ScriptBlock')]
        [ScriptBlock] $ScriptBlock,

        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [String] $Path,

        [Parameter(Mandatory, ParameterSetName = 'File')]
        [System.IO.FileInfo] $File,

        [Parameter(Mandatory, ParameterSetName = 'Container')]
        [Pester.ContainerInfo] $Container,

        $Data
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-BlockWithoutParameterAliases`

**Signature:**
```powershell
function New-BlockWithoutParameterAliases {
    [OutputType([scriptblock])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Management.Automation.CommandMetadata]
        $Metadata,
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [scriptblock]
        $Block
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-CoverageBreakpoint`

**Signature:**
```powershell
function New-CoverageBreakpoint {
    param ([System.Management.Automation.Language.Ast] $Command)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-CoverageInfo`

**Signature:**
```powershell
function New-CoverageInfo {
    param ($Path, [string] $Class = $null, [string] $Function = $null, [int] $StartLine = 0, [int] $EndLine = 0, [bool] $IncludeTests = $false, $RecursePaths = $true)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-DiscoveredBlockContainerObject`

**Signature:**
```powershell
function New-DiscoveredBlockContainerObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $BlockContainer,
        [Parameter(Mandatory)]
        $Block
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-EachBlockSetup`

**Signature:**
```powershell
function New-EachBlockSetup {
    param (
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock
    )
```

**Description:**

endpoint for adding a setup for each block in the current block

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-EachBlockTeardown`

**Signature:**
```powershell
function New-EachBlockTeardown {
    param (
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock
    )
```

**Description:**

endpoint for adding a teardown for each block in the current block

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-EachTestSetup`

**Signature:**
```powershell
function New-EachTestSetup {
    param (
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock
    )
```

**Description:**

endpoint for adding a setup for each test in the block

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-EachTestTeardown`

**Signature:**
```powershell
function New-EachTestTeardown {
    param (
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock
    )
```

**Description:**

endpoint for adding a teardown for each test in the block

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-FilterObject`

**Signature:**
```powershell
function New-FilterObject {
    [CmdletBinding()]
    param (
        [String[]] $FullName,
        [String[]] $Tag,
        [String[]] $ExcludeTag,
        [String[]] $Line,
        [String[]] $ExcludeLine
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-Fixture`

**Signature:**
```powershell
function New-Fixture {
    <#
    .SYNOPSIS
    This function generates two scripts, one that defines a function
    and another one that contains its tests.

    .DESCRIPTION
    This function generates two scripts, one that defines a function
    and another one that contains its tests. The files are by default
    placed in the current directory and are called and populated as such:

    The script defining the function: .\Clean.ps1:

    ```powershell
    function Clean {
```

**Description:**

file src\functions\New-Fixture.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-LineNode`

**Signature:**
```powershell
function New-LineNode {
    param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true)] [object] $LineObject
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-MockBehavior`

**Signature:**
```powershell
function New-MockBehavior {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $ContextInfo,
        [ScriptBlock] $MockWith = { },
        [Switch] $Verifiable,
        [ScriptBlock] $ParameterFilter,
        [Parameter(Mandatory)]
        $Hook,
        [string[]]$RemoveParameterType,
        [string[]]$RemoveParameterValidation
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-MockObject`

**Signature:**
```powershell
function New-MockObject {
    <#
    .SYNOPSIS
    This function instantiates a .NET object from a type.

    .DESCRIPTION
    Using the New-MockObject you can mock an object based on .NET type.

    An .NET assembly for the particular type must be available in the system and loaded.

    .PARAMETER Type
    The .NET type to create. This creates the object without calling any of its constructors or initializers. Use this to instantiate an object that does not have a public constructor. If your object has a constructor, or is giving you errors, try using the constructor and provide the object using the InputObject parameter to decorate it.

    .PARAMETER InputObject
    An already constructed object to decorate. Use `New-Object` or `[typeName]::new()` to create it.

    .PARAMETER Properties
    Properties to define, specified as a hashtable, in format `@{ PropertyName = value }`.
```

**Description:**

file src\functions\New-MockObject.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-OneTimeBlockSetup`

**Signature:**
```powershell
function New-OneTimeBlockSetup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock
    )
```

**Description:**

endpoint for adding a setup for all blocks in the current block

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-OneTimeBlockTeardown`

**Signature:**
```powershell
function New-OneTimeBlockTeardown {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock
    )
```

**Description:**

endpoint for adding a teardown for all clocks in the current block

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-OneTimeTestSetup`

**Signature:**
```powershell
function New-OneTimeTestSetup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock
    )
```

**Description:**

endpoint for adding a setup for all tests in the block

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-OneTimeTestTeardown`

**Signature:**
```powershell
function New-OneTimeTestTeardown {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock
    )
```

**Description:**

endpoint for adding a teardown for all tests in the block

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-ParametrizedBlock`

**Signature:**
```powershell
function New-ParametrizedBlock {
    param (
        [Parameter(Mandatory = $true)]
        [String] $Name,
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock,
        [int] $StartLine = $MyInvocation.ScriptLineNumber,
        [int] $StartColumn = $MyInvocation.OffsetInLine,
        [String[]] $Tag = @(),
        [HashTable] $FrameworkData = @{ },
        [Switch] $Focus,
        [Switch] $Skip,
        $Data
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-ParametrizedTest`

**Signature:**
```powershell
function New-ParametrizedTest () {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String] $Name,
        [Parameter(Mandatory = $true, Position = 1)]
        [ScriptBlock] $ScriptBlock,
        [int] $StartLine = $MyInvocation.ScriptLineNumber,
        [int] $StartColumn = $MyInvocation.OffsetInLine,
        [String[]] $Tag = @(),
        # do not use [hashtable[]] because that throws away the order if user uses [ordered] hashtable
        [object[]] $Data,
        [Switch] $Focus,
        [Switch] $Skip
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-PesterConfiguration`

**Signature:**
```powershell
function New-PesterConfiguration {
    <#
    .SYNOPSIS
    Creates a new PesterConfiguration object for advanced configuration of Invoke-Pester.

    .DESCRIPTION
    The New-PesterConfiguration function creates a new PesterConfiguration-object
    to enable advanced configurations for runnings tests using Invoke-Pester.

    Without parameters, the function generates a configuration-object with default
    options. The returned PesterConfiguration-object can be modified to suit your
    requirements.

    Calling New-PesterConfiguration is equivalent to calling [PesterConfiguration]::Default which was used in early versions of Pester 5.

    For a complete list of options, see `Get-Help about_PesterConfiguration` or https://pester.dev/docs/v5/usage/configuration

    .PARAMETER Hashtable
    Override the default values for the options defined in the provided dictionary/hashtable.
    See about_PesterConfiguration help topic or inspect a PesterConfiguration-object to learn about the schema and
    available options.

    .EXAMPLE
    ```powershell
    $config = New-PesterConfiguration
    $config.Run.PassThru = $true

    Invoke-Pester -Configuration $config
    ```

    Creates a default PesterConfiguration-object and changes the Run.PassThru option
    to return the result object after the test run. The configuration object is
    provided to Invoke-Pester to alter the default behaviour.

    .EXAMPLE
    ```powershell
    $MyOptions = @{
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-PesterContainer`

**Signature:**
```powershell
function New-PesterContainer {
    <#
    .SYNOPSIS
    Generates ContainerInfo-objects used as for Invoke-Pester -Container

    .DESCRIPTION
    Pester 5 supports running tests files and scriptblocks using parameter-input.
    To use this feature, Invoke-Pester expects one or more ContainerInfo-objects
    created using this function, that specify test containers in the form of paths
    to the test files or scriptblocks containing the tests directly.

    A optional Data-dictionary can be provided to supply the containers with any
    required parameter-values. This is useful in when tests are generated dynamically
    based on parameter-input. This method enables complex test-solutions while being
    able to re-use a lot of test-code.

    .PARAMETER Path
    Specifies one or more paths to files containing tests. The value is a path\file
    name or name pattern. Wildcards are permitted.

    .PARAMETER ScriptBlock
    Specifies one or more scriptblocks containing tests.

    .PARAMETER Data
    Allows a dictionary to be provided with parameter-values that should be used during
    execution of the test containers defined in Path or ScriptBlock.

    .EXAMPLE
    ```powershell
    $container = New-PesterContainer -Path 'CodingStyle.Tests.ps1' -Data @{ File = "Get-Emoji.ps1" }
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-PesterOption`

**Signature:**
```powershell
function New-PesterOption {
    #TODO: move those options, right now I am just not exposing this function and added the testSuiteName
    <#
    .SYNOPSIS
    Creates an object that contains advanced options for Invoke-Pester
    .DESCRIPTION
    By using New-PesterOption you can set options what allow easier integration with external applications or
    modifies output generated by Invoke-Pester.
    The result of New-PesterOption need to be assigned to the parameter 'PesterOption' of the Invoke-Pester function.
    .PARAMETER IncludeVSCodeMarker
    When this switch is set, an extra line of output will be written to the console for test failures, making it easier
    for VSCode's parser to provide highlighting / tooltips on the line where the error occurred.
    .PARAMETER TestSuiteName
    When generating NUnit XML output, this controls the name assigned to the root "test-suite" element.  Defaults to "Pester".
    .PARAMETER ScriptBlockFilter
    Filters scriptblock based on the path and line number. This is intended for integration with external tools so we don't rely on names (strings) that can have expandable variables in them.
    .PARAMETER Experimental
    Enables experimental features of Pester to be enabled.
    .PARAMETER ShowScopeHints
    EXPERIMENTAL: Enables debugging output for debugging transitions among scopes. (Experimental flag needs to be used to enable this.)

    .INPUTS
    None
    You cannot pipe input to this command.
    .OUTPUTS
    System.Management.Automation.PSObject
    .EXAMPLE
        PS > $Options = New-PesterOption -TestSuiteName "Tests - Set A"

        PS > Invoke-Pester -PesterOption $Options -Outputfile ".\Results-Set-A.xml" -OutputFormat NUnitXML

        The result of commands will be execution of tests and saving results of them in a NUnitMXL file where the root "test-suite"
        will be named "Tests - Set A".
    .LINK
    https://github.com/pester/Pester/wiki/New-PesterOption

    .LINK
    Invoke-Pester
    #>
    [CmdletBinding()]
    param (
        [switch] $IncludeVSCodeMarker,

        [ValidateNotNullOrEmpty()]
        [string] $TestSuiteName = 'Pester',

        [switch] $Experimental,

        [switch] $ShowScopeHints,

        [hashtable[]] $ScriptBlockFilter
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-PesterState`

**Signature:**
```powershell
function New-PesterState {
    $o = [PSCustomObject] @{
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-PluginObject`

**Signature:**
```powershell
function New-PluginObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String] $Name,
        [Hashtable] $Configuration,
        [ScriptBlock] $Start,
        [ScriptBlock] $DiscoveryStart,
        [ScriptBlock] $ContainerDiscoveryStart,
        [ScriptBlock] $BlockDiscoveryStart,
        [ScriptBlock] $TestDiscoveryStart,
        [ScriptBlock] $TestDiscoveryEnd,
        [ScriptBlock] $BlockDiscoveryEnd,
        [ScriptBlock] $ContainerDiscoveryEnd,
        [ScriptBlock] $DiscoveryEnd,
        [ScriptBlock] $RunStart,
        [scriptblock] $ContainerRunStart,
        [ScriptBlock] $OneTimeBlockSetupStart,
        [ScriptBlock] $EachBlockSetupStart,
        [ScriptBlock] $OneTimeTestSetupStart,
        [ScriptBlock] $EachTestSetupStart,
        [ScriptBlock] $EachTestTeardownEnd,
        [ScriptBlock] $OneTimeTestTeardownEnd,
        [ScriptBlock] $EachBlockTeardownEnd,
        [ScriptBlock] $OneTimeBlockTeardownEnd,
        [ScriptBlock] $ContainerRunEnd,
        [ScriptBlock] $RunEnd,
        [ScriptBlock] $End
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-RandomTempDirectory`

**Signature:**
```powershell
function New-RandomTempDirectory {
    do {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-RandomTempRegistry`

**Signature:**
```powershell
function New-RandomTempRegistry {
    do {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-ShouldErrorRecord`

**Signature:**
```powershell
function New-ShouldErrorRecord ([string] $Message, [string] $File, [string] $Line, [string] $LineText, $Terminating) {
    $exception = [Exception] $Message
    $errorID = 'PesterAssertionFailed'
    $errorCategory = [Management.Automation.ErrorCategory]::InvalidResult
    # we use ErrorRecord.TargetObject to pass structured information about the error to a reporting system.
    $targetObject = @{ Message = $Message; File = $File; Line = $Line; LineText = $LineText; Terminating = $Terminating }
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-Test`

**Signature:**
```powershell
function New-Test {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String] $Name,
        [Parameter(Mandatory = $true, Position = 1)]
        [ScriptBlock] $ScriptBlock,
        [int] $StartLine = $MyInvocation.ScriptLineNumber,
        [String[]] $Tag = @(),
        $Data,
        [String] $GroupId,
        [Switch] $Focus,
        [Switch] $Skip
    )
```

**Description:**

endpoint for adding a test

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-TestDrive`

**Signature:**
```powershell
function New-TestDrive {
    param(
        [string] $Path
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `New-TestRegistry`

**Signature:**
```powershell
function New-TestRegistry {
    param(
        [string] $Path
    )
```

**Description:**

file src\functions\TestRegistry.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `none`

**Signature:**
```powershell
function none ($InputObject) {
    -not (any $InputObject)
}

function defined {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Normalize-Path`

**Signature:**
```powershell
function Normalize-Path {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('PSPath', 'FullName')]
        [string[]] $Path
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `notDefined`

**Signature:**
```powershell
function notDefined {
    param(
        [Parameter(Mandatory)]
        [String] $Name
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldBeExactlyFailureMessage`

**Signature:**
```powershell
function NotShouldBeExactlyFailureMessage($ActualValue, $ExpectedValue, $Because) {
    return "Expected $(Format-Nicely $ExpectedValue) to be different from the actual value,$(if ($null -ne $Because) { Format-Because $Because }) but got exactly the same value."
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldBeFailureMessage`

**Signature:**
```powershell
function NotShouldBeFailureMessage($ActualValue, $ExpectedValue, $Because) {
    return "Expected $(Format-Nicely $ExpectedValue) to be different from the actual value,$(if ($null -ne $Because) { Format-Because $Because }) but got the same value."
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldBeFalseFailureMessage`

**Signature:**
```powershell
function NotShouldBeFalseFailureMessage($ActualValue) {
}
# file src\functions\assertions\Contain.ps1
function Should-Contain($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldBeGreaterOrEqualFailureMessage`

**Signature:**
```powershell
function NotShouldBeGreaterOrEqualFailureMessage() {
}
# file src\functions\assertions\BeLike.ps1
function Should-BeLike($ActualValue, $ExpectedValue, [switch] $Negate, [String] $Because) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldBeGreaterThanFailureMessage`

**Signature:**
```powershell
function NotShouldBeGreaterThanFailureMessage() {
}

function ShouldBeLessOrEqualFailureMessage() {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldBeInFailureMessage`

**Signature:**
```powershell
function NotShouldBeInFailureMessage() {
}
# file src\functions\assertions\BeLessThan.ps1
function Should-BeLessThan($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldBeLessOrEqualFailureMessage`

**Signature:**
```powershell
function NotShouldBeLessOrEqualFailureMessage() {
}
# file src\functions\assertions\BeIn.ps1
function Should-BeIn($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldBeLessThanFailureMessage`

**Signature:**
```powershell
function NotShouldBeLessThanFailureMessage() {
}

function ShouldBeGreaterOrEqualFailureMessage() {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldBeLikeExactlyFailureMessage`

**Signature:**
```powershell
function NotShouldBeLikeExactlyFailureMessage() {
}
# file src\functions\assertions\BeNullOrEmpty.ps1

function Should-BeNullOrEmpty($ActualValue, [switch] $Negate, [string] $Because) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldBeLikeFailureMessage`

**Signature:**
```powershell
function NotShouldBeLikeFailureMessage() {
}
# file src\functions\assertions\BeLikeExactly.ps1
function Should-BeLikeExactly($ActualValue, $ExpectedValue, [switch] $Negate, [String] $Because) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldBeNullOrEmptyFailureMessage`

**Signature:**
```powershell
function NotShouldBeNullOrEmptyFailureMessage ($Because) {
    return "Expected a value,$(Format-Because $Because) but got `$null or empty."
}

& $script:SafeCommands['Add-ShouldOperator'] -Name BeNullOrEmpty `
    -InternalName       Should-BeNullOrEmpty `
    -Test               ${function:Should-BeNullOrEmpty} `
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldBeOfTypeFailureMessage`

**Signature:**
```powershell
function NotShouldBeOfTypeFailureMessage() {
}
# file src\functions\assertions\BeTrueOrFalse.ps1
function Should-BeTrue($ActualValue, [switch] $Negate, [string] $Because) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldBeTrueFailureMessage`

**Signature:**
```powershell
function NotShouldBeTrueFailureMessage($ActualValue) {
}
function ShouldBeFalseFailureMessage($ActualValue) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldContainFailureMessage`

**Signature:**
```powershell
function NotShouldContainFailureMessage() {
}
# file src\functions\assertions\Exist.ps1
function Should-Exist($ActualValue, [switch] $Negate, [string] $Because) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldExistFailureMessage`

**Signature:**
```powershell
function NotShouldExistFailureMessage() {
}
# file src\functions\assertions\FileContentMatch.ps1
function Should-FileContentMatch($ActualValue, $ExpectedContent, [switch] $Negate, $Because) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldFileContentMatchExactlyFailureMessage`

**Signature:**
```powershell
function NotShouldFileContentMatchExactlyFailureMessage($ActualValue, $ExpectedContent) {
    return "Expected $(Format-Nicely $ExpectedContent) to not be case sensitively found in file $(Format-Nicely $ActualValue),$(Format-Because $Because) but it was found."
}

& $script:SafeCommands['Add-ShouldOperator'] -Name FileContentMatchExactly `
    -InternalName Should-FileContentMatchExactly `
    -Test         ${function:Should-FileContentMatchExactly}
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldFileContentMatchFailureMessage`

**Signature:**
```powershell
function NotShouldFileContentMatchFailureMessage($ActualValue, $ExpectedContent, $Because) {
    return "Expected $(Format-Nicely $ExpectedContent) to not be found in file '$ActualValue',$(Format-Because $Because) but it was found."
}

& $script:SafeCommands['Add-ShouldOperator'] -Name FileContentMatch `
    -InternalName Should-FileContentMatch `
    -Test         ${function:Should-FileContentMatch}
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldFileContentMatchMultilineExactlyFailureMessage`

**Signature:**
```powershell
function NotShouldFileContentMatchMultilineExactlyFailureMessage($ActualValue, $ExpectedContent, $Because) {
    return "Expected $(Format-Nicely $ExpectedContent) to not be case sensitively found in file $(Format-Nicely $ActualValue),$(Format-Because $Because) but it was found."
}

& $script:SafeCommands['Add-ShouldOperator'] -Name FileContentMatchMultilineExactly `
    -InternalName Should-FileContentMatchMultilineExactly `
    -Test         ${function:Should-FileContentMatchMultilineExactly}
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldFileContentMatchMultilineFailureMessage`

**Signature:**
```powershell
function NotShouldFileContentMatchMultilineFailureMessage($ActualValue, $ExpectedContent, $Because) {
    return "Expected $(Format-Nicely $ExpectedContent) to not be found in file $(Format-Nicely $ActualValue),$(Format-Because $Because) but it was found."
}

& $script:SafeCommands['Add-ShouldOperator'] -Name FileContentMatchMultiline `
    -InternalName Should-FileContentMatchMultiline `
    -Test         ${function:Should-FileContentMatchMultiline}
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldHaveCountFailureMessage`

**Signature:**
```powershell
function NotShouldHaveCountFailureMessage() {
}
# file src\functions\assertions\HaveParameter.ps1
function Should-HaveParameter (
    $ActualValue,
    [String] $ParameterName,
    $Type,
    [String] $DefaultValue,
    [Switch] $Mandatory,
    [String] $InParameterSet,
    [Switch] $HasArgumentCompleter,
    [String[]] $Alias,
    [Switch] $Negate,
    [String] $Because ) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldMatchExactlyFailureMessage`

**Signature:**
```powershell
function NotShouldMatchExactlyFailureMessage($ActualValue, $RegularExpression) {
    return "Expected regular expression $(Format-Nicely $RegularExpression) to not case sensitively match $(Format-Nicely $ActualValue),$(Format-Because $Because) but it did match."
}

& $script:SafeCommands['Add-ShouldOperator'] -Name MatchExactly `
    -InternalName Should-MatchExactly `
    -Test         ${function:Should-MatchExactly} `
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldMatchFailureMessage`

**Signature:**
```powershell
function NotShouldMatchFailureMessage($ActualValue, $RegularExpression, $Because) {
    return "Expected regular expression $(Format-Nicely $RegularExpression) to not match $(Format-Nicely $ActualValue),$(Format-Because $Because) but it did match."
}

& $script:SafeCommands['Add-ShouldOperator'] -Name Match `
    -InternalName Should-Match `
    -Test         ${function:Should-Match}
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `NotShouldThrowFailureMessage`

**Signature:**
```powershell
function NotShouldThrowFailureMessage {
    # to make the should tests happy, for now
}

& $script:SafeCommands['Add-ShouldOperator'] -Name Throw `
    -InternalName Should-Throw `
    -Test         ${function:Should-Throw}
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `or`

**Signature:**
```powershell
function or {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $DefaultValue,
        [Parameter(ValueFromPipeline = $true)]
        $InputObject
    )
```

**Description:**

file src\Pester.Utility.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `PostProcess-DiscoveredBlock`

**Signature:**
```powershell
function PostProcess-DiscoveredBlock {
    param (
        [Parameter(Mandatory = $true)]
        $Block,
        $Filter,
        $BlockContainer,
        [Parameter(Mandatory = $true)]
        $RootBlock
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `PostProcess-ExecutedBlock`

**Signature:**
```powershell
function PostProcess-ExecutedBlock {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Block
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `PostProcess-RspecTestRun`

**Signature:**
```powershell
function PostProcess-RspecTestRun ($TestRun) {
    $discoveryOnly = $PesterPreference.Run.SkipRun.Value

    Fold-Run $Run -OnTest {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `PrivateFunction`

**Signature:**
```powershell
function PrivateFunction {
        return $true
    }

    Export-ModuleMember -Function PublicFunction

    # The test script:

    Import-Module MyModule

    InModuleScope MyModule {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `PSConsoleHostReadLine`

**Signature:**
```powershell
function PSConsoleHostReadLine
{
```

<sub>**Source:** `Modules\PSReadLine\2.4.5\PSReadLine.psm1`</sub>

### `PublicFunction`

**Signature:**
```powershell
function PublicFunction {
        # Does something
    }

    function PrivateFunction {
```

**Description:**

The script module:

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Recurse-Up`

**Signature:**
```powershell
function Recurse-Up {
    param(
        [Parameter(Mandatory)]
        $InputObject,
        [ScriptBlock] $Action
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `RegisterBuiltinCompleters`

**Signature:**
```powershell
function RegisterBuiltinCompleters {
    $processIdOrNameScriptBlock = {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.psm1`</sub>

### `Remove-MockFunctionsAndAliases`

**Signature:**
```powershell
function Remove-MockFunctionsAndAliases ($SessionState) {
    # when a test is terminated (e.g. by stopping at a breakpoint and then stopping the execution of the script)
    # the aliases and bootstrap functions for the currently mocked functions will remain in place
    # Then on subsequent runs the bootstrap function will be picked up instead of the real command,
    # because there is still an alias associated with it, and the test will fail.
    # So before putting Pester state in place we should make sure that all Pester mocks are gone
    # by deleting every alias pointing to a function that starts with PesterMock_. Then we also delete the
    # bootstrap function.
    #
    # Avoid using Get-Command to find mock functions, it is slow. https://github.com/pester/Pester/discussions/2331
    $Get_Alias = $script:SafeCommands['Get-Alias']
    $Get_ChildItem = $script:SafeCommands['Get-ChildItem']
    $Remove_Item = $script:SafeCommands['Remove-Item']
    foreach ($alias in (& $Get_Alias -Definition "PesterMock_*")) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Remove-MockHook`

**Signature:**
```powershell
function Remove-MockHook {
    param (
        [Parameter(Mandatory)]
        $Hooks
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Remove-RSpecNonPublicProperties`

**Signature:**
```powershell
function Remove-RSpecNonPublicProperties ($run) {
    # $runProperties = @(
    #     'Configuration'
    #     'Containers'
    #     'ExecutedAt'
    #     'FailedBlocksCount'
    #     'FailedCount'
    #     'NotRunCount'
    #     'PassedCount'
    #     'PSBoundParameters'
    #     'Result'
    #     'SkippedCount'
    #     'TotalCount'
    #     'Duration'
    # )

    # $containerProperties = @(
    #     'Blocks'
    #     'Content'
    #     'ErrorRecord'
    #     'Executed'
    #     'ExecutedAt'
    #     'FailedCount'
    #     'NotRunCount'
    #     'PassedCount'
    #     'Result'
    #     'ShouldRun'
    #     'Skip'
    #     'SkippedCount'
    #     'Duration'
    #     'Type' # needed because of nunit export path expansion
    #     'TotalCount'
    # )

    # $blockProperties = @(
    #     'Blocks'
    #     'ErrorRecord'
    #     'Executed'
    #     'ExecutedAt'
    #     'FailedCount'
    #     'Name'
    #     'NotRunCount'
    #     'PassedCount'
    #     'Path'
    #     'Result'
    #     'ScriptBlock'
    #     'ShouldRun'
    #     'Skip'
    #     'SkippedCount'
    #     'StandardOutput'
    #     'Tag'
    #     'Tests'
    #     'Duration'
    #     'TotalCount'
    # )

    # $testProperties = @(
    #     'Data'
    #     'ErrorRecord'
    #     'Executed'
    #     'ExecutedAt'
    #     'ExpandedName'
    #     'Id' # needed because of grouping of data driven tests in nunit export
    #     'Name'
    #     'Path'
    #     'Result'
    #     'ScriptBlock'
    #     'ShouldRun'
    #     'Skip'
    #     'Skipped'
    #     'StandardOutput'
    #     'Tag'
    #     'Duration'
    # )

    Fold-Run $run -OnRun {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Remove-TestDrive`

**Signature:**
```powershell
function Remove-TestDrive ($TestDrivePath) {
    $DriveName = 'TestDrive'
    $Drive = & $SafeCommands['Get-PSDrive'] -Name $DriveName -ErrorAction Ignore
    $Path = ($Drive).Root

    if ($pwd -like "$DriveName*") {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Remove-TestDriveSymbolicLinks`

**Signature:**
```powershell
function Remove-TestDriveSymbolicLinks ([String] $Path) {

    # remove symbolic links to work around problem with Remove-Item.
    # see https://github.com/PowerShell/PowerShell/issues/621
    #     https://github.com/pester/Pester/issues/1100

    # powershell 5 and higher
    # & $SafeCommands["Get-ChildItem"] -Recurse -Path $Path -Attributes "ReparsePoint" |
    #    % { $_.Delete() }
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Remove-TestRegistry`

**Signature:**
```powershell
function Remove-TestRegistry ($TestRegistryPath) {
    $DriveName = 'TestRegistry'
    $Drive = & $SafeCommands['Get-PSDrive'] -Name $DriveName -ErrorAction Ignore
    if ($null -eq $Drive) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `RemoveGitKeyBindings`

**Signature:**
```powershell
function RemoveGitKeyBindings() {
    $script:GitKeyHandlers | ForEach-Object {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Git.ps1`</sub>

### `Repair-ConflictingParameters`

**Signature:**
```powershell
function Repair-ConflictingParameters {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.CommandMetadata])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.CommandMetadata]
        $Metadata,
        [Parameter()]
        [string[]]
        $RemoveParameterType,
        [Parameter()]
        [string[]]
        $RemoveParameterValidation
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Repair-EnumParameters`

**Signature:**
```powershell
function Repair-EnumParameters {
    param (
        [string]
        $ParamBlock,
        [System.Management.Automation.CommandMetadata]
        $Metadata
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Replace-PSConsoleReadLineText`

**Signature:**
```powershell
function Replace-PSConsoleReadLineText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int] $Start,
        [Parameter(Mandatory = $true)]
        [int] $Length,
        [Parameter(Mandatory = $true)]
        [string] $ReplacementText
    )
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.PSConsoleReadLineWrappers.ps1`</sub>

### `ReplaceValueInArray`

**Signature:**
```powershell
function ReplaceValueInArray {
    param (
        [object[]] $Array,
        [object] $Value,
        [object] $NewValue
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Reset-ConflictingParameters`

**Signature:**
```powershell
function Reset-ConflictingParameters {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]
        $BoundParameters
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Reset-PerContainerState`

**Signature:**
```powershell
function Reset-PerContainerState {
    param(
        [Parameter(Mandatory = $true)]
        $RootBlock
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Reset-TestSuiteTimer`

**Signature:**
```powershell
function Reset-TestSuiteTimer ($o) {

}

function Switch-Timer {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Resolve-CodeCoverageConfiguration`

**Signature:**
```powershell
function Resolve-CodeCoverageConfiguration {
    $supportedFormats = 'JaCoCo', 'CoverageGutters', 'Cobertura'
    if ($PesterPreference.CodeCoverage.OutputFormat.Value -notin $supportedFormats) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Resolve-Command`

**Signature:**
```powershell
function Resolve-Command {
    param (
        [string] $CommandName,
        [string] $ModuleName,
        [Parameter(Mandatory)]
        [Management.Automation.SessionState] $SessionState
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Resolve-CoverageInfo`

**Signature:**
```powershell
function Resolve-CoverageInfo {
    param ([psobject] $UnresolvedCoverageInfo)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Resolve-OutputConfiguration`

**Signature:**
```powershell
function Resolve-OutputConfiguration ([PesterConfiguration]$PesterPreference) {
    $supportedVerbosity = 'None', 'Normal', 'Detailed', 'Diagnostic'
    if ($PesterPreference.Output.Verbosity.Value -notin $supportedVerbosity) {
```

**Description:**

This is not a plugin-step due to Output-features being dependencies in Invoke-PluginStep etc for error/debug Output-options are also used for Write-PesterDebugMessage which is independent of WriteScreenPlugin

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Resolve-SkipRemainingOnFailureConfiguration`

**Signature:**
```powershell
function Resolve-SkipRemainingOnFailureConfiguration {
    $supportedValues = 'None', 'Block', 'Container', 'Run'
    if ($PesterPreference.Run.SkipRemainingOnFailure.Value -notin $supportedValues) {
```

**Description:**

file src\functions\Get-SkipRemainingOnFailurePlugin.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Resolve-TestResultConfiguration`

**Signature:**
```powershell
function Resolve-TestResultConfiguration {
    $supportedFormats = 'NUnitXml', 'NUnit2.5', 'NUnit3', 'JUnitXml'
    if ($PesterPreference.TestResult.OutputFormat.Value -notin $supportedFormats) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ResolveTestScripts`

**Signature:**
```powershell
function ResolveTestScripts {
    param ([object[]] $Path)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Run-Test`

**Signature:**
```powershell
function Run-Test {
    param (
        [Parameter(Mandatory = $true)]
        [PSObject[]] $Block,
        [Parameter(Mandatory = $true)]
        [Management.Automation.SessionState] $SessionState
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `script`

**Signature:**
```powershell
function script:PrepareArg($argStr) {
	if (-not $argStr.EndsWith("\\") -and $argStr.EndsWith('\')) {
```

**Description:**

if the quoted string ends with a '\', and we need to escape it for Windows:

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `Set-CurrentBlock`

**Signature:**
```powershell
function Set-CurrentBlock {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Block
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Set-CurrentTest`

**Signature:**
```powershell
function Set-CurrentTest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Test
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Set-DynamicParameterVariable`

**Signature:**
```powershell
function Set-DynamicParameterVariable {
    <#
        .SYNOPSIS
        This command is used by Pester's Mocking framework.  You do not need to call it directly.
    #>

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SessionState]
        $SessionState,

        [hashtable]
        $Parameters,

        [System.Management.Automation.CommandMetadata]
        $Metadata
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Set-Hint`

**Signature:**
```powershell
function Set-Hint {
    param(
        [Parameter(Mandatory = $true)]
        [String] $Hint,
        [Parameter(Mandatory = $true)]
        $InputObject,
        [Switch] $Force
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Set-ItResult`

**Signature:**
```powershell
function Set-ItResult {
    <#
    .SYNOPSIS
    Set-ItResult is used inside the It block to explicitly set the test result

    .DESCRIPTION
    Sometimes a test shouldn't be executed, sometimes the condition cannot be evaluated.
    By default such tests would typically fail and produce a big red message.
    Using Set-ItResult it is possible to set the result from the inside of the It script
    block to either inconclusive, pending or skipped.

    As of Pester 5, there is no "Inconclusive" or "Pending" test state, so all tests will now go to state skipped,
    however the test result notes will include information about being inconclusive or testing to keep this command
    backwards compatible

    .PARAMETER Inconclusive
    Sets the test result to inconclusive. Cannot be used at the same time as -Pending or -Skipped

    .PARAMETER Pending
    **DEPRECATED** Sets the test result to pending. Cannot be used at the same time as -Inconclusive or -Skipped

    .PARAMETER Skipped
    Sets the test result to skipped. Cannot be used at the same time as -Inconclusive or -Pending

    .PARAMETER Because
    Similarly to failing tests, skipped and inconclusive tests should have reason. It allows
    to provide information to the user why the test is neither successful nor failed.

    .EXAMPLE
    ```powershell
    Describe "Example" {
```

**Description:**

file src\functions\Set-ItResult.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Set-LocationFuzzyEverything`

**Signature:**
```powershell
function Set-LocationFuzzyEverything() {
        param($Directory = $null)
```

**Description:**

.ExternalHelp PSFzf.psm1-help.xml

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Functions.ps1`</sub>

### `Set-PesterStatistics`

**Signature:**
```powershell
function Set-PesterStatistics($Node) {
    if ($null -eq $Node) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Set-PsFzfOption`

**Signature:**
```powershell
function Set-PsFzfOption {
	param(
		[switch]
		$TabExpansion,
		[string]
		$PSReadlineChordProvider,
		[string]
		$PSReadlineChordReverseHistory,
		[string]
		$PSReadlineChordSetLocation,
		[string]
		$PSReadlineChordReverseHistoryArgs,
		[switch]
		$GitKeyBindings,
		[switch]
		$EnableAliasFuzzyEdit,
		[switch]
		$EnableAliasFuzzyFasd,
		[switch]
		$EnableAliasFuzzyHistory,
		[switch]
		$EnableAliasFuzzyKillProcess,
		[switch]
		$EnableAliasFuzzySetLocation,
		[switch]
		$EnableAliasFuzzyScoop,
		[switch]
		$EnableAliasFuzzySetEverything,
		[switch]
		$EnableAliasFuzzyZLocation,
		[switch]
		$EnableAliasFuzzyGitStatus,
		[switch]
		$EnableFd,
		[string]
		$TabContinuousTrigger,
		[ScriptBlock]
		$AltCCommand
	)
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `Set-RemainingAsSkipped`

**Signature:**
```powershell
function Set-RemainingAsSkipped {
    param(
        [Parameter(Mandatory)]
        [Pester.Test]
        $FailedTest,

        [Parameter(Mandatory)]
        [Pester.Block]
        $Block
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Set-ScriptBlockHint`

**Signature:**
```powershell
function Set-ScriptBlockHint {
    param(
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock,
        [string] $Hint
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Set-ScriptBlockScope`

**Signature:**
```powershell
function Set-ScriptBlockScope {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock,

        [Parameter(Mandatory = $true, ParameterSetName = 'FromSessionState')]
        [System.Management.Automation.SessionState]
        $SessionState,

        [Parameter(Mandatory = $true, ParameterSetName = 'FromSessionStateInternal')]
        [AllowNull()]
        $SessionStateInternal
    )
```

**Description:**

file src\functions\Pester.Scoping.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Set-SessionStateHint`

**Signature:**
```powershell
function Set-SessionStateHint {
    param(
        [Parameter(Mandatory = $true)]
        [String] $Hint,
        [Parameter(Mandatory = $true)]
        [Management.Automation.SessionState] $SessionState,
        [Switch] $PassThru
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Set-ShouldOperatorHelpMessage`

**Signature:**
```powershell
function Set-ShouldOperatorHelpMessage {
    <#
    .SYNOPSIS
    Sets the helpmessage for a Should-operator. Used in Should's online help for the switch-parameter.
    .PARAMETER OperatorName
    The name of the assertion/operator.
    .PARAMETER HelpMessage
    Help message for switch-parameter for the operator in Should.
    .NOTES
    Internal function as it's only useful for built-in Should operators/assertion atm. to improve online docs.
    Can be merged into Add-ShouldOperator later if we'd like to make it pulic and include value in Get-ShouldOperator

    https://github.com/pester/Pester/issues/2335
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $OperatorName,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $HelpMessage
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `SetGitKeyBindings`

**Signature:**
```powershell
function SetGitKeyBindings($enable) {
    if ($enable) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Git.ps1`</sub>

### `SetPsReadlineShortcut`

**Signature:**
```powershell
function SetPsReadlineShortcut($Chord, [switch]$Override, $BriefDesc, $Desc, [scriptblock]$scriptBlock) {
	if ([string]::IsNullOrEmpty($Chord)) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `SetTabExpansion`

**Signature:**
```powershell
function SetTabExpansion($enable) {
    if ($enable) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.psm1`</sub>

### `SetupGitPaths`

**Signature:**
```powershell
function SetupGitPaths() {
    if (-not $script:foundGit) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Git.ps1`</sub>

### `Should`

**Signature:**
```powershell
function Should {
    <#
    .SYNOPSIS
    Should is a keyword that is used to define an assertion inside an It block.

    .DESCRIPTION
    Should is a keyword that is used to define an assertion inside an It block.
    Should provides assertion methods to verify assertions e.g. comparing objects.
    If assertion is not met the test fails and an exception is thrown.

    Should can be used more than once in the It block if more than one assertion
    need to be verified. Each Should keyword needs to be on a separate line.
    Test will be passed only when all assertion will be met (logical conjunction).

    .PARAMETER ActualValue
    The actual value that was obtained in the test which should be verified against
    a expected value.

    .EXAMPLE
    ```powershell
    Describe "d1" {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-Be`

**Signature:**
```powershell
function Should-Be ($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
    <#
    .SYNOPSIS
    Compares one object with another for equality
    and throws if the two objects are not the same.

    .EXAMPLE
    $actual = "Actual value"
    $actual | Should -Be "actual value"

    This test will pass. -Be is not case sensitive.
    For a case sensitive assertion, see -BeExactly.

    .EXAMPLE
    $actual = "Actual value"
    $actual | Should -Be "not actual value"

    This test will fail, as the two strings are not identical.
    #>
    [bool] $succeeded = ArraysAreEqual $ActualValue $ExpectedValue

    if ($Negate) {
```

**Description:**

file src\functions\assertions\Be.ps1 Be

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-BeExactly`

**Signature:**
```powershell
function Should-BeExactly($ActualValue, $ExpectedValue, $Because) {
    <#
    .SYNOPSIS
    Compares one object with another for equality and throws if the
    two objects are not the same. This comparison is case sensitive.

    .EXAMPLE
    $actual = "Actual value"
    $actual | Should -Be "Actual value"

    This test will pass. The two strings are identical.

    .EXAMPLE
    $actual = "Actual value"
    $actual | Should -Be "actual value"

    This test will fail, as the two strings do not match case sensitivity.
    #>
    [bool] $succeeded = ArraysAreEqual $ActualValue $ExpectedValue -CaseSensitive

    if ($Negate) {
```

**Description:**

BeExactly

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-BeFalse`

**Signature:**
```powershell
function Should-BeFalse($ActualValue, [switch] $Negate, $Because) {
    <#
    .SYNOPSIS
    Asserts that the value is false, or falsy.

    .EXAMPLE
    $false | Should -BeFalse

    This test passes. $false is false.

    .EXAMPLE
    0 | Should -BeFalse

    This test passes. 0 is false.

    .EXAMPLE
    $null | Should -BeFalse

    PowerShell does not enter a `If ($null) {}` block.
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-BeGreaterOrEqual`

**Signature:**
```powershell
function Should-BeGreaterOrEqual($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
    <#
    .SYNOPSIS
    Asserts that a number (or other comparable value) is greater than or equal to an expected value.
    Uses PowerShell's -ge operator to compare the two values.

    .EXAMPLE
    2 | Should -BeGreaterOrEqual 0

    This test passes, as PowerShell evaluates `2 -ge 0` as true.

    .EXAMPLE
    2 | Should -BeGreaterOrEqual 2

    This test also passes, as PowerShell evaluates `2 -ge 2` as true.
    #>
    if ($Negate) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-BeGreaterThan`

**Signature:**
```powershell
function Should-BeGreaterThan($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
    <#
    .SYNOPSIS
    Asserts that a number (or other comparable value) is greater than an expected value.
    Uses PowerShell's -gt operator to compare the two values.

    .EXAMPLE
    2 | Should -BeGreaterThan 0

    This test passes, as PowerShell evaluates `2 -gt 0` as true.
    #>
    if ($Negate) {
```

**Description:**

file src\functions\assertions\BeGreaterThan.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-BeIn`

**Signature:**
```powershell
function Should-BeIn($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
    <#
    .SYNOPSIS
    Asserts that a collection of values contain a specific value.
    Uses PowerShell's -contains operator to confirm.

    .EXAMPLE
    1 | Should -BeIn @(1,2,3,'a','b','c')

    This test passes, as 1 exists in the provided collection.
    #>
    [bool] $succeeded = $ExpectedValue -contains $ActualValue
    if ($Negate) {
```

**Description:**

file src\functions\assertions\BeIn.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-BeLessOrEqual`

**Signature:**
```powershell
function Should-BeLessOrEqual($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
    <#
    .SYNOPSIS
    Asserts that a number (or other comparable value) is lower than, or equal to an expected value.
    Uses PowerShell's -le operator to compare the two values.

    .EXAMPLE
    1 | Should -BeLessOrEqual 10

    This test passes, as PowerShell evaluates `1 -le 10` as true.

    .EXAMPLE
    10 | Should -BeLessOrEqual 10

    This test also passes, as PowerShell evaluates `10 -le 10` as true.
    #>
    if ($Negate) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-BeLessThan`

**Signature:**
```powershell
function Should-BeLessThan($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
    <#
    .SYNOPSIS
    Asserts that a number (or other comparable value) is lower than an expected value.
    Uses PowerShell's -lt operator to compare the two values.

    .EXAMPLE
    1 | Should -BeLessThan 10

    This test passes, as PowerShell evaluates `1 -lt 10` as true.
    #>
    if ($Negate) {
```

**Description:**

file src\functions\assertions\BeLessThan.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-BeLike`

**Signature:**
```powershell
function Should-BeLike($ActualValue, $ExpectedValue, [switch] $Negate, [String] $Because) {
    <#
    .SYNOPSIS
    Asserts that the actual value matches a wildcard pattern using PowerShell's -like operator.
    This comparison is not case-sensitive.

    .EXAMPLE
    $actual = "Actual value"
    $actual | Should -BeLike "actual *"

    This test will pass. -BeLike is not case sensitive.
    For a case sensitive assertion, see -BeLikeExactly.

    .EXAMPLE
    $actual = "Actual value"
    $actual | Should -BeLike "not actual *"

    This test will fail, as the first string does not match the expected value.
    #>
    [bool] $succeeded = $ActualValue -like $ExpectedValue
    if ($Negate) {
```

**Description:**

file src\functions\assertions\BeLike.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-BeLikeExactly`

**Signature:**
```powershell
function Should-BeLikeExactly($ActualValue, $ExpectedValue, [switch] $Negate, [String] $Because) {
    <#
    .SYNOPSIS
    Asserts that the actual value matches a wildcard pattern using PowerShell's -like operator.
    This comparison is case-sensitive.

    .EXAMPLE
    $actual = "Actual value"
    $actual | Should -BeLikeExactly "Actual *"

    This test will pass, as the string matches the provided pattern.

    .EXAMPLE
    $actual = "Actual value"
    $actual | Should -BeLikeExactly "actual *"

    This test will fail, as -BeLikeExactly is case-sensitive.
    #>
    [bool] $succeeded = $ActualValue -clike $ExpectedValue
    if ($Negate) {
```

**Description:**

file src\functions\assertions\BeLikeExactly.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-BeNullOrEmpty`

**Signature:**
```powershell
function Should-BeNullOrEmpty($ActualValue, [switch] $Negate, [string] $Because) {
    <#
    .SYNOPSIS
    Checks values for null or empty (strings).
    The static [String]::IsNullOrEmpty() method is used to do the comparison.

    .EXAMPLE
    $null | Should -BeNullOrEmpty

    This test will pass. $null is null.

    .EXAMPLE
    $null | Should -Not -BeNullOrEmpty

    This test will fail and throw an error.

    .EXAMPLE
    @() | Should -BeNullOrEmpty

    An empty collection will pass this test.

    .EXAMPLE
    ""  | Should -BeNullOrEmpty

    An empty string will pass this test.
    #>
    if ($null -eq $ActualValue -or $ActualValue.Count -eq 0) {
```

**Description:**

file src\functions\assertions\BeNullOrEmpty.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-BeOfType`

**Signature:**
```powershell
function Should-BeOfType($ActualValue, $ExpectedType, [switch] $Negate, [string]$Because) {
    <#
    .SYNOPSIS
    Asserts that the actual value should be an object of a specified type
    (or a subclass of the specified type) using PowerShell's -is operator.

    .EXAMPLE
    $actual = Get-Item $env:SystemRoot
    $actual | Should -BeOfType System.IO.DirectoryInfo

    This test passes, as $actual is a DirectoryInfo object.

    .EXAMPLE
    $actual | Should -BeOfType System.IO.FileSystemInfo

    This test passes, as DirectoryInfo's base class is FileSystemInfo.

    .EXAMPLE
    $actual | Should -HaveType System.IO.FileSystemInfo

    This test passes for the same reason, but uses the -HaveType alias instead.

    .EXAMPLE
    $actual | Should -BeOfType System.IO.FileInfo

    This test will fail, as FileInfo is not a base class of DirectoryInfo.
    #>
    if ($ExpectedType -is [string]) {
```

**Description:**

file src\functions\assertions\BeOfType.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-BeTrue`

**Signature:**
```powershell
function Should-BeTrue($ActualValue, [switch] $Negate, [string] $Because) {
    <#
    .SYNOPSIS
    Asserts that the value is true, or truthy.

    .EXAMPLE
    $true | Should -BeTrue

    This test passes. $true is true.

    .EXAMPLE
    1 | Should -BeTrue

    This test passes. 1 is true.

    .EXAMPLE
    1,2,3 | Should -BeTrue

    PowerShell does not enter a `If (-not @(1,2,3)) {}` block.
```

**Description:**

file src\functions\assertions\BeTrueOrFalse.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-Contain`

**Signature:**
```powershell
function Should-Contain($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
    <#
    .SYNOPSIS
    Asserts that collection contains a specific value.
    Uses PowerShell's -contains operator to confirm.

    .EXAMPLE
    1,2,3 | Should -Contain 1

    This test passes, as 1 exists in the provided collection.
    #>
    [bool] $succeeded = $ActualValue -contains $ExpectedValue
    if ($Negate) {
```

**Description:**

file src\functions\assertions\Contain.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-Exist`

**Signature:**
```powershell
function Should-Exist($ActualValue, [switch] $Negate, [string] $Because) {
    <#
    .SYNOPSIS
    Does not perform any comparison, but checks if the object calling Exist is present in a PS Provider.
    The object must have valid path syntax. It essentially must pass a Test-Path call.

    .EXAMPLE
    $actual = (Dir . )[0].FullName
    Remove-Item $actual
    $actual | Should -Exist

    `Should -Exist` calls Test-Path. Test-Path expects a file,
    returns $false because the file was removed, and fails the test.
    #>
    [bool] $succeeded = & $SafeCommands['Test-Path'] $ActualValue

    if ($Negate) {
```

**Description:**

file src\functions\assertions\Exist.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-FileContentMatch`

**Signature:**
```powershell
function Should-FileContentMatch($ActualValue, $ExpectedContent, [switch] $Negate, $Because) {
    <#
    .SYNOPSIS
    Checks to see if a file contains the specified text.
    This search is not case sensitive and uses regular expressions.

    .EXAMPLE
    Set-Content -Path TestDrive:\file.txt -Value 'I am a file.'
    'TestDrive:\file.txt' | Should -FileContentMatch 'I Am'

    Create a new file and verify its content. This test passes.
    The 'I Am' regular expression (RegEx) pattern matches against the txt file contents.
    For case-sensitivity, see FileContentMatchExactly.

    .EXAMPLE
    'TestDrive:\file.txt' | Should -FileContentMatch '^I.*file\.$'

    This RegEx pattern also matches against the "I am a file." string from Example 1.
    With a matching RegEx pattern, this test also passes.

    .EXAMPLE
    'TestDrive:\file.txt' | Should -FileContentMatch 'I Am Not'

    This test fails, as the RegEx pattern does not match "I am a file."

    .EXAMPLE
    'TestDrive:\file.txt' | Should -FileContentMatch 'I.am.a.file'

    This test passes, because "." in RegEx matches any character including a space.

    .EXAMPLE
    'TestDrive:\file.txt' | Should -FileContentMatch ([regex]::Escape('I.am.a.file'))

    Tip: Use [regex]::Escape("pattern") to match the exact text.
    This test fails, because "I am a file." != "I.am.a.file"
    #>
    $succeeded = (@(& $SafeCommands['Get-Content'] -Encoding UTF8 $ActualValue) -match $ExpectedContent).Count -gt 0

    if ($Negate) {
```

**Description:**

file src\functions\assertions\FileContentMatch.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-FileContentMatchExactly`

**Signature:**
```powershell
function Should-FileContentMatchExactly($ActualValue, $ExpectedContent, [switch] $Negate, [String] $Because) {
    <#
    .SYNOPSIS
    Checks to see if a file contains the specified text.
    This search is case sensitive and uses regular expressions to match the text.

    .EXAMPLE
    Set-Content -Path TestDrive:\file.txt -Value 'I am a file.'
    'TestDrive:\file.txt' | Should -FileContentMatchExactly 'I am'

    Create a new file and verify its content. This test passes.
    The 'I am' regular expression (RegEx) pattern matches against the txt file contents.

    .EXAMPLE
    'TestDrive:\file.txt' | Should -FileContentMatchExactly 'I Am'

    This test checks a case-sensitive pattern against the "I am a file." string from Example 1.
    Because the RegEx pattern fails to match, this test fails.
#>
    $succeeded = (@(& $SafeCommands['Get-Content'] -Encoding UTF8 $ActualValue) -cmatch $ExpectedContent).Count -gt 0

    if ($Negate) {
```

**Description:**

file src\functions\assertions\FileContentMatchExactly.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-FileContentMatchMultiline`

**Signature:**
```powershell
function Should-FileContentMatchMultiline($ActualValue, $ExpectedContent, [switch] $Negate, [String] $Because) {
    <#
    .SYNOPSIS
    As opposed to FileContentMatch and FileContentMatchExactly operators,
    FileContentMatchMultiline presents content of the file being tested as one string object,
    so that the expression you are comparing it to can consist of several lines.

    When using FileContentMatchMultiline operator, '^' and '$' represent the beginning and end
    of the whole file, instead of the beginning and end of a line.

    .EXAMPLE
    $Content = "I am the first line.`nI am the second line."
    Set-Content -Path TestDrive:\file.txt -Value $Content -NoNewline
    'TestDrive:\file.txt' | Should -FileContentMatchMultiline 'first line\.\r?\nI am'

    This regular expression (RegEx) pattern matches the file contents, and the test passes.

    .EXAMPLE
    'TestDrive:\file.txt' | Should -FileContentMatchMultiline '^I am the first.*\n.*second line\.$'

    Using the file from Example 1, this RegEx pattern also matches, and this test also passes.

    .EXAMPLE
    'TestDrive:\file.txt' | Should -FileContentMatchMultiline '^I am the first line\.$'

    FileContentMatchMultiline uses the '$' symbol to match the end of the file,
    not the end of any single line within the file. This test fails.
#>
    $succeeded = [bool] ((& $SafeCommands['Get-Content'] $ActualValue -Delimiter ([char]0)) -match $ExpectedContent)

    if ($Negate) {
```

**Description:**

file src\functions\assertions\FileContentMatchMultiline.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-FileContentMatchMultilineExactly`

**Signature:**
```powershell
function Should-FileContentMatchMultilineExactly($ActualValue, $ExpectedContent, [switch] $Negate, [String] $Because) {
    <#
    .SYNOPSIS
    As opposed to FileContentMatch and FileContentMatchExactly operators,
    FileContentMatchMultilineExactly presents content of the file being tested as one string object,
    so that the case sensitive expression you are comparing it to can consist of several lines.

    When using FileContentMatchMultilineExactly operator, '^' and '$' represent the beginning and end
    of the whole file, instead of the beginning and end of a line.

    .EXAMPLE
    $Content = "I am the first line.`nI am the second line."
    Set-Content -Path TestDrive:\file.txt -Value $Content -NoNewline
    'TestDrive:\file.txt' | Should -FileContentMatchMultilineExactly "first line.`nI am"

    This specified content across multiple lines case sensitively matches the file contents, and the test passes.

    .EXAMPLE
    'TestDrive:\file.txt' | Should -FileContentMatchMultilineExactly "First line.`nI am"

    Using the file from Example 1, this specified content across multiple lines does not case sensitively match,
    because the 'F' on the first line is capitalized. This test fails.

    .EXAMPLE
    'TestDrive:\file.txt' | Should -FileContentMatchMultilineExactly 'first line\.\r?\nI am'

    Using the file from Example 1, this RegEx pattern case sensitively matches the file contents, and the test passes.

    .EXAMPLE
    'TestDrive:\file.txt' | Should -FileContentMatchMultilineExactly '^I am the first.*\n.*second line\.$'

    Using the file from Example 1, this RegEx pattern also case sensitively matches, and this test also passes.

    .EXAMPLE
    'TestDrive:\file.txt' | Should -FileContentMatchMultilineExactly '^am the first line\.$'

    Using the file from Example 1, FileContentMatchMultilineExactly uses the '^' symbol to case sensitively match the start of the file,
    so '^am' is invalid here because the start of the file is '^I am'. This test fails.

    .EXAMPLE
    'TestDrive:\file.txt' | Should -FileContentMatchMultilineExactly '^I am the first line\.$'

    Using the file from Example 1, FileContentMatchMultilineExactly uses the '$' symbol to case sensitively match the end of the file,
    not the end of any single line within the file. This test also fails.
    #>
    $succeeded = [bool] ((& $SafeCommands['Get-Content'] $ActualValue -Delimiter ([char]0)) -cmatch $ExpectedContent)

    if ($Negate) {
```

**Description:**

file src\functions\assertions\FileContentMatchMultilineExactly.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-HaveCount`

**Signature:**
```powershell
function Should-HaveCount($ActualValue, [int] $ExpectedValue, [switch] $Negate, [string] $Because) {
    <#
    .SYNOPSIS
    Asserts that a collection has the expected amount of items.

    .EXAMPLE
    1,2,3 | Should -HaveCount 3

    This test passes, because it expected three objects, and received three.
    This is like running `@(1,2,3).Count` in PowerShell.
    #>
    if ($ExpectedValue -lt 0) {
```

**Description:**

file src\functions\assertions\HaveCount.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-HaveParameter`

**Signature:**
```powershell
function Should-HaveParameter (
    $ActualValue,
    [String] $ParameterName,
    $Type,
    [String] $DefaultValue,
    [Switch] $Mandatory,
    [String] $InParameterSet,
    [Switch] $HasArgumentCompleter,
    [String[]] $Alias,
    [Switch] $Negate,
    [String] $Because ) {
```

**Description:**

file src\functions\assertions\HaveParameter.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-Invoke`

**Signature:**
```powershell
function Should-Invoke {
    <#
    .SYNOPSIS
    Checks if a Mocked command has been called a certain number of times
    and throws an exception if it has not.

    .DESCRIPTION
    This command verifies that a mocked command has been called a certain number
    of times.  If the call history of the mocked command does not match the parameters
    passed to Should -Invoke, Should -Invoke will throw an exception.

    .PARAMETER CommandName
    The mocked command whose call history should be checked.

    .PARAMETER ModuleName
    The module where the mock being checked was injected.  This is optional,
    and must match the ModuleName that was used when setting up the Mock.

    .PARAMETER Times
    The number of times that the mock must be called to avoid an exception
    from throwing.

    .PARAMETER Exactly
    If this switch is present, the number specified in Times must match
    exactly the number of times the mock has been called. Otherwise it
    must match "at least" the number of times specified.  If the value
    passed to the Times parameter is zero, the Exactly switch is implied.

    .PARAMETER ParameterFilter
    An optional filter to qualify which calls should be counted. Only those
    calls to the mock whose parameters cause this filter to return true
    will be counted.

    .PARAMETER ExclusiveFilter
    Like ParameterFilter, except when you use ExclusiveFilter, and there
    were any calls to the mocked command which do not match the filter,
    an exception will be thrown.  This is a convenient way to avoid needing
    to have two calls to Should -Invoke like this:

    Should -Invoke SomeCommand -Times 1 -ParameterFilter { $something -eq $true }
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-InvokeInternal`

**Signature:**
```powershell
function Should-InvokeInternal {
    [CmdletBinding(DefaultParameterSetName = 'ParameterFilter')]
    [OutputType([Pester.ShouldResult])]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable] $ContextInfo,

        [int] $Times = 1,

        [Parameter(ParameterSetName = 'ParameterFilter')]
        [ScriptBlock] $ParameterFilter = { $True },

        [Parameter(ParameterSetName = 'ExclusiveFilter', Mandatory = $true)]
        [scriptblock] $ExclusiveFilter,

        [string] $ModuleName,

        [switch] $Exactly,
        [switch] $Negate,
        [string] $Because,

        [Parameter(Mandatory)]
        [Management.Automation.SessionState] $SessionState,

        [Parameter(Mandatory)]
        [HashTable] $MockTable
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-InvokeVerifiable`

**Signature:**
```powershell
function Should-InvokeVerifiable ([switch] $Negate, [string] $Because) {
    <#
    .SYNOPSIS
    Checks if any Verifiable Mock has not been invoked. If so, this will throw an exception.

    .DESCRIPTION
    This can be used in tandem with the -Verifiable switch of the Mock
    function. Mock can be used to mock the behavior of an existing command
    and optionally take a -Verifiable switch. When Should -InvokeVerifiable
    is called, it checks to see if any Mock marked Verifiable has not been
    invoked. If any mocks have been found that specified -Verifiable and
    have not been invoked, an exception will be thrown.

    .EXAMPLE
    Mock Set-Content {} -Verifiable -ParameterFilter {$Path -eq "some_path" -and $Value -eq "Expected Value"}
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-InvokeVerifiableInternal`

**Signature:**
```powershell
function Should-InvokeVerifiableInternal {
    [CmdletBinding()]
    [OutputType([Pester.ShouldResult])]
    param(
        [Parameter(Mandatory)]
        $Behaviors,
        [switch] $Negate,
        [string] $Because
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-Match`

**Signature:**
```powershell
function Should-Match($ActualValue, $RegularExpression, [switch] $Negate, [string] $Because) {
    <#
    .SYNOPSIS
    Uses a regular expression to compare two objects.
    This comparison is not case sensitive.

    .EXAMPLE
    "I am a value" | Should -Match "I Am"

    The "I Am" regular expression (RegEx) pattern matches the provided string,
    so the test passes. For case sensitive matches, see MatchExactly.
    .EXAMPLE
    "I am a value" | Should -Match "I am a bad person" # Test will fail

    RegEx pattern does not match the string, and the test fails.
    .EXAMPLE
    "Greg" | Should -Match ".reg" # Test will pass

    This test passes, as "." in RegEx matches any character.
    .EXAMPLE
    "Greg" | Should -Match ([regex]::Escape(".reg"))

    One way to provide literal characters to Match is the [regex]::Escape() method.
    This test fails, because the pattern does not match a period symbol.
    #>
    [bool] $succeeded = $ActualValue -match $RegularExpression

    if ($Negate) {
```

**Description:**

file src\functions\assertions\Match.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-MatchExactly`

**Signature:**
```powershell
function Should-MatchExactly($ActualValue, $RegularExpression, [switch] $Negate, [string] $Because) {
    <#
    .SYNOPSIS
    Uses a regular expression to compare two objects.
    This comparison is case sensitive.

    .EXAMPLE
    "I am a value" | Should -MatchExactly "I am"

    The "I am" regular expression (RegEx) pattern matches the string.
    This test passes.

    .EXAMPLE
    "I am a value" | Should -MatchExactly "I Am"

    Because MatchExactly is case sensitive, this test fails.
    For a case insensitive test, see Match.
    #>
    [bool] $succeeded = $ActualValue -cmatch $RegularExpression

    if ($Negate) {
```

**Description:**

file src\functions\assertions\MatchExactly.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Should-Throw`

**Signature:**
```powershell
function Should-Throw {
    <#
    .SYNOPSIS
    Checks if an exception was thrown. Enclose input in a script block.

    Warning: The input object must be a ScriptBlock, otherwise it is processed outside of the assertion.

    .EXAMPLE
    { foo } | Should -Throw
```

**Description:**

file src\functions\assertions\PesterThrow.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldBeExactlyFailureMessage`

**Signature:**
```powershell
function ShouldBeExactlyFailureMessage($ActualValue, $ExpectedValue, $Because) {
    # This looks odd; it's to unroll single-element arrays so the "-is [string]" expression works properly.
    $ActualValue = $($ActualValue)
    $ExpectedValue = $($ExpectedValue)

    if (-not (($ExpectedValue -is [string]) -and ($ActualValue -is [string]))) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldBeFailureMessage`

**Signature:**
```powershell
function ShouldBeFailureMessage($ActualValue, $ExpectedValue, $Because) {
    # This looks odd; it's to unroll single-element arrays so the "-is [string]" expression works properly.
    $ActualValue = $($ActualValue)
    $ExpectedValue = $($ExpectedValue)

    if (-not (($ExpectedValue -is [string]) -and ($ActualValue -is [string]))) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldBeFalseFailureMessage`

**Signature:**
```powershell
function ShouldBeFalseFailureMessage($ActualValue) {
}
function NotShouldBeFalseFailureMessage($ActualValue) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldBeGreaterOrEqualFailureMessage`

**Signature:**
```powershell
function ShouldBeGreaterOrEqualFailureMessage() {
}
function NotShouldBeGreaterOrEqualFailureMessage() {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldBeGreaterThanFailureMessage`

**Signature:**
```powershell
function ShouldBeGreaterThanFailureMessage() {
}
function NotShouldBeGreaterThanFailureMessage() {
```

**Description:**

keeping tests happy

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldBeInFailureMessage`

**Signature:**
```powershell
function ShouldBeInFailureMessage() {
}
function NotShouldBeInFailureMessage() {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldBeLessOrEqualFailureMessage`

**Signature:**
```powershell
function ShouldBeLessOrEqualFailureMessage() {
}
function NotShouldBeLessOrEqualFailureMessage() {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldBeLessThanFailureMessage`

**Signature:**
```powershell
function ShouldBeLessThanFailureMessage() {
}
function NotShouldBeLessThanFailureMessage() {
```

**Description:**

keeping tests happy

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldBeLikeExactlyFailureMessage`

**Signature:**
```powershell
function ShouldBeLikeExactlyFailureMessage() {
}
function NotShouldBeLikeExactlyFailureMessage() {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldBeLikeFailureMessage`

**Signature:**
```powershell
function ShouldBeLikeFailureMessage() {
}
function NotShouldBeLikeFailureMessage() {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldBeNullOrEmptyFailureMessage`

**Signature:**
```powershell
function ShouldBeNullOrEmptyFailureMessage($ActualValue, $Because) {
    return "Expected `$null or empty,$(Format-Because $Because) but got $(Format-Nicely $ActualValue)."
}

function NotShouldBeNullOrEmptyFailureMessage ($Because) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldBeOfTypeFailureMessage`

**Signature:**
```powershell
function ShouldBeOfTypeFailureMessage() {
}

function NotShouldBeOfTypeFailureMessage() {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldBeTrueFailureMessage`

**Signature:**
```powershell
function ShouldBeTrueFailureMessage($ActualValue) {
}
function NotShouldBeTrueFailureMessage($ActualValue) {
```

**Description:**

to keep tests happy

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldContainFailureMessage`

**Signature:**
```powershell
function ShouldContainFailureMessage() {
}
function NotShouldContainFailureMessage() {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldExistFailureMessage`

**Signature:**
```powershell
function ShouldExistFailureMessage() {
}
function NotShouldExistFailureMessage() {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldFileContentMatchExactlyFailureMessage`

**Signature:**
```powershell
function ShouldFileContentMatchExactlyFailureMessage($ActualValue, $ExpectedContent) {
    return "Expected $(Format-Nicely $ExpectedContent) to be case sensitively found in file $(Format-Nicely $ActualValue),$(Format-Because $Because) but it was not found."
}

function NotShouldFileContentMatchExactlyFailureMessage($ActualValue, $ExpectedContent) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldFileContentMatchFailureMessage`

**Signature:**
```powershell
function ShouldFileContentMatchFailureMessage($ActualValue, $ExpectedContent, $Because) {
    return "Expected $(Format-Nicely $ExpectedContent) to be found in file '$ActualValue',$(Format-Because $Because) but it was not found."
}

function NotShouldFileContentMatchFailureMessage($ActualValue, $ExpectedContent, $Because) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldFileContentMatchMultilineExactlyFailureMessage`

**Signature:**
```powershell
function ShouldFileContentMatchMultilineExactlyFailureMessage($ActualValue, $ExpectedContent, $Because) {
    return "Expected $(Format-Nicely $ExpectedContent) to be case sensitively found in file $(Format-Nicely $ActualValue),$(Format-Because $Because) but it was not found."
}

function NotShouldFileContentMatchMultilineExactlyFailureMessage($ActualValue, $ExpectedContent, $Because) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldFileContentMatchMultilineFailureMessage`

**Signature:**
```powershell
function ShouldFileContentMatchMultilineFailureMessage($ActualValue, $ExpectedContent, $Because) {
    return "Expected $(Format-Nicely $ExpectedContent) to be found in file $(Format-Nicely $ActualValue),$(Format-Because $Because) but it was not found."
}

function NotShouldFileContentMatchMultilineFailureMessage($ActualValue, $ExpectedContent, $Because) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldHaveCountFailureMessage`

**Signature:**
```powershell
function ShouldHaveCountFailureMessage() {
}
function NotShouldHaveCountFailureMessage() {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldMatchExactlyFailureMessage`

**Signature:**
```powershell
function ShouldMatchExactlyFailureMessage($ActualValue, $RegularExpression) {
    return "Expected regular expression $(Format-Nicely $RegularExpression) to case sensitively match $(Format-Nicely $ActualValue),$(Format-Because $Because) but it did not match."
}

function NotShouldMatchExactlyFailureMessage($ActualValue, $RegularExpression) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldMatchFailureMessage`

**Signature:**
```powershell
function ShouldMatchFailureMessage($ActualValue, $RegularExpression, $Because) {
    return "Expected regular expression $(Format-Nicely $RegularExpression) to match $(Format-Nicely $ActualValue),$(Format-Because $Because) but it did not match."
}

function NotShouldMatchFailureMessage($ActualValue, $RegularExpression, $Because) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `ShouldThrowFailureMessage`

**Signature:**
```powershell
function ShouldThrowFailureMessage {
    # to make the should tests happy, for now
}

function NotShouldThrowFailureMessage {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Show-ParentList`

**Signature:**
```powershell
function Show-ParentList ($command) {
        $c = $command
        "`n`nCommand: $c" | Write-Host
        $(for ($ast = $c; $null -ne $ast; $ast = $ast.Parent) {
```

**Description:**

function Write-Host { }

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Sort-Property`

**Signature:**
```powershell
function Sort-Property ($InputObject, [string[]]$SignificantProperties, $Limit = 4) {

    $properties = @($InputObject.PSObject.Properties |
            & $SafeCommands['Where-Object'] { $_.Name -notlike "_*" } |
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Start-TraceScript`

**Signature:**
```powershell
function Start-TraceScript ($Breakpoints) {

    $points = [Collections.Generic.List[Pester.Tracing.CodeCoveragePoint]]@()
    foreach ($breakpoint in $breakpoints) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Stop-Pipeline`

**Signature:**
```powershell
function Stop-Pipeline {
	# borrowed from https://stackoverflow.com/a/34800670:
	(Add-Type -Passthru -TypeDefinition '
	using System.Management.Automation;
	namespace PSFzf.IO {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Base.ps1`</sub>

### `Stop-TraceScript`

**Signature:**
```powershell
function Stop-TraceScript {
    param ([bool] $Patched)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `sum`

**Signature:**
```powershell
function sum ($InputObject, $PropertyName, $Zero) {
    if (none $InputObject.Length) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Switch-Timer`

**Signature:**
```powershell
function Switch-Timer {
    param (
        [Parameter(Mandatory)]
        [ValidateSet("Framework", "UserCode")]
        $Scope
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Test-AssertionOperatorIsDuplicate`

**Signature:**
```powershell
function Test-AssertionOperatorIsDuplicate {
    param (
        [psobject] $Operator
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Test-CommandInScope`

**Signature:**
```powershell
function Test-CommandInScope {
    param ([System.Management.Automation.Language.Ast] $Command, [string] $Class, [string] $Function)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Test-CoverageOverlapsCommand`

**Signature:**
```powershell
function Test-CoverageOverlapsCommand {
    param ([object] $CoverageInfo, [System.Management.Automation.Language.Ast] $Command)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Test-CoverageOverlapsCommandByLineNumber`

**Signature:**
```powershell
function Test-CoverageOverlapsCommandByLineNumber {
    param ([object] $CoverageInfo, [System.Management.Automation.Language.Ast] $Command)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Test-Hint`

**Signature:**
```powershell
function Test-Hint {
    param (
        [Parameter(Mandatory = $true)]
        $InputObject
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Test-IsClosure`

**Signature:**
```powershell
function Test-IsClosure {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Test-ParameterFilter`

**Signature:**
```powershell
function Test-ParameterFilter {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock,

        [System.Collections.IDictionary]
        $BoundParameters,

        [object[]]
        $ArgumentList,

        [System.Management.Automation.CommandMetadata]
        $Metadata,

        [Parameter(Mandatory)]
        [Management.Automation.SessionState]
        $SessionState
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Test-RangeContainsValue`

**Signature:**
```powershell
function Test-RangeContainsValue {
    param ([int] $Value, [int] $Min, [int] $Max)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Test-ShouldRun`

**Signature:**
```powershell
function Test-ShouldRun {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Item,
        $Filter
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `tryAddValue`

**Signature:**
```powershell
function tryAddValue {
    [CmdletBinding()]
    param(
        $Hashtable,
        $Key,
        $Value
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `tryGetProperty`

**Signature:**
```powershell
function tryGetProperty {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        $InputObject,
        [Parameter(Mandatory = $true, Position = 1)]
        $PropertyName
    )
```

**Description:**

looks for a property on object that might be null

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `tryGetValue`

**Signature:**
```powershell
function tryGetValue {
    [CmdletBinding()]
    param(
        $Hashtable,
        $Key
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `tryRemoveKey`

**Signature:**
```powershell
function tryRemoveKey ($Hashtable, $Key) {
    if ($Hashtable.ContainsKey($Key)) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `trySetProperty`

**Signature:**
```powershell
function trySetProperty {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        $InputObject,
        [Parameter(Mandatory = $true, Position = 1)]
        $PropertyName,
        [Parameter(Mandatory = $true, Position = 2)]
        $Value
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Update-CmdLine`

**Signature:**
```powershell
function Update-CmdLine($result) {
    InvokePromptHack
    if ($result.Length -gt 0) {
```

<sub>**Source:** `Modules\PSFzf\2.7.2\PSFzf.Git.ps1`</sub>

### `View-Flat`

**Signature:**
```powershell
function View-Flat {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Block
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Where-Failed`

**Signature:**
```powershell
function Where-Failed {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Block
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-BlockToScreen`

**Signature:**
```powershell
function Write-BlockToScreen {
    param ($Block)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-CIErrorToScreen`

**Signature:**
```powershell
function Write-CIErrorToScreen {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('AzureDevops', 'GithubActions', IgnoreCase)]
        [string] $CIFormat,

        [Parameter(Mandatory)]
        [ValidateSet('Error', 'Warning', IgnoreCase)]
        [string] $CILogLevel,

        [Parameter(Mandatory)]
        [string] $Header,

        # [Parameter(Mandatory)]
        # Do not make this mandatory, just providing a string array is not enough,
        # for the mandatory check to pass, it also throws when any item in the array is empty or null.
        [string[]] $Message
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-CoverageReport`

**Signature:**
```powershell
function Write-CoverageReport {
    param ([object] $CoverageReport)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-ErrorToScreen`

**Signature:**
```powershell
function Write-ErrorToScreen {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Err,
        [string] $ErrorMargin,
        [switch] $Throw,
        [string] $StackTraceVerbosity = [PesterConfiguration]::Default.Output.StackTraceVerbosity.Value
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-Host`

**Signature:**
```powershell
function Write-Host { }
    }
    # function Write-Host { }
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-JUnitReport`

**Signature:**
```powershell
function Write-JUnitReport {
    param([Pester.Run] $Result, [System.Xml.XmlWriter] $XmlWriter)
```

**Description:**

file src\functions\TestResults.JUnit4.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-JUnitTestCaseAttributes`

**Signature:**
```powershell
function Write-JUnitTestCaseAttributes {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    param($TestResult,[System.Xml.XmlWriter] $XmlWriter, [string] $ClassName)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-JUnitTestCaseElements`

**Signature:**
```powershell
function Write-JUnitTestCaseElements {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    param($TestResult, [System.Xml.XmlWriter] $XmlWriter, [string] $Package)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-JUnitTestCaseMessageElements`

**Signature:**
```powershell
function Write-JUnitTestCaseMessageElements {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    param($TestResult,[System.Xml.XmlWriter] $XmlWriter, [string] $StatusElementName)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-JUnitTestResultAttributes`

**Signature:**
```powershell
function Write-JUnitTestResultAttributes {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    param([Pester.Run] $Result, [System.Xml.XmlWriter] $XmlWriter)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-JUnitTestSuiteAttributes`

**Signature:**
```powershell
function Write-JUnitTestSuiteAttributes {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    param($Action, [System.Xml.XmlWriter] $XmlWriter, [string] $Package, [uint16] $Id)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-JUnitTestSuiteElements`

**Signature:**
```powershell
function Write-JUnitTestSuiteElements {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    param([Pester.Container] $Container, [System.Xml.XmlWriter] $XmlWriter, [uint16] $Id)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnit3CategoryProperty`

**Signature:**
```powershell
function Write-NUnit3CategoryProperty ([string[]]$Tag, [System.Xml.XmlWriter] $XmlWriter) {
    foreach ($t in $Tag) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnit3DataProperty`

**Signature:**
```powershell
function Write-NUnit3DataProperty ([System.Collections.IDictionary] $Data, [System.Xml.XmlWriter] $XmlWriter) {
    foreach ($d in $Data.GetEnumerator()) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnit3EnvironmentInformation`

**Signature:**
```powershell
function Write-NUnit3EnvironmentInformation {
    param(
        [System.Xml.XmlWriter] $XmlWriter,
        [System.Collections.IDictionary] $Environment = (Get-RunTimeEnvironment)
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnit3FailureElement`

**Signature:**
```powershell
function Write-NUnit3FailureElement ($TestResult, [System.Xml.XmlWriter] $XmlWriter) {
    # TODO: remove monkey patching the error message when parent setup failed so this test never run
    # TODO: do not format the errors here, instead format them in the core using some unified function so we get the same thing on the screen and in nunit

    $result = Get-ErrorForXmlReport -TestResult $TestResult
    $XmlWriter.WriteStartElement('failure')

    $XmlWriter.WriteStartElement('message')
    $XmlWriter.WriteCData($result.FailureMessage)
    $XmlWriter.WriteEndElement() # Close message

    if ($result.StackTrace) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnit3OutputElement`

**Signature:**
```powershell
function Write-NUnit3OutputElement ($Output, [System.Xml.XmlWriter] $XmlWriter) {
    # The characters in the range 0x01 to 0x20 are invalid for CData
    # (with the exception of the characters 0x09, 0x0A and 0x0D)
    # We convert each of these using the unicode printable version,
    # which is obtained by adding 0x2400
    [int]$unicodeControlPictures = 0x2400

    # Avoid indexing into an enumerable, such as a `string`, when there is only one item in the
    # output array.
    $out = @($Output)
    $linesCount = $out.Length
    $o = for ($i = 0; $i -lt $linesCount; $i++) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnit3Report`

**Signature:**
```powershell
function Write-NUnit3Report([Pester.Run] $Result, [System.Xml.XmlWriter] $XmlWriter) {
    # Write the XML Declaration
    $XmlWriter.WriteStartDocument($false)

    # Write Root Element
    $xmlWriter.WriteStartElement('test-run')

    Write-NUnit3TestRunAttributes @PSBoundParameters

    # Write Filter Element (required)
    $xmlWriter.WriteStartElement('filter')
    $XmlWriter.WriteEndElement()

    Write-NUnit3TestRunChildNode @PSBoundParameters

    $XmlWriter.WriteEndElement()
}

function Write-NUnit3TestRunAttributes {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnit3TestCaseAttributes`

**Signature:**
```powershell
function Write-NUnit3TestCaseAttributes {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param($TestResult, [string] $ParentPath, [System.Xml.XmlWriter] $XmlWriter)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnit3TestCaseElement`

**Signature:**
```powershell
function Write-NUnit3TestCaseElement {
    param($TestResult, [string] $ParentPath, [System.Xml.XmlWriter] $XmlWriter)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnit3TestRunAttributes`

**Signature:**
```powershell
function Write-NUnit3TestRunAttributes {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param([Pester.Run] $Result, [System.Xml.XmlWriter] $XmlWriter)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnit3TestRunChildNode`

**Signature:**
```powershell
function Write-NUnit3TestRunChildNode {
    param(
        [Pester.Run] $Result,
        [System.Xml.XmlWriter] $XmlWriter
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnit3TestSuiteAttributes`

**Signature:**
```powershell
function Write-NUnit3TestSuiteAttributes {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param($TestSuiteInfo, [System.Xml.XmlWriter] $XmlWriter)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnit3TestSuiteElement`

**Signature:**
```powershell
function Write-NUnit3TestSuiteElement {
    param(
        $Node,
        [System.Xml.XmlWriter] $XmlWriter,
        [string] $ParentPath,
        [System.Collections.IDictionary] $RuntimeEnvironment
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnitCultureInformation`

**Signature:**
```powershell
function Write-NUnitCultureInformation {
    param([System.Xml.XmlWriter] $XmlWriter)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnitEnvironmentInformation`

**Signature:**
```powershell
function Write-NUnitEnvironmentInformation {
    param([System.Xml.XmlWriter] $XmlWriter)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnitReasonElement`

**Signature:**
```powershell
function Write-NUnitReasonElement ($TestResult, [System.Xml.XmlWriter] $XmlWriter) {
    # TODO: do not format the errors here, instead format them in the core using some unified function so we get the same thing on the screen and in nunit

    $result = Get-ErrorForXmlReport -TestResult $TestResult
    if ($result.FailureMessage) {
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnitReport`

**Signature:**
```powershell
function Write-NUnitReport {
    param([Pester.Run] $Result, [System.Xml.XmlWriter] $XmlWriter)
```

**Description:**

file src\functions\TestResults.NUnit25.ps1

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnitTestCaseAttributes`

**Signature:**
```powershell
function Write-NUnitTestCaseAttributes {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param($TestResult, [System.Xml.XmlWriter] $XmlWriter, [string] $ParameterizedSuiteName)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnitTestCaseElement`

**Signature:**
```powershell
function Write-NUnitTestCaseElement {
    param($TestResult, [System.Xml.XmlWriter] $XmlWriter, [string] $ParameterizedSuiteName)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnitTestResultAttributes`

**Signature:**
```powershell
function Write-NUnitTestResultAttributes {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param([Pester.Run] $Result, [System.Xml.XmlWriter] $XmlWriter)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnitTestResultChildNodes`

**Signature:**
```powershell
function Write-NUnitTestResultChildNodes {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param([Pester.Run] $Result, [System.Xml.XmlWriter] $XmlWriter)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnitTestSuiteAttributes`

**Signature:**
```powershell
function Write-NUnitTestSuiteAttributes {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param($TestSuiteInfo, [string] $TestSuiteType = 'TestFixture', [System.Xml.XmlWriter] $XmlWriter, [string] $Path)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-NUnitTestSuiteElements`

**Signature:**
```powershell
function Write-NUnitTestSuiteElements {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param($Node, [System.Xml.XmlWriter] $XmlWriter, [string] $Path)
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-PesterDebugMessage`

**Signature:**
```powershell
function Write-PesterDebugMessage {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet("Filter", "Skip", "Runtime", "RuntimeCore", "Mock", "MockCore", "Discovery", "DiscoveryCore", "SessionState", "Timing", "TimingCore", "Plugin", "PluginCore", "CodeCoverage", "CodeCoverageCore")]
        [String[]] $Scope,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "Default")]
        [String] $Message,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "Lazy")]
        [ScriptBlock] $LazyMessage,
        [Parameter(Position = 2)]
        [Management.Automation.ErrorRecord] $ErrorRecord
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-PesterHostMessage`

**Signature:**
```powershell
function Write-PesterHostMessage {
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [Alias('Message', 'Msg')]
        $Object,

        [ConsoleColor]
        $ForegroundColor,

        [ConsoleColor]
        $BackgroundColor,

        [switch]
        $NoNewLine,

        $Separator = ' ',

        [ValidateSet('Ansi', 'ConsoleColor', 'Plaintext')]
        [string]
        $RenderMode = $PesterPreference.Output.RenderMode.Value
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-PesterReport`

**Signature:**
```powershell
function Write-PesterReport {
    param (
        [Parameter(mandatory = $true, valueFromPipeline = $true)]
        [Pester.Run] $RunResult
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-PesterStart`

**Signature:**
```powershell
function Write-PesterStart {
    param(
        [Parameter(mandatory = $true, valueFromPipeline = $true)]
        $Context
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

### `Write-ScriptBlockInvocationHint`

**Signature:**
```powershell
function Write-ScriptBlockInvocationHint {
    param(
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock,
        [Parameter(Mandatory = $true)]
        [String]
        $Hint
    )
```

<sub>**Source:** `Modules\Pester\5.7.1\Pester.psm1`</sub>

## Other

### `__gh_debug`

**Signature:**
```powershell
function __gh_debug {
    if ($env:BASH_COMP_DEBUG_FILE) {
```

**Description:**

powershell completion for gh                                   -*- shell-script -*-

<sub>**Source:** `Config\gh-completion-cache.ps1`</sub>

### `Disable-FullPSReadLine`

**Signature:**
```powershell
function Disable-FullPSReadLine {
    try {
```

**Description:**

Provide a function to disable PSReadLine features if needed

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Disable-TransientPrompt`

**Signature:**
```powershell
function Disable-TransientPrompt {
        Set-PSReadLineKeyHandler -Key Enter -Function AcceptLine
        $script:TransientPrompt = $false
    }

    function global:prompt {
```

<sub>**Source:** `Config\starship-init-cache.ps1`</sub>

### `Enable-TerminalIcon`

**Signature:**
```powershell
function Enable-TerminalIcon {
            try {
```

**Description:**

Provide an explicit enable function for Terminal-Icons so nothing related to it is created at startup

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Enable-TransientPrompt`

**Signature:**
```powershell
function Enable-TransientPrompt {
        Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
```

<sub>**Source:** `Config\starship-init-cache.ps1`</sub>

### `Get-Cwd`

**Signature:**
```powershell
function Get-Cwd {
        $cwd = Get-Location
        $provider_prefix = "$($cwd.Provider.ModuleName)\$($cwd.Provider.Name)::"
        return @{
```

<sub>**Source:** `Config\starship-init-cache.ps1`</sub>

### `global`

**Signature:**
```powershell
function global:prompt {
        $origDollarQuestion = $global:?
        $origLastExitCode = $global:LASTEXITCODE

        # Invoke precmd, if specified
        try {
```

<sub>**Source:** `Config\starship-init-cache.ps1`</sub>

### `Import-PSModule`

**Signature:**
```powershell
function Import-PSModule {
            param([string]$Name)
```

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Initialize-ProfileCore`

**Signature:**
```powershell
function Initialize-ProfileCore {
            if (-not (Get-Module -Name ProfileCore -ListAvailable)) {
```

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Initialize-ProfileManagement`

**Signature:**
```powershell
function Initialize-ProfileManagement {
            if (-not (Get-Module -Name ProfileManagement -ListAvailable)) {
```

**Description:**

Defer importing heavy profile modules until first use

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Initialize-PSModule`

**Signature:**
```powershell
function Initialize-PSModule {
            Ensure-ProfileCore
            $cmd = Get-Command -Module ProfileCore -Name Initialize-PSModule -ErrorAction SilentlyContinue
            if ($cmd) { & $cmd @args } else { Write-Warning 'Initialize-PSModule not available' }
```

**Description:**

Lightweight proxies that import the module on first use and then invoke the real function

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Install-Bat`

**Signature:**
```powershell
function Install-Bat {
    Write-ColorOutput "Installing bat..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Chocolatey`

**Signature:**
```powershell
function Install-Chocolatey {
    Write-ColorOutput "Installing Chocolatey..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Dependency`

**Signature:**
```powershell
function Install-Dependency {
    <#
    .SYNOPSIS
        Install PowerShell profile dependencies
    .DESCRIPTION
        Installs package managers and CLI tools required by the PowerShell profile
    .PARAMETER All
        Install all dependencies (package managers + CLI tools)
    .PARAMETER PackageManagers
        Install only package managers (Chocolatey, Scoop)
    .PARAMETER CliTools
        Install only CLI tools (git, fzf, bat, eza, etc.)
    .PARAMETER Tool
        Install a specific tool by name
    .EXAMPLE
        Install-Dependency -All
    .EXAMPLE
        Install-Dependency -PackageManagers
    .EXAMPLE
        Install-Dependency -Tool git
    #>
    param(
        [switch]$All,
        [switch]$PackageManagers,
        [switch]$CliTools,
        [string]$Tool
    )
```

**Description:**

Initialize startup modules - deferred to first use for faster startup Modules will be loaded on-demand via lazy-loading proxies Uncomment below to force eager loading: Initialize-PSModule

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Install-Eza`

**Signature:**
```powershell
function Install-Eza {
    Write-ColorOutput "Installing eza..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Fd`

**Signature:**
```powershell
function Install-Fd {
    Write-ColorOutput "Installing fd..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Fzf`

**Signature:**
```powershell
function Install-Fzf {
    Write-ColorOutput "Installing fzf..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Git`

**Signature:**
```powershell
function Install-Git {
    Write-ColorOutput "Installing Git..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Lazygit`

**Signature:**
```powershell
function Install-Lazygit {
    Write-ColorOutput "Installing lazygit..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Ripgrep`

**Signature:**
```powershell
function Install-Ripgrep {
    Write-ColorOutput "Installing ripgrep..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Scoop`

**Signature:**
```powershell
function Install-Scoop {
    Write-ColorOutput "Installing Scoop..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Winget`

**Signature:**
```powershell
function Install-Winget {
    Write-ColorOutput "Checking Winget..." $Cyan
    if (Test-CommandExist 'winget') {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Install-Zoxide`

**Signature:**
```powershell
function Install-Zoxide {
    Write-ColorOutput "Installing zoxide..." $Cyan
    if ($WhatIf) {
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

### `Invoke-Native`

**Signature:**
```powershell
function Invoke-Native {
        param($Executable, $Arguments)
```

<sub>**Source:** `Config\starship-init-cache.ps1`</sub>

### `Measure-Block`

**Signature:**
```powershell
function Measure-Block {
    param(
        [string]$Name,
        [scriptblock]$Block,
        [switch]$Async
    )
```

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Register-PSModule`

**Signature:**
```powershell
function Register-PSModule {
            param(
                [string]$Name,
                [string]$Description,
                [string]$Category,
                [scriptblock]$InitializerBlock
            )
```

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Start-BackgroundJob`

**Signature:**
```powershell
function Start-BackgroundJob {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [scriptblock]$ScriptBlock,
        [Parameter(ValueFromRemainingArguments = $true)] $ArgumentList
    )
```

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Test-CachedPath`

**Signature:**
```powershell
function Test-CachedPath {
    param([string]$Path)
```

**Description:**

Helper function for cached Test-Path

<sub>**Source:** `Microsoft.PowerShell_profile.ps1`</sub>

### `Write-ColorOutput`

**Signature:**
```powershell
function Write-ColorOutput {
    param([string]$Message)
```

<sub>**Source:** `tools\install-dependencies.ps1`</sub>

## System

### `_fzf_get_path_using_fd`

**Signature:**
```powershell
function _fzf_get_path_using_fd
{
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `_fzf_get_path_using_rg`

**Signature:**
```powershell
function _fzf_get_path_using_rg
{
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `_fzf_open_path`

**Signature:**
```powershell
function _fzf_open_path
{
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `Clear-All`

**Signature:**
```powershell
function Clear-All {
  Clear-RecycleBin
  Delete-TempData
  Run-DiskCleanUp
}
```

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `Clear-Disk`

**Signature:**
```powershell
function Clear-Disk {
  #3# Using Disk cleanup Tool
  # Display a message indicating the usage of the Disk Cleanup tool
  Write-Verbose "Using Disk cleanup Tool" -ForegroundColor Yellow
  # Run the Disk Cleanup tool with the specified sagerun parameter
  cleanmgr /sagerun:1 | out-Null
  # Emit a beep sound using ASCII code 7
  Write-Verbose "$([char]7)"
  # Display a success message indicating that Disk Cleanup was successfully done
  Write-Verbose "Disk Cleanup Successfully done" -ForegroundColor Green
}

function Clear-All {
```

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `Clear-RecycleBin`

**Signature:**
```powershell
function Clear-RecycleBin {
  #1# Removing recycle bin files
  # Set the path to the recycle bin on the C drive
  $Path = 'C' + ':\$Recycle.Bin'
  # Get all items (files and directories) within the recycle bin path, including hidden ones
  Write-Verbose "[INFO] Cleaning recycle bin with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
  Get-ChildItem $Path -Force -Recurse -ErrorAction SilentlyContinue |
  # Remove the items, excluding any files with the .ini extension
  Remove-Item -Recurse -Exclude *.ini -ErrorAction SilentlyContinue
  # Display a success message
  Write-Verbose "All the necessary data removed from recycle bin successfully" -ForegroundColor Green
}

function Clear-TempData {
```

**Description:**

Source: https://www.geeksforgeeks.org/disk-cleanup-using-powershell-scripts/

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `Clear-TempData`

**Signature:**
```powershell
function Clear-TempData {
  #2# Remove Temp files from various locations
  Write-Verbose "Erasing temporary files from various locations" -ForegroundColor Yellow
  # Specify the path where temporary files are stored in the Windows Temp folder
  $Path1 = 'C' + ':\Windows\Temp'
  # Remove all items (files and directories) from the Windows Temp folder
  Write-Verbose "[INFO] Cleaning Windows Temp folder with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
  Get-ChildItem $Path1 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  # Specify the path where temporary files are stored in the Windows Prefetch folder
  $Path2 = 'C' + ':\Windows\Prefetch'
  # Remove all items (files and directories) from the Windows Prefetch folder
  Write-Verbose "[INFO] Cleaning Windows Prefetch folder with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
  Get-ChildItem $Path2 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  # Specify the path where temporary files are stored in the user's AppData\Local\Temp folder
  $Path3 = 'C' + ':\Users\*\AppData\Local\Temp'
  # Remove all items (files and directories) from the specified user's Temp folder
  Write-Verbose "[INFO] Cleaning user Temp folder with ErrorAction SilentlyContinue (errors will be suppressed)" -ForegroundColor Yellow
  Get-ChildItem $Path3 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  # Display a success message
  Write-Verbose "removed all the temp files successfully" -ForegroundColor Green
}

function Clear-Disk {
```

<sub>**Source:** `Core\System\clean.ps1`</sub>

### `cma`

**Signature:**
```powershell
function cma
{
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `cmc`

**Signature:**
```powershell
function cmc
{
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `cmp`

**Signature:**
```powershell
function cmp
{
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `cms`

**Signature:**
```powershell
function cms
{
```

<sub>**Source:** `Core\System\chezmoi.ps1`</sub>

### `dirs`

**Signature:**
```powershell
function dirs
{
```

**Description:**

Does the the rough equivalent of dir /s /b. For example, dirs *.png is dir /s /b *.png

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `Env`

**Signature:**
```powershell
function Env:
{ Set-Location Env:
```

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `fdg`

**Signature:**
```powershell
function fdg
{
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `HKCU`

**Signature:**
```powershell
function HKCU:
{ Set-Location HKCU:
```

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `HKLM`

**Signature:**
```powershell
function HKLM:
{ Set-Location HKLM:
```

**Description:**

Drive shortcuts

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `n`

**Signature:**
```powershell
function n
{ notepad $args
```

**Description:**

Quick shortcut to start notepad

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

### `rgg`

**Signature:**
```powershell
function rgg
{
```

<sub>**Source:** `Core\System\fzf.ps1`</sub>

### `sha256`

**Signature:**
```powershell
function sha256
{ Get-FileHash -Algorithm SHA256 $args
```

**Description:**

FROM https://github.com/ChrisTitusTech/powershell-profile/ If so and the current host is a command line, then change to red color as warning to user that they are operating in an elevated context Useful shortcuts for traversing directories Compute file hashes - useful for checking successful downloads

<sub>**Source:** `Core\System\linuxLike.ps1`</sub>

## Utilities

### `akkorokamui`

**Signature:**
```powershell
function akkorokamui { ssh -p 54226 tears@192.168.1.100 }
```

**Description:**

SSH Aliases

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Clear-DnsCache`

**Signature:**
```powershell
function Clear-DnsCache { Clear-DnsClientCache }
Set-Alias -Name flushdns -Value Clear-DnsCache

# Clipboard Utilities
function Set-ClipboardContent {
```

**Description:**

Networking Utilities

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `df`

**Signature:**
```powershell
function df { get-volume }
function which($name) { Get-Command $name | Select-Object -ExpandProperty Definition }
```

**Description:**

System utilities

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Edit-FileContent`

**Signature:**
```powershell
function Edit-FileContent($file, $find, $replace) {
  (Get-Content $file).replace("$find", $replace) | Set-Content $file
}
Set-Alias -Name sed -Value Edit-FileContent

function Get-CommandPath($command) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Expand-CustomArchive`

**Signature:**
```powershell
function Expand-CustomArchive {
    param (
        [Parameter(Mandatory=$true)]
        [string]$File,
        [string]$Folder
    )
```

<sub>**Source:** `Core\Utils\FileSystemUtils.ps1`</sub>

### `Expand-MultipleArchive`

**Signature:**
```powershell
function Expand-MultipleArchive {
  $CurrentDate = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
  $Folder = "extracted_$($CurrentDate)"
  New-Item -Path $Folder -ItemType Directory | Out-Null
  foreach ($File in $args) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Expand-ZipFile`

**Signature:**
```powershell
function Expand-ZipFile($file) {
  Write-Output("Extracting", $file, "to", $pwd)
  $fullFile = Get-ChildItem -Path $pwd -Filter .\cove.zip | ForEach-Object { $_.FullName }
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Find-File`

**Signature:**
```powershell
function Find-File {
    param(
        [Parameter(Position=0)]
        [string]$pattern = "*",
        [string]$path = ".",
        [switch]$recurse,
        [int]$depth = 3
    )
```

**Description:**

Search utilities for PowerShell profile

<sub>**Source:** `Core\Utils\SearchUtils.ps1`</sub>

### `Find-PowerShellCommand`

**Signature:**
```powershell
function Find-PowerShellCommand {
    param([string]$name)
```

<sub>**Source:** `Core\Utils\SearchUtils.ps1`</sub>

### `Find-String`

**Signature:**
```powershell
function Find-String($regex, $dir) {
  if ($dir) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-ClipboardContent`

**Signature:**
```powershell
function Get-ClipboardContent { Get-Clipboard }
Set-Alias -Name pst -Value Get-ClipboardContent

# System utilities
function df { get-volume }
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-CommandPath`

**Signature:**
```powershell
function Get-CommandPath($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
Set-Alias -Name which -Value Get-CommandPath

# SSH Aliases
function akkorokamui { ssh -p 54226 tears@192.168.1.100 }
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-Font`

**Signature:**
```powershell
function Get-Font {
  param (
    $regex
  )
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-FormatedUptime`

**Signature:**
```powershell
function Get-FormatedUptime {
    $bootuptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    $CurrentDate = Get-Date
    $uptime = $CurrentDate - $bootuptime
    Write-Output "Uptime: $($uptime.Days) Days, $($uptime.Hours) Hours, $($uptime.Minutes) Minutes"
}

function Get-PubIP {
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `Get-GitStatus`

**Signature:**
```powershell
function Get-GitStatus { git status }
function Invoke-GitPull { git pull }
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-ProcessByName`

**Signature:**
```powershell
function Get-ProcessByName($name) { Get-Process $name }
Set-Alias -Name pgrep -Value Get-ProcessByName

# Search and find utilities
function find-file($name) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Get-PubIP`

**Signature:**
```powershell
function Get-PubIP {
    (Invoke-WebRequest http://ifconfig.me/ip).Content
}

function Initialize-EncodingConfig {
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `Get-PwshInstalled`

**Signature:**
```powershell
function Get-PwshInstalled {
    return Get-Command pwsh -ErrorAction SilentlyContinue
  }

  # Function to install PowerShell 7 using winget
  function Install-Pwsh {
```

**Description:**

Function to check if pwsh is installed

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `hb`

**Signature:**
```powershell
function hb {
  if ($args.Length -eq 0) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `head`

**Signature:**
```powershell
function head {
  param($Path, $n = 10)
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Initialize-Editor`

**Signature:**
```powershell
function Initialize-Editor {
  if ($script:EditorInitialized) { return }
```

**Description:**

Editor detection and configuration - lazy loaded

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Initialize-EncodingConfig`

**Signature:**
```powershell
function Initialize-EncodingConfig {
    $env:PYTHONIOENCODING = 'utf-8'
    [System.Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
    [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
}

# Create module manifest if it doesn't exist
if (-not (Test-Path "$moduleRoot\CommonUtils.psd1")) {
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `Install-Pwsh`

**Signature:**
```powershell
function Install-Pwsh {
    Write-Verbose "Installing PowerShell 7..."
    winget install --id Microsoft.Powershell --source winget -y
  }

  # Check if pwsh is installed
  if (-not (Get-PwshInstalled)) {
```

**Description:**

Function to install PowerShell 7 using winget

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Invoke-GitPull`

**Signature:**
```powershell
function Invoke-GitPull { git pull }
function Invoke-GitPush { git push }
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Invoke-GitPush`

**Signature:**
```powershell
function Invoke-GitPush { git push }
Set-Alias -Name gst -Value Get-GitStatus
Set-Alias -Name pull -Value Invoke-GitPull
Set-Alias -Name push -Value Invoke-GitPush

# Docker aliases
Set-Alias -Name d -Value docker
Set-Alias -Name dc -Value docker-compose

# Conditional aliases
$script:hasLazygit = Test-CommandExist 'lazygit'
if ($script:hasLazygit) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `ix`

**Signature:**
```powershell
function ix ($file) {
  curl.exe -F "f:1=@$file" ix.io
}

function Test-IsAdmin {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `la_with_eza`

**Signature:**
```powershell
function la_with_eza{
    $ezaOutput = eza --icons --git --color=always --group-directories-first --all
    if ($script:hasBat) {
```

**Description:**

this should be the same as ls -al no tree

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `ll`

**Signature:**
```powershell
function ll {
    Get-ChildItem | Format-Table -AutoSize -Property Mode, LastWriteTime, Length, Name
  }
  # Remove the alias if it exists to avoid circular reference
  Remove-Alias -Name ll -ErrorAction SilentlyContinue
}

# File and directory management
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `ll_with_eza`

**Signature:**
```powershell
function ll_with_eza {
    $ezaOutput = eza --icons --git --color=always --group-directories-first --long --header
    if ($script:hasBat) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `ls_with_eza`

**Signature:**
```powershell
function ls_with_eza {
    param([Parameter(ValueFromRemainingArguments = $true)]$params)
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `lt_with_eza`

**Signature:**
```powershell
function lt_with_eza {
    eza --icons --git --color=always --group-directories-first --long --header --tree --sort=name
  }
  Set-Alias -Name ls -Value ls_with_eza -Force -Option AllScope -Scope Global
  Set-Alias -Name ll -Value ll_with_eza -Force -Option AllScope -Scope Global
  Set-Alias -Name la -Value la_with_eza -Force -Option AllScope -Scope Global
  Set-Alias -Name lt -Value lt_with_eza -Force -Option AllScope -Scope Global
}
else {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `mkcd`

**Signature:**
```powershell
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }
function New-File {
```

**Description:**

File and directory management

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `New-DirectoryAndEnter`

**Signature:**
```powershell
function New-DirectoryAndEnter {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$dir)
```

**Description:**

File system utilities for PowerShell profile

<sub>**Source:** `Core\Utils\FileSystemUtils.ps1`</sub>

### `New-File`

**Signature:**
```powershell
function New-File {
    [CmdletBinding(SupportsShouldProcess)]
    param($file)
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `pretty_git_branch`

**Signature:**
```powershell
function pretty_git_branch
{
```

<sub>**Source:** `Core\Utils\Development\gitHelpers.ps1`</sub>

### `pretty_git_branch_sorted`

**Signature:**
```powershell
function pretty_git_branch_sorted
{
```

<sub>**Source:** `Core\Utils\Development\gitHelpers.ps1`</sub>

### `pretty_git_format`

**Signature:**
```powershell
function pretty_git_format
{
```

<sub>**Source:** `Core\Utils\Development\gitHelpers.ps1`</sub>

### `pretty_git_log`

**Signature:**
```powershell
function pretty_git_log
{
```

<sub>**Source:** `Core\Utils\Development\gitHelpers.ps1`</sub>

### `Reset-ProfileState`

**Signature:**
```powershell
function Reset-ProfileState {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$Quiet
    )
```

<sub>**Source:** `Core\Utils\profile_management.ps1`</sub>

### `Restart-BIOS`

**Signature:**
```powershell
function Restart-BIOS {
    [CmdletBinding(SupportsShouldProcess)]
    param()
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Search-FileContent`

**Signature:**
```powershell
function Search-FileContent {
    param(
        [Parameter(Mandatory=$true)]
        [string]$pattern,
        [string]$path = ".",
        [string]$filter = "*.*",
        [switch]$caseSensitive
    )
```

<sub>**Source:** `Core\Utils\SearchUtils.ps1`</sub>

### `Set-ClipboardContent`

**Signature:**
```powershell
function Set-ClipboardContent {
    [CmdletBinding(SupportsShouldProcess)]
    param($content)
```

**Description:**

Clipboard Utilities

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Set-EnvironmentVariable`

**Signature:**
```powershell
function Set-EnvironmentVariable {
    [CmdletBinding(SupportsShouldProcess)]
    param($name, $value)
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `show_git_head`

**Signature:**
```powershell
function show_git_head
{
```

<sub>**Source:** `Core\Utils\Development\gitHelpers.ps1`</sub>

### `Stop-ProcessByName`

**Signature:**
```powershell
function Stop-ProcessByName {
    [CmdletBinding(SupportsShouldProcess)]
    param($name)
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `sysinfo`

**Signature:**
```powershell
function sysinfo { Get-ComputerInfo }

# Networking Utilities
function Clear-DnsCache { Clear-DnsClientCache }
```

**Description:**

Quick Access to System Information

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `tail`

**Signature:**
```powershell
function tail {
  param($Path, $n = 10)
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `Test-CommandExist`

**Signature:**
```powershell
function Test-CommandExist {
    [CmdletBinding()]
    param([string]$command)
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `Test-IsAdmin`

**Signature:**
```powershell
function Test-IsAdmin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-FormatedUptime {
```

<sub>**Source:** `Core\Utils\CommonUtils.ps1`</sub>

### `Upgrade`

**Signature:**
```powershell
function Upgrade {
  # Function to check if pwsh is installed
  function Get-PwshInstalled {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `uptime`

**Signature:**
```powershell
function uptime {
  If ($PSVersionTable.PSVersion.Major -eq 5) {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `v`

**Signature:**
```powershell
function v {
  if (-not $script:EditorInitialized) { Initialize-Editor }
```

**Description:**

Lazy editor alias that initializes on first use

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

### `which`

**Signature:**
```powershell
function which($name) { Get-Command $name | Select-Object -ExpandProperty Definition }

function Set-EnvironmentVariable {
```

<sub>**Source:** `Core\Utils\unified_aliases.ps1`</sub>

