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
        #'*','ThisPC','Dell','HP','Lenovo','Microsoft'
        [ValidateSet('*','ThisPC','Dell','HP','Lenovo','Microsoft')]
        [System.String[]]$DriverPack,

        #Updates the required OSDCloud PowerShell Modules
        [System.Management.Automation.SwitchParameter]$PSUpdate,

        #Optional. Allows the selection of an Operating System to add to the USB
        [System.Management.Automation.SwitchParameter]$OS,

        #Optional. Allows the selection of Driver Packs to download
        #If this parameter is not used, any language can be downloaded downloaded
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

        #Optional. Selects the proper OS License
        #If this parameter is not used, Operating Systems with the specified License can be downloaded
        #'Retail','Volume'
        [ValidateSet('Retail','Volume')]
        [System.String]$OSLicense,

        #Optional. Selects an Operating System to download
        #If this parameter is not used, any Operating Systems can be downloaded
        #'Windows 11 21H2','Windows 10 21H2','Windows 10 21H1','Windows 10 20H2','Windows 10 2004','Windows 10 1909','Windows 10 1903','Windows 10 1809'
        [ValidateSet(
            'Windows 11 21H2',
            'Windows 10 21H2','Windows 10 21H1','Windows 10 20H2','Windows 10 2004',
            'Windows 10 1909','Windows 10 1903',
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
    $UsbVolumes = Get-Volume.usb
    $WorkspacePath = Get-OSDCloudWorkspace
    $IsAdmin = Get-OSDGather -Property IsAdmin
    #=================================================
    #	Test USB Volumes
    #   Absolutely need to have USB volumes for this
    #   function to work
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    if ($UsbVolumes) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) USB volumes found"
        Write-Host -ForegroundColor DarkGray "========================================================================="
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find any USB volumes"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Plug in a USB drive first"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    #=================================================
    #	Test OSDCloud Workspace
    #   Not a big deal, but can't robocopy against it
    #=================================================
    if (! $WorkspacePath) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Workspace is not present on this system"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You will not be able to update the WinPE volume"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        $RobocopyWorkspace = $false
    }
    elseif (! (Test-Path $WorkspacePath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Workspace is not at the path $WorkspacePath"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You will not be able to update the WinPE volume"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        $RobocopyWorkspace = $false
    }
    elseif (! (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud WinPE does not exist at $WorkspacePath\Media\sources\boot.wim"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You will not be able to update the WinPE volume"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        $RobocopyWorkspace = $false
    }
    else {
        $RobocopyWorkspace = $true
    }
    #=================================================
    #	Set WinPE USB Volume Label
    #=================================================
    $WinpeVolumes = Get-Volume.usb | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT')}
    if ($WinpeVolumes) {
        if ($IsAdmin) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Setting OSDCloud USB WinPE volume labels to WinPE"
            foreach ($volume in $WinpeVolumes) {
                Set-Volume -DriveLetter $volume.DriveLetter -NewFileSystemLabel 'WinPE' -ErrorAction Ignore
            }
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to set OSDCloud USB WinPE volume label"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Run this function again elevated with Admin rights"
        }
    }
    #=================================================
    #	Update all WinPE volumes with Workspace
    #=================================================
    $WinpeVolumes = Get-Volume.usb | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT') -or ($_.FileSystemLabel -eq 'WinPE')}
    if ($WinpeVolumes -and $RobocopyWorkspace) {
        foreach ($volume in $WinpeVolumes) {
            if (Test-Path -Path "$($volume.DriveLetter):\") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) ROBOCOPY $WorkspacePath\Media $($volume.DriveLetter):\"
                robocopy "$WorkspacePath\Media" "$($volume.DriveLetter):\" *.* /e /ndl /njh /njs /np /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                Write-Host -ForegroundColor DarkGray "========================================================================="
            }
        }
    }
    #=================================================
    #   Update OSDCloud Workspace PowerShell
    #=================================================
    if ($RobocopyWorkspace) {
        if ($PSUpdate -or $DriverPack -or $OS -or $OSName -or $OSLicense -or $OSLanguage) {
            $PowerShellPath = "$WorkspacePath\PowerShell"
        
            if (! (Test-Path "$PowerShellPath")) {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloud Workspace PowerShell at $WorkspacePath\PowerShell"
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
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Updating OSDCloud Workspace PowerShell Modules and Scripts at $PowerShellPath"
        
            try {
                Save-Module OSD -Path "$PowerShellPath\Offline\Modules" -ErrorAction Stop
            }
            catch {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the OSD PowerShell Module at $PowerShellPath\Offline\Modules"
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
            }
        
            try {
                Save-Module WindowsAutoPilotIntune -Path "$PowerShellPath\Offline\Modules" -ErrorAction Stop
            }
            catch {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the WindowsAutoPilotIntune PowerShell Module at $PowerShellPath\Offline\Modules"
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
            }
        
            try {
                Save-Script -Name Get-WindowsAutopilotInfo -Path "$PowerShellPath\Offline\Scripts" -ErrorAction Stop
            }
            catch {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the Get-WindowsAutopilotInfo PowerShell Script at $PowerShellPath\Offline\Scripts"
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
            }
        }
    }
    #=================================================
    #   OSDCloudVolumes
    #=================================================
    $OSDCloudVolumes = Get-Volume.usb | Where-Object {$_.FileSystemLabel -eq 'OSDCloud'} | Where-Object {$_.SizeGB -ge 8} | Sort-Object DriveLetter -Descending
    if ($OSDCloudVolumes) {
        if ($IsAdmin) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Setting OSDCloud USB volume labels to OSDCloudUSB"
            foreach ($volume in $OSDCloudVolumes) {
                Set-Volume -DriveLetter $volume.DriveLetter -NewFileSystemLabel 'OSDCloudUSB' -ErrorAction Ignore
            }
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to set OSDCloud USB volume label"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Run this function again elevated with Admin rights"
        }
    }
    #=================================================
    #   IsOfflineReady
    #=================================================
    $OSDCloudVolumes = Get-Volume.usb | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Where-Object {$_.SizeGB -ge 8} | Sort-Object DriveLetter -Descending
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
            if ($IsOfflineReady -or $UpdateModules -or $PSUpdate -or $DriverPack -or $OS -or $OSName -or $OSLicense -or $OSLanguage) {
                if (Test-Path "$WorkspacePath\Config") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) ROBOCOPY $WorkspacePath\Config $($volume.DriveLetter):\OSDCloud\Config"
                    robocopy "$WorkspacePath\Config" "$($volume.DriveLetter):\OSDCloud\Config" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    Write-Host -ForegroundColor DarkGray "========================================================================="
                }
    
                if (Test-Path "$WorkspacePath\DriverPacks") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) ROBOCOPY $WorkspacePath\DriverPacks $($volume.DriveLetter):\OSDCloud\DriverPacks"
                    robocopy "$WorkspacePath\DriverPacks" "$($volume.DriveLetter):\OSDCloud\DriverPacks" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    Write-Host -ForegroundColor DarkGray "========================================================================="
                }
    
                if (Test-Path "$WorkspacePath\OS") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) ROBOCOPY $WorkspacePath\OS $($volume.DriveLetter):\OSDCloud\OS"
                    robocopy "$WorkspacePath\OS" "$($volume.DriveLetter):\OSDCloud\OS" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    Write-Host -ForegroundColor DarkGray "========================================================================="
                }
    
                if (Test-Path "$WorkspacePath\PowerShell") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) ROBOCOPY $WorkspacePath\PowerShell $($volume.DriveLetter):\OSDCloud\PowerShell"
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
        if ($DriverPack -or $OS -or $OSName -or $OSLicense -or $OSLanguage) {
            if (! ($OSDCloudVolumes)) {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud USB volume"
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) The USB volume must be labeled OSDCloud and be at least 8GB in size"
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Break
            }
        
            if (($OSDCloudVolumes | Measure-Object).Count -gt 1) {
                Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select a single OSDCloud USB volume in PowerShell GridView and press OK"
                $OSDCloudVolumes = $OSDCloudVolumes | Out-GridView -Title 'Select an OSDCloud USB volume and press OK' -OutputMode Single
            }
        
            if (! ($OSDCloudVolumes)) {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You must select one OSDCloud USB volume"
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Break
            }
        }
    }
    #=================================================
    #   OSDCloud OSName
    #=================================================
    if (($OSDCloudVolumes | Measure-Object).Count -eq 1) {
        if ($OS -or $OSName -or $OSLicense -or $OSLanguage) {
            $OSDownloadPath = "$($OSDCloudVolumes.DriveLetter):\OSDCloud\OS"
    
            $OSDCloudSavedOS = $null
            if (Test-Path $OSDownloadPath) {
                $OSDCloudSavedOS = Get-ChildItem -Path $OSDownloadPath *.esd -Recurse -File | Select-Object -ExpandProperty Name
            }
            $OperatingSystems = Get-WSUSXML -Catalog FeatureUpdate -UpdateArch 'x64' -Silent
        
            if ($OSName) {
                $OperatingSystems = $OperatingSystems | Where-Object {$_.Catalog -cmatch $OSName}
            }
            if ($OSLicense -eq 'Retail') {
                $OperatingSystems = $OperatingSystems | Where-Object {$_.Title -match 'consumer'}
            }
            if ($OSLicense -eq 'Volume') {
                $OperatingSystems = $OperatingSystems | Where-Object {$_.Title -match 'business'}
            }
            if ($OSLanguage){
                $OperatingSystems = $OperatingSystems | Where-Object {$_.Title -match $OSLanguage}
            }
        
            if ($OperatingSystems) {
                $OperatingSystems = $OperatingSystems | Sort-Object Title
    
                foreach ($Item in $OperatingSystems) {
                    $Item.Catalog = $Item.Catalog -replace 'FeatureUpdate ',''
                    if ($OSDCloudSavedOS) {
                        if ($Item.FileName -in $OSDCloudSavedOS) {
                            $Item.OSDStatus = 'Downloaded'
                        }
                    }
                }
    
                $OperatingSystems = $OperatingSystems | Select-Object -Property OSDVersion,OSDStatus,@{Name='OperatingSystem';Expression={($_.Catalog)}},Title,CreationDate,FileUri,FileName
        
                Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select one or more Operating Systems to download in PowerShell GridView"
                $OperatingSystems = $OperatingSystems | Sort-Object -Property @{Expression='OSDStatus';Descending=$true}, OperatingSystem -Descending | Out-GridView -Title 'Select one or more Operating Systems to download and press OK' -PassThru
        
                foreach ($OperatingSystem in $OperatingSystems) {
                    if ($OperatingSystem.OSDStatus -eq 'Downloaded') {
                        Get-ChildItem -Path $OSDownloadPath -Recurse -Include $OperatingSystem.FileName | Select-Object -ExpandProperty FullName
                    }
                    elseif (Test-WebConnection -Uri "$($OperatingSystem.FileUri)") {
                        $OSDownloadChildPath = Join-Path $OSDownloadPath (($OperatingSystem.Catalog) -replace 'FeatureUpdate ','')
                        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Downloading OSDCloud Operating System to $OSDownloadChildPath"
                        $SaveWebFile = Save-WebFile -SourceUrl $OperatingSystem.FileUri -DestinationDirectory "$OSDownloadChildPath" -DestinationName $OperatingSystem.FileName
                        
                        if (Test-Path $SaveWebFile.FullName) {
                            Get-Item $SaveWebFile.FullName
                        }
                        else {
                            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not download the Operating System"
                        }
                    }
                    else {
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not verify an Internet connection for the Operating System"
                    }
                }
            }
            else {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to determine a suitable Operating System"
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
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) DriverPacks will require up to 2GB each"
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
                Get-DellDriverPack -DownloadPath "$DriverPackDownloadPath\Dell"
            }
            if ($DriverPack -contains 'HP') {
                Get-HPDriverPack -DownloadPath "$DriverPackDownloadPath\HP"
            }
            if ($DriverPack -contains 'Lenovo') {
                Get-LenovoDriverPack -DownloadPath "$DriverPackDownloadPath\Lenovo"
            }
            if ($DriverPack -contains 'Microsoft') {
                Get-MicrosoftDriverPack -DownloadPath "$DriverPackDownloadPath\Microsoft"
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
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Updating OSD and WindowsAutoPilotIntune PowerShell Modules at $PowerShellPath"
        
                    try {
                        Save-Module OSD -Path "$PowerShellPath\Offline\Modules" -ErrorAction Stop
                    }
                    catch {
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the OSD PowerShell Module at $PowerShellPath\Offline\Modules"
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
                    }
        
                    try {
                        Save-Module WindowsAutoPilotIntune -Path "$PowerShellPath\Offline\Modules" -ErrorAction Stop
                    }
                    catch {
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the WindowsAutoPilotIntune PowerShell Module at $PowerShellPath\Offline\Modules"
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
                    }
        
                    try {
                        Save-Script -Name Get-WindowsAutopilotInfo -Path "$PowerShellPath\Offline\Scripts" -ErrorAction Stop
                    }
                    catch {
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the Get-WindowsAutopilotInfo PowerShell Script at $PowerShellPath\Offline\Scripts"
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
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
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OSName 'Windows 11 21H2'"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OSLanguage en-us"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OSLicense Volume"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OSName 'Windows 10 21H2' -OSLanguage en-us"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OSName 'Windows 10 20H2' -OSLanguage de-de -OSLicense Volume"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Yellow "Update Offline PowerShell Modules and Scripts:"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -PSUpdate"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Update-OSDCloudUSB is complete"
    #=================================================
}