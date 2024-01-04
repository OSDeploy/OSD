function Invoke-OSDCloudIPU {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (

        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet(
            'Windows 11 23H2 x64',    
            'Windows 11 22H2 x64',
            'Windows 11 21H2 x64',
            'Windows 10 22H2 x64')]
        [System.String]
        $OSName#,
        <#
        #Operating System Edition of the Windows installation
        #Alias = Edition
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Legacy')]
        [ValidateSet('Home','HomeN','Home Single Language','Education','EducationN','Enterprise','EnterpriseN','Professional','ProfessionalN')]
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
        $OSActivation
        #>
    )
    
    #============================================================================
    #region Functions
    #============================================================================
    Function Get-TPMVer {
    $Manufacturer = (Get-WmiObject -Class:Win32_ComputerSystem).Manufacturer
    if ($Manufacturer -match "HP")
        {
        if ($((Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_TPM).SpecVersion) -match "1.2")
            {
            $versionInfo = (Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_TPM).ManufacturerVersionInfo
            $verMaj      = [Convert]::ToInt32($versionInfo[0..1] -join '', 16)
            $verMin      = [Convert]::ToInt32($versionInfo[2..3] -join '', 16)
            $verBuild    = [Convert]::ToInt32($versionInfo[4..6] -join '', 16)
            $verRevision = 0
            [version]$ver = "$verMaj`.$verMin`.$verBuild`.$verRevision"
            Write-Output "TPM Verion: $ver | Spec: $((Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_TPM).SpecVersion)"
            }
        else {Write-Output "TPM Verion: $((Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_TPM).ManufacturerVersion) | Spec: $((Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_TPM).SpecVersion)"}
        }

    else
        {
        if ($((Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_TPM).SpecVersion) -match "1.2")
            {
            Write-Output "TPM Verion: $((Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_TPM).ManufacturerVersion) | Spec: $((Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_TPM).SpecVersion)"
            }
        else {Write-Output "TPM Verion: $((Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_TPM).ManufacturerVersion) | Spec: $((Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_TPM).SpecVersion)"}
        }
    }

    #============================================================================
    #endregion Functions
    #============================================================================   
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Starting Invoke-OSDCloudIPU"
    Write-Host -ForegroundColor Gray "Looking of Details about this device...."


    $BIOSInfo = Get-WmiObject -Class 'Win32_Bios'

    # Get the current BIOS release date and format it to datetime
    $CurrentBIOSDate = [System.Management.ManagementDateTimeConverter]::ToDatetime($BIOSInfo.ReleaseDate).ToUniversalTime()

    $Manufacturer = (Get-WmiObject -Class:Win32_ComputerSystem).Manufacturer
    $ManufacturerBaseBoard = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Manufacturer
    $ComputerModel = (Get-WmiObject -Class:Win32_ComputerSystem).Model
    if ($ManufacturerBaseBoard -eq "Intel Corporation")
        {
        $ComputerModel = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product
        }
    $HPProdCode = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product
    $Serial = (Get-WmiObject -class:win32_bios).SerialNumber
    $cpuDetails = @(Get-WmiObject -Class Win32_Processor)[0]

    Write-Output "Computer Name: $env:computername"
    $CurrentOSInfo = Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    $WindowsRelease = $CurrentOSInfo.GetValue('ReleaseId')
    if ($WindowsRelease -eq "2009"){$WindowsRelease = $CurrentOSInfo.GetValue('DisplayVersion')}
    $Build = $($CurrentOSInfo.GetValue('CurrentBuild'))
    $BuildUBR_CurrentOS = $Build +"."+$($CurrentOSInfo.GetValue('UBR'))
    Write-Output "Windows $WindowsRelease | $BuildUBR_CurrentOS"
    Write-Output "Computer Model: $ComputerModel"
    Write-Output "Serial: $Serial"
    if ($Manufacturer -like "H*"){Write-Output "Computer Product Code: $HPProdCode"}
    Write-Output $cpuDetails.Name
    Write-Output "Current BIOS Level: $($BIOSInfo.SMBIOSBIOSVersion) From Date: $CurrentBIOSDate"
    Get-TPMVer
    $TimeUTC = [System.DateTime]::UtcNow
    $TimeCLT = get-date
    Write-Output "Current Client Time: $TimeCLT"
    Write-Output "Current Client UTC: $TimeUTC"
    Write-Output "Time Zone: $(Get-TimeZone)"
    $Locale = Get-WinSystemLocale
    if ($Locale -ne "en-US"){Write-Output "WinSystemLocale: $locale"}
    Get-WmiObject win32_LogicalDisk -Filter "DeviceID='C:'" | % { $FreeSpace = $_.FreeSpace/1GB -as [int] ; $DiskSize = $_.Size/1GB -as [int] }

    if ($Build -le 19045){
        $Win11 = Get-Win11Readiness
        if ($Win11.Return -eq "CAPABLE"){
            Write-Host -ForegroundColor Green "Device is Windows 11 CAPABLE"
        }
        else {
            Write-Host -ForegroundColor Yellow "Device is !NOT! Windows 11 CAPABLE"
            if ($Build -eq 19045){
                write-host -ForegroundColor Yellow "This Device is already at the latest supported Version of Windows for this Hardware"
            }
            elseif ($Build -lt 19045){
                write-host -ForegroundColor Green "But.. You can upgrade it to Windows 10 22H2"
            }
        }
    }

    $OSVersion = "Windows $($OSName.split(" ")[1])"
    $OSReleaseID = $OSName.split(" ")[2]
    $Product = (Get-MyComputerProduct)
    $DriverPack = Get-OSDCloudDriverPack -Product $Product -OSVersion $OSVersion -OSReleaseID $OSReleaseID
    Write-host -ForegroundColor Gray "Recommended Driverpack for upgrade: $($DriverPack.Name)"

    if (!($OSEdition)){
        $OSEdition = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name "EditionID"
    }
    if (!($OSLanguage)){
        $OSLanguage = (Get-WinSystemLocale).Name
    }
    if (!($OSActivation)){
        $OSActivation = (Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey }).ProductKeyChannel
    }

    #=================================================
    #	OSEditionId and OSActivation
    #=================================================
    if ($OSEdition -eq 'Home') {
        $OSEditionId = 'Core'
        $OSActivation = 'Retail'
        $OSImageIndex = 4
    }
    if ($OSEdition -eq 'Home N') {
        $OSEditionId = 'CoreN'
        $OSActivation = 'Retail'
        $OSImageIndex = 5
    }
    if ($OSEdition -eq 'Home Single Language') {
        $OSEditionId = 'CoreSingleLanguage'
        $OSActivation = 'Retail'
        $OSImageIndex = 6
    }
    if ($OSEdition -eq 'Enterprise') {
        $OSEditionId = 'Enterprise'
        $OSActivation = 'Volume'
        $OSImageIndex = 6
    }
    if (($OSEdition -eq 'Enterprise N') -or ($OSEdition -eq 'EnterpriseN')) {
        $OSEditionId = 'EnterpriseN'
        $OSActivation = 'Volume'
        $OSImageIndex = 7
    }
    if ($OSEdition -eq 'Education') {
        $OSEditionId = 'Education'
        if ($OSActivation -eq 'Retail') {$OSImageIndex = 7}
        if ($OSActivation -eq 'Volume') {$OSImageIndex = 4}
    }
    if (($OSEdition -eq 'Education N') -or ($OSEdition -eq 'EducationN')) {
        $OSEditionId = 'EducationN'
        if ($OSActivation -eq 'Retail') {$OSImageIndex = 8}
        if ($OSActivation -eq 'Volume') {$OSImageIndex = 5}
    }
    if (($OSEdition -eq 'Pro') -or ($OSEdition -eq 'Professional'))  {
        $OSEditionId = 'Professional'
        if ($OSActivation -eq 'Retail') {$OSImageIndex = 9}
        if ($OSActivation -eq 'Volume') {$OSImageIndex = 8}
    }
    if (($OSEdition -eq 'Pro N') -or ($OSEdition -eq 'ProfessionalN')) {
        $OSEditionId = 'ProfessionalN'
        if ($OSActivation -eq 'Retail') {$OSImageIndex = 10}
        if ($OSActivation -eq 'Volume') {$OSImageIndex = 9}
    }
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor DarkCyan "These are set automatically based on your current OS"
    Write-Host -ForegroundColor Cyan "OSEditionId: " -NoNewline
    Write-Host -ForegroundColor Green $OSEditionId
    Write-Host -ForegroundColor Cyan "OSImageIndex: " -NoNewline
    Write-Host -ForegroundColor Green $OSImageIndex
    Write-Host -ForegroundColor Cyan "OSLanguage: " -NoNewline
    Write-Host -ForegroundColor Green $OSLanguage
    Write-Host -ForegroundColor Cyan "OSActivation: " -NoNewline
    Write-Host -ForegroundColor Green $OSActivation
 
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Starting Feature Update lookup and Download"

    $ScratchLocation = 'c:\OSDCloud\IPU'
    $MediaLocation = "$ScratchLocation\Media"
    if (!(Test-Path -Path $ScratchLocation)){New-Item -Path $ScratchLocation -ItemType Directory -Force | Out-Null}
    if (Test-Path -Path $MediaLocation){Remove-Item -Path $MediaLocation -Force -Recurse}
    New-Item -Path $MediaLocation -ItemType Directory -Force | Out-Null

    $ESD = Get-FeatureUpdate -OSName $OSName -OSActivation $OSActivation -OSLanguage $OSLanguage 
    Write-Host -ForegroundColor Cyan "Name: " -NoNewline
    Write-Host -ForegroundColor Green $ESD.Name
    Write-Host -ForegroundColor Cyan "Architecture: " -NoNewline
    Write-Host -ForegroundColor Green $ESD.Architecture
    Write-Host -ForegroundColor Cyan "Activation: " -NoNewline
    Write-Host -ForegroundColor Green $ESD.Activation
    Write-Host -ForegroundColor Cyan "Build: " -NoNewline
    Write-Host -ForegroundColor Green $ESD.Build    
    Write-Host -ForegroundColor Cyan "FileName: " -NoNewline
    Write-Host -ForegroundColor Green $ESD.FileName   
    Write-Host -ForegroundColor Cyan "Url: " -NoNewline
    Write-Host -ForegroundColor Green $ESD.Url   
         
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Getting Content for Upgrade Media"   

    $ImagePath = "$ScratchLocation\$($ESD.FileName)"
    if (Test-path -path $ImagePath){
        Write-Host -ForegroundColor Gray "Found previously downloaded media, getting SHA1 Hash"
        $SHA1Hash = Get-FileHash $ImagePath -Algorithm SHA1
        if ($SHA1Hash.Hash -eq $esd.SHA1){
            Write-Host -ForegroundColor Gray "SHA1 Match on $ImagePath, skipping Download"
        }
        else {
            Write-Host -ForegroundColor Gray "SHA1 Match Failed on $ImagePath, removing content"
            #Save-WebFile -SourceUrl $ESD.Url -DestinationDirectory $ScratchLocation -DestinationName $ESD.FileName
            Write-Host -ForegroundColor Gray "Starting Download to $ImagePath, this takes awhile"
            
            <# This was taking way too long for some files
            #Get ESD Size
            $req = [System.Net.HttpWebRequest]::Create("$($ESD.Url)")
            $res = $req.GetResponse()
            (Invoke-WebRequest $ESD.Url -Method Head).Headers.'Content-Length'
            $ESDSizeMB = $([Math]::Round($res.ContentLength /1000000)) 
            Write-Host "Total Size: $ESDSizeMB MB"
            #>

            #Clear Out any Previous Attempts
            $ExistingBitsJob = Get-BitsTransfer -Name "$($ESD.FileName)" -AllUsers -ErrorAction SilentlyContinue
            If ($ExistingBitsJob) {
                Remove-BitsTransfer -BitsJob $ExistingBitsJob
            }
    
            #Start Download using BITS
            $BitsJob = Start-BitsTransfer -Source $ESD.Url -Destination $ImagePath -DisplayName "$($ESD.FileName)" -Description "Windows Media Download" -RetryInterval 60
            If ($BitsJob.JobState -eq "Error"){
                write-Host "BITS tranfer failed: $($BitsJob.ErrorDescription)"
            }
        }
    }



    #Grab ESD File and create bootable ISO

    if ((Test-Path -Path $ImagePath) -and (Test-Path -Path $MediaLocation)){
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Starting Extract of ESD file to create Setup Content"
        $ApplyPath = $MediaLocation
        Write-Host -ForegroundColor Gray "Expanding $ImagePath Index 1 to $ApplyPath"
        $Expand = Expand-WindowsImage -ImagePath $ImagePath -Index 1 -ApplyPath $ApplyPath
        #Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex 2 -DestinationImagePath "$ApplyPath\Sources\boot.wim" -CompressionType max -CheckIntegrity
        #Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex 3 -DestinationImagePath "$ApplyPath\Sources\boot.wim" -CompressionType max -CheckIntegrity -Setbootable
        Write-Host -ForegroundColor Gray "Expanding $ImagePath Index $OSImageIndex to $ApplyPath\Sources\install.wim"
        $Expand = Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex $OSImageIndex -DestinationImagePath "$ApplyPath\Sources\install.wim" -CompressionType max -CheckIntegrity
        #Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex 5 -DestinationImagePath "$ApplyPath\Sources\install.wim" -CompressionType max -CheckIntegrity
    }
    #>
}