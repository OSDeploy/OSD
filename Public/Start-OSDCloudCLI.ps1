function Start-OSDCloudCLI {
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

        #$Global:StartOSDCloudCLI.MSCatalogFirmware = $true
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
    #	$Global:StartOSDCloudCLI
    #=================================================
    $localOSDCloudParams = (Get-Command Start-OSDCloudCLI).Parameters
    $Global:StartOSDCloudCLI = $null
    $Global:StartOSDCloudCLI = [ordered]@{
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
        $Global:StartOSDCloudCLI.MSCatalogFirmware = $true
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
        $Global:StartOSDCloudCLI.ScreenshotCapture = $true
        Start-ScreenPNGProcess -Directory $Global:StartOSDCloudCLI.ScreenshotPath
    }
    #=================================================
    #	Computer Information
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($Global:StartOSDCloudCLI.Function) | $ComputerManufacturer $($Global:StartOSDCloudCLI.ComputerModel) product $ComputerProduct"
    #=================================================
    #	Battery
    #=================================================
    if ($Global:StartOSDCloudCLI.IsOnBattery) {
        Write-Warning "Computer is currently running on Battery"
    }
    #=================================================
    #	-ZTI
    #=================================================
    if ($Global:StartOSDCloudCLI.ZTI) {
        $Global:StartOSDCloudCLI.GetDiskFixed = Get-Disk.fixed | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number

        if (($Global:StartOSDCloudCLI.GetDiskFixed | Measure-Object).Count -lt 2) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Warning "This Warning is displayed when using the -ZTI parameter"
            Write-Warning "OSDisk will be cleaned automatically without confirmation"
            Write-Warning "Press CTRL + C to cancel"
            $Global:StartOSDCloudCLI.GetDiskFixed | Select-Object -Property Number, BusType, MediaType,`
            FriendlyName, PartitionStyle, NumberOfPartitions,`
            @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}} | Format-Table

            Write-Warning "OSDCloud will continue in 5 seconds"
            Start-Sleep -Seconds 5
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Warning "More than 1 Fixed Disk is present"
            Write-Warning "Disks will not be cleaned automatically"
            $Global:StartOSDCloudCLI.GetDiskFixed | Select-Object -Property Number, BusType, MediaType,`
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
    if ($Global:StartOSDCloudCLI.ImageFileFullName -and $Global:StartOSDCloudCLI.ImageFileItem -and $Global:StartOSDCloudCLI.ImageFileName) {
        #Custom Image set in OSDCloudGUI
        Break
    }
    #=================================================
    #	ParameterSet CustomImage
    #=================================================
    elseif ($PSCmdlet.ParameterSetName -eq 'CustomImage') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Custom Windows Image"

        if ($Global:StartOSDCloudCLI.ImageFileUrl) {
            Write-Host -ForegroundColor DarkGray "ImageFileUrl: $($Global:StartOSDCloudCLI.ImageFileUrl)"
            Write-Host -ForegroundColor DarkGray "ImageIndex: $($Global:StartOSDCloudCLI.OSImageIndex)"
        }
        if ($PSBoundParameters.ContainsKey('FindImageFile')) {
            $Global:StartOSDCloudCLI.ImageFileItem = Select-OSDCloudFileWim

            if ($Global:StartOSDCloudCLI.ImageFileItem) {
                $Global:StartOSDCloudCLI.OSImageIndex = Select-OSDCloudImageIndex -ImagePath $Global:StartOSDCloudCLI.ImageFileItem.FullName

                Write-Host -ForegroundColor DarkGray "ImageFileItem: $($Global:StartOSDCloudCLI.ImageFileItem.FullName)"
                Write-Host -ForegroundColor DarkGray "OSImageIndex: $($Global:StartOSDCloudCLI.OSImageIndex)"
            }
            else {
                $Global:StartOSDCloudCLI.ImageFileItem = $null
                $Global:StartOSDCloudCLI.OSImageIndex = 'AUTO'
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
        if ($Global:StartOSDCloudCLI.OSName) {
            #Do nothing
        }
        elseif ($Global:StartOSDCloudCLI.ZTI) {
            $Global:StartOSDCloudCLI.OSName = 'Windows 11 22H2 x64'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select an Operating System"

            $i = $null
            $Global:StartOSDCloudCLI.OSNameMenu = foreach ($Item in $Global:StartOSDCloudCLI.OSNameValues) {
                $i++

                $ObjectProperties = @{
                    Selection   = $i
                    Name     = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }

            $Global:StartOSDCloudCLI.OSNameMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host

            do {
                $SelectReadHost = Read-Host -Prompt "Enter the Selection Number"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloudCLI.OSNameMenu.Selection))))

            $Global:StartOSDCloudCLI.OSName = $Global:StartOSDCloudCLI.OSNameMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        }
        $OSName = $Global:StartOSDCloudCLI.OSName

        if ($OSName -match 'Windows 10') {
            $Global:StartOSDCloudCLI.OSVersion = 'Windows 10'
        }
        if ($OSName -match 'Windows 11') {
            $Global:StartOSDCloudCLI.OSVersion = 'Windows 11'
        }
        $OSVersion = $Global:StartOSDCloudCLI.OSVersion

        if ($OSName -match '22H2') {
            $Global:StartOSDCloudCLI.OSReleaseID = '22H2'
        }
        if ($OSName -match '21H2') {
            $Global:StartOSDCloudCLI.OSReleaseID = '21H2'
        }
        if ($OSName -match '21H1') {
            $Global:StartOSDCloudCLI.OSReleaseID = '21H1'
        }
        if ($OSName -match '20H2') {
            $Global:StartOSDCloudCLI.OSReleaseID = '20H2'
        }
        if ($OSName -match '2004') {
            $Global:StartOSDCloudCLI.OSReleaseID = '2004'
        }
        if ($OSName -match '1909') {
            $Global:StartOSDCloudCLI.OSReleaseID = '1909'
        }
        if ($OSName -match '1903') {
            $Global:StartOSDCloudCLI.OSReleaseID = '1903'
        }
        if ($OSName -match '1809') {
            $Global:StartOSDCloudCLI.OSReleaseID = '1809'
        }
        $OSReleaseID = $Global:StartOSDCloudCLI.OSReleaseID
    }
    #=================================================
    #	ParameterSet Legacy
    #=================================================
    elseif ($PSCmdlet.ParameterSetName -eq 'Legacy') {

        if ($Global:StartOSDCloudCLI.OSVersion) {
            #Do nothing
        }
        elseif ($Global:StartOSDCloudCLI.ZTI) {
            $Global:StartOSDCloudCLI.OSVersion = 'Windows 11'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select an Operating System"

            $i = $null
            $Global:StartOSDCloudCLI.OSVersionMenu = foreach ($Item in $Global:StartOSDCloudCLI.OSVersionValues) {
                $i++

                $ObjectProperties = @{
                    Selection   = $i
                    Name     = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }

            $Global:StartOSDCloudCLI.OSVersionMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host

            do {
                $SelectReadHost = Read-Host -Prompt "Enter the Selection Number"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloudCLI.OSVersionMenu.Selection))))

            $Global:StartOSDCloudCLI.OSVersion = $Global:StartOSDCloudCLI.OSVersionMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        }
        $OSVersion = $Global:StartOSDCloudCLI.OSVersion
        #=================================================
        #	OSReleaseID
        #=================================================
        if ($Global:StartOSDCloudCLI.OSReleaseID) {
            #Do nothing
        }
        elseif ($Global:StartOSDCloudCLI.ZTI) {
            $Global:StartOSDCloudCLI.OSReleaseID = '22H2'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select a ReleaseID for $OSVersion x64"
            
            $i = $null
            $Global:StartOSDCloudCLI.OSReleaseIDMenu = foreach ($Item in $Global:StartOSDCloudCLI.OSReleaseIDValues) {
                $i++
            
                $ObjectProperties = @{
                    Selection   = $i
                    Name     = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
            
            $Global:StartOSDCloudCLI.OSReleaseIDMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
            
            do {
                $SelectReadHost = Read-Host -Prompt "Enter the Selection Number"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloudCLI.OSReleaseIDMenu.Selection))))
            
            $Global:StartOSDCloudCLI.OSReleaseID = $Global:StartOSDCloudCLI.OSReleaseIDMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        }
        $OSReleaseID = $Global:StartOSDCloudCLI.OSReleaseID
    }
    #=================================================
    #	OSEdition
    #=================================================
    if (($PSCmdlet.ParameterSetName -eq 'Default') -or ($PSCmdlet.ParameterSetName -eq 'Legacy')) {
        if ($Global:StartOSDCloudCLI.OSEdition) {
        }
        elseif ($ZTI) {
            $Global:StartOSDCloudCLI.OSEdition = 'Enterprise'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select an Operating System Edition"
            $Global:StartOSDCloudCLI.OSEditionValues = @('Home','Home N','Home Single Language','Education','Education N','Enterprise','Enterprise N','Pro','Pro N')

            $i = $null
            $Global:StartOSDCloudCLI.OSEditionMenu = foreach ($Item in $Global:StartOSDCloudCLI.OSEditionValues) {
                $i++
            
                $ObjectProperties = @{
                    Selection   = $i
                    Name     = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
            
            $Global:StartOSDCloudCLI.OSEditionMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
            
            do {
                $SelectReadHost = Read-Host -Prompt "Enter the Selection Number"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloudCLI.OSEditionMenu.Selection))))
            
            $Global:StartOSDCloudCLI.OSEdition = $Global:StartOSDCloudCLI.OSEditionMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        }
        #=================================================
        #	OSEditionId and OSActivation
        #=================================================
        if ($Global:StartOSDCloudCLI.OSEdition -eq 'Home') {
            $Global:StartOSDCloudCLI.OSEditionId = 'Core'
            $Global:StartOSDCloudCLI.OSActivation = 'Retail'
            $Global:StartOSDCloudCLI.OSImageIndex = 4
        }
        if ($Global:StartOSDCloudCLI.OSEdition -eq 'Home N') {
            $Global:StartOSDCloudCLI.OSEditionId = 'CoreN'
            $Global:StartOSDCloudCLI.OSActivation = 'Retail'
            $Global:StartOSDCloudCLI.OSImageIndex = 5
        }
        if ($Global:StartOSDCloudCLI.OSEdition -eq 'Home Single Language') {
            $Global:StartOSDCloudCLI.OSEditionId = 'CoreSingleLanguage'
            $Global:StartOSDCloudCLI.OSActivation = 'Retail'
            $Global:StartOSDCloudCLI.OSImageIndex = 6
        }
        if ($Global:StartOSDCloudCLI.OSEdition -eq 'Enterprise') {
            $Global:StartOSDCloudCLI.OSEditionId = 'Enterprise'
            $Global:StartOSDCloudCLI.OSActivation = 'Volume'
            $Global:StartOSDCloudCLI.OSImageIndex = 6
        }
        if ($Global:StartOSDCloudCLI.OSEdition -eq 'Enterprise N') {
            $Global:StartOSDCloudCLI.OSEditionId = 'EnterpriseN'
            $Global:StartOSDCloudCLI.OSActivation = 'Volume'
            $Global:StartOSDCloudCLI.OSImageIndex = 7
        }
        $OSEdition = $Global:StartOSDCloudCLI.OSEdition
        #=================================================
        #	OSActivation
        #=================================================
        if ($Global:StartOSDCloudCLI.OSActivation) {
            #Do nothing
        }
        elseif ($Global:StartOSDCloudCLI.ZTI) {
            $Global:StartOSDCloudCLI.OSActivation = 'Volume'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select an Operating System License Activation"
            
            $i = $null
            $Global:StartOSDCloudCLI.OSActivationMenu = foreach ($Item in $Global:StartOSDCloudCLI.OSActivationValues) {
                $i++
            
                $ObjectProperties = @{
                    Selection           = $i
                    Name                = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
            
            $Global:StartOSDCloudCLI.OSActivationMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
            
            do {
                $SelectReadHost = Read-Host -Prompt "Enter the Selection Number"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloudCLI.OSActivationMenu.Selection))))
            
            $Global:StartOSDCloudCLI.OSActivationMenu = $Global:StartOSDCloudCLI.OSActivationMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name

            if ($Global:StartOSDCloudCLI.OSActivationMenu -match 'Retail') {
                $Global:StartOSDCloudCLI.OSActivation = 'Retail'
            }
            else {
                $Global:StartOSDCloudCLI.OSActivation = 'Volume'
            }
            #Write-Host -ForegroundColor Cyan "OSActivation: " -NoNewline
            #Write-Host -ForegroundColor Green $Global:StartOSDCloudCLI.OSActivation
        }
        if ($Global:StartOSDCloudCLI.OSEdition -eq 'Education') {
            $Global:StartOSDCloudCLI.OSEditionId = 'Education'
            if ($Global:StartOSDCloudCLI.OSActivation -eq 'Retail') {$Global:StartOSDCloudCLI.OSImageIndex = 7}
            if ($Global:StartOSDCloudCLI.OSActivation -eq 'Volume') {$Global:StartOSDCloudCLI.OSImageIndex = 4}
        }
        if ($Global:StartOSDCloudCLI.OSEdition -eq 'Education N') {
            $Global:StartOSDCloudCLI.OSEditionId = 'EducationN'
            if ($Global:StartOSDCloudCLI.OSActivation -eq 'Retail') {$Global:StartOSDCloudCLI.OSImageIndex = 8}
            if ($Global:StartOSDCloudCLI.OSActivation -eq 'Volume') {$Global:StartOSDCloudCLI.OSImageIndex = 5}
        }
        if ($Global:StartOSDCloudCLI.OSEdition -eq 'Pro') {
            $Global:StartOSDCloudCLI.OSEditionId = 'Professional'
            if ($Global:StartOSDCloudCLI.OSActivation -eq 'Retail') {$Global:StartOSDCloudCLI.OSImageIndex = 9}
            if ($Global:StartOSDCloudCLI.OSActivation -eq 'Volume') {$Global:StartOSDCloudCLI.OSImageIndex = 8}
        }
        if ($Global:StartOSDCloudCLI.OSEdition -eq 'Pro N') {
            $Global:StartOSDCloudCLI.OSEditionId = 'ProfessionalN'
            if ($Global:StartOSDCloudCLI.OSActivation -eq 'Retail') {$Global:StartOSDCloudCLI.OSImageIndex = 10}
            if ($Global:StartOSDCloudCLI.OSActivation -eq 'Volume') {$Global:StartOSDCloudCLI.OSImageIndex = 9}
        }
        $OSActivation = $Global:StartOSDCloudCLI.OSActivation
        Write-Host -ForegroundColor Cyan "OSEditionId: " -NoNewline
        Write-Host -ForegroundColor Green $Global:StartOSDCloudCLI.OSEditionId
        Write-Host -ForegroundColor Cyan "OSImageIndex: " -NoNewline
        Write-Host -ForegroundColor Green $Global:StartOSDCloudCLI.OSImageIndex
        #=================================================
        #	OSLanguage
        #=================================================
        if ($Global:StartOSDCloudCLI.OSLanguage) {
        }
        elseif ($PSBoundParameters.ContainsKey('OSLanguage')) {
        }
        elseif ($ZTI) {
            $Global:StartOSDCloudCLI.OSLanguage = 'en-us'
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select an Operating System Language"

            $i = $null
            $Global:StartOSDCloudCLI.OSLanguageMenu = foreach ($Item in $Global:StartOSDCloudCLI.OSLanguageValues) {
                $i++
            
                $ObjectProperties = @{
                    Selection   = $i
                    Name     = $Item
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
            
            $Global:StartOSDCloudCLI.OSLanguageMenu | Select-Object -Property Selection, Name | Format-Table | Out-Host
            
            do {
                $SelectReadHost = Read-Host -Prompt "Enter the Selection number"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Global:StartOSDCloudCLI.OSLanguageMenu.Selection))))
            
            $Global:StartOSDCloudCLI.OSLanguage = $Global:StartOSDCloudCLI.OSLanguageMenu | Where-Object {$_.Selection -eq $SelectReadHost} | Select-Object -ExpandProperty Name
        }
        $OSLanguage = $Global:StartOSDCloudCLI.OSLanguage
    }
    #=================================================
    #	Default
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'Default') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Get-OSDCloudOperatingSystems"

        $Global:StartOSDCloudCLI.OperatingSystem = Get-OSDCloudOperatingSystems | Where-Object {$_.Name -match $OSName} | Where-Object {$_.Activation -eq $OSActivation} | Where-Object {$_.Language -eq $OSLanguage}
    }
    #=================================================
    #	Legacy
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'Legacy') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Get-OSDCloudOperatingSystems"

        $Global:StartOSDCloudCLI.OperatingSystem = Get-OSDCloudOperatingSystems | Where-Object {$_.Version -match $OSVersion} | Where-Object {$_.Activation -eq $OSActivation} | Where-Object {$_.Language -eq $OSLanguage} | Where-Object {$_.ReleaseID -eq $OSReleaseID}
    }
    #=================================================
    #	Default or Legacy
    #=================================================
    if ($PSCmdlet.ParameterSetName -ne 'CustomImage') {
        if ($Global:StartOSDCloudCLI.OperatingSystem) {
            $Global:StartOSDCloudCLI.ImageFileName = $Global:StartOSDCloudCLI.OperatingSystem.FileName
            $Global:StartOSDCloudCLI.ImageFileUrl = $Global:StartOSDCloudCLI.OperatingSystem.Url
        }
        else {
            Write-Warning "Unable to locate a Windows Feature Update"
            Write-Warning "OSDCloud cannot continue"
            Break
        }

        $Global:StartOSDCloudCLI.ImageFileItem = Find-OSDCloudFile -Name $Global:StartOSDCloudCLI.OperatingSystem.FileName -Path '\OSDCloud\OS\' | Sort-Object FullName | Where-Object {$_.Length -gt 3GB}
        $Global:StartOSDCloudCLI.ImageFileItem = $Global:StartOSDCloudCLI.ImageFileItem | Where-Object {$_.FullName -notlike "C*"} | Where-Object {$_.FullName -notlike "X*"} | Select-Object -First 1

        if ($Global:StartOSDCloudCLI.ImageFileItem) {
            #Write-Host -ForegroundColor Green "OK"
            Write-Host -ForegroundColor DarkGray $Global:StartOSDCloudCLI.OperatingSystem.Name
            Write-Host -ForegroundColor DarkGray $Global:StartOSDCloudCLI.ImageFileItem.FullName
        }
        elseif (Test-WebConnection -Uri $Global:StartOSDCloudCLI.OperatingSystem.Url) {
            #Write-Host -ForegroundColor Yellow "Download"
            Write-Host -ForegroundColor Yellow $Global:StartOSDCloudCLI.OperatingSystem.Name
            Write-Host -ForegroundColor Yellow $Global:StartOSDCloudCLI.OperatingSystem.Url
        }
        else {
            Write-Warning $Global:StartOSDCloudCLI.OperatingSystem.Name
            Write-Warning $Global:StartOSDCloudCLI.OperatingSystem.Url
            Write-Warning "Could not verify an Internet connection for Windows Feature Update"
            Write-Warning "OSDCloud cannot continue"
            Break
        }
    }
    #================================================
    #   Set Driver Pack
    #   New logic added to Get-OSDCloudDriverPack
    #   This should match the proper OS Version ReleaseID
    #================================================
    $Global:StartOSDCloudCLI.DriverPack = Get-OSDCloudDriverPack -Product $ComputerProduct -OSVersion $Global:StartOSDCloudCLI.OSVersion -OSReleaseID $Global:StartOSDCloudCLI.OSReleaseID
    if ($Global:StartOSDCloudCLI.DriverPack) {
        $Global:StartOSDCloudCLI.DriverPackName = $Global:StartOSDCloudCLI.DriverPack.Name
    }
    #=================================================
    #   Invoke-OSDCloud.ps1
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-OSDCloudCLI Configuration"
    $Global:StartOSDCloudCLI | Out-Host
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Invoke-OSDCloud ... Starting in 5 seconds..."
    Start-Sleep -Seconds 5
    Invoke-OSDCloud
}