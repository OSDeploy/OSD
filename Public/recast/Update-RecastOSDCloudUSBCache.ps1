function Update-RecastOSDCloudUSBCache {
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
    https://github.com/OSDeploy/OSD/tree/master/docs

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
        $OSDProduct,

        [Parameter(Mandatory = $false, HelpMessage = 'WinPE Post Action.')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Quit','Restart','Shutdown')]
        [string]
        $WinPEPostAction = 'Quit'
    )
    #=================================================
    # Emit function/version context and surface legacy parameter usage.
    $ModuleVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] $ModuleVersion"
    #=================================================
    # Dependency guard: OSDCloud relies on curl.exe for downloads.
    if (-not (Get-Command -Name 'curl.exe' -ErrorAction SilentlyContinue)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCloud requires 'curl.exe' which is not available on this system. Please ensure curl.exe is available in the system PATH."
    }
    #=================================================
    # Require an eligible USB cache before doing any online catalog or download work.
    $osdCoreCacheUsbPath = Get-OSDCoreCachePathUSB | Select-Object -First 1
    if (-not $osdCoreCacheUsbPath) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] No eligible OSDCoreCache USB drive was detected. Connect a USB drive with an OSDCloud directory, NTFS or exFAT format, and more than 10 GB free."
    }
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCoreCache USB is available at $osdCoreCacheUsbPath"
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
    if ([string]::IsNullOrWhiteSpace($OSEditionId)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to resolve OSEditionId for OSEdition '$OSEdition'."
    }
    Write-Verbose -Message ('[{0}] [{1}] OSEditionId: {2}' -f (Get-Date -format s), $MyInvocation.MyCommand.Name, $OSEditionId)
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
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to load OperatingSystem Catalog"
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

    # Select and set the matching operating system object using core selection logic.
    $global:OSDCoreOperatingSystemObject = Set-OSDCoreOperatingSystemObject `
        -OSActivation $OSActivation `
        -OSArchitecture $OSArchitecture `
        -OSLanguageCode $OSLanguageCode `
        -OSReleaseID $OSReleaseID `
        -OSVersion 'Windows 11'

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
    # OSDCoreOperatingSystemObject
    if ($global:OSDCoreOperatingSystemObject) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Verifying OSDCoreOperatingSystemObject."
        # Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] OSDCoreOperatingSystemObject:"
        $tempOSDCoreOperatingSystemObject = $global:OSDCoreOperatingSystemObject | Select-Object -Property Name, FileName, Url, SHA1, SHA256
        # $global:OSDCoreOperatingSystemObject | Out-Host
        $tempOSDCoreOperatingSystemObject | Out-Host

        # Confirm the selected operating system download URL before offering cache download work.
        $osdCoreOperatingSystemObjectUrlReachable = Test-OSDCoreOperatingSystemObjectUrl -OperatingSystemObject $global:OSDCoreOperatingSystemObject
        if ($osdCoreOperatingSystemObjectUrlReachable) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OperatingSystem URL is reachable. OK."
        }
        else {
            Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] OperatingSystem URL is not reachable."
        }

        # Prefer SHA256 when the catalog provides it, and fall back to SHA1 for older entries.
        $expectedOperatingSystemHash = $null
        $expectedOperatingSystemHashAlgorithm = $null
        if (-not [string]::IsNullOrWhiteSpace([string]$global:OSDCoreOperatingSystemObject.SHA256)) {
            $expectedOperatingSystemHash = [string]$global:OSDCoreOperatingSystemObject.SHA256
            $expectedOperatingSystemHashAlgorithm = 'SHA256'
        }
        elseif (-not [string]::IsNullOrWhiteSpace([string]$global:OSDCoreOperatingSystemObject.SHA1)) {
            $expectedOperatingSystemHash = [string]$global:OSDCoreOperatingSystemObject.SHA1
            $expectedOperatingSystemHashAlgorithm = 'SHA1'
        }

        # Check whether the selected OS payload is already present in the USB cache inventory.
        $osdCoreOperatingSystemCacheContent = Get-OSDCoreCacheOperatingSystemObject -OperatingSystemObject $global:OSDCoreOperatingSystemObject
        if ($osdCoreOperatingSystemCacheContent) {
            # Verify the cached payload before treating it as ready.
            if (-not [string]::IsNullOrWhiteSpace($expectedOperatingSystemHash)) {
                $actualOperatingSystemHash = (Get-FileHash -Path $osdCoreOperatingSystemCacheContent.FullName -Algorithm $expectedOperatingSystemHashAlgorithm -ErrorAction Stop).Hash
                if ($actualOperatingSystemHash -ne $expectedOperatingSystemHash.Trim()) {
                    throw "[$(Get-Date -format s)] OSDCoreOperatingSystemObject $expectedOperatingSystemHashAlgorithm hash mismatch for $($osdCoreOperatingSystemCacheContent.FullName). Expected $($expectedOperatingSystemHash.Trim()), found $actualOperatingSystemHash."
                }
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OperatingSystem cached file $expectedOperatingSystemHashAlgorithm hash verified. OK."
            }
            else {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OperatingSystem cached file hash was not verified because no hash property was available."
            }
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OperatingSystem is ready at $($osdCoreOperatingSystemCacheContent.FullName)."
        }
        else {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OperatingSystem is not available on a USB drive."

            # Do not offer a download when the catalog URL cannot be reached.
            if (-not $osdCoreOperatingSystemObjectUrlReachable) {
                Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] OperatingSystem download was not offered because the URL is not reachable."
            }
            elseif (Test-OSDCoreCacheUSB) {
                $osdCoreCacheUsbPath = Get-OSDCoreCachePathUSB | Select-Object -First 1
                if ($osdCoreCacheUsbPath) {
                    # Build the destination path used by the USB cache OS folder layout.
                    $osdCoreOperatingSystemDestinationChildPath = "$($global:OSDCoreOperatingSystemObject.Version) $($global:OSDCoreOperatingSystemObject.ReleaseID)"
                    $osdCoreOperatingSystemDestination = [System.IO.Path]::GetFullPath((Join-Path -Path (Join-Path -Path ([string]$osdCoreCacheUsbPath) -ChildPath 'OS') -ChildPath $osdCoreOperatingSystemDestinationChildPath))
                    $osdCoreOperatingSystemDestinationFullName = Join-Path -Path $osdCoreOperatingSystemDestination -ChildPath ([string]$global:OSDCoreOperatingSystemObject.FileName)
                    $downloadOperatingSystem = $true

                    # If the destination file already exists and verifies, skip the interactive download prompt.
                    if (Test-Path -LiteralPath $osdCoreOperatingSystemDestinationFullName) {
                        if (-not [string]::IsNullOrWhiteSpace($expectedOperatingSystemHash)) {
                            $actualOperatingSystemHash = (Get-FileHash -Path $osdCoreOperatingSystemDestinationFullName -Algorithm $expectedOperatingSystemHashAlgorithm -ErrorAction Stop).Hash
                            if ($actualOperatingSystemHash -ne $expectedOperatingSystemHash.Trim()) {
                                throw "[$(Get-Date -format s)] OperatingSystem $expectedOperatingSystemHashAlgorithm hash mismatch for $osdCoreOperatingSystemDestinationFullName. Expected $($expectedOperatingSystemHash.Trim()), found $actualOperatingSystemHash."
                            }
                            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OperatingSystem existing file $expectedOperatingSystemHashAlgorithm hash verified. OK."
                        }
                        else {
                            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OperatingSystem already exists at $osdCoreOperatingSystemDestinationFullName. No hash property was available to verify."
                        }
                        $global:OSDCoreCacheContent = Get-OSDCoreCacheContent
                        $downloadOperatingSystem = $false
                    }

                    # Prompt before downloading the OS payload because it can be large.
                    $caption = 'Download OperatingSystem to OSDCoreCache USB'
                    $message = "Download $($global:OSDCoreOperatingSystemObject.FileName) to: $osdCoreOperatingSystemDestination"
                    $choices = @(
                        (New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Download the OperatingSystem to the USB cache.'),
                        (New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Skip the OperatingSystem download.')
                    )
                    if ($downloadOperatingSystem -and ($host.UI.PromptForChoice($caption, $message, $choices, 1) -eq 0)) {
                        $savedOperatingSystem = Invoke-OSDCoreDownloadFile -SourceUrl $global:OSDCoreOperatingSystemObject.Url -DestinationDirectory $osdCoreOperatingSystemDestination -DestinationName $global:OSDCoreOperatingSystemObject.FileName -ErrorAction Stop

                        # Verify the downloaded payload before refreshing the cache inventory.
                        if (-not [string]::IsNullOrWhiteSpace($expectedOperatingSystemHash)) {
                            $actualOperatingSystemHash = (Get-FileHash -Path $savedOperatingSystem.FullName -Algorithm $expectedOperatingSystemHashAlgorithm -ErrorAction Stop).Hash
                            if ($actualOperatingSystemHash -ne $expectedOperatingSystemHash.Trim()) {
                                throw "[$(Get-Date -format s)] OSDCoreOperatingSystemObject $expectedOperatingSystemHashAlgorithm hash mismatch for $($savedOperatingSystem.FullName). Expected $($expectedOperatingSystemHash.Trim()), found $actualOperatingSystemHash."
                            }
                            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCoreOperatingSystemObject $expectedOperatingSystemHashAlgorithm hash verified. OK."
                        }
                        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDCoreOperatingSystemObject downloaded to $($savedOperatingSystem.FullName)"
                        $global:OSDCoreCacheContent = Get-OSDCoreCacheContent
                    }
                }
                else {
                    Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] No eligible OSDCoreCache USB path is available for OperatingSystem download."
                }
            }
            else {
                Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] No eligible OSDCoreCache USB drive is available for OperatingSystem download."
            }
        }
    } else {
        Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] OSDCoreOperatingSystemObject is not set."
        Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] OSDCloud will not function on this device or on this network."
    }
    #================================================
    # OSDCoreDriverPackObject
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDManufacturer: $($global:OSDCoreDevice.OSDManufacturer)"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDModel: $($global:OSDCoreDevice.OSDModel)"
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSDProduct: $($global:OSDCoreDevice.OSDProduct)"
    if ($global:OSDCoreDriverPackObject) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Verifying OSDCoreDriverPackObject."
        $global:OSDCoreDriverPackObject | Out-Host

        $osdCoreDriverPackObjectUrlReachable = Test-OSDCoreDriverPackObjectUrl -DriverPackObject $global:OSDCoreDriverPackObject
        if ($osdCoreDriverPackObjectUrlReachable) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack URL is reachable. OK."
        }
        else {
            Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] DriverPack URL is not reachable."
        }

        # Driver pack catalogs use either HashMD5 or MD5Hash depending on the source.
        $expectedDriverPackHashMD5 = $null
        if ($global:OSDCoreDriverPackObject.PSObject.Properties.Match('HashMD5').Count -gt 0) {
            $expectedDriverPackHashMD5 = [string]$global:OSDCoreDriverPackObject.HashMD5
        }
        elseif ($global:OSDCoreDriverPackObject.PSObject.Properties.Match('MD5Hash').Count -gt 0) {
            $expectedDriverPackHashMD5 = [string]$global:OSDCoreDriverPackObject.MD5Hash
        }

        # Check whether the selected driver pack is already present in the cache inventory.
        $osdCoreDriverPackCacheContent = Get-OSDCoreCacheDriverPackObject -DriverPackObject $global:OSDCoreDriverPackObject
        if ($osdCoreDriverPackCacheContent) {
            # Verify cached driver pack integrity when the catalog includes an MD5 hash.
            if (-not [string]::IsNullOrWhiteSpace($expectedDriverPackHashMD5)) {
                $actualDriverPackHashMD5 = (Get-FileHash -Path $osdCoreDriverPackCacheContent.FullName -Algorithm MD5 -ErrorAction Stop).Hash
                if ($actualDriverPackHashMD5 -ne $expectedDriverPackHashMD5.Trim()) {
                    throw "[$(Get-Date -format s)] DriverPack MD5 hash mismatch for $($osdCoreDriverPackCacheContent.FullName). Expected $($expectedDriverPackHashMD5.Trim()), found $actualDriverPackHashMD5."
                }
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack cached file MD5 hash verified. OK."
            }
            else {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack cached file hash was not verified because no MD5 hash property was available."
            }
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack is ready at $($osdCoreDriverPackCacheContent.FullName)"
        }
        else {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack is not available on a USB Drive."

            # Do not offer a download when the driver pack URL cannot be reached.
            if (-not $osdCoreDriverPackObjectUrlReachable) {
                Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] DriverPack download was not offered because the URL is not reachable."
            }
            elseif (Test-OSDCoreCacheUSB) {
                $osdCoreCacheUsbPath = Get-OSDCoreCachePathUSB | Select-Object -First 1
                if ($osdCoreCacheUsbPath) {
                    # Store driver packs under the cache DriverPacks folder by manufacturer.
                    $osdCoreDriverPackDestination = [System.IO.Path]::GetFullPath((Join-Path -Path (Join-Path -Path ([string]$osdCoreCacheUsbPath) -ChildPath 'DriverPacks') -ChildPath ([string]$global:OSDCoreDriverPackObject.Manufacturer)))
                    $osdCoreDriverPackDestinationFullName = Join-Path -Path $osdCoreDriverPackDestination -ChildPath ([string]$global:OSDCoreDriverPackObject.FileName)
                    $downloadDriverPack = $true

                    # If a valid destination file already exists, refresh cache content and skip download.
                    if (Test-Path -LiteralPath $osdCoreDriverPackDestinationFullName) {
                        if (-not [string]::IsNullOrWhiteSpace($expectedDriverPackHashMD5)) {
                            $actualDriverPackHashMD5 = (Get-FileHash -Path $osdCoreDriverPackDestinationFullName -Algorithm MD5 -ErrorAction Stop).Hash
                            if ($actualDriverPackHashMD5 -ne $expectedDriverPackHashMD5.Trim()) {
                                throw "[$(Get-Date -format s)] DriverPack MD5 hash mismatch for $osdCoreDriverPackDestinationFullName. Expected $($expectedDriverPackHashMD5.Trim()), found $actualDriverPackHashMD5."
                            }
                            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack existing file MD5 hash verified. OK."
                        }
                        else {
                            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack already exists at $osdCoreDriverPackDestinationFullName. No MD5 hash property was available to verify."
                        }
                        $global:OSDCoreCacheContent = Get-OSDCoreCacheContent
                        $downloadDriverPack = $false
                    }

                    # Prompt before downloading because driver packs can be large and vendor-specific.
                    $caption = 'Download DriverPack to OSDCoreCache USB'
                    $message = "Download $($global:OSDCoreDriverPackObject.FileName) to: $osdCoreDriverPackDestination"
                    $choices = @(
                        (New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Download the driver pack to the USB cache.'),
                        (New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Skip the driver pack download.')
                    )
                    if ($downloadDriverPack -and ($host.UI.PromptForChoice($caption, $message, $choices, 1) -eq 0)) {
                        $savedDriverPack = Invoke-OSDCoreDownloadFile -SourceUrl $global:OSDCoreDriverPackObject.Url -DestinationDirectory $osdCoreDriverPackDestination -DestinationName $global:OSDCoreDriverPackObject.FileName -ErrorAction Stop

                        # Verify the downloaded driver pack before refreshing the cache inventory.
                        if (-not [string]::IsNullOrWhiteSpace($expectedDriverPackHashMD5)) {
                            $actualDriverPackHashMD5 = (Get-FileHash -Path $savedDriverPack.FullName -Algorithm MD5 -ErrorAction Stop).Hash
                            if ($actualDriverPackHashMD5 -ne $expectedDriverPackHashMD5.Trim()) {
                                throw "[$(Get-Date -format s)] DriverPack MD5 hash mismatch for $($savedDriverPack.FullName). Expected $($expectedDriverPackHashMD5.Trim()), found $actualDriverPackHashMD5."
                            }
                            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack MD5 hash verified. OK."
                        }
                        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DriverPack downloaded to $($savedDriverPack.FullName)"
                        $global:OSDCoreCacheContent = Get-OSDCoreCacheContent
                    }
                }
                else {
                    Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] No eligible OSDCoreCache USB path is available for download."
                }
            }
            else {
                Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] No eligible OSDCoreCache USB drive is available for download."
            }
        }
    }
    else {
        Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] OSDCoreDriverPackObject is not set."
        Write-Host -ForegroundColor DarkYellow "[$(Get-Date -format s)] OSDCloud will not apply a DriverPack for this device or on this network."
    }
    #================================================
    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] Done."
    #================================================
}
