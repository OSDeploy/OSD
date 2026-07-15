function Start-RecastOSDCloudCLI {
    <#
    .SYNOPSIS
    Starts the Recast OSDCloud command-line deployment workflow.

    .DESCRIPTION
    Initializes device and deployment context, discovers matching operating systems,
    resolves driver pack metadata for the current device (or supplied overrides),
    validates required dependencies, and prepares global state consumed by
    the Recast OSDCloud CLI workflow.

    .PARAMETER OSArchitecture
    Operating system architecture used when selecting catalog entries.
    Supported values are amd64 and arm64.

    .PARAMETER OSReleaseID
    Operating system release identifier used for catalog selection.

    .PARAMETER OSLanguageCode
    Operating system language code used for catalog selection.
    If not specified, the value is inferred from the current keyboard layout.

    .PARAMETER OSActivation
    Operating system activation channel used for catalog selection.

    .PARAMETER OSEdition
    Operating system edition used for catalog selection.
    Valid values depend on OSArchitecture at runtime.

    .PARAMETER OSDManufacturer
    Overrides the detected computer manufacturer for driver pack matching.
    If omitted, the detected device manufacturer is used.

    .PARAMETER OSDModel
    Overrides the detected computer model for logging and context alignment.
    If omitted, the detected device model is used.

    .PARAMETER OSDProduct
    Overrides the detected computer product/system ID for driver pack matching.
    If omitted, the detected device product value is used.

    .EXAMPLE
    Start-RecastOSDCloudCLI
    Starts OSDCloud CLI using detected device values and default deployment selection.

    .EXAMPLE
    Start-RecastOSDCloudCLI -OSArchitecture arm64 -OSEdition Pro -OSReleaseID 24H2
    Starts OSDCloud CLI for an ARM64 Windows 11 Pro 24H2 deployment selection.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-09 - Standardized comment-based help metadata and links.
    2026-07-14 - Updated help content for CLI-specific behavior and parameter documentation.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, HelpMessage = 'Operating system architecture for deployment selection.')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('amd64','arm64')]
        [string]
        $OSArchitecture = $env:PROCESSOR_ARCHITECTURE,

        [Parameter(Mandatory = $false, HelpMessage = 'Operating system release identifier for deployment selection.')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('25H2','24H2','23H2','22H2','21H2')]
        [string]
        $OSReleaseID = '25H2',

        [Parameter(Mandatory = $false, HelpMessage = 'Operating system language code for deployment selection.')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet (
            'ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','en-us','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw'
        )]
        [string]
        $OSLanguageCode,

        [Parameter(Mandatory = $false, HelpMessage = 'Operating system activation channel for deployment selection.')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Retail','Volume')]
        [string]
        $OSActivation = 'Retail',

        [Parameter(Mandatory = $false, HelpMessage = 'Operating system edition identifier for deployment selection.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $OSEdition = 'Pro',

        [Parameter(Mandatory = $false, HelpMessage = 'Optional manufacturer override used for driver pack selection.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $OSDManufacturer,

        [Parameter(Mandatory = $false, HelpMessage = 'Optional model override used for driver pack selection.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $OSDModel,

        [Parameter(Mandatory = $false, HelpMessage = 'Optional product/system ID override used for driver pack selection.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $OSDProduct
    )
    #=================================================
    # Emit function/version context and surface legacy parameter usage.
    $ModuleVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] $ModuleVersion"
    #=================================================
    # Resolve architecture-specific edition constraints and normalize edition metadata.
    $OSEditionValuesByArchitecture = @{
        amd64 = @('Home','Home N','Education','Education N','Pro','Pro N','Enterprise','Enterprise N')
        arm64 = @('Home','Pro','Enterprise')
    }
    if (-not $OSEditionValuesByArchitecture.ContainsKey($OSArchitecture)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unsupported OSArchitecture '$OSArchitecture'."
    }

    $OSEditionValues = $OSEditionValuesByArchitecture[$OSArchitecture]
    if ($OSEdition -notin $OSEditionValues) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSEdition '$OSEdition' is not valid for OSArchitecture '$OSArchitecture'. Valid values: $($OSEditionValues -join ', ')."
    }

    $OSEditionIdByName = @{
        'Home' = 'Core'
        'Home N' = 'CoreN'
        'Education' = 'Education'
        'Education N' = 'EducationN'
        'Pro' = 'Professional'
        'Pro N' = 'ProfessionalN'
        'Enterprise' = 'Enterprise'
        'Enterprise N' = 'EnterpriseN'
    }
    $OSEditionId = $OSEditionIdByName[$OSEdition]
    #=================================================
    # OSDCoreDevice
    if (-not ($global:OSDCoreDevice)) {
        Initialize-OSDCoreDevice
    }
    #=================================================
    # OSDCoreOperatingSystems
    if ($PSBoundParameters.ContainsKey('OSArchitecture')) {
        $global:OSDCoreOperatingSystems = Get-OSDCoreOperatingSystems | Where-Object { $_.Architecture -match "$OSArchitecture" }
    }

    # Validate that the OS catalog was preloaded for this architecture.
    if (-not $global:OSDCoreOperatingSystems) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to load Operating Systems"
    }

    # Automatically determine default OSLanguageCode from the detected keyboard layout if not explicitly provided.
    if (-not $PSBoundParameters.ContainsKey('OSLanguageCode')) {
        if (Get-Command -Name 'Convert-KeyboardLayoutToLanguageCode' -ErrorAction SilentlyContinue) {
            $OSLanguageCode = Convert-KeyboardLayoutToLanguageCode -KeyboardLayout $global:OSDCoreDevice.KeyboardLayout -FallbackLanguageCode 'en-US'
        }
        else {
            $OSLanguageCode = 'en-US'
        }
    }

    # Select the matching operating system object from the preloaded catalog based on the provided or default parameters.
    $global:OSDCoreOperatingSystemObject = $global:OSDCoreOperatingSystems | `
        Where-Object { $_.Activation -eq $OSActivation } | `
        Where-Object { $_.Architecture -match $OSArchitecture } | `
        Where-Object { $_.Language -eq $OSLanguageCode } | `
        Where-Object { $_.ReleaseID -eq $OSReleaseID } | `
        Where-Object { $_.Version -eq 'Windows 11' }

    if (-not $global:OSDCoreOperatingSystemObject) {
        throw "[$(Get-Date -format s)] Unable to find a matching operating system object for OSReleaseID '$OSReleaseID', OSArchitecture '$OSArchitecture', Activation '$OSActivation', and Language '$OSLanguageCode'."
    }
    #=================================================
    # OSDCoreDriverPacks
    # Resolve driver pack metadata for the detected device, with optional manufacturer overrides supplied by the caller.
    if ($PSBoundParameters.ContainsKey('OSDManufacturer')) {
        $global:OSDCoreDevice.OSDManufacturer = $OSDManufacturer
        $global:OSDCoreDriverPacks = Get-OSDCoreDriverPacks -OSDManufacturer $OSDManufacturer
    }

    # Resolve driver pack metadata for the detected device, with optional model overrides supplied by the caller.
    if ($PSBoundParameters.ContainsKey('OSDModel')) {
        $global:OSDCoreDevice.OSDModel = $OSDModel
    }

    # Resolve driver pack metadata for the detected device, with optional product overrides supplied by the caller.
    if ($PSBoundParameters.ContainsKey('OSDProduct')) {
        $global:OSDCoreDevice.OSDProduct = $OSDProduct
    }
    $global:OSDCoreDriverPackObject = $global:OSDCoreDriverPacks | Where-Object { $_.SystemId -match $global:OSDCoreDevice.OSDProduct } | Select-Object -First 1
    #================================================
    #   Output OSDCore Objects
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDManufacturer: $($global:OSDCoreDevice.OSDManufacturer)"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDModel: $($global:OSDCoreDevice.OSDModel)"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDProduct: $($global:OSDCoreDevice.OSDProduct)"
    if ($global:OSDCoreDriverPackObject) {
        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] OSDCoreDriverPackObject:"
        $global:OSDCoreDriverPackObject | Out-Host
    }
    if ($global:OSDCoreOperatingSystemObject) {
        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] OSDCoreOperatingSystemObject:"
        $global:OSDCoreOperatingSystemObject | Out-Host
    }
    #=================================================
    # Dependency guard: OSDCloud relies on curl.exe for downloads.
    if (-not (Get-Command -Name 'curl.exe' -ErrorAction SilentlyContinue)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCloud requires 'curl.exe' which is not available on this system. Please ensure curl.exe is available in the system PATH."
    }
    #=================================================
    # Detect candidate deployment disk(s).
    $DeploymentDiskObject = Get-OSDCoreDeploymentDisk

    # Stop immediately if no eligible local deployment disk is found.
    if (-not $DeploymentDiskObject) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCloud requires at least one Local Disk, but no compatible Local Disk was found."
    }
    # If multiple disks are discovered, keep behavior deterministic by using
    # the first disk and logging all candidates for troubleshooting visibility.
    if (@($DeploymentDiskObject).Count -gt 1) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Multiple Local Disks were found. OSDCloud will default to DiskNumber: $($DeploymentDiskObject[0].DiskNumber)"
        $DeploymentDiskObject | ForEach-Object {
            Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DiskNumber: $($_.DiskNumber), FriendlyName: $($_.FriendlyName), Size(GB): $([math]::Round($_.Size / 1GB, 2))"
        }
    }
    # Limit to the selected disk object expected by downstream workflow code.
    $DeploymentDiskObject = $DeploymentDiskObject | Select-Object -First 1
    #=================================================
    # Build deployment state consumed by the broader OSDCloud workflow.
    $global:OSDCloudDeploy = $null
    $global:OSDCloudDeploy = [ordered]@{
        DeploymentDiskObject  = $DeploymentDiskObject
        # DriverFolderName          = $null
        # DriverFolderNames         = @()
        # DriverFolderPath          = $null
        # DriverFolderPaths         = @()
        # DriverFolderSelections    = @()
        # DriverPackName        = $DriverPackName
        # DriverPackObject      = $DriverPackObject
        # DriverPackValues      = [array]$DriverPackValues
        # Flows                     = [array]$global:OSDCloudWorkflowTasks
        Function              = $($MyInvocation.MyCommand.Name)
        # ImageFileName         = $ImageFileName
        # ImageFileUrl          = $ImageFileUrl
        LaunchMethod          = 'RecastOSDCloud'
        Module                = $($MyInvocation.MyCommand.Module.Name)
        OperatingSystem       = $OperatingSystem
        # OperatingSystemObject = $OperatingSystemObject
        # OperatingSystemValues = $OperatingSystemValues
        OSActivation          = $OSActivation
        OSActivationValues    = $OSActivationValues
        OSArchitecture        = $OSArchitecture
        OSBuild               = $OSBuild
        OSBuildVersion        = $OSBuildVersion
        OSEdition             = $OSEdition
        OSEditionId           = $OSEditionId
        OSEditionValues       = $OSEditionValues
        OSLanguageCode        = $OSLanguageCode
        OSLanguageCodeValues  = $OSLanguageCodeValues
        OSVersion             = $OSVersion
        TimeStart             = $null
        # WorkflowName              = $WorkflowName
        # WorkflowTaskName          = $WorkflowTaskName
        # WorkflowTaskObject        = $WorkflowTaskObject
    }
    #================================================
    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] Starting Invoke-RecastOSDCloud in 5 seconds ..."
    Start-Sleep -Seconds 5
    Invoke-RecastOSDCloud
    #================================================
}
