function Invoke-OSDCloudIPU {
    <#
    Log Files for IPU: https://learn.microsoft.com/en-us/windows/deployment/upgrade/log-files
    Setup Command Line: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-command-line-options?view=windows-11
    #>
    
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (

        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet(
            'Windows 11 23H2 x64',
            'Windows 11 23H2 ARM64',    
            'Windows 11 22H2 x64',
            'Windows 11 21H2 x64',
            'Windows 10 22H2 x64',
            'Windows 10 22H2 ARM64')]
        [System.String]
        $OSName = 'Windows 11 23H2 x64',

        [switch]
        $Silent,

        [switch]
        $SkipDriverPack,

        [switch]
        $NoReboot,

        [switch]
        $DownloadOnly,

        [switch]
        $DiagnosticPrompt
    )
    #region Admin Elevation
    $whoiam = [system.security.principal.windowsidentity]::getcurrent().name
    $isElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if ($isElevated) {
        Write-Host -ForegroundColor Green "[+] Running as $whoiam and IS Admin Elevated"
    }
    else {
        Write-Warning "[-] Running as $whoiam and is NOT Admin Elevated"
        Break
    }

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

    #endregion Functions
    
    #============================================================================
    #region Device Info
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
    if ($Build -le 19045){$WinVer = "10"}
    else {$WinVer = "11"}
    Write-Output "Windows $WinVer $WindowsRelease | $BuildUBR_CurrentOS"
    Write-Output "Architecture ('env:PROCESSOR_ARCHITECTURE'): $env:PROCESSOR_ARCHITECTURE "
    Write-Output "Architecture (Get-NativeMatchineImage): $((Get-NativeMatchineImage).NativeMachine)"
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
    $FreeSpace = (Get-CimInstance win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace/1GB -as [int]
    $DiskSize = (Get-CimInstance win32_LogicalDisk -Filter "DeviceID='C:'").Size/1GB -as [int]
    Write-Output "C:\ Drive Size: $DiskSize, Freespace: $FreeSpace"

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

    #$OSVersion = "Windows $($OSName.split(" ")[1])"
    #$OSReleaseID = $OSName.split(" ")[2]
    #$Product = (Get-MyComputerProduct)
    
    $DriverPack = Get-OSDCloudDriverPack # -Product $Product -OSVersion $OSVersion -OSReleaseID $OSReleaseID
    if ($DriverPack){
        Write-host -ForegroundColor Gray "Recommended Driverpack for upgrade: $($DriverPack.Name)"
        if ($SkipDriverPack){
            write-host -ForegroundColor Yellow "Skipping Download and Integration [-SkipDriverPack]"
        }
    }

    #endregion Device Info

    #============================================================================
    #region Current Activiation
    #============================================================================

    if (!($OSEdition)){
        $OSEdition = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name "EditionID"
    }
    if (!($OSLanguage)){
        $OSLanguage = (Get-WinSystemLocale).Name
    }
    if (!($OSActivation)){
        $OSActivation = (Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey }).ProductKeyChannel
    }
    if ($OSActivation -match "OEM"){
        $OSActivation = "Retail"
    }
    $OSArch = $env:PROCESSOR_ARCHITECTURE   
    if ($OSArch -eq "AMD64"){$OSArch = 'x64'}
    #endregion Current Activiation
    
    if ($OSArch -eq "ARM64"){
        #=================================================
        #	OSEditionId and OSActivation ARM64
        #=================================================
        if (($OSEdition -eq 'Home') -or ($OSEdition -eq 'Core')) {
            $OSEditionId = 'Core'
            $OSActivation = 'Retail'
            $OSImageIndex = 4
        }
        if ($OSEdition -eq 'Home Single Language') {
            $OSEditionId = 'CoreSingleLanguage'
            $OSActivation = 'Retail'
            $OSImageIndex = 5
        }
        if (($OSEdition -eq 'Pro') -or ($OSEdition -eq 'Professional'))  {
            $OSEditionId = 'Professional'
            if ($OSActivation -eq 'Retail') {$OSImageIndex = 6}
            if ($OSActivation -eq 'Volume') {$OSImageIndex = 8}
        }
    }
    else {
        #=================================================
        #	OSEditionId and OSActivation x64 (AMD64)
        #=================================================
        if (($OSEdition -eq 'Home') -or ($OSEdition -eq 'Core')) {
            $OSEditionId = 'Core'
            $OSActivation = 'Retail'
            $OSImageIndex = 4
        }
        if (($OSEdition -eq 'Home N') -or ($OSEdition -eq 'CoreN')) {
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
    Write-Host -ForegroundColor Cyan "OSArch: " -NoNewline
    Write-Host -ForegroundColor Green $OSArch

    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Starting Feature Update lookup and Download"

    #============================================================================
    #region Detect & Download ESD File
    #============================================================================

    $ScratchLocation = 'c:\OSDCloud\IPU'
    $OSMediaLocation = 'c:\OSDCloud\OS'
    $MediaLocation = "$ScratchLocation\Media"
    if (!(Test-Path -Path $OSMediaLocation)){New-Item -Path $OSMediaLocation -ItemType Directory -Force | Out-Null}
    if (!(Test-Path -Path $ScratchLocation)){New-Item -Path $ScratchLocation -ItemType Directory -Force | Out-Null}
    if (Test-Path -Path $MediaLocation){Remove-Item -Path $MediaLocation -Force -Recurse}
    New-Item -Path $MediaLocation -ItemType Directory -Force | Out-Null

    $ESD = Get-FeatureUpdate -OSName $OSName -OSActivation $OSActivation -OSLanguage $OSLanguage -OSArchitecture $OSArch
    if (!($ESD)){
        Write-Host -ForegroundColor Red "Unable to Determine proper ESD Upgrade File"
        throw "Unable to Determine proper ESD Upgrade File"
    }
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

    #Build Media Paths
    $SubFolderName = "$($ESD.Version) $($ESD.ReleaseId)"
    $ImageFolderPath = "$OSMediaLocation\$SubFolderName"
    if (!(Test-Path -Path $ImageFolderPath)){New-Item -Path $ImageFolderPath -ItemType Directory -Force | Out-Null}
    $ImagePath = "$ImageFolderPath\$($ESD.FileName)"
    $ImageDownloadRequired = $true

    #Check Flash Drive for Media
    $OSDCloudUSB = Get-Volume.usb | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Select-Object -First 1
    if ($OSDCloudUSB){
        $USBImagePath = "$($OSDCloudUSB.DriveLetter):\OSDCloud\OS\$SubFolderName\$($ESD.FileName)"
        if ((Test-Path -path $USBImagePath) -and (!(Test-Path -path $ImagePath))){
            Write-Host -ForegroundColor Green "Found media on OSDCloudUSB - Copying Local"
            Copy-Item -Path $USBImagePath -Destination $ImagePath
        }
    }
    
    #Test for Media
    if (Test-path -path $ImagePath){
        Write-Host -ForegroundColor Gray "Found previously downloaded media, getting SHA1 Hash"
        $SHA1Hash = Get-FileHash $ImagePath -Algorithm SHA1
        if ($SHA1Hash.Hash -eq $esd.SHA1){
            Write-Host -ForegroundColor Gray "SHA1 Match on $ImagePath, skipping Download"
            $ImageDownloadRequired = $false
        }
        else {
            Write-Host -ForegroundColor Gray "SHA1 Match Failed on $ImagePath, removing content"
        }
        
    }
    if ($ImageDownloadRequired -eq $true){
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
    
        if ((Get-Service -name BITS).Status -ne "Running"){
            Write-Host -ForegroundColor Yellow "BITS Service is not Running, which is required to download ESD File, attempting to Start"
            $StartBITS = Start-Service -Name BITS -PassThru
            Start-Sleep -Seconds 2
            if ($StartBITS.Status -ne "Running"){

            }
        }
        #Start Download using BITS
        Write-Host -ForegroundColor DarkGray "Start-BitsTransfer -Source $ESD.Url -Destination $ImageFolderPath -DisplayName $($ESD.FileName) -Description 'Windows Media Download' -RetryInterval 60"
        $BitsJob = Start-BitsTransfer -Source $ESD.Url -Destination $ImageFolderPath -DisplayName "$($ESD.FileName)" -Description "Windows Media Download" -RetryInterval 60
        If ($BitsJob.JobState -eq "Error"){
            write-Host "BITS tranfer failed: $($BitsJob.ErrorDescription)"
        }

    }

    #endregion Detect & Download ESD File

    #============================================================================
    #region Extract of ESD file to create Setup Content
    #============================================================================


    #Grab ESD File and create bootable ISO
    if ((!(Test-Path -Path $ImagePath)) -or (!(Test-Path -Path $MediaLocation))){
        if (!(Test-Path -Path $ImagePath)){
            Write-Host -ForegroundColor Red "Missing $ImagePath, double check download process"
            throw "Failed to find $ImagePath, double check download process"
        }
        if (!(Test-Path -Path $MediaLocation)){
            Write-Host -ForegroundColor Red "Missing $MediaLocation, double check folder exist"
            throw "Faield to find $MediaLocation, double check folder exist"
        }
    }
    if ((Test-Path -Path $ImagePath) -and (Test-Path -Path $MediaLocation)){
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Starting Extract of ESD file to create Setup Content"
        $ApplyPath = $MediaLocation
        Write-Host -ForegroundColor Gray "Expanding $ImagePath Index 1 to $ApplyPath"
        $Expand = Expand-WindowsImage -ImagePath $ImagePath -Index 1 -ApplyPath $ApplyPath
        ##Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex 2 -DestinationImagePath "$ApplyPath\Sources\boot.wim" -CompressionType max -CheckIntegrity
        ##Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex 3 -DestinationImagePath "$ApplyPath\Sources\boot.wim" -CompressionType max -CheckIntegrity -Setbootable
        Write-Host -ForegroundColor Gray "Expanding $ImagePath Index $OSImageIndex to $ApplyPath\Sources\install.wim"
        $Expand = Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex $OSImageIndex -DestinationImagePath "$ApplyPath\Sources\install.wim" -CheckIntegrity
        ##Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex 5 -DestinationImagePath "$ApplyPath\Sources\install.wim" -CompressionType max -CheckIntegrity
        $null = $Expand
    }
    
    #endregion Extract of ESD file to create Setup Content

    if (!(Test-Path -Path "$MediaLocation\Setup.exe")){
        Write-Host -ForegroundColor Red "Setup.exe not found, something went wrong"
        throw
    }
    if (!(Test-Path -Path "$MediaLocation\sources\install.wim")){
        Write-Host -ForegroundColor Red "install.wim not found, something went wrong"
        throw
    }


    if (($DriverPack) -and (!($SkipDriverPack))){
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Getting Driver Pack for IPU Integration"           
        $DriverPackDownloadRequired = $true
        if (!(Test-Path -Path "C:\Drivers")){New-Item -Path "C:\Drivers" -ItemType Directory -Force | Out-Null}
        $DriverPackPath = "C:\Drivers\$($DriverPack.FileName)"
        if (Test-path -path $DriverPackPath){
            Write-Host -ForegroundColor Gray "Found previously downloaded DriverPack File, getting MD5 Hash"
            $MD5Hash = Get-FileHash $DriverPackPath -Algorithm MD5
            if ($MD5Hash.Hash -eq $DriverPack.HashMD5){
                Write-Host -ForegroundColor Gray "MD5 Match on $DriverPackPath, skipping Download"
                $DriverPackDownloadRequired = $false
            }
            else {
                Write-Host -ForegroundColor Gray "MD5 Match Failed on $DriverPackPath, removing content"
            }
        }
        
        IF ($DriverPackDownloadRequired -eq $true){
            Write-Host -ForegroundColor Gray "Starting Download to $DriverPackPath, this takes awhile"
            <#
            #Get DrivePack Size
            $req = [System.Net.HttpWebRequest]::Create("$($DriverPack.Url)")
            $res = $req.GetResponse()
            (Invoke-WebRequest $ESD.Url -Method Head).Headers.'Content-Length'
            $SizeMB = $([Math]::Round($res.ContentLength /1000000)) 
            Write-Host "Total Size: $SizeMB MB"
            #>

            #Clear Out any Previous Attempts
            $ExistingBitsJob = Get-BitsTransfer -Name "$($DriverPack.FileName)" -AllUsers -ErrorAction SilentlyContinue
            If ($ExistingBitsJob) {
                Remove-BitsTransfer -BitsJob $ExistingBitsJob
            }
    
            #Start Download using BITS
            $BitsJob = Start-BitsTransfer -Source $DriverPack.Url -Destination $DriverPackPath -DisplayName "$($DriverPack.FileName)" -Description "Driver Pack Download" -RetryInterval 60
            If ($BitsJob.JobState -eq "Error"){
                write-Host "BITS tranfer failed: $($BitsJob.ErrorDescription)"
            }
        }
        #Expand Driver Pack
        if (Test-path -path $DriverPackPath){
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Expanding DriverPack for Upgrade Media"   
            Expand-StagedDriverPack
            $DriverPackFile = Get-ChildItem -Path $DriverPackPath -Filter $DriverPack.FileName
            $DriverPackExpandPath = Join-Path $DriverPackFile.Directory $DriverPackFile.BaseName
            if (Test-Path -Path $DriverPackExpandPath){

            }
        }
    }
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Triggering Windows Upgrade Setup"   
    
    if ($DownloadOnly){
        Write-Host -ForegroundColor Yellow "Download Complete, exiting script before install based on 'DownloadOnly' switch"
    }
    else {
        #============================================================================
        #region Creating Arguments based on Parameters
        #============================================================================
        #Driver Integration - Adds .inf-style drivers to the new Windows 10 installation.
        if ($DriverPack){
            if ($DriverPackPath){
                if (Test-path -path $DriverPackPath){
                    $driverarg = "/InstallDrivers $DriverPackExpandPath"
                }
            }
        }
        else {
            $DriverArg = ""
        }
        
        #Run Silently - This will suppress any Windows Setup user experience including the rollback user experience.
        if ($Silent){
            $SilentArg = "/quiet"
        }
        else{
            $SilentArg = ""
        }
        
        #Dynamic Updates - Specifies whether Windows Setup will perform Dynamic Update operations (search, download, and install updates).
        if ($DynamicUpdate){
            $DynamicUpdateArg = "/DynamicUpdate Enable"
        }
        else{
            $DynamicUpdateArg = "/DynamicUpdate Disable"
        }
        
        #Diagnostic Prompt - Specifies that the Command Prompt is available during Windows Setup.
        if ($DiagnosticPrompt){
            $DiagnosticPromptArg = "/diagnosticprompt enable"
        }
        else{
            $DiagnosticPromptArg  = ""
        }
        #Diagnostic Prompt - Specifies that the Command Prompt is available during Windows Setup.
        if ($NoReboot){
            $NoRebootArg = "/noreboot"
        }
        else{
            $NoRebootArg  = ""
        }
        
        $ParamStartProcess = @{
            FilePath = "$MediaLocation\Setup.exe"
            ArgumentList = "/Auto Upgrade $DynamicUpdateArg /EULA accept $DriverArg /Priority High $SilentArg $DiagnosticPromptArg $NoRebootArg"
        } 

        Write-Host -ForegroundColor Cyan "Setup Path: " -NoNewline
        Write-Host -ForegroundColor Green $ParamStartProcess.FilePath
        Write-Host -ForegroundColor Cyan "Arguments: " -NoNewline
        Write-Host -ForegroundColor Green $ParamStartProcess.ArgumentList


        #endregion Creating Arguments based on Parameters

        Start-Process @ParamStartProcess
    }
}