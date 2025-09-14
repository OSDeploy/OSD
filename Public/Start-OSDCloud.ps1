function Start-OSDCloud {
    <#
    .SYNOPSIS
    Starts the OSDCloud Windows 10 or 11 Build Process from the OSD Module or a GitHub Repository

    .DESCRIPTION
    Starts the OSDCloud Windows 10 or 11 Build Process from the OSD Module or a GitHub Repository

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        #Automatically populated from Get-MyComputerManufacturer -Brief
        [System.String]
        $Manufacturer = (Get-MyComputerManufacturer -Brief),

        #Automatically populated from Get-MyComputerProduct
        [System.String]
        $Product = (Get-MyComputerProduct),

        #$Global:StartOSDCloud.MSCatalogFirmware = $true
        [System.Management.Automation.SwitchParameter]
        $Firmware,

        #Restart the computer after Invoke-OSDCloud to OOBE
        [System.Management.Automation.SwitchParameter]
        $Restart,

        #Shutdown the computer after Invoke-OSDCloud
        [System.Management.Automation.SwitchParameter]
        $Shutdown,

        #Skips the Autopilot Task routine
        [System.Management.Automation.SwitchParameter]
        $SkipAutopilot,

        #Skips the ODT Task routine
        [System.Management.Automation.SwitchParameter]
        $SkipODT,

        #Skip prompting to wipe Disks
        [System.Management.Automation.SwitchParameter]
        $ZTI,

        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet(
            'Windows 11 24H2 x64',
            'Windows 11 23H2 x64',
            'Windows 11 22H2 x64',
            'Windows 10 22H2 x64')]
        [System.String]
        $OSName,

        #Operating System Version of the Windows installation
        [Parameter(ParameterSetName = 'Legacy')]
        [ValidateSet('Windows 11','Windows 10')]
        [System.String]
        $OSVersion,

        #Operating System Build of the Windows installation
        #Alias = Build
        [Parameter(ParameterSetName = 'Legacy')]
        [ValidateSet('24H2','23H2','22H2')]
        [Alias('Build')]
        [System.String]
        $OSBuild,

        #Operating System Edition of the Windows installation
        #Alias = Edition
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Legacy')]
        [ValidateSet('Home','Home N','Home Single Language','Education','Education N','Enterprise','Enterprise N','Pro','Pro N')]
        [Alias('Edition')]
        [System.String]
        $OSEdition,

        #Operating System Language of the Windows installation
        #Alias = Culture, OSCulture
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Legacy')]
        [ValidateSet (
            'ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','en-us','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw'
        )]
        [Alias('Culture','OSCulture')]
        [System.String]
        $OSLanguage,

        #License of the Windows Operating System
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Legacy')]
        [ValidateSet('Retail','Volume')]
        [Alias('License','OSLicense','Activation')]
        [System.String]
        $OSActivation,

        #Searches for the specified WIM file
        [Parameter(ParameterSetName = 'CustomImage')]
        [System.Management.Automation.SwitchParameter]
        $FindImageFile,

        #Downloads a WIM file specified by the URK
        [Parameter(ParameterSetName = 'CustomImage')]
        [System.String]
        $ImageFileUrl,

        #Images using the specified Image Index
        [Parameter(ParameterSetName = 'CustomImage')]
        [Alias('ImageIndex')]
        [System.Int32]
        $OSImageIndex = 0,

        $Architecture = $Env:PROCESSOR_ARCHITECTURE
    )
    #=================================================
    #	$Global:StartOSDCloud
    #=================================================
    $Global:StartOSDCloud = $null
    $Global:StartOSDCloud = [ordered]@{
        LaunchMethod = 'OSDCloudCLI'
        AutopilotJsonChildItem = $null
        AutopilotJsonItem = $null
        AutopilotJsonName = $null
        AutopilotJsonObject = $null
        AutopilotOOBEJsonChildItem = $null
        AutopilotOOBEJsonItem = $null
        AutopilotOOBEJsonName = $null
        AutopilotOOBEJsonObject = $null
        Function = $MyInvocation.MyCommand.Name
        GetDiskFixed = $null
        GetFeatureUpdate = $null
        ImageFileFullName = $null
        ImageFileItem = $null
        ImageFileName = $null
        ImageFileSource = $null
        ImageFileDestination = $null
        ImageFileUrl = $ImageFileUrl
        IsOnBattery = Get-OSDGather -Property IsOnBattery
        Manufacturer = $Manufacturer
        MSCatalogFirmware = $false
        MSCatalogDiskDrivers = $true
        MSCatalogNetDrivers = $true
        MSCatalogScsiDrivers = $true
        OOBEDeployJsonChildItem = $null
        OOBEDeployJsonItem = $null
        OOBEDeployJsonName = $null
        OOBEDeployJsonObject = $null
        OSActivation = $OSActivation
        OSBuild = $OSBuild
        OSBuildMenu = $null
        OSBuildNames = $null
        OSEdition = $OSEdition
        OSEditionId = $null
        OSEditionMenu = $null
        OSEditionNames = $null
        OSImageIndex = $OSImageIndex
        OSLanguage = $OSLanguage
        OSLanguageMenu = $null
        OSLanguageNames = $null
        OSName = $OSName
        OSNameMenu = $null
        OSNames = @('Windows 11 24H2 x64', 'Windows 11 23H2 x64', 'Windows 11 22H2 x64', 'Windows 10 22H2 x64')
        OSVersion = $OSVersion
        OSVersionMenu = $null
        OSVersionNames = @('Windows 11','Windows 10')
        Product = $Product
        Restart = $Restart
        Shutdown = $Shutdown
        SkipAutopilot = $SkipAutopilot
        SkipAutopilotOOBE = $null
        SkipODT = $SkipODT
        SkipOOBEDeploy = $null
        TimeStart = Get-Date
        ZTI = $ZTI
    }
    #=================================================
    #	Update Defaults
    #=================================================
    if ($Firmware) {
        $Global:StartOSDCloud.MSCatalogFirmware = $true
    }
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=================================================
    #	$Global:StartOSDCloudGUI
    #=================================================
    if ($Global:StartOSDCloudGUI) {
        foreach ($Key in $Global:StartOSDCloudGUI.Keys) {
            $Global:StartOSDCloud.$Key = $Global:StartOSDCloudGUI.$Key
        }
    }

    if ($Global:StartOSDCloud.OSLicense) {
        $Global:StartOSDCloud.OSActivation = $Global:StartOSDCloud.OSLicense
    }
    #=================================================
    #	Computer Information
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "[$(Get-Date -format G)] $($Global:StartOSDCloud.Function) | Manufacturer: $Manufacturer | Product: $Product"
    #=================================================
    #	Battery
    #=================================================
    if ($Global:StartOSDCloud.IsOnBattery) {
        Write-Warning "Computer is currently running on Battery"
    }
    #=================================================
    #	-ZTI
    #=================================================
    if ($Global:StartOSDCloud.ZTI) {
        $Global:StartOSDCloud.GetDiskFixed = Get-LocalDisk | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number

        if (($Global:StartOSDCloud.GetDiskFixed | Measure-Object).Count -lt 2) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Warning "This Warning is displayed when using the -ZTI parameter"
            Write-Warning "OSDisk will be cleaned automatically without confirmation"
            Write-Warning "Press CTRL + C to cancel"
            $Global:StartOSDCloud.GetDiskFixed | Select-Object -Property Number, BusType, MediaType,`
            FriendlyName, PartitionStyle, NumberOfPartitions,`
            @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}} | Format-Table

            Write-Warning "OSDCloud will continue in 5 seconds"
            Start-Sleep -Seconds 5
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Warning "More than 1 Fixed Disk is present"
            Write-Warning "Disks will not be cleaned automatically"
            $Global:StartOSDCloud.GetDiskFixed | Select-Object -Property Number, BusType, MediaType,`
            FriendlyName, PartitionStyle, NumberOfPartitions,`
            @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}} | Format-Table
            Start-Sleep -Seconds 5
        }
    }
    #=================================================
    #	Test Web Connection
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "[$(Get-Date -format G)] Test-WebConnection" -NoNewline
    #Write-Host -ForegroundColor DarkGray "google.com"

    if (Test-WebConnection -Uri "google.com") {
        Write-Host -ForegroundColor Green " OK"
    }
    else {
        Write-Host -ForegroundColor Red " FAILED"
        Write-Warning "Could not validate an Internet connection"
        Write-Warning "OSDCloud will continue, but there may be issues if this can't be resolved"
    }
    #=================================================
    #	Custom Image
    #=================================================
    if ($Global:StartOSDCloud.ImageFileFullName -and $Global:StartOSDCloud.ImageFileItem -and $Global:StartOSDCloud.ImageFileName) {
        #Custom Image set in OSDCloudGUI
    }
    #=================================================
    #	ParameterSet CustomImage
    #=================================================
    elseif ($PSCmdlet.ParameterSetName -eq 'CustomImage') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Custom Windows Image"

        if ($Global:StartOSDCloud.ImageFileUrl) {
            Write-Host -ForegroundColor DarkGray "ImageFileUrl: $($Global:StartOSDCloud.ImageFileUrl)"
            Write-Host -ForegroundColor DarkGray "OSImageIndex: $($Global:StartOSDCloud.OSImageIndex)"
        }
        if ($PSBoundParameters.ContainsKey('FindImageFile')) {
            $Global:StartOSDCloud.ImageFileItem = Select-OSDCloudFileWim

            if ($Global:StartOSDCloud.ImageFileItem) {
                $Global:StartOSDCloud.OSImageIndex = Select-OSDCloudImageIndex -ImagePath $Global:StartOSDCloud.ImageFileItem.FullName

                Write-Host -ForegroundColor DarkGray "ImageFileItem: $($Global:StartOSDCloud.ImageFileItem.FullName)"
                Write-Host -ForegroundColor DarkGray "OSImageIndex: $($Global:StartOSDCloud.OSImageIndex)"
            }
            else {
                $Global:StartOSDCloud.ImageFileItem = $null
                $Global:StartOSDCloud.OSImageIndex = 0
                #$Global:OSDImageParent = $null
                #$Global:OSDCloudWimFullName = $null
                Write-Warning "Custom Windows Image on USB was not found"
                Break
            }
        }
    }
    #=================================================
    #	ParameterSet Default
    #=================================================
    elseif ($PSCmdlet.ParameterSetName -eq 'Default') {
        #=================================================
        #	OSName
        #=================================================
        if ($Global:StartOSDCloud.OSName) {
        }
        elseif ($Global:StartOSDCloud.ZTI) {
            $Global:StartOSDCloud.OSName = 'Windows 11 24H2 x64'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "[$(Get-Date -format G)] Select an Operating System"

            $i = $null
            $Global:StartOSDCloud.OSNameMenu = foreach ($Item in $Global:StartOSDCloud.OSNames) {
                $i++

                $ObjectProperties = @{
                    Selection   = $i
                    Name     = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }

            $Global:StartOSDCloud.OSNameMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host

            do {
                $SelectReadHost = Read-Host -Prompt "Enter the Selection Number"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloud.OSNameMenu.Selection))))

            $Global:StartOSDCloud.OSName = $Global:StartOSDCloud.OSNameMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        }
        $OSName = $Global:StartOSDCloud.OSName
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'Legacy') {
        #=================================================
        #	OSVersion
        #=================================================
        if ($Global:StartOSDCloud.OSVersion) {
        }
        elseif ($Global:StartOSDCloud.ZTI) {
            $Global:StartOSDCloud.OSVersion = 'Windows 11'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "[$(Get-Date -format G)] Select an Operating System"
            $Global:StartOSDCloud.OSVersionNames = @('Windows 11','Windows 10')

            $i = $null
            $Global:StartOSDCloud.OSVersionMenu = foreach ($Item in $Global:StartOSDCloud.OSVersionNames) {
                $i++

                $ObjectProperties = @{
                    Selection   = $i
                    Name     = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }

            $Global:StartOSDCloud.OSVersionMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host

            do {
                $SelectReadHost = Read-Host -Prompt "Enter the Selection Number"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloud.OSVersionMenu.Selection))))

            $Global:StartOSDCloud.OSVersion = $Global:StartOSDCloud.OSVersionMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        }
        $OSVersion = $Global:StartOSDCloud.OSVersion
        #=================================================
        #	OSBuild
        #=================================================
        if ($Global:StartOSDCloud.OSBuild) {
        }
        elseif ($Global:StartOSDCloud.ZTI) {
            $Global:StartOSDCloud.OSBuild = '24H2'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "[$(Get-Date -format G)] Select a Build for $OSVersion x64"
            $Global:StartOSDCloud.OSBuildNames = @('24H2','23H2','22H2')
            
            $i = $null
            $Global:StartOSDCloud.OSBuildMenu = foreach ($Item in $Global:StartOSDCloud.OSBuildNames) {
                $i++
            
                $ObjectProperties = @{
                    Selection   = $i
                    Name     = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
            
            $Global:StartOSDCloud.OSBuildMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
            
            do {
                $SelectReadHost = Read-Host -Prompt "Enter the Selection Number"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloud.OSBuildMenu.Selection))))
            
            $Global:StartOSDCloud.OSBuild = $Global:StartOSDCloud.OSBuildMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        }
        $OSBuild = $Global:StartOSDCloud.OSBuild
    }
        #=================================================
        #	OSEdition
        #=================================================
    if (($PSCmdlet.ParameterSetName -eq 'Default') -or ($PSCmdlet.ParameterSetName -eq 'Legacy')) {
        if ($Global:StartOSDCloud.OSEdition) {
        }
        elseif ($ZTI) {
            $Global:StartOSDCloud.OSEdition = 'Enterprise'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "[$(Get-Date -format G)] Select an Operating System Edition"
            $Global:StartOSDCloud.OSEditionNames = @('Home','Home N','Home Single Language','Education','Education N','Enterprise','Enterprise N','Pro','Pro N')

            $i = $null
            $Global:StartOSDCloud.OSEditionMenu = foreach ($Item in $Global:StartOSDCloud.OSEditionNames) {
                $i++
            
                $ObjectProperties = @{
                    Selection   = $i
                    Name     = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
            
            $Global:StartOSDCloud.OSEditionMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
            
            do {
                $SelectReadHost = Read-Host -Prompt "Enter the Selection Number"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloud.OSEditionMenu.Selection))))
            
            $Global:StartOSDCloud.OSEdition = $Global:StartOSDCloud.OSEditionMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        }
        #=================================================
        #	OSEditionId and OSActivation
        #=================================================
        if ($Global:StartOSDCloud.OSEdition -eq 'Home') {
            $Global:StartOSDCloud.OSEditionId = 'Core'
            $Global:StartOSDCloud.OSActivation = 'Retail'
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Home N') {
            $Global:StartOSDCloud.OSEditionId = 'CoreN'
            $Global:StartOSDCloud.OSActivation = 'Retail'
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Home Single Language') {
            $Global:StartOSDCloud.OSEditionId = 'CoreSingleLanguage'
            $Global:StartOSDCloud.OSActivation = 'Retail'
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Education') {
            $Global:StartOSDCloud.OSEditionId = 'Education'
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Education N') {
            $Global:StartOSDCloud.OSEditionId = 'EducationN'
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Pro') {
            $Global:StartOSDCloud.OSEditionId = 'Professional'
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Pro N') {
            $Global:StartOSDCloud.OSEditionId = 'ProfessionalN'
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Enterprise') {
            $Global:StartOSDCloud.OSEditionId = 'Enterprise'
            $Global:StartOSDCloud.OSActivation = 'Volume'
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Enterprise N') {
            $Global:StartOSDCloud.OSEditionId = 'EnterpriseN'
            $Global:StartOSDCloud.OSActivation = 'Volume'
        }
        $OSEdition = $Global:StartOSDCloud.OSEdition
        #=================================================
        #	OSActivation
        #=================================================
        if ($Global:StartOSDCloud.OSActivation) {
        }
        elseif ($Global:StartOSDCloud.ZTI) {
            $Global:StartOSDCloud.OSActivation = 'Volume'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "[$(Get-Date -format G)] Select an Operating System License"
            $Global:StartOSDCloud.OSActivationNames = @('Retail Windows Consumer Editions','Volume Windows Business Editions')
            
            $i = $null
            $Global:StartOSDCloud.OSActivationMenu = foreach ($Item in $Global:StartOSDCloud.OSActivationNames) {
                $i++
            
                $ObjectProperties = @{
                    Selection           = $i
                    Name                = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
            
            $Global:StartOSDCloud.OSActivationMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
            
            do {
                $SelectReadHost = Read-Host -Prompt "Enter the Selection Number"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloud.OSActivationMenu.Selection))))
            
            $Global:StartOSDCloud.OSActivationMenu = $Global:StartOSDCloud.OSActivationMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name

            if ($Global:StartOSDCloud.OSActivationMenu -match 'Retail') {
                $Global:StartOSDCloud.OSActivation = 'Retail'
            }
            else {
                $Global:StartOSDCloud.OSActivation = 'Volume'
            }
        }
        $OSActivation = $Global:StartOSDCloud.OSActivation
        Write-Host -ForegroundColor Cyan "OSEditionId: " -NoNewline
        Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSEditionId
        Write-Host -ForegroundColor Cyan "OSImageIndex: " -NoNewline
        Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSImageIndex
        #=================================================
        #	OSLanguage
        #=================================================
        if ($Global:StartOSDCloud.OSLanguage) {
        }
        elseif ($PSBoundParameters.ContainsKey('OSLanguage')) {
        }
        elseif ($ZTI) {
            $Global:StartOSDCloud.OSLanguage = 'en-us'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "[$(Get-Date -format G)] Select an Operating System Language"
            $Global:StartOSDCloud.OSLanguageNames = @('ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr','en-gb','en-us','es-es','es-mx','et-ee','fi-fi','fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it','ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl','pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk','sl-si','sr-latn-rs','sv-se','th-th','tr-tr','uk-ua','zh-cn','zh-tw')
            
            $i = $null
            $Global:StartOSDCloud.OSLanguageMenu = foreach ($Item in $Global:StartOSDCloud.OSLanguageNames) {
                $i++
            
                $ObjectProperties = @{
                    Selection   = $i
                    Name     = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
            
            $Global:StartOSDCloud.OSLanguageMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
            
            do {
                $SelectReadHost = Read-Host -Prompt "Enter the Selection number"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloud.OSLanguageMenu.Selection))))
            
            $Global:StartOSDCloud.OSLanguage = $Global:StartOSDCloud.OSLanguageMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        }
        $OSLanguage = $Global:StartOSDCloud.OSLanguage
    }
    #=================================================
    #	Default
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'Default') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Get-FeatureUpdate " -NoNewline
        Write-Host -ForegroundColor DarkGray "-OSName '$OSName' -OSActivation $OSActivation -OSLanguage $OSLanguage"

        $Params = @{
            OSName = $OSName
            OSActivation = $OSActivation
            OSLanguage = $OSLanguage
        }
        $Global:StartOSDCloud.GetFeatureUpdate = Get-FeatureUpdate @Params
    }
    #=================================================
    #	Legacy
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'Legacy') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Get-FeatureUpdate Legacy " -NoNewline
        Write-Host -ForegroundColor DarkGray "-OSVersion '$OSVersion' -OSBuild $OSBuild -OSActivation $OSActivation -OSLanguage $OSLanguage"

        $Params = @{
            OSVersion   = $OSVersion
            OSBuild     = $OSBuild
            OSActivation   = $OSActivation
            OSLanguage  = $OSLanguage
        }
        $Global:StartOSDCloud.GetFeatureUpdate = Get-FeatureUpdate @Params
    }
    #=================================================
    #	Default or Legacy
    #=================================================
    if ($PSCmdlet.ParameterSetName -ne 'CustomImage') {
        if ($Global:StartOSDCloud.GetFeatureUpdate) {
            #$Global:StartOSDCloud.GetFeatureUpdate = $Global:StartOSDCloud.GetFeatureUpdate | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash
            #$Global:StartOSDCloud.ImageFileName = $Global:StartOSDCloud.GetFeatureUpdate.FileName
            #$Global:StartOSDCloud.ImageFileUrl = $Global:StartOSDCloud.GetFeatureUpdate.FileUri
            $Global:StartOSDCloud.GetFeatureUpdate = $Global:StartOSDCloud.GetFeatureUpdate | Select-Object -Property ReleaseDate,Name,Version,ReleaseID,Architecture,FileName,Url,SHA1,AdditionalHash
            $Global:StartOSDCloud.ImageFileName = $Global:StartOSDCloud.GetFeatureUpdate.FileName
            $Global:StartOSDCloud.ImageFileUrl = $Global:StartOSDCloud.GetFeatureUpdate.Url
        }
        else {
            Write-Warning "Unable to locate a Windows Feature Update"
            Write-Warning "OSDCloud cannot continue"
            Break
        }

        $Global:StartOSDCloud.ImageFileItem = Find-OSDCloudFile -Name $Global:StartOSDCloud.GetFeatureUpdate.FileName -Path '\OSDCloud\OS\' | Sort-Object FullName | Where-Object {$_.Length -gt 3GB}
        $Global:StartOSDCloud.ImageFileItem = $Global:StartOSDCloud.ImageFileItem | Where-Object {$_.FullName -notlike "C*"} | Where-Object {$_.FullName -notlike "X*"} | Select-Object -First 1

        if ($Global:StartOSDCloud.ImageFileItem) {
            #Write-Host -ForegroundColor Green "OK"
            #Write-Host -ForegroundColor DarkGray $Global:StartOSDCloud.GetFeatureUpdate.Title
            Write-Host -ForegroundColor DarkGray $Global:StartOSDCloud.GetFeatureUpdate.Name
            Write-Host -ForegroundColor DarkGray $Global:StartOSDCloud.ImageFileItem.FullName
        }
        #elseif (Test-WebConnection -Uri $Global:StartOSDCloud.GetFeatureUpdate.FileUri) {
        elseif (Test-WebConnection -Uri $Global:StartOSDCloud.ImageFileUrl) {
            #Write-Host -ForegroundColor Yellow "Download"
            #Write-Host -ForegroundColor Yellow $Global:StartOSDCloud.GetFeatureUpdate.Title
            Write-Host -ForegroundColor Yellow $Global:StartOSDCloud.GetFeatureUpdate.Name
            #Write-Host -ForegroundColor Yellow $Global:StartOSDCloud.GetFeatureUpdate.FileUri
            Write-Host -ForegroundColor Yellow $Global:StartOSDCloud.ImageFileUrl
        }
        else {
            #Write-Warning $Global:StartOSDCloud.GetFeatureUpdate.Title
            #Write-Warning $Global:StartOSDCloud.GetFeatureUpdate.FileUri
            Write-Warning $Global:StartOSDCloud.GetFeatureUpdate.Name
            Write-Warning $Global:StartOSDCloud.ImageFileUrl
            Write-Warning "Could not verify an Internet connection for Windows Feature Update"
            Write-Warning "OSDCloud cannot continue"
            Break
        }
    }
    #=================================================
    #   Invoke-OSDCloud
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "[$(Get-Date -format G)] Start-OSDCloud Configuration"
    $Global:StartOSDCloudCLI | Out-Host
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #================================================
    #   Test TPM
    #================================================
    try {
        $Win32Tpm = Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_Tpm

        if ($null -eq $Win32Tpm) {
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] TPM: Not Supported"
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] Autopilot: Not Supported"
            Start-Sleep -Seconds 5
        }
        elseif ($Win32Tpm.SpecVersion) {
            if ($null -eq $Win32Tpm.SpecVersion) {
                Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] TPM: Unable to detect the TPM Version"
                Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] Autopilot: Not Supported"
                Start-Sleep -Seconds 5
            }

            $majorVersion = $Win32Tpm.SpecVersion.Split(",")[0] -as [int]
            if ($majorVersion -lt 2) {
                Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] TPM: Version is less than 2.0"
                Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] Autopilot: Not Supported"
                Start-Sleep -Seconds 5
            }
            else {
                #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM IsActivated: $($Win32Tpm.IsActivated_InitialValue)"
                #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM IsEnabled: $($Win32Tpm.IsEnabled_InitialValue)"
                #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM IsOwned: $($Win32Tpm.IsOwned_InitialValue)"
                #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM Manufacturer: $($Win32Tpm.ManufacturerIdTxt)"
                #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM Manufacturer Version: $($Win32Tpm.ManufacturerVersion)"
                #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM SpecVersion: $($Win32Tpm.SpecVersion)"
                Write-Host -ForegroundColor Green "[$(Get-Date -format G)] TPM 2.0: Supported"
                Write-Host -ForegroundColor Green "[$(Get-Date -format G)] Autopilot: Supported"
            }
        }
        else {
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] TPM: Not Supported"
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] Autopilot: Not Supported"
            Start-Sleep -Seconds 5
        }
    }
    catch {
    }
    #================================================
    #   Invoke-OSDCloud
    #================================================
    Write-Host -ForegroundColor Green "[$(Get-Date -format G)] Starting Invoke-OSDCloud in 5 seconds ..."
    Start-Sleep -Seconds 5
    Invoke-OSDCloud
}
