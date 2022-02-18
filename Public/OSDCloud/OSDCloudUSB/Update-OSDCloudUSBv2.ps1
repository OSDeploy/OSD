<#
.SYNOPSIS
Creates an OSDCloud USB Drive and updates WinPE
Clear, Initialize, Partition (WinPE and OSDCloud), and Format a USB Disk
Requires Admin Rights

.Description
Creates an OSDCloud USB Drive and updates WinPE
Clear, Initialize, Partition (WinPE and OSDCloud), and Format a USB Disk
Requires Admin Rights

.PARAMETER WorkspacePath
Directory for the Workspace.  Contains the Media directory

.EXAMPLE
Update-OSDCloudUSB -WorkspacePath C:\OSDCloud

.LINK
https://osdcloud.osdeploy.com
#>
function Update-OSDCloudUSB {
    [CmdletBinding()]
    param (
        [ValidateSet('*','ThisPC','Dell','HP','Lenovo','Microsoft')]
        [System.String[]]$DriverPack,

        [ValidateSet(
            'Windows 11 21H2',
            'Windows 10 21H2',
            'Windows 10 21H1',
            'Windows 10 20H2',
            'Windows 10 2004',
            'Windows 10 1909',
            'Windows 10 1903',
            'Windows 10 1809'
            )]
        [System.String]$OS,

        [ValidateSet('Retail','Volume')]
        [System.String]$OSLicense,

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

        [switch]$Offline
    )
    #=================================================
    #	Block
    #=================================================
    Block-PowerShellVersionLt5
    Block-NoCurl
    Block-WinPE
    #=================================================
    #	Initialize
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    $IsAdmin = Get-OSDGather -Property IsAdmin
    $UsbVolumes = Get-Volume.usb
    $WorkspacePath = Get-OSDCloud.workspace
    #=================================================
    #	USB Volumes
    #   e9ae9fce-f699-4300-8276-3cdf8a9cf675
    #=================================================
    if ($UsbVolumes) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) USB volumes found"
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find any USB Volumes"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You may need to run New-OSDCloudUSB first"
        Get-Help New-OSDCloudUSB -Examples
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    #=================================================
    #	Set USB Volume Label
    #=================================================
    $WinpeVolumes = $UsbVolumes | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT')}

    if ($WinpeVolumes) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Setting OSDCloud USB WinPE volume labels to WinPE"
        if ($IsAdmin) {
            foreach ($WinpeVolume in $WinpeVolumes) {
                Set-Volume -DriveLetter $WinpeVolume.DriveLetter -NewFileSystemLabel 'WinPE' -ErrorAction Ignore
            }
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to set OSDCloud USB WinPE volume label"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Run this function again elevated with Admin rights"
        }
    }
    #=================================================
    #	Test OSDCloud Workspace
    #=================================================
    if (! $WorkspacePath) {
        $TestWorkspace = $false
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Workspace is not present on this system"
    }
    elseif (! (Test-Path $WorkspacePath)) {
        $TestWorkspace = $false
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Workspace is not at the path $WorkspacePath"
    }
    elseif (! (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        $TestWorkspace = $false
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud WinPE does not exist at $WorkspacePath\Media\sources\boot.wim"
    }
    else {
        $TestWorkspace = $true
    }
    #=================================================
    #   Update OSDCloud Workspace PowerShell
    #=================================================
    if ($TestWorkspace) {
        $PowerShellPath = "$WorkspacePath\PowerShell"

        if (-not (Test-Path "$PowerShellPath")) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloud Workspace PowerShell at $WorkspacePath\PowerShell"
            $null = New-Item -Path "$PowerShellPath" -ItemType Directory -Force -ErrorAction Ignore
        }
        if (-not (Test-Path "$PowerShellPath\Offline\Modules")) {
            $null = New-Item -Path "$PowerShellPath\Offline\Modules" -ItemType Directory -Force -ErrorAction Ignore
        }
        if (-not (Test-Path "$PowerShellPath\Offline\Scripts")) {
            $null = New-Item -Path "$PowerShellPath\Offline\Scripts" -ItemType Directory -Force -ErrorAction Ignore
        }
        if (-not (Test-Path "$PowerShellPath\Required\Modules")) {
            $null = New-Item -Path "$PowerShellPath\Required\Modules" -ItemType Directory -Force -ErrorAction Ignore
        }
        if (-not (Test-Path "$PowerShellPath\Required\Scripts")) {
            $null = New-Item -Path "$PowerShellPath\Required\Scripts" -ItemType Directory -Force -ErrorAction Ignore
        }

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
    #=================================================
    #	Update all WinPE volumes with Workspace
    #=================================================
    if ($TestWorkspace) {
        $WinpeVolumes = $UsbVolumes | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT') -or ($_.FileSystemLabel -eq 'WinPE')}
    
        foreach ($WinpeVolume in $WinpeVolumes) {
            if (Test-Path -Path "$($WinPEVolume.DriveLetter):\") {
                if ($IsAdmin) {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Admin Copying $WorkspacePath\Media to OSDCloud WinPE volume at $($WinPEVolume.DriveLetter):\"
                    robocopy "$WorkspacePath\Media" "$($WinPEVolume.DriveLetter):\" *.* /e /ndl /njh /njs /np /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /zb
                }
                else {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $WorkspacePath\Media to OSDCloud WinPE volume at $($WinPEVolume.DriveLetter):\"
                    robocopy "$WorkspacePath\Media" "$($WinPEVolume.DriveLetter):\" *.* /e /ndl /njh /njs /np /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }
        }
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Cannot update OSDCloud WinPE without an OSDCloud Workspace"
    }
    #=================================================
    #   Update all OSDCloud volumes with Workspace
    #=================================================
    $OSDCloudVolumes = Get-Volume.usb | Where-Object {$_.FileSystemLabel -eq 'OSDCloud'}

    if ($OSDCloudVolumes -and $TestWorkspace) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Offline USB volumes found"
        foreach ($OSDCloudVolume in $OSDCloudVolumes) {
            if (Test-Path "$WorkspacePath\Config") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $WorkspacePath\Config to $($OSDCloudVolume.DriveLetter):\OSDCloud\Config"
                if ($IsAdmin) {
                    robocopy "$WorkspacePath\Config" "$($OSDCloudVolume.DriveLetter):\OSDCloud\Config" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /zb
                }
                else {
                    robocopy "$WorkspacePath\Config" "$($OSDCloudVolume.DriveLetter):\OSDCloud\Config" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }

            if (Test-Path "$WorkspacePath\DriverPacks") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $WorkspacePath\DriverPacks to $($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks"
                if ($IsAdmin) {
                    robocopy "$WorkspacePath\DriverPacks" "$($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /zb
                }
                else {
                    robocopy "$WorkspacePath\DriverPacks" "$($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }

            if (Test-Path "$WorkspacePath\OS") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $WorkspacePath\OS $($OSDCloudVolume.DriveLetter):\OSDCloud\OS"
                if ($IsAdmin) {
                    robocopy "$WorkspacePath\OS" "$($OSDCloudVolume.DriveLetter):\OSDCloud\OS" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /zb
                }
                else {
                    robocopy "$WorkspacePath\OS" "$($OSDCloudVolume.DriveLetter):\OSDCloud\OS" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }

            if (Test-Path "$WorkspacePath\PowerShell") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud Workspace $WorkspacePath\PowerShell to $($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell"
                if ($IsAdmin) {
                    robocopy "$WorkspacePath\PowerShell" "$($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information" /zb
                }
                else {
                    robocopy "$WorkspacePath\PowerShell" "$($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }
        }
    }

    #=================================================
    #   OSDCloud Offline PowerShell Paths
    #=================================================
    if ($DriverPack -or $OS -or $OSLicense -or $OSLanguage) {
        if ($OSDCloudVolumes) {
            foreach ($OSDCloudVolume in $OSDCloudVolumes) {
                $PowerShellPath = "$($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell"

                if (-not (Test-Path "$PowerShellPath")) {
                    $null = New-Item -Path "$PowerShellPath" -ItemType Directory -Force -ErrorAction Ignore
                }
                if (-not (Test-Path "$PowerShellPath\Offline\Modules")) {
                    $null = New-Item -Path "$PowerShellPath\Offline\Modules" -ItemType Directory -Force -ErrorAction Ignore
                }
                if (-not (Test-Path "$PowerShellPath\Offline\Scripts")) {
                    $null = New-Item -Path "$PowerShellPath\Offline\Scripts" -ItemType Directory -Force -ErrorAction Ignore
                }
                if (-not (Test-Path "$PowerShellPath\Required\Modules")) {
                    $null = New-Item -Path "$PowerShellPath\Required\Modules" -ItemType Directory -Force -ErrorAction Ignore
                }
                if (-not (Test-Path "$PowerShellPath\Required\Scripts")) {
                    $null = New-Item -Path "$PowerShellPath\Required\Scripts" -ItemType Directory -Force -ErrorAction Ignore
                }

                if (! (Test-Path "$PowerShellPath\Offline\Modules\OSD")) {
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
        }
    }
    #=================================================
    #   Single OSDCloud Volume
    #=================================================
    if ($DriverPack -or $OS -or $OSLicense -or $OSLanguage) {
        if (($OSDCloudVolumes).Count -gt 1) {
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select a single OSDCloud USB volume in PowerShell GridView and press OK"
            $OSDCloudVolumes = $OSDCloudVolumes | Out-GridView -Title 'Select an OSDCloud USB volume and press OK' -PassThru -OutputMode Single
        }
    }
    #=================================================
    #   OSDCloud OS
    #=================================================
    if (($OSDCloudVolumes).Count -eq 1) {
        if ($OS -or $OSLicense -or $OSLanguage) {
            $OSDownloadPath = "$($OSDCloudVolumes.DriveLetter):\OSDCloud\OS"
    
            $OSDCloudSavedOS = $null
            if (Test-Path $OSDownloadPath) {
                $OSDCloudSavedOS = Get-ChildItem -Path $OSDownloadPath *.esd -Recurse -File | Select-Object -ExpandProperty Name
            }
            $OperatingSystems = Get-WSUSXML -Catalog FeatureUpdate -UpdateArch 'x64'
        
            if ($OS) {
                $OperatingSystems = $OperatingSystems | Where-Object {$_.Catalog -cmatch $OS}
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
        
                Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select one or more OSDCloud Operating Systems to download in PowerShell GridView"
                $OperatingSystems = $OperatingSystems | Sort-Object -Property OperatingSystem -Descending | Out-GridView -Title 'Select one or more OSDCloud Operating Systems to download and press OK' -PassThru
        
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
                            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not download the OSDCloud Operating System"
                        }
                    }
                    else {
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not verify an Internet connection for the OSDCloud Operating System"
                    }
                }
            }
            else {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to determine a suitable OSDCloud Operating System"
            }
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor DarkGray "To save an OSDCloud Offline Operating System:"
            Write-Host -ForegroundColor DarkGray "Update-OSDCloudOfflineUSB -OS 'Windows 11 21H2'"
            Write-Host -ForegroundColor DarkGray "Update-OSDCloudOfflineUSB -OS 'Windows 10 21H2' -OSLicense Retail"
            Write-Host -ForegroundColor DarkGray "Update-OSDCloudOfflineUSB -OS 'Windows 10 21H1' -OSLicense Volume -OSLanguage en-us"
        }
    }
    #=================================================
    #   OSDCloud DriverPack
    #=================================================
    if (($OSDCloudVolumes).Count -eq 1) {
        if ($DriverPack) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) DriverPacks will require up to 2GB each"
            $DriverPackDownloadPath = "$($OSDCloudVolumes.DriveLetter):\OSDCloud\DriverPacks"
    
            $OSDCloudSavedDriverPacks = $null
            if (Test-Path $DriverPackDownloadPath) {
                $OSDCloudSavedDriverPacks = Get-ChildItem -Path $DriverPackDownloadPath *.* -Recurse -File | Select-Object -ExpandProperty Name
            }
    
            if ($DriverPack -contains '*') {
                $DriverPack = 'Dell','HP','Lenovo','Microsoft'
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
        }
        else {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor DarkGray "To save an OSDCloud Offline Driver Pack:"
            Write-Host -ForegroundColor DarkGray "Update-OSDCloudOfflineUSB -DriverPack *"
            Write-Host -ForegroundColor DarkGray "Update-OSDCloudOfflineUSB -DriverPack ThisPC"
            Write-Host -ForegroundColor DarkGray "Update-OSDCloudOfflineUSB -DriverPack Dell"
            Write-Host -ForegroundColor DarkGray "Update-OSDCloudOfflineUSB -DriverPack Dell,HP,Lenovo,Microsoft"
            Write-Host -ForegroundColor DarkGray "========================================================================="
        }
    }
    #=================================================
    #   Complete
    #=================================================
    if ($PSBoundParameters.ContainsKey('Offline')) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Update-OSDCloudUSB (WinPE and Offline) is complete"
    }
    else {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Update-OSDCloudUSB (WinPE) is complete"
    }
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #=================================================
}