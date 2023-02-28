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
        [Alias('Manufacturer')]
        [System.String]
        $ComputerManufacturer = (Get-MyComputerManufacturer -Brief),

        #Automatically populated from Get-MyComputerProduct
        [Alias('Product')]
        [System.String]
        $ComputerProduct = (Get-MyComputerProduct),

        #$Global:StartOSDCloud.MSCatalogFirmware = $true
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

        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet(
            'Windows 11 22H2 x64',
            'Windows 11 21H2 x64',
            'Windows 10 22H2 x64',
            'Windows 10 21H2 x64',
            'Windows 10 21H1 x64',
            'Windows 10 20H2 x64',
            'Windows 10 2004 x64',
            'Windows 10 1909 x64',
            'Windows 10 1903 x64',
            'Windows 10 1809 x64')]
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
        [ValidateSet('22H2','21H2','21H1','20H2','2004','1909','1903','1809')]
        [Alias('Build','OSBuild')]
        [System.String]
        $OSReleaseID,

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
        [Alias('OSLicense')]
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
        [System.String]
        $ImageIndex = 'AUTO'
    )
    #=================================================
    #	$Global:StartOSDCloud
    #=================================================
    $localOSDCloudParams = (Get-Command Start-OSDCloud).Parameters
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
        ComputerManufacturer = $ComputerManufacturer
        ComputerModel = (Get-MyComputerModel)
        ComputerProduct = $ComputerProduct
        Function = $MyInvocation.MyCommand.Name
        GetDiskFixed = $null
        ImageFileDestination = $null
        ImageFileFullName = $null
        ImageFileItem = $null
        ImageFileName = $null
        ImageFileSource = $null
        ImageFileUrl = $ImageFileUrl
        IsOnBattery = Get-OSDGather -Property IsOnBattery
        MSCatalogDiskDrivers = $true
        MSCatalogFirmware = $true
        MSCatalogNetDrivers = $true
        MSCatalogScsiDrivers = $true
        OOBEDeployJsonChildItem = $null
        OOBEDeployJsonItem = $null
        OOBEDeployJsonName = $null
        OOBEDeployJsonObject = $null
        OSEdition = $OSEdition
        OSEditionId = $null
        OSEditionMenu = $null
        OSEditionValues = $localOSDCloudParams["OSEdition"].Attributes.ValidValues
        OSImageIndex = $ImageIndex
        OSLanguage = $OSLanguage
        OSLanguageMenu = $null
        OSLanguageValues = $localOSDCloudParams["OSLanguage"].Attributes.ValidValues
        OSActivation = $OSActivation
        OSActivationMenu = $null
        OSActivationValues = $localOSDCloudParams["OSActivation"].Attributes.ValidValues
        OSName = $OSName
        OSNameMenu = $null
        OSNameValues = $localOSDCloudParams["OSName"].Attributes.ValidValues
        OSReleaseID = $OSReleaseID
        OSReleaseIDMenu = $null
        OSReleaseIDValues = $localOSDCloudParams["OSReleaseID"].Attributes.ValidValues
        OSVersion = $OSVersion
        OSVersionMenu = $null
        OSVersionValues = $localOSDCloudParams["OSVersion"].Attributes.ValidValues
        Restart = $Restart
        ScreenshotCapture = $false
        ScreenshotPath = "$env:TEMP\Screenshots"
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
    #	-Screenshot
    #=================================================
    if ($PSBoundParameters.ContainsKey('Screenshot')) {
        $Global:StartOSDCloud.ScreenshotCapture = $true
        Start-ScreenPNGProcess -Directory $Global:StartOSDCloud.ScreenshotPath
    }
    #=================================================
    #	Computer Information
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($Global:StartOSDCloud.Function) | $ComputerManufacturer $($Global:StartOSDCloud.ComputerModel) product $ComputerProduct"
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
        Break
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
                $Global:StartOSDCloud.OSImageIndex = 'AUTO'
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
        if ($Global:StartOSDCloud.OSName) {
            #Do nothing
        }
        elseif ($Global:StartOSDCloud.ZTI) {
            $Global:StartOSDCloud.OSName = 'Windows 11 22H2 x64'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select an Operating System"

            $i = $null
            $Global:StartOSDCloud.OSNameMenu = foreach ($Item in $Global:StartOSDCloud.OSNameValues) {
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

        if ($OSName -match 'Windows 10') {
            $Global:StartOSDCloud.OSVersion = 'Windows 10'
        }
        if ($OSName -match 'Windows 11') {
            $Global:StartOSDCloud.OSVersion = 'Windows 11'
        }
        $OSVersion = $Global:StartOSDCloud.OSVersion

        if ($OSName -match '22H2') {
            $Global:StartOSDCloud.OSReleaseID = '22H2'
        }
        if ($OSName -match '21H2') {
            $Global:StartOSDCloud.OSReleaseID = '21H2'
        }
        if ($OSName -match '21H1') {
            $Global:StartOSDCloud.OSReleaseID = '21H1'
        }
        if ($OSName -match '20H2') {
            $Global:StartOSDCloud.OSReleaseID = '20H2'
        }
        if ($OSName -match '2004') {
            $Global:StartOSDCloud.OSReleaseID = '2004'
        }
        if ($OSName -match '1909') {
            $Global:StartOSDCloud.OSReleaseID = '1909'
        }
        if ($OSName -match '1903') {
            $Global:StartOSDCloud.OSReleaseID = '1903'
        }
        if ($OSName -match '1809') {
            $Global:StartOSDCloud.OSReleaseID = '1809'
        }
        $OSReleaseID = $Global:StartOSDCloud.OSReleaseID
    }
    #=================================================
    #	ParameterSet Legacy
    #=================================================
    elseif ($PSCmdlet.ParameterSetName -eq 'Legacy') {

        if ($Global:StartOSDCloud.OSVersion) {
            #Do nothing
        }
        elseif ($Global:StartOSDCloud.ZTI) {
            $Global:StartOSDCloud.OSVersion = 'Windows 11'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select an Operating System"

            $i = $null
            $Global:StartOSDCloud.OSVersionMenu = foreach ($Item in $Global:StartOSDCloud.OSVersionValues) {
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
        #	OSReleaseID
        #=================================================
        if ($Global:StartOSDCloud.OSReleaseID) {
            #Do nothing
        }
        elseif ($Global:StartOSDCloud.ZTI) {
            $Global:StartOSDCloud.OSReleaseID = '22H2'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select a ReleaseID for $OSVersion x64"
            
            $i = $null
            $Global:StartOSDCloud.OSReleaseIDMenu = foreach ($Item in $Global:StartOSDCloud.OSReleaseIDValues) {
                $i++
            
                $ObjectProperties = @{
                    Selection   = $i
                    Name     = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
            
            $Global:StartOSDCloud.OSReleaseIDMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
            
            do {
                $SelectReadHost = Read-Host -Prompt "Enter the Selection Number"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloud.OSReleaseIDMenu.Selection))))
            
            $Global:StartOSDCloud.OSReleaseID = $Global:StartOSDCloud.OSReleaseIDMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        }
        $OSReleaseID = $Global:StartOSDCloud.OSReleaseID
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
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select an Operating System Edition"
            $Global:StartOSDCloud.OSEditionValues = @('Home','Home N','Home Single Language','Education','Education N','Enterprise','Enterprise N','Pro','Pro N')

            $i = $null
            $Global:StartOSDCloud.OSEditionMenu = foreach ($Item in $Global:StartOSDCloud.OSEditionValues) {
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
            $Global:StartOSDCloud.OSImageIndex = 4
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Home N') {
            $Global:StartOSDCloud.OSEditionId = 'CoreN'
            $Global:StartOSDCloud.OSActivation = 'Retail'
            $Global:StartOSDCloud.OSImageIndex = 5
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Home Single Language') {
            $Global:StartOSDCloud.OSEditionId = 'CoreSingleLanguage'
            $Global:StartOSDCloud.OSActivation = 'Retail'
            $Global:StartOSDCloud.OSImageIndex = 6
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Enterprise') {
            $Global:StartOSDCloud.OSEditionId = 'Enterprise'
            $Global:StartOSDCloud.OSActivation = 'Volume'
            $Global:StartOSDCloud.OSImageIndex = 6
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Enterprise N') {
            $Global:StartOSDCloud.OSEditionId = 'EnterpriseN'
            $Global:StartOSDCloud.OSActivation = 'Volume'
            $Global:StartOSDCloud.OSImageIndex = 7
        }
        $OSEdition = $Global:StartOSDCloud.OSEdition
        #=================================================
        #	OSActivation
        #=================================================
        if ($Global:StartOSDCloud.OSActivation) {
            #Do nothing
        }
        elseif ($Global:StartOSDCloud.ZTI) {
            $Global:StartOSDCloud.OSActivation = 'Volume'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select an Operating System License Activation"
            
            $i = $null
            $Global:StartOSDCloud.OSActivationMenu = foreach ($Item in $Global:StartOSDCloud.OSActivationValues) {
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
            #Write-Host -ForegroundColor Cyan "OSActivation: " -NoNewline
            #Write-Host -ForegroundColor Green $Global:StartOSDCloud.OSActivation
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Education') {
            $Global:StartOSDCloud.OSEditionId = 'Education'
            if ($Global:StartOSDCloud.OSActivation -eq 'Retail') {$Global:StartOSDCloud.OSImageIndex = 7}
            if ($Global:StartOSDCloud.OSActivation -eq 'Volume') {$Global:StartOSDCloud.OSImageIndex = 4}
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Education N') {
            $Global:StartOSDCloud.OSEditionId = 'EducationN'
            if ($Global:StartOSDCloud.OSActivation -eq 'Retail') {$Global:StartOSDCloud.OSImageIndex = 8}
            if ($Global:StartOSDCloud.OSActivation -eq 'Volume') {$Global:StartOSDCloud.OSImageIndex = 5}
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Pro') {
            $Global:StartOSDCloud.OSEditionId = 'Professional'
            if ($Global:StartOSDCloud.OSActivation -eq 'Retail') {$Global:StartOSDCloud.OSImageIndex = 9}
            if ($Global:StartOSDCloud.OSActivation -eq 'Volume') {$Global:StartOSDCloud.OSImageIndex = 8}
        }
        if ($Global:StartOSDCloud.OSEdition -eq 'Pro N') {
            $Global:StartOSDCloud.OSEditionId = 'ProfessionalN'
            if ($Global:StartOSDCloud.OSActivation -eq 'Retail') {$Global:StartOSDCloud.OSImageIndex = 10}
            if ($Global:StartOSDCloud.OSActivation -eq 'Volume') {$Global:StartOSDCloud.OSImageIndex = 9}
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
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select an Operating System Language"

            $i = $null
            $Global:StartOSDCloud.OSLanguageMenu = foreach ($Item in $Global:StartOSDCloud.OSLanguageValues) {
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
        Write-Host -ForegroundColor Cyan "Get-OSDCloudOperatingSystems"

        $Global:StartOSDCloud.OperatingSystem = Get-OSDCloudOperatingSystems | Where-Object {$_.Name -match $OSName} | Where-Object {$_.Activation -eq $OSActivation} | Where-Object {$_.Language -eq $OSLanguage}
    }
    #=================================================
    #	Legacy
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'Legacy') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Get-OSDCloudOperatingSystems"

        $Global:StartOSDCloud.OperatingSystem = Get-OSDCloudOperatingSystems | Where-Object {$_.Version -match $OSVersion} | Where-Object {$_.Activation -eq $OSActivation} | Where-Object {$_.Language -eq $OSLanguage} | Where-Object {$_.ReleaseID -eq $OSReleaseID}
    }
    #=================================================
    #	Default or Legacy
    #=================================================
    if ($PSCmdlet.ParameterSetName -ne 'CustomImage') {
        if ($Global:StartOSDCloud.OperatingSystem) {
            $Global:StartOSDCloud.ImageFileName = $Global:StartOSDCloud.OperatingSystem.FileName
            $Global:StartOSDCloud.ImageFileUrl = $Global:StartOSDCloud.OperatingSystem.Url
        }
        else {
            Write-Warning "Unable to locate a Windows Feature Update"
            Write-Warning "OSDCloud cannot continue"
            Break
        }

        $Global:StartOSDCloud.ImageFileItem = Find-OSDCloudFile -Name $Global:StartOSDCloud.OperatingSystem.FileName -Path '\OSDCloud\OS\' | Sort-Object FullName | Where-Object {$_.Length -gt 3GB}
        $Global:StartOSDCloud.ImageFileItem = $Global:StartOSDCloud.ImageFileItem | Where-Object {$_.FullName -notlike "C*"} | Where-Object {$_.FullName -notlike "X*"} | Select-Object -First 1

        if ($Global:StartOSDCloud.ImageFileItem) {
            #Write-Host -ForegroundColor Green "OK"
            Write-Host -ForegroundColor DarkGray $Global:StartOSDCloud.OperatingSystem.Name
            Write-Host -ForegroundColor DarkGray $Global:StartOSDCloud.ImageFileItem.FullName
        }
        elseif (Test-WebConnection -Uri $Global:StartOSDCloud.OperatingSystem.Url) {
            #Write-Host -ForegroundColor Yellow "Download"
            Write-Host -ForegroundColor Yellow $Global:StartOSDCloud.OperatingSystem.Name
            Write-Host -ForegroundColor Yellow $Global:StartOSDCloud.OperatingSystem.Url
        }
        else {
            Write-Warning $Global:StartOSDCloud.OperatingSystem.Name
            Write-Warning $Global:StartOSDCloud.OperatingSystem.Url
            Write-Warning "Could not verify an Internet connection for Windows Feature Update"
            Write-Warning "OSDCloud cannot continue"
            Break
        }
    }
    #=================================================
    #   Invoke-OSDCloud.ps1
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Invoke-OSDCloud Configuration"
    $Global:StartOSDCloud | Out-Host
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Invoke-OSDCloud ... Starting in 5 seconds..."
    Start-Sleep -Seconds 5
    Invoke-OSDCloud
}