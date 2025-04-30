function New-OSDCloudUSB {
    <#
    .SYNOPSIS
    Creates an OSDCloud USB Drive and copies the contents of the OSDCloud Workspace Media directory
    Clear, Initialize, Partition (WinPE and OSDCloudUSB), and Format a USB Disk
    Requires Admin Rights

    .DESCRIPTION
    Creates an OSDCloud USB Drive and copies the contents of the OSDCloud Workspace Media directory
    Clear, Initialize, Partition (WinPE and OSDCloud), and Format a USB Disk
    Requires Admin Rights

    .EXAMPLE
    New-OSDCloudUSB -WorkspacePath C:\OSDCloud

    .EXAMPLE
    New-OSDCloudUSB -fromIsoFile D:\osdcloud.iso

    .EXAMPLE
    New-OSDCloudUSB -fromIsoUrl https://contoso.blob.core.windows.net/public/osdcloud.iso

    .LINK
    https://www.osdcloud.com/setup/osdcloud-usb
    #>

    [CmdletBinding(DefaultParameterSetName='Workspace')]
    param (
        #Path to the OSDCloud Workspace containing the Media directory
        #This parameter is not necessary if Get-OSDCloudWorkspace can get a return
        [Parameter(ParameterSetName='Workspace',ValueFromPipelineByPropertyName)]
        [System.String]$WorkspacePath,
        
        #Path to an OSDCloud ISO
        #This file will be mounted and the contents will be copied to the OSDCloud USB
        [Parameter(ParameterSetName='fromIsoFile',Mandatory)]
        [System.IO.FileInfo]$fromIsoFile,
        
        #Path to an OSDCloud ISO saved on the internet
        #This file will be downloaded and mounted and the contents will be copied to the OSDCloud USB
        [Parameter(ParameterSetName='fromIsoUrl',Mandatory)]
        [System.String]$fromIsoUrl
    )
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-WindowsReleaseIdLt1703
    Block-WinPE
    #=================================================
    #	Initialize
    #=================================================
    $BootLabel = 'WinPE'
    $DataLabel = 'OSDCloudUSB'
    $ErrorActionPreference = 'Stop'
    $WinpeSourcePath = $null
    #=================================================
    #	Resolve Workspace
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'Workspace') {
        if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
            Set-OSDCloudWorkspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
        }
        $WorkspacePath = Get-OSDCloudWorkspace -ErrorAction Stop
    
        if (-NOT ($WorkspacePath)) {
            Write-Warning "[$(Get-Date -format G)] Unable to find an OSDCloud Workspace"
            Break
        }
    
        if (-NOT (Test-Path $WorkspacePath)) {
            Write-Warning "[$(Get-Date -format G)] Unable to find an OSDCloud Workspace at $WorkspacePath"
            Break
        }
    
        if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
            Write-Warning "[$(Get-Date -format G)] Unable to find an OSDCloud WinPE at $WorkspacePath\Media\sources\boot.wim"
            Break
        }
        
        $WinpeSourcePath = "$WorkspacePath\Media"
    }
    #=================================================
    #	Resolve fromIsoFile
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'fromIsoFile') {
        $fromIsoFileGetItem = Get-Item -Path $fromIsoFile -ErrorAction Ignore
        $fromIsoFileFullName = $fromIsoFileGetItem.FullName

        if ($fromIsoFileGetItem -and $fromIsoFileGetItem.Extension -eq '.iso') {
            #Do nothing
        }
        else {
            Write-Warning "[$(Get-Date -format G)] Unable to get the properties of $fromIsoFile"
            Write-Warning "[$(Get-Date -format G)] Something went very very wrong in this process"
            Break
        }
        #=================================================
        #   Mount fromIsoFile
        #=================================================
        $Volumes = (Get-Volume).Where({$_.DriveLetter}).DriveLetter

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] Mounting OSDCloudISO at $fromIsoFileFullName"
        $MountDiskImage = Mount-DiskImage -ImagePath $fromIsoFileFullName
        Start-Sleep -Seconds 3
        $MountDiskImageDriveLetter = (Compare-Object -ReferenceObject $Volumes -DifferenceObject (Get-Volume).Where({$_.DriveLetter}).DriveLetter).InputObject

        if ($MountDiskImageDriveLetter) {
            $WinpeSourcePath = "$($MountDiskImageDriveLetter):\"
        }
        else {
            Write-Warning "[$(Get-Date -format G)] Unable to mount $MountDiskImage"
            Write-Warning "[$(Get-Date -format G)] Something went very very wrong in this process"
            Break
        }
    }
    #=================================================
    #	Resolve CloudISO
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'fromIsoUrl') {
        $ResolveUrl = Invoke-WebRequest -Uri $fromIsoUrl -Method Head -MaximumRedirection 0 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($ResolveUrl.StatusCode -eq 302) {
            $fromIsoUrl = $ResolveUrl.Headers.Location
        }

        $fromIsoFileGetItem = Save-WebFile -SourceUrl $fromIsoUrl -DestinationDirectory (Join-Path $HOME 'Downloads')
        $fromIsoFileFullName = $fromIsoFileGetItem.FullName
    
        if ($fromIsoFileGetItem -and $fromIsoFileGetItem.Extension -eq '.iso') {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] OSDCloudISO downloaded to $fromIsoFileFullName"
        }
        else {
            Write-Warning "[$(Get-Date -format G)] Unable to download OSDCloudISO"
            Write-Warning "[$(Get-Date -format G)] Something went very very wrong in this process"
            Break
        }
        #=================================================
        #   Mount OSDCloudISO
        #=================================================
        $Volumes = (Get-Volume).Where({$_.DriveLetter}).DriveLetter

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] Mounting OSDCloudISO"
        $MountDiskImage = Mount-DiskImage -ImagePath $fromIsoFileFullName
        Start-Sleep -Seconds 3
        $MountDiskImageDriveLetter = (Compare-Object -ReferenceObject $Volumes -DifferenceObject (Get-Volume).Where({$_.DriveLetter}).DriveLetter).InputObject

        if ($MountDiskImageDriveLetter) {
            $WinpeSourcePath = "$($MountDiskImageDriveLetter):\"
        }
        else {
            Write-Warning "[$(Get-Date -format G)] Unable to mount $MountDiskImage"
            Write-Warning "[$(Get-Date -format G)] Something went very very wrong in this process"
            Break
        }
    }
    #=================================================
    #	Test WinpeSourcePath
    #=================================================
    if (-NOT ($WinpeSourcePath)) {
        Write-Warning "[$(Get-Date -format G)] Unable to find an OSDCloud Media"
        Break
    }

    if (-NOT (Test-Path $WinpeSourcePath)) {
        Write-Warning "[$(Get-Date -format G)] Unable to find an OSDCloud Media at $WinpeSourcePath"
        Break
    }

    if (-NOT (Test-Path "$WinpeSourcePath\sources\boot.wim")) {
        Write-Warning "[$(Get-Date -format G)] Unable to find an OSDCloud WinPE at $WinpeSourcePath\sources\boot.wim"
        Break
    }
    #=================================================
    #	New-BootableUSBDrive
    #=================================================
    $BootableUSBDrive = New-BootableUSBDrive -BootLabel $BootLabel -DataLabel $DataLabel
    $BootableUSBDrive = $BootableUSBDrive | Select-Object -First 1
    #=================================================
    #	Test USB Volumes
    #=================================================
    $WinPEPartition = Get-USBPartition | Where-Object {($_.DiskNumber -eq $BootableUSBDrive.DiskNumber) -and ($_.PartitionNumber -eq 2)}
    if (-NOT ($WinPEPartition)) {
        Write-Warning "[$(Get-Date -format G)] Unable to create OSDCloud WinPE Partition"
        Write-Warning "[$(Get-Date -format G)] Something went very very wrong in this process"
        Break
    }
    $OSDCloudPartition = Get-USBPartition | Where-Object {($_.DiskNumber -eq $BootableUSBDrive.DiskNumber) -and ($_.PartitionNumber -eq 1)}
    if (-NOT ($OSDCloudPartition)) {
        Write-Warning "[$(Get-Date -format G)] Unable to create OSDCloud Data Partition"
        Write-Warning "[$(Get-Date -format G)] Something went very very wrong in this process"
        Break
    }
    #=================================================
    #	WinpeDestinationPath
    #=================================================
    $WinpeDestinationPath = "$($WinPEPartition.DriveLetter):\"
    if (-NOT ($WinpeDestinationPath)) {
        Write-Warning "[$(Get-Date -format G)] Unable to find Destination Path at $WinpeDestinationPath"
        Break
    }
    #=================================================
    #	Update WinPE Volume
    #=================================================
    if ((Test-Path -Path "$WinpeSourcePath") -and (Test-Path -Path "$WinpeDestinationPath")) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] Copying $WinpeSourcePath to OSDCloud WinPE partition at $WinpeDestinationPath"
        robocopy "$WinpeSourcePath" "$WinpeDestinationPath" *.* /e /ndl /njh /njs /np /r:0 /w:0 /b /zb
    }
    #=================================================
    #	Remove Read-Only Attribute
    #=================================================
    Get-ChildItem -Path $WinpeDestinationPath -File -Recurse -Force | foreach {
        Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $false -Force -ErrorAction Ignore
    }
    #=================================================
    #   Dismount OSDCloudISO
    #=================================================
    if ($MountDiskImage) {
        Start-Sleep -Seconds 3
        Write-Verbose "[$(Get-Date -format G)] Dismounting $($MountDiskImage.ImagePath)"
        $null = Dismount-DiskImage -ImagePath $MountDiskImage.ImagePath
    }
    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor Cyan "[$(Get-Date -format G)] New-OSDCloudUSB is complete"
    #=================================================
}
function New-OSDCloudUSBSetupCompleteTemplate {
    $OSDCloudUSB = Get-Volume.usb | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Select-Object -First 1
    $SetupCompletePath = "$($OSDCloudUSB.DriveLetter):\OSDCloud\Config\Scripts\SetupComplete"
    $ScriptsPath = $SetupCompletePath

    if (!(Test-Path -Path $ScriptsPath)){New-Item -Path $ScriptsPath -ItemType Directory -Force} 

    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})


    Write-Output "Creating $($RunScript.Script) Files"

    $BatFilePath = "$($RunScript.Path)\$($RunScript.batFile)"
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"
            
    #Create Batch File to Call PowerShell File
    if (Test-Path -Path $PSFilePath){
        copy-item $PSFilePath -Destination "$ScriptsPath\SetupComplete.ps1.bak"
    }        
    New-Item -Path $BatFilePath -ItemType File -Force
    $CustomActionContent = New-Object system.text.stringbuilder
    [void]$CustomActionContent.Append('%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File C:\OSDCloud\Scripts\SetupComplete\SetupComplete.ps1')
    Add-Content -Path $BatFilePath -Value $CustomActionContent.ToString()

    #Create PowerShell File to do actions

    New-Item -Path $PSFilePath -ItemType File -Force
    Add-Content -path $PSFilePath 'Write-Output "========================================================="'
    Add-Content -path $PSFilePath 'Write-Output "Calling Custom Setup Complete File: $($PSCommandPath)"'
    Add-Content -path $PSFilePath 'Write-Output ""'
    Add-Content -path $PSFilePath 'Write-Output "CONFIRMED THIS RAN FROM FILE COPIED VIA FLASH DRIVE"'
    Add-Content -path $PSFilePath 'Write-Output ""'
    Add-Content -path $PSFilePath 'Write-Output "Completed Custom Setup Complete File: $($PSCommandPath)"'
    Add-Content -path $PSFilePath 'Write-Output "========================================================="'
}
function Update-OSDCloudUSB {
    <#
    .SYNOPSIS
    Updates an OSDCloud USB by downloading OS and Driver Packs from the internet

    .DESCRIPTION
    Updates an OSDCloud USB by downloading OS and Driver Packs from the internet

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param (
        #Optional. Select one or more of the following Driver Packs to download
        [ValidateSet('*','ThisPC','Dell','HP','Lenovo','Microsoft')]
        [System.String[]]$DriverPack,

        #Updates the required OSDCloud PowerShell Modules
        [System.Management.Automation.SwitchParameter]$PSUpdate,

        #Optional. Allows the selection of an Operating System to add to the USB
        [System.Management.Automation.SwitchParameter]$OS,

        #Optional. Allows the selection of Driver Packs to download.  If this parameter is not used, any language can be downloaded downloaded
        [ValidateSet (
            'ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','en-us','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw'
        )]
        [System.String]$OSLanguage,

        #Optional. Selects the proper OS License. If this parameter is not used, Operating Systems with the specified License can be downloaded
        [Alias('Activation','License','OSLicense')]
        [ValidateSet('Retail','Volume')]
        [System.String]$OSActivation,

        #Optional. Selects an Operating System to download
        #If this parameter is not used, any Operating Systems can be downloaded
        #'Windows 11 22H2','Windows 11 21H2','Windows 10 22H2','Windows 10 21H2','Windows 10 21H1','Windows 10 20H2','Windows 10 2004','Windows 10 1909','Windows 10 1903','Windows 10 1809'
        [ValidateSet(
            'Windows 11 24H2','Windows 11 23H2','Windows 11 22H2','Windows 11 21H2',
            'Windows 10 22H2','Windows 10 21H2','Windows 10 21H1','Windows 10 20H2','Windows 10 2004',
            'Windows 10 1909H','Windows 10 1903',
            'Windows 10 1809'
        )]
        [System.String]$OSName
    )
    #=================================================
    #	Block
    #=================================================
    Block-WinPE
    Block-PowerShellVersionLt5
    #=================================================
    #	Initialize
    #=================================================
    $UsbVolumes = Get-USBVolume
    $WorkspacePath = Get-OSDCloudWorkspace
    $IsAdmin = Get-OSDGather -Property IsAdmin
    #=================================================
    #	Test USB Volumes
    #   Absolutely need to have USB volumes for this
    #   function to work
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    if ($UsbVolumes) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] USB volumes found"
        Write-Host -ForegroundColor DarkGray "========================================================================="
    }
    else {
        Write-Warning "[$(Get-Date -format G)] Unable to find any USB volumes"
        Write-Warning "[$(Get-Date -format G)] Plug in a USB drive first"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    #=================================================
    #	Test OSDCloud Workspace
    #   Not a big deal, but can't robocopy against it
    #=================================================
    if (! $WorkspacePath) {
        Write-Warning "[$(Get-Date -format G)] OSDCloud Workspace is not present on this system"
        Write-Warning "[$(Get-Date -format G)] You will not be able to update the WinPE volume"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        $RobocopyWorkspace = $false
    }
    elseif (! (Test-Path $WorkspacePath)) {
        Write-Warning "[$(Get-Date -format G)] OSDCloud Workspace is not at the path $WorkspacePath"
        Write-Warning "[$(Get-Date -format G)] You will not be able to update the WinPE volume"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        $RobocopyWorkspace = $false
    }
    elseif (! (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "[$(Get-Date -format G)] OSDCloud WinPE does not exist at $WorkspacePath\Media\sources\boot.wim"
        Write-Warning "[$(Get-Date -format G)] You will not be able to update the WinPE volume"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        $RobocopyWorkspace = $false
    }
    else {
        $RobocopyWorkspace = $true
    }
    #=================================================
    #	Set WinPE USB Volume Label
    #=================================================
    $WinpeVolumes = Get-USBVolume | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT')}
    if ($WinpeVolumes) {
        if ($IsAdmin) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] Setting OSDCloud USB WinPE volume labels to WinPE"
            foreach ($volume in $WinpeVolumes) {
                Set-Volume -DriveLetter $volume.DriveLetter -NewFileSystemLabel 'WinPE' -ErrorAction Ignore
            }
        }
        else {
            Write-Warning "[$(Get-Date -format G)] Unable to set OSDCloud USB WinPE volume label"
            Write-Warning "[$(Get-Date -format G)] Run this function again elevated with Admin rights"
        }
    }
    #=================================================
    #	Update all WinPE volumes with Workspace
    #=================================================
    $WinpeVolumes = Get-USBVolume | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT') -or ($_.FileSystemLabel -eq 'WinPE')}
    if ($WinpeVolumes -and $RobocopyWorkspace) {
        foreach ($volume in $WinpeVolumes) {
            if (Test-Path -Path "$($volume.DriveLetter):\") {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] ROBOCOPY $WorkspacePath\Media $($volume.DriveLetter):\"
                robocopy "$WorkspacePath\Media" "$($volume.DriveLetter):\" *.* /e /ndl /njh /njs /np /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                Write-Host -ForegroundColor DarkGray "========================================================================="
            }
        }
    }
    #=================================================
    #   Update OSDCloud Workspace PowerShell
    #=================================================
    if ($RobocopyWorkspace) {
        if ($PSUpdate -or $DriverPack -or $OS -or $OSName -or $OSActivation -or $OSLanguage) {
            $PowerShellPath = "$WorkspacePath\PowerShell"
        
            if (! (Test-Path "$PowerShellPath")) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] Creating OSDCloud Workspace PowerShell at $WorkspacePath\PowerShell"
                $null = New-Item -Path "$PowerShellPath" -ItemType Directory -Force -ErrorAction Ignore
                $UpdateModules = $true
            }
            if (! (Test-Path "$PowerShellPath\Offline\Modules")) {
                $null = New-Item -Path "$PowerShellPath\Offline\Modules" -ItemType Directory -Force -ErrorAction Ignore
                $UpdateModules = $true
            }
            if (! (Test-Path "$PowerShellPath\Offline\Scripts")) {
                $null = New-Item -Path "$PowerShellPath\Offline\Scripts" -ItemType Directory -Force -ErrorAction Ignore
                $UpdateModules = $true
            }
            if (! (Test-Path "$PowerShellPath\Required\Modules")) {
                $null = New-Item -Path "$PowerShellPath\Required\Modules" -ItemType Directory -Force -ErrorAction Ignore
            }
            if (! (Test-Path "$PowerShellPath\Required\Scripts")) {
                $null = New-Item -Path "$PowerShellPath\Required\Scripts" -ItemType Directory -Force -ErrorAction Ignore
            }
        }
    }
    #=================================================
    #   Update OSDCloud Workspace PowerShell
    #=================================================
    if ($RobocopyWorkspace) {
        if ($UpdateModules -or $PSUpdate) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] Updating OSDCloud Workspace PowerShell Modules and Scripts at $PowerShellPath"

            try {
                Save-Module OSD -Path "$PowerShellPath\Offline\Modules" -ErrorAction Stop
            }
            catch {
                Write-Warning "[$(Get-Date -format G)] There were some issues updating the OSD PowerShell Module at $PowerShellPath\Offline\Modules"
                Write-Warning "[$(Get-Date -format G)] Make sure you have an Internet connection and can access powershellgallery.com"
            }
        
            try {
                Save-Module WindowsAutoPilotIntune -Path "$PowerShellPath\Offline\Modules" -ErrorAction Stop
            }
            catch {
                Write-Warning "[$(Get-Date -format G)] There were some issues updating the WindowsAutoPilotIntune PowerShell Module at $PowerShellPath\Offline\Modules"
                Write-Warning "[$(Get-Date -format G)] Make sure you have an Internet connection and can access powershellgallery.com"
            }
        
            try {
                Save-Script -Name Get-WindowsAutopilotInfo -Path "$PowerShellPath\Offline\Scripts" -ErrorAction Stop
            }
            catch {
                Write-Warning "[$(Get-Date -format G)] There were some issues updating the Get-WindowsAutopilotInfo PowerShell Script at $PowerShellPath\Offline\Scripts"
                Write-Warning "[$(Get-Date -format G)] Make sure you have an Internet connection and can access powershellgallery.com"
            }
        }
    }
    #=================================================
    #   OSDCloudVolumes
    #=================================================
    $OSDCloudVolumes = Get-USBVolume | Where-Object {$_.FileSystemLabel -eq 'OSDCloud'} | Where-Object {$_.SizeGB -ge 8} | Sort-Object DriveLetter -Descending
    if ($OSDCloudVolumes) {
        if ($IsAdmin) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] Setting OSDCloud USB volume labels to OSDCloudUSB"
            foreach ($volume in $OSDCloudVolumes) {
                Set-Volume -DriveLetter $volume.DriveLetter -NewFileSystemLabel 'OSDCloudUSB' -ErrorAction Ignore
            }
        }
        else {
            Write-Warning "[$(Get-Date -format G)] Unable to set OSDCloud USB volume label"
            Write-Warning "[$(Get-Date -format G)] Run this function again elevated with Admin rights"
        }
    }
    #=================================================
    #   IsOfflineReady
    #=================================================
    $OSDCloudVolumes = Get-USBVolume | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Where-Object {$_.SizeGB -ge 8} | Sort-Object DriveLetter -Descending
    $IsOfflineReady = $false
    if ($RobocopyWorkspace -and $OSDCloudVolumes) {
        foreach ($volume in $OSDCloudVolumes) {
            if (Test-Path "$($volume.DriveLetter):\OSDCloud") {
                $IsOfflineReady = $true
            }
        }
    }
    #=================================================
    #   Update OSDCloud Offline
    #=================================================
    if ($RobocopyWorkspace -and $OSDCloudVolumes) {
        foreach ($volume in $OSDCloudVolumes) {
            if ($IsOfflineReady -or $UpdateModules -or $PSUpdate -or $DriverPack -or $OS -or $OSName -or $OSActivation -or $OSLanguage) {
                if (Test-Path "$WorkspacePath\Config") {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] ROBOCOPY $WorkspacePath\Config $($volume.DriveLetter):\OSDCloud\Config"
                    robocopy "$WorkspacePath\Config" "$($volume.DriveLetter):\OSDCloud\Config" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    Write-Host -ForegroundColor DarkGray "========================================================================="
                }
    
                if (Test-Path "$WorkspacePath\DriverPacks") {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] ROBOCOPY $WorkspacePath\DriverPacks $($volume.DriveLetter):\OSDCloud\DriverPacks"
                    robocopy "$WorkspacePath\DriverPacks" "$($volume.DriveLetter):\OSDCloud\DriverPacks" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    Write-Host -ForegroundColor DarkGray "========================================================================="
                }
    
                if (Test-Path "$WorkspacePath\OS") {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] ROBOCOPY $WorkspacePath\OS $($volume.DriveLetter):\OSDCloud\OS"
                    robocopy "$WorkspacePath\OS" "$($volume.DriveLetter):\OSDCloud\OS" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    Write-Host -ForegroundColor DarkGray "========================================================================="
                }
    
                if (Test-Path "$WorkspacePath\PowerShell") {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] ROBOCOPY $WorkspacePath\PowerShell $($volume.DriveLetter):\OSDCloud\PowerShell"
                    robocopy "$WorkspacePath\PowerShell" "$($volume.DriveLetter):\OSDCloud\PowerShell" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    Write-Host -ForegroundColor DarkGray "========================================================================="
                }
            }
        }
    }
    #=================================================
    #   Single OSDCloudVolume
    #=================================================
    if ($OSDCloudVolumes) {
        if ($DriverPack -or $OS -or $OSName -or $OSActivation -or $OSLanguage) {
            if (! ($OSDCloudVolumes)) {
                Write-Warning "[$(Get-Date -format G)] Unable to find an OSDCloud USB volume"
                Write-Warning "[$(Get-Date -format G)] The USB volume must be labeled OSDCloud and be at least 8GB in size"
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Break
            }
        
            if (($OSDCloudVolumes | Measure-Object).Count -gt 1) {
                Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] Select a single OSDCloud USB volume in PowerShell GridView and press OK"
                $OSDCloudVolumes = $OSDCloudVolumes | Out-GridView -Title 'Select an OSDCloud USB volume and press OK' -OutputMode Single
            }
        
            if (! ($OSDCloudVolumes)) {
                Write-Warning "[$(Get-Date -format G)] You must select one OSDCloud USB volume"
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Break
            }
        }
    }
    #=================================================
    #   OSDCloud OSName
    #=================================================
    if (($OSDCloudVolumes | Measure-Object).Count -eq 1) {
        if ($OS -or $OSName -or $OSActivation -or $OSLanguage) {
            $OSDownloadPath = "$($OSDCloudVolumes.DriveLetter):\OSDCloud\OS"
    
            $OSDCloudSavedOS = $null
            if (Test-Path $OSDownloadPath) {
                $OSDCloudSavedOS = Get-ChildItem -Path $OSDownloadPath *.esd -Recurse -File | Select-Object -ExpandProperty Name
            }
            #$OperatingSystems = Get-WSUSXML -Catalog FeatureUpdate -UpdateArch 'x64' -Silent
            $OperatingSystems = Get-OSDCloudOperatingSystems
        
            if ($OSName) {
                #$OperatingSystems = $OperatingSystems | Where-Object {$_.Catalog -cmatch $OSName}
                $OperatingSystems = $OperatingSystems | Where-Object {$_.Name -cmatch $OSName}
            }
            if ($OSActivation -eq 'Retail') {
                #$OperatingSystems = $OperatingSystems | Where-Object {$_.Title -match 'consumer'}
                $OperatingSystems = $OperatingSystems | Where-Object {$_.Activation -match 'Retail'}
            }
            if ($OSActivation -eq 'Volume') {
                #$OperatingSystems = $OperatingSystems | Where-Object {$_.Title -match 'business'}
                $OperatingSystems = $OperatingSystems | Where-Object {$_.Activation -match 'Volume'}
            }
            if ($OSLanguage){
                #$OperatingSystems = $OperatingSystems | Where-Object {$_.Title -match $OSLanguage}
                $OperatingSystems = $OperatingSystems | Where-Object {$_.Language -match $OSLanguage}
            }
        
            if ($OperatingSystems) {
                $OperatingSystems = $OperatingSystems | Sort-Object Title
    
                foreach ($Item in $OperatingSystems) {
                    #$Item.Catalog = $Item.Catalog -replace 'FeatureUpdate ',''
                    if ($OSDCloudSavedOS) {
                        if ($Item.FileName -in $OSDCloudSavedOS) {
                            $Item.Status = 'Downloaded'
                        }
                    }
                }
    
                #$OperatingSystems = $OperatingSystems | Select-Object -Property OSDVersion,OSDStatus,@{Name='OperatingSystem';Expression={($_.Catalog)}},Title,CreationDate,FileUri,FileName
                $OperatingSystems = $OperatingSystems | Select-Object -Property Version,ReleaseID,Status,Name,ReleaseDate,Url,FileName

                Write-Host -ForegroundColor Yellow "[$(Get-Date -format G)] Select one or more Operating Systems to download in PowerShell GridView"
                #$OperatingSystems = $OperatingSystems | Sort-Object -Property @{Expression='OSDStatus';Descending=$true}, OperatingSystem -Descending | Out-GridView -Title 'Select one or more Operating Systems to download and press OK' -PassThru
                $OperatingSystems = $OperatingSystems | Sort-Object -Property @{Expression='Status';Descending=$true}, Name -Descending | Out-GridView -Title 'Select one or more Operating Systems to download and press OK' -PassThru

                
                foreach ($OperatingSystem in $OperatingSystems) {
                    if ($OperatingSystem.Status -eq 'Downloaded') {
                        Get-ChildItem -Path $OSDownloadPath -Recurse -Include $OperatingSystem.FileName | Select-Object -ExpandProperty FullName
                    }
                    elseif (Test-WebConnection -Uri "$($OperatingSystem.Url)") {
                        #$OSDownloadChildPath = Join-Path $OSDownloadPath (($OperatingSystem.Catalog) -replace 'FeatureUpdate ','')
                        #$OSDownloadChildPath = Join-Path $OSDownloadPath $($OperatingSystem.OperatingSystem)
                        $FolderName = "$($OperatingSystem.Version) $($OperatingSystem.ReleaseID)"
                        $OSDownloadChildPath = Join-Path $OSDownloadPath $FolderName
                        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] Downloading OSDCloud Operating System to $OSDownloadChildPath"
                        #$SaveWebFile = Save-WebFile -SourceUrl $OperatingSystem.FileUri -DestinationDirectory "$OSDownloadChildPath" -DestinationName $OperatingSystem.FileName
                        $SaveWebFile = Save-WebFile -SourceUrl $OperatingSystem.Url -DestinationDirectory "$OSDownloadChildPath" -DestinationName $OperatingSystem.FileName

                        
                        if (Test-Path $SaveWebFile.FullName) {
                            Get-Item $SaveWebFile.FullName
                        }
                        else {
                            Write-Warning "[$(Get-Date -format G)] Could not download the Operating System"
                        }
                    }
                    else {
                        Write-Warning "[$(Get-Date -format G)] Could not verify an Internet connection for the Operating System"
                    }
                }
            }
            else {
                Write-Warning "[$(Get-Date -format G)] Unable to determine a suitable Operating System"
            }
            Write-Host -ForegroundColor DarkGray "========================================================================="
        }
        else {
        }
    }
    #=================================================
    #   OSDCloud DriverPack
    #=================================================
    if (($OSDCloudVolumes | Measure-Object).Count -eq 1) {
        if ($DriverPack) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] DriverPacks will require up to 2GB each"
            $DriverPackDownloadPath = "$($OSDCloudVolumes.DriveLetter):\OSDCloud\DriverPacks"
    
            $OSDCloudSavedDriverPacks = $null
            if (Test-Path $DriverPackDownloadPath) {
                $OSDCloudSavedDriverPacks = Get-ChildItem -Path $DriverPackDownloadPath *.* -Recurse -File | Select-Object -ExpandProperty Name
            }
    
            if ($DriverPack -contains '*') {
                $DriverPack = 'ThisPC','Dell','HP','Lenovo','Microsoft'
            }
    
            if ($DriverPack -contains 'ThisPC') {
                $Manufacturer = Get-MyComputerManufacturer -Brief
                Save-MyDriverPack -DownloadPath "$DriverPackDownloadPath\$Manufacturer"
            }
        
            if ($DriverPack -contains 'Dell') {
                Get-DellDriverPackCatalog -DownloadPath "$DriverPackDownloadPath\Dell"
            }
            if ($DriverPack -contains 'HP') {
                Get-HPDriverPackCatalog -DownloadPath "$DriverPackDownloadPath\HP"
            }
            if ($DriverPack -contains 'Lenovo') {
                Get-LenovoDriverPackCatalog -DownloadPath "$DriverPackDownloadPath\Lenovo"
            }
            if ($DriverPack -contains 'Microsoft') {
                Get-SurfaceDriverPackCatalog -DownloadPath "$DriverPackDownloadPath\Microsoft"
            }
            Write-Host -ForegroundColor DarkGray "========================================================================="
        }
        else {
        }
    }
    #=================================================
    #   PowerShell
    #=================================================
    if (($OSDCloudVolumes | Measure-Object).Count -eq 1) {
        if (Test-Path "$($OSDCloudVolumes.DriveLetter):\OSDCloud") {
            $PowerShellPath = "$($OSDCloudVolumes.DriveLetter):\OSDCloud\PowerShell"
            if (-not (Test-Path "$PowerShellPath")) {
                $null = New-Item -Path "$PowerShellPath" -ItemType Directory -Force -ErrorAction Ignore
                $UpdateModules = $true
            }
            if (-not (Test-Path "$PowerShellPath\Offline\Modules")) {
                $null = New-Item -Path "$PowerShellPath\Offline\Modules" -ItemType Directory -Force -ErrorAction Ignore
                $UpdateModules = $true
            }
            if (-not (Test-Path "$PowerShellPath\Offline\Scripts")) {
                $null = New-Item -Path "$PowerShellPath\Offline\Scripts" -ItemType Directory -Force -ErrorAction Ignore
                $UpdateModules = $true
            }
            if (-not (Test-Path "$PowerShellPath\Required\Modules")) {
                $null = New-Item -Path "$PowerShellPath\Required\Modules" -ItemType Directory -Force -ErrorAction Ignore
            }
            if (-not (Test-Path "$PowerShellPath\Required\Scripts")) {
                $null = New-Item -Path "$PowerShellPath\Required\Scripts" -ItemType Directory -Force -ErrorAction Ignore
            }
        }
    }
    #=================================================
    #   Online
    #=================================================
    if ($OSDCloudVolumes -and $IsOfflineReady) {
        if ($UpdateModules -or $PSUpdate) {
            if (($OSDCloudVolumes | Measure-Object).Count -eq 1) {
                if (Test-Path "$($OSDCloudVolumes.DriveLetter):\OSDCloud") {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] Updating OSD and WindowsAutoPilotIntune PowerShell Modules at $PowerShellPath"

                    try {
                        Save-Module OSD -Path "$PowerShellPath\Offline\Modules" -ErrorAction Stop
                    }
                    catch {
                        Write-Warning "[$(Get-Date -format G)] There were some issues updating the OSD PowerShell Module at $PowerShellPath\Offline\Modules"
                        Write-Warning "[$(Get-Date -format G)] Make sure you have an Internet connection and can access powershellgallery.com"
                    }
        
                    try {
                        Save-Module WindowsAutoPilotIntune -Path "$PowerShellPath\Offline\Modules" -ErrorAction Stop
                    }
                    catch {
                        Write-Warning "[$(Get-Date -format G)] There were some issues updating the WindowsAutoPilotIntune PowerShell Module at $PowerShellPath\Offline\Modules"
                        Write-Warning "[$(Get-Date -format G)] Make sure you have an Internet connection and can access powershellgallery.com"
                    }
        
                    try {
                        Save-Script -Name Get-WindowsAutopilotInfo -Path "$PowerShellPath\Offline\Scripts" -ErrorAction Stop
                    }
                    catch {
                        Write-Warning "[$(Get-Date -format G)] There were some issues updating the Get-WindowsAutopilotInfo PowerShell Script at $PowerShellPath\Offline\Scripts"
                        Write-Warning "[$(Get-Date -format G)] Make sure you have an Internet connection and can access powershellgallery.com"
                    }
                    Write-Host -ForegroundColor DarkGray "========================================================================="
                }
            }
        }
        else {
        }
    }
    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor Yellow "Download a Driver Pack to OSDCloud USB:"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -DriverPack *"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -DriverPack ThisPC"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -DriverPack Dell"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -DriverPack Dell,HP,Lenovo,Microsoft"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Yellow "Download an Operating System to OSDCloud USB:"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OS"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OSName 'Windows 11 24H2'"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OSLanguage en-us"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OSActivation Volume"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OSName 'Windows 11 24H2' -OSLanguage en-us"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OSName 'Windows 11 24H2' -OSLanguage de-de -OSActivation Volume"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Yellow "Update Offline PowerShell Modules and Scripts:"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -PSUpdate"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "[$(Get-Date -format G)] Update-OSDCloudUSB is complete"
    #=================================================
}