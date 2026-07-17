function Start-RecastOSDCloudGUI {
    <#
    .SYNOPSIS
    Starts the Recast OSDCloud graphical deployment workflow.

    .DESCRIPTION
    Initializes device and deployment context, discovers matching operating systems,
    resolves driver pack metadata for the current device (or supplied overrides),
    validates required dependencies, and then prepares global state consumed by
    the Recast OSDCloud GUI workflow.

    .PARAMETER BrandName
    Sets the branding text shown in the OSDCloud GUI title/header.
    Defaults to the module resource value.

    .PARAMETER BrandColor
    Sets the branding color shown in the OSDCloud GUI.
    Provide a hex color value, for example '#0096D6'.

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

    .PARAMETER v2
    Legacy compatibility switch. This parameter is non-functional and retained
    temporarily to avoid breaking existing scripts.

    .EXAMPLE
    Start-RecastOSDCloudGUI
    Starts OSDCloud GUI using detected device values and default branding.

    .EXAMPLE
    Start-RecastOSDCloudGUI -BrandName 'Contoso' -BrandColor '#005A9C'
    Starts OSDCloud GUI with custom branding.

    .EXAMPLE
    Start-RecastOSDCloudGUI -OSArchitecture arm64 -OSEdition Pro -OSReleaseID 24H2
    Starts OSDCloud GUI with an ARM64 Windows 11 Pro 24H2 deployment selection.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-09 - Standardized comment-based help metadata and links.
    2026-07-09 - The -v2 parameter is deprecated and will be removed in a future release.
    2026-07-14 - Added complete parameter help coverage and updated examples.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, HelpMessage = 'Custom brand text for the OSDCloud GUI.')]
        [Alias('Brand')]
        [ValidateNotNullOrEmpty()]
        [string]
        $BrandName = $Global:OSDModuleResource.StartOSDCloudGUI.BrandName,

        [Parameter(Mandatory = $false, HelpMessage = 'Brand color in hex format (for example #0096D6).')]
        [Alias('Color')]
        [ValidatePattern('^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})$')]
        [string]
        $BrandColor = $Global:OSDModuleResource.StartOSDCloudGUI.BrandColor,

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
        $OSDProduct,

        [Parameter(Mandatory = $false, HelpMessage = 'Legacy compatibility switch. This parameter is deprecated and non-functional.')]
        [System.Management.Automation.SwitchParameter]
        $v2
    )
    #=================================================
    # Parameter Changes
    if ($v2) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] v2 parameter is deprecated and non-functional and will be removed in a future release. Please remove the v2 parameter from your command."
    }
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
        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] OSDCoreDriverPackObject"
        $global:OSDCoreDriverPackObject | Out-Host
    }
    if ($global:OSDCoreOperatingSystemObject) {
        Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] OSDCoreOperatingSystemObject"
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
    $global:RecastOSDeploy = $null
    $global:RecastOSDeploy = [ordered]@{
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
        LaunchMethod          = 'RecastOSDCloudGUI'
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
    # Build GUI configuration defaults from module resources and current device context.
    $Global:OSDCloudGUI = $null
    $Global:OSDCloudGUI = [ordered]@{
        Function              = [System.String]'Start-RecastOSDCloudGUI'
        LaunchMethod          = [System.String]'OSDCloudGUI'
        AutomateConfiguration = $null
        AutomateJsonFile      = $null
        BrandName             = [System.String]$BrandName
        BrandColor            = [System.String]$BrandColor
        ComputerManufacturer  = [System.String]$OSDManufacturer
        ComputerModel         = [System.String]$OSDModel
        ComputerProduct       = [System.String]$OSDProduct
        # DriverPack                  = $null
        # DriverPacks                 = $null
        # DriverPackName        = $DriverPackName
        # DriverPackObject      = $DriverPackObject
        # DriverPackValues      = [array]$DriverPackValues
        IsOnBattery           = [System.Boolean]$global:OSDCoreDevice.IsOnBattery
        OSActivation          = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Activation
        OSEdition             = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Edition
        OSLanguage            = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Language
        OSImageIndex          = [System.Int32]$Global:OSDModuleResource.OSDCloud.Default.ImageIndex
        OSName                = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Name
        OSReleaseID           = [System.String]$Global:OSDModuleResource.OSDCloud.Default.ReleaseID
        OSVersion             = [System.String]$Global:OSDModuleResource.OSDCloud.Default.Version
        OSActivationValues    = [array]$Global:OSDModuleResource.OSDCloud.Values.Activation
        OSEditionValues       = [array]$Global:OSDModuleResource.OSDCloud.Values.Edition
        OSLanguageValues      = [array]$Global:OSDModuleResource.OSDCloud.Values.Language
        OSNameValues          = [array]$Global:OSDModuleResource.OSDCloud.Values.Name
        OSNameARM64Values     = [array]$Global:OSDModuleResource.OSDCloud.Values.NameARM64
        OSReleaseIDValues     = [array]$Global:OSDModuleResource.OSDCloud.Values.ReleaseID
        OSVersionValues       = [array]$Global:OSDModuleResource.OSDCloud.Values.Version

        ClearDiskConfirm      = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.ClearDiskConfirm
        restartComputer       = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.restartComputer

        updateDiskDrivers     = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateDiskDrivers
        updateFirmware        = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateFirmware
        updateNetworkDrivers  = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateNetworkDrivers
        updateSCSIDrivers     = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.updateSCSIDrivers
        SyncMSUpCatDriverUSB  = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.SyncMSUpCatDriverUSB

        OEMActivation         = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.OEMActivation
        WindowsUpdate         = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.WindowsUpdate
        WindowsUpdateDrivers  = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.WindowsUpdateDrivers
        WindowsDefenderUpdate = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.WindowsDefenderUpdate

        HPIAALL               = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPIAALL
        HPIADrivers           = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPIADrivers
        HPIAFirmware          = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPIAFirmware
        HPIASoftware          = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPIASoftware
        HPTPMUpdate           = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPTPMUpdate
        HPBIOSUpdate          = [System.Boolean]$Global:OSDModuleResource.StartOSDCloudGUI.HPBIOSUpdate

        TimeStart             = [datetime](Get-Date)
    }
    #================================================
    # Export baseline GUI settings, then look for external automation JSON
    # on non-C drives to override interactive defaults when present.
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Exporting default configuration to $env:Temp\Start-RecastOSDCloudGUI.json"
    $Global:OSDCloudGUI | ConvertTo-Json -Depth 10 | Out-File -FilePath "$env:TEMP\Start-RecastOSDCloudGUI.json" -Force

    $Global:OSDCloudGUI.AutomateJsonFile = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -ne 'C' } | ForEach-Object {
        Get-ChildItem "$($_.Root)OSDCloud\Automate" -Include "Start-RecastOSDCloudGUI.json" -File -Force -Recurse -ErrorAction Ignore
    }
    if ($Global:OSDCloudGUI.AutomateJsonFile) {
        foreach ($Item in $Global:OSDCloudGUI.AutomateJsonFile) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $($Item.FullName)"
            $Global:OSDCloudGUI.AutomateConfiguration = Get-Content -Path "$($Item.FullName)" -Raw | ConvertFrom-Json -ErrorAction "Stop" | ConvertTo-Hashtable
        }
    }
    if ($Global:OSDCloudGUI.AutomateConfiguration) {
        # Apply each discovered automation setting onto the active GUI config.
        foreach ($Key in $Global:OSDCloudGUI.AutomateConfiguration.Keys) {
            $Global:OSDCloudGUI.$Key = $Global:OSDCloudGUI.AutomateConfiguration.$Key
        }
    }
    #================================================
    $Global:OSDCloudGuiBranding = @{
        Title = $Global:OSDCloudGUI.BrandName
        Color = $Global:OSDCloudGUI.BrandColor
    }
    Write-Host -ForegroundColor Green "OSDCloudGUI Configuration"
    $Global:OSDCloudGUI | Out-Host
    #================================================
    # Launch the WPF GUI entry point with the prepared global state.
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\RecastOSDCloudGUI\MainWindow.ps1"
    Start-Sleep -Seconds 2
    #================================================
}
