function New-OSDCloudOSWimFile {
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
        $OSActivation
    
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
    #================================================
    #   Get Index & OS Info
    #================================================
    <#
    if ($OSName -match "ARM64"){
        $OSArch = 'ARM64'
        $IndexInfo = Get-OSDCloudOperatingSystemsIndexes -OSArch ARM64 | Where-Object {$_.Name -match $OSName} | Where-Object {$_.Activation -eq $OSActivation} | Where-Object {$_.Language -eq $OSLanguage}
    }
    else {
        $OSArch = 'x64'
        $IndexInfo = Get-OSDCloudOperatingSystemsIndexes | Where-Object {$_.Name -match $OSName} | Where-Object {$_.Activation -eq $OSActivation} | Where-Object {$_.Language -eq $OSLanguage}
    }
    #>

    if ($OSName -match "ARM64"){
        $OSArch = 'ARM64'
        $OSDCloudOperatingSystem = (Get-OSDCloudOperatingSystemsIndexes -OSArch ARM64) | Where-Object {$_.Name -match $OSName} | Where-Object {$_.Activation -eq $OSActivation} | Where-Object {$_.Language -eq $OSLanguage}
    }
    else {
        $OSArch = 'x64'
        $OSDCloudOperatingSystem = Get-OSDCloudOperatingSystemsIndexes | Where-Object {$_.Name -match $OSName} | Where-Object {$_.Activation -eq $OSActivation} | Where-Object {$_.Language -eq $OSLanguage}
    }
    $OSEditionID = "$($OSDCloudOperatingSystem.Version) $OSEdition"
    $OSImageIndex = $OSDCloudOperatingSystem.Indexes.$OSEditionID

    if ($OSImageIndex -eq $null){
        Write-Host -ForegroundColor Red "Unable to determine OSImageIndex for Index $OSEdition"
        Write-Host -ForegroundColor Yellow "Available Indexes are $($OSDCloudOperatingSystem.IndexNames.replace($(($OSDCloudOperatingSystem).Version),'') -join ', ')"
        throw "Unable to determine OSImageIndex for $OSName $OSEdition $OSActivation $OSLanguage"
    }
    
    #$OSBuild = $OSDCloudOperatingSystem.Build
    #$OSReleaseID = $OSDCloudOperatingSystem.ReleaseID
    #$OSVersion = $OSDCloudOperatingSystem.Version
    
    #$ImageFileName = $OSDCloudOperatingSystem.FileName
    #$ImageFileUrl = $OSDCloudOperatingSystem.Url

    $ImageFileItem = Find-OSDCloudFile -Name $OSDCloudOperatingSystem.FileName -Path '\OSDCloud\OS\' | Sort-Object FullName | Where-Object {$_.Length -gt 3GB}
    $ImageFileItem = $ImageFileItem | Where-Object {$_.FullName -notlike "C*"} | Where-Object {$_.FullName -notlike "X*"} | Select-Object -First 1


    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor DarkCyan "These are set automatically based on your current OS"
    Write-Host -ForegroundColor Cyan "OSEditionId: " -NoNewline
    Write-Host -ForegroundColor Green $OSEdition
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

    <##>
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
    
}