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
        $OSEdition = 'Pro',

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
        $OSLanguage = 'en-us',

        #License of the Windows Operating System
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Legacy')]
        [ValidateSet('Retail','Volume')]
        [Alias('License','OSLicense','Activation')]
        [System.String]
        $OSActivation = 'Retail',

        #Create ISO File - Requries Windows ADK (oscdimg.exe)
        [Parameter(ParameterSetName = 'Default')]
        [Switch]
        $CreateISO
    
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
    Write-Host -ForegroundColor DarkCyan "These are set based on your input parameters"
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
    $MediaLocation = "$ScratchLocation\Media\$OSName"
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
        Write-Host -ForegroundColor Gray "Found previously downloaded media: $ImagePath"
        write-host -ForegroundColor Gray " ... Getting SHA1 Hash for validation"
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

    #https://www.deploymentresearch.com/how-to-really-create-a-windows-10-build-10041-iso-no-3rd-party-tools-needed/
    #Using info from Johan's process to export properly
    #DISM commands are left for reference only.

    #Grab ESD File and create bootable ISO
    if ((!(Test-Path -Path $ImagePath)) -or (!(Test-Path -Path $MediaLocation))){
        if (!(Test-Path -Path $ImagePath)){
            Write-Host -ForegroundColor Red "Missing $ImagePath, double check download process"
            throw "Failed to find $ImagePath, double check download process"
        }
        if (!(Test-Path -Path $MediaLocation)){
            Write-Host -ForegroundColor Red "Missing $MediaLocation, double check folder exist"
            throw "Failed to find $MediaLocation, double check folder exist"
        }
    }
    if ((Test-Path -Path $ImagePath) -and (Test-Path -Path $MediaLocation)){
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Starting Extract of ESD file to create Setup Content"
        $ApplyPath = $MediaLocation
        Write-Host -ForegroundColor Gray "Expanding $ImagePath Index 1 to $ApplyPath"
        $Expand = Expand-WindowsImage -ImagePath $ImagePath -Index 1 -ApplyPath $ApplyPath

        # Create empty boot.wim file with compression type set to maximum
        $EmptyFolder = "$($env:TEMP)\EmptyFolder"
        New-Item -ItemType Directory -Path $EmptyFolder -Force | Out-Null
        #dism.exe /Capture-Image /ImageFile:$ISOMediaFolder\sources\boot.wim /CaptureDir:$EmptyFolder /Name:EmptyIndex /Compress:max
        New-WindowsImage -ImagePath $ApplyPath\Sources\boot.wim -CapturePath $EmptyFolder -Name EmptyIndex -Description "Empty Index" -CompressionType Fast
        
        # Export base Windows PE to empty boot.wim file (creating a second index)
        #dism.exe /Export-image /SourceImageFile:$ESDFile /SourceIndex:2 /DestinationImageFile:$ISOMediaFolder\sources\boot.wim /Compress:Recovery /Bootable
        Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex 2 -DestinationImagePath "$ApplyPath\Sources\boot.wim" -CompressionType Fast -CheckIntegrity -Setbootable
        
        # Delete the first empty index in boot.wim
        #dism.exe /Delete-Image /ImageFile:$ISOMediaFolder\sources\boot.wim /Index:1
        Remove-WindowsImage -ImagePath $ApplyPath\Sources\boot.wim -Index 1

        # Export Windows PE with Setup to boot.wim file
        #dism.exe /Export-image /SourceImageFile:$ESDFile /SourceIndex:3 /DestinationImageFile:$ISOMediaFolder\sources\boot.wim /Compress:Recovery /Bootable
        Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex 3 -DestinationImagePath "$ApplyPath\Sources\boot.wim" -CompressionType Fast -CheckIntegrity -Setbootable
        
        # Create empty install.wim file with MDT/ConfigMgr friendly compression type (maximum)
        #dism.exe /Capture-Image /ImageFile:$ISOMediaFolder\sources\install.wim /CaptureDir:C:\EmptyFolder /Name:EmptyIndex /Compress:max
        New-WindowsImage -ImagePath $ApplyPath\Sources\install.wim -CapturePath $EmptyFolder -Name EmptyIndex -Description "Empty Index" -CompressionType Fast

        #Export the OS Image to the install.wim file
        Write-Host -ForegroundColor Gray "Expanding $ImagePath Index $OSImageIndex to $ApplyPath\Sources\install.wim"
        #dism.exe /Export-image /SourceImageFile:$ESDFile /SourceIndex:4 /DestinationImageFile:$ISOMediaFolder\sources\install.wim /Compress:Recovery
        ##Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex 5 -DestinationImagePath "$ApplyPath\Sources\install.wim" -CompressionType max -CheckIntegrity
        $Expand = Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex $OSImageIndex -DestinationImagePath "$ApplyPath\Sources\install.wim" -CheckIntegrity -CompressionType Fast
        $null = $Expand

        # Delete the first empty index in install.wim
        #dism.exe /Delete-Image /ImageFile:$ISOMediaFolder\sources\install.wim /Index:1
        Remove-WindowsImage -ImagePath $ApplyPath\Sources\install.wim -Index 1
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
    Write-Host -ForegroundColor DarkGray "========================================================================="
    if ($CreateISO){
        $PathToOscdimg = (Get-AdkPaths).oscdimgexe
        if (!(Test-Path -Path $PathToOscdimg)){
            Write-Host -ForegroundColor Red "oscdimg.exe not found, unable to create ISO File"
            throw "oscdimg.exe not found, unable to create ISO File"
        }
        else {
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating ISO File"
            $BootData='2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$ApplyPath\boot\etfsboot.com","$ApplyPath\efi\Microsoft\boot\efisys.bin"

            $ISOFile = "`"$ScratchLocation\$($ESD.Version) $($ESD.ReleaseId) $($ESD.Architecture).iso`""
            $ISOFilePath = "$ScratchLocation\$($ESD.Version) $($ESD.ReleaseId) $($ESD.Architecture).iso"
            if (Test-Path -Path $ISOFilePath){Remove-Item -Path $ISOFilePath -Force}
            $ISOMedia = "`"$ApplyPath`""
            $Proc = Start-Process -FilePath $PathToOscdimg -ArgumentList @("-bootdata:$BootData",'-u2','-udfver102',"$ISOMedia","$ISOFile") -PassThru -Wait -NoNewWindow
            if($Proc.ExitCode -ne 0)
            {
                Throw "Failed to generate ISO with exitcode: $($Proc.ExitCode)"
            }
            if (Test-Path -Path $ISOFilePath){
                Write-Host -ForegroundColor Green "ISO File Created: $ISOFile"
            }
            else {
                Write-Host -ForegroundColor Red "Failed to Create ISO File"
            }
        }
    }
}