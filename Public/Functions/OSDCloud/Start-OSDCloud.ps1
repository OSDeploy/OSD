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
        #Overrides the System Manufacturer for Driver matching
        [System.String]
        $Manufacturer = (Get-MyComputerManufacturer -Brief),
        
        #Automatically populated from Get-MyComputerProduct
        #Overrides the System Product for Driver matching
        [System.String]
        $Product = (Get-MyComputerProduct),

        #$Global:StartOSDCloud.ApplyCatalogFirmware = $true
        [System.Management.Automation.SwitchParameter]
        $Firmware,

        #Restart the computer after Invoke-OSDCloud to OOBE
        [System.Management.Automation.SwitchParameter]
        $Restart,

        #Shutdown the computer after Invoke-OSDCloud
        [System.Management.Automation.SwitchParameter]
        $Shutdown,
        
        #Captures screenshots during OSDCloud WinPE
        [System.Management.Automation.SwitchParameter]
        $Screenshot,
        
        #Skips the Autopilot Task routine
        [System.Management.Automation.SwitchParameter]
        $SkipAutopilot,
        
        #Skips the ODT Task routine
        [System.Management.Automation.SwitchParameter]
        $SkipODT,
        
        #Skip prompting to wipe Disks
        [System.Management.Automation.SwitchParameter]
        $ZTI,

        #Operating System Version of the Windows installation
        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet('Windows 11','Windows 10')]
        [System.String]
        $OSVersion,

        #Operating System Build of the Windows installation
        #Alias = Build
        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet('21H2','21H1','20H2','2004','1909','1903','1809')]
        [Alias('Build')]
        [System.String]
        $OSBuild,

        #Operating System Edition of the Windows installation
        #Alias = Edition
        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet('Home','Home N','Home Single Language','Education','Education N','Enterprise','Enterprise N','Pro','Pro N')]
        [Alias('Edition')]
        [System.String]
        $OSEdition,

        #Operating System Language of the Windows installation
        #Alias = Culture, OSCulture
        [Parameter(ParameterSetName = 'Default')]
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
        [ValidateSet('Retail','Volume')]
        [System.String]
        $OSLicense,

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
        [int32]
        $ImageIndex = 1
    )
    #=================================================
    #	$Global:StartOSDCloud
    #=================================================
    $Global:StartOSDCloud = $null
    $Global:StartOSDCloud = [ordered]@{
        ApplyManufacturerDrivers = $true
        ApplyCatalogDrivers = $true
        ApplyCatalogFirmware = $false
        AutopilotJsonChildItem = $null
        AutopilotJsonItem = $null
        AutopilotJsonName = $null
        AutopilotJsonObject = $null
        AutopilotOOBEJsonChildItem = $null
        AutopilotOOBEJsonItem = $null
        AutopilotOOBEJsonName = $null
        AutopilotOOBEJsonObject = $null
        DriverPackUrl = $null
        DriverPackOffline = $null
        DriverPackSource = $null
        Function = $MyInvocation.MyCommand.Name
        GetDiskFixed = $null
        GetFeatureUpdate = $null
        GetMyDriverPack = $null
        ImageFileFullName = $null
        ImageFileItem = $null
        ImageFileName = $null
        ImageFileSource = $null
        ImageFileTarget = $null
        ImageFileUrl = $ImageFileUrl
        IsOnBattery = Get-OSDGather -Property IsOnBattery
        Manufacturer = $Manufacturer
        OOBEDeployJsonChildItem = $null
        OOBEDeployJsonItem = $null
        OOBEDeployJsonName = $null
        OOBEDeployJsonObject = $null
        OSBuild = $OSBuild
        OSBuildMenu = $null
        OSBuildNames = $null
        OSEdition = $OSEdition
        OSEditionId = $null
        OSEditionMenu = $null
        OSEditionNames = $null
        OSImageIndex = $ImageIndex
        OSLanguage = $OSLanguage
        OSLanguageMenu = $null
        OSLanguageNames = $null
        OSLicense = $OSLicense
        OSVersion = $OSVersion
        OSVersionMenu = $null
        OSVersionNames = @('Windows 11','Windows 10')
        Product = $Product
        Restart = $Restart
        Screenshot = $Screenshot
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
        $Global:StartOSDCloud.ApplyCatalogFirmware = $true
    }
    #=================================================
    #	$Global:StartOSDCloudGUI
    #=================================================
    if ($Global:StartOSDCloudGUI) {
        foreach ($Key in $Global:StartOSDCloudGUI.Keys) {
            $Global:StartOSDCloud.$Key = $Global:StartOSDCloudGUI.$Key
        }
    }
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=================================================
    #	-Screenshot
    #=================================================
    if ($PSBoundParameters.ContainsKey('Screenshot')) {
        $Global:StartOSDCloud.Screenshot = "$env:TEMP\ScreenPNG"
        Start-ScreenPNGProcess -Directory $Global:StartOSDCloud.Screenshot
    }
    #=================================================
    #	Computer Information
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($Global:StartOSDCloud.Function) | Manufacturer: $Manufacturer | Product: $Product"
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
        $Global:StartOSDCloud.GetDiskFixed = Get-Disk.fixed | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number

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
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test-WebConnection" -NoNewline
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
            Write-Host -ForegroundColor DarkGray "ImageIndex: $($Global:StartOSDCloud.OSImageIndex)"
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
                $Global:StartOSDCloud.OSImageIndex = 1
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
        #	OSVersion
        #=================================================
        if ($Global:StartOSDCloud.OSVersion) {
        }
        elseif ($Global:StartOSDCloud.ZTI) {
            $Global:StartOSDCloud.OSVersion = 'Windows 10'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select an Operating System"
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
        #	Defaults
        #=================================================
        if ($Global:StartOSDCloud.OSVersion -eq 'Windows 11') {
            $Global:StartOSDCloud.OSBuild = '21H2'
        }
        #=================================================
        #	OSBuild
        #=================================================
        if ($Global:StartOSDCloud.OSBuild) {
        }
        elseif ($Global:StartOSDCloud.ZTI) {
            $Global:StartOSDCloud.OSBuild = '21H2'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select a Build for $OSVersion x64"
            $Global:StartOSDCloud.OSBuildNames = @('21H2','21H1','20H2','2004','1909','1903','1809')
            
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
        #=================================================
        #	OSEdition
        #=================================================
        if ($Global:StartOSDCloud.OSEdition) {
        }
        elseif ($ZTI) {
            $Global:StartOSDCloud.OSEdition = 'Enterprise'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select an Edition for $OSVersion x64 $OSBuild"
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
        #	OSEditionId and OSLicense
        #=================================================
        if ($Global:StartOSDCloud.OSEdition -eq 'Home') {
            $Global:StartOSDCloud.OSEditionId = 'Core'
            $Global:StartOSDCloud.OSLicense = 'Retail'
            $Global:StartOSDCloud.OSImageIndex = 4
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Home N') {
            $Global:StartOSDCloud.OSEditionId = 'CoreN'
            $Global:StartOSDCloud.OSLicense = 'Retail'
            $Global:StartOSDCloud.OSImageIndex = 5
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Home Single Language') {
            $Global:StartOSDCloud.OSEditionId = 'CoreSingleLanguage'
            $Global:StartOSDCloud.OSLicense = 'Retail'
            $Global:StartOSDCloud.OSImageIndex = 6
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Enterprise') {
            $Global:StartOSDCloud.OSEditionId = 'Enterprise'
            $Global:StartOSDCloud.OSLicense = 'Volume'
            $Global:StartOSDCloud.OSImageIndex = 6
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Enterprise N') {
            $Global:StartOSDCloud.OSEditionId = 'EnterpriseN'
            $Global:StartOSDCloud.OSLicense = 'Volume'
            $Global:StartOSDCloud.OSImageIndex = 7
        }
        $OSEdition = $Global:StartOSDCloud.OSEdition
        #=================================================
        #	OSLicense
        #=================================================
        if ($Global:StartOSDCloud.OSLicense) {
        }
        elseif ($Global:StartOSDCloud.ZTI) {
            $Global:StartOSDCloud.OSLicense = 'Volume'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select a License for $OSVersion x64 $OSBuild $OSEdition"
            $Global:StartOSDCloud.OSLicenseNames = @('Retail Windows Consumer Editions','Volume Windows Business Editions')
            
            $i = $null
            $Global:StartOSDCloud.OSLicenseMenu = foreach ($Item in $Global:StartOSDCloud.OSLicenseNames) {
                $i++
            
                $ObjectProperties = @{
                    Selection           = $i
                    Name                = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
            
            $Global:StartOSDCloud.OSLicenseMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
            
            do {
                $SelectReadHost = Read-Host -Prompt "Enter the Selection Number"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloud.OSLicenseMenu.Selection))))
            
            $Global:StartOSDCloud.OSLicenseMenu = $Global:StartOSDCloud.OSLicenseMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name

            if ($Global:StartOSDCloud.OSLicenseMenu -match 'Retail') {
                $Global:StartOSDCloud.OSLicense = 'Retail'
            }
            else {
                $Global:StartOSDCloud.OSLicense = 'Volume'
            }
            #Write-Host -ForegroundColor Cyan "OSLicense: " -NoNewline
            #Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSLicense
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Education') {
            $Global:StartOSDCloud.OSEditionId = 'Education'
            if ($Global:StartOSDCloud.OSLicense -eq 'Retail') {$Global:StartOSDCloud.OSImageIndex = 7}
            if ($Global:StartOSDCloud.OSLicense -eq 'Volume') {$Global:StartOSDCloud.OSImageIndex = 4}
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Education N') {
            $Global:StartOSDCloud.OSEditionId = 'EducationN'
            if ($Global:StartOSDCloud.OSLicense -eq 'Retail') {$Global:StartOSDCloud.OSImageIndex = 8}
            if ($Global:StartOSDCloud.OSLicense -eq 'Volume') {$Global:StartOSDCloud.OSImageIndex = 5}
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Pro') {
            $Global:StartOSDCloud.OSEditionId = 'Professional'
            if ($Global:StartOSDCloud.OSLicense -eq 'Retail') {$Global:StartOSDCloud.OSImageIndex = 9}
            if ($Global:StartOSDCloud.OSLicense -eq 'Volume') {$Global:StartOSDCloud.OSImageIndex = 8}
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Pro N') {
            $Global:StartOSDCloud.OSEditionId = 'ProfessionalN'
            if ($Global:StartOSDCloud.OSLicense -eq 'Retail') {$Global:StartOSDCloud.OSImageIndex = 10}
            if ($Global:StartOSDCloud.OSLicense -eq 'Volume') {$Global:StartOSDCloud.OSImageIndex = 9}
        }
        $OSLicense = $Global:StartOSDCloud.OSLicense
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
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select a Language for $OSVersion x64 $OSBuild $OSEdition $OSLicense"
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
        #=================================================
        #	Get-FeatureUpdate
        #   This is where we take the OSB OSE OSL information and get the
        #   Feature Update.  Global Variables will be set for Deploy-OSDCloud
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Get-FeatureUpdate " -NoNewline
        Write-Host -ForegroundColor DarkGray "-OSVersion '$OSVersion' -OSBuild $OSBuild -OSLicense $OSLicense -OSLanguage $OSLanguage"

        $Params = @{
            OSVersion   = $OSVersion
            OSBuild     = $OSBuild
            OSLicense   = $OSLicense
            OSLanguage  = $OSLanguage
        }
        $Global:StartOSDCloud.GetFeatureUpdate = Get-FeatureUpdate @Params

        if ($Global:StartOSDCloud.GetFeatureUpdate) {
            $Global:StartOSDCloud.GetFeatureUpdate = $Global:StartOSDCloud.GetFeatureUpdate | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash
            $Global:StartOSDCloud.ImageFileName = $Global:StartOSDCloud.GetFeatureUpdate.FileName
            $Global:StartOSDCloud.ImageFileUrl = $Global:StartOSDCloud.GetFeatureUpdate.FileUri
        }
        else {
            Write-Warning "Unable to locate a Windows Feature Update"
            Write-Warning "OSDCloud cannot continue"
            Break
        }
        #=================================================
        #	Get-FeatureUpdate Offline
        #   Determine if the OS is Offline
        #   Need to bail if the file is Online is not valid or not Offline
        #=================================================
        $Global:StartOSDCloud.ImageFileItem = Find-OSDCloudFile -Name $Global:StartOSDCloud.GetFeatureUpdate.FileName -Path '\OSDCloud\OS\' | Sort-Object FullName | Where-Object {$_.Length -gt 3GB}
        $Global:StartOSDCloud.ImageFileItem = $Global:StartOSDCloud.ImageFileItem | Where-Object {$_.FullName -notlike "C*"} | Where-Object {$_.FullName -notlike "X*"} | Select-Object -First 1

        if ($Global:StartOSDCloud.ImageFileItem) {
            #Write-Host -ForegroundColor Green "OK"
            Write-Host -ForegroundColor DarkGray $Global:StartOSDCloud.GetFeatureUpdate.Title
            Write-Host -ForegroundColor DarkGray $Global:StartOSDCloud.ImageFileItem.FullName
        }
        elseif (Test-WebConnection -Uri $Global:StartOSDCloud.GetFeatureUpdate.FileUri) {
            #Write-Host -ForegroundColor Yellow "Download"
            Write-Host -ForegroundColor Yellow $Global:StartOSDCloud.GetFeatureUpdate.Title
            Write-Host -ForegroundColor Yellow $Global:StartOSDCloud.GetFeatureUpdate.FileUri
        }
        else {
            Write-Warning $Global:StartOSDCloud.GetFeatureUpdate.Title
            Write-Warning $Global:StartOSDCloud.GetFeatureUpdate.FileUri
            Write-Warning "Could not verify an Internet connection for Windows Feature Update"
            Write-Warning "OSDCloud cannot continue"
            Break
        }
    }
    #=================================================
    #	Start-OSDCloud Get-MyDriverPack
    #=================================================
    if ($Global:StartOSDCloud.Product -ne 'None') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Get-MyDriverPack " -NoNewline
        Write-Host -ForegroundColor DarkGray "-Manufacturer $($Global:StartOSDCloud.Manufacturer) -Product $($Global:StartOSDCloud.Product)"

        $Global:StartOSDCloud.GetMyDriverPack = Get-MyDriverPack -Manufacturer $Global:StartOSDCloud.Manufacturer -Product $Global:StartOSDCloud.Product

        if ($Global:StartOSDCloud.GetMyDriverPack) {
            $Global:StartOSDCloud.DriverPackOffline = Find-OSDCloudFile -Name $Global:StartOSDCloud.GetMyDriverPack.FileName -Path '\OSDCloud\DriverPacks\' | Sort-Object FullName
            $Global:StartOSDCloud.DriverPackOffline = $Global:StartOSDCloud.DriverPackOffline | Where-Object {$_.FullName -notlike "C*"} | Where-Object {$_.FullName -notlike "X*"} | Select-Object -First 1

            if ($Global:StartOSDCloud.DriverPackOffline) {
                Write-Host -ForegroundColor DarkGray $Global:StartOSDCloud.GetMyDriverPack.Name
                Write-Host -ForegroundColor DarkGray $Global:StartOSDCloud.DriverPackOffline.FullName
            }
            elseif (Test-WebConnection -Uri $Global:StartOSDCloud.GetMyDriverPack.DriverPackUrl) {
                Write-Host -ForegroundColor Yellow $Global:StartOSDCloud.GetMyDriverPack.Name
                Write-Host -ForegroundColor Yellow $Global:StartOSDCloud.GetMyDriverPack.DriverPackUrl
            }
            else {
                Write-Warning $Global:StartOSDCloud.GetMyDriverPack.Name
                Write-Warning $Global:StartOSDCloud.GetMyDriverPack.DriverPackUrl
                Write-Warning "Could not verify an Internet connection for the Driver Pack"
                Write-Warning "OSDCloud will continue, but there may be issues"
            }
        }
        else {
            Write-Warning "Unable to determine a suitable Driver Pack for this Computer Model"
        }
    }
    #=================================================
    #   Invoke-OSDCloud.ps1
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Invoke-OSDCloud ... Starting in 5 seconds..."
    Start-Sleep -Seconds 5
    Invoke-OSDCloud
    #=================================================
}