<#
.SYNOPSIS
Saves OSDCloud to an NTFS Partition on a USB Drive

.DESCRIPTION
Saves OSDCloud to an NTFS Partition on a USB Drive

.PARAMETER OSEdition
Edition of the Windows installation

.PARAMETER OSCulture
Culture of the Windows installation

.LINK
https://osdcloud.osdeploy.com/

.NOTES
21.3.13 Initial Release
#>
function Save-OSDCloud {
    [CmdletBinding()]
    param (
        [ValidateSet('2009','2004','1909','1903','1809')]
        [Alias('Build')]
        [string]$OSBuild = '2009',

        [ValidateSet('Education','Enterprise','Pro')]
        [Alias('Edition')]
        [string]$OSEdition = 'Enterprise',

        [ValidateSet (
            'ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','en-us','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw'
        )]
        [Alias('Culture')]
        [string]$OSCulture = 'en-us'
    )

    $Global:OSDCloudStartTime = Get-Date
    #===================================================================================================
    #	About Save
    #===================================================================================================
    if ($MyInvocation.MyCommand.Name -eq 'Save-OSDCloud') {
        $GetUSBVolume = Get-USBVolume | Where-Object {$_.FileSystem -eq 'NTFS'} | Where-Object {$_.SizeGB -ge 8} | Sort-Object DriveLetter -Descending

        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Save-OSDCloud will save all required content to an 8GB+ NTFS USB Volume"
        Write-Host -ForegroundColor White "Windows 10 will require about 4GB"
        Write-Host -ForegroundColor White "Hardware Drivers will require between 1-2GB for Dell Systems"

        if (-NOT ($GetUSBVolume)) {
            Write-Warning "Unfortunately, I don't see any USB Volumes that will work"
            Write-Warning "Save-OSDCloud has left the building"
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Break
        }

        $GetUSBVolume | Select-Object -Property DriveType, DriveLetter, FileSystemLabel, SizeGB, SizeRemainingMB | Format-Table
        Write-Warning "USB Free Space is not verified before downloading yet, so this is on you!"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor White "Starting in 5 " -NoNewline
        Start-Sleep -Seconds 1
        Write-Host -ForegroundColor White "4 " -NoNewline
        Start-Sleep -Seconds 1
        Write-Host -ForegroundColor White "3 " -NoNewline
        Start-Sleep -Seconds 1
        Write-Host -ForegroundColor White "2 " -NoNewline
        Start-Sleep -Seconds 1
        Write-Host -ForegroundColor White "1 "
        Start-Sleep -Seconds 1
    }
    #===================================================================================================
    #	Get-USBVolume
    #===================================================================================================
    if ($MyInvocation.MyCommand.Name -eq 'Save-OSDCloud') {
        if (Get-USBVolume) {
            $SelectUSBVolume = Select-USBVolume -MinimumSizeGB 8 -FileSystem 'NTFS'
            $OSDCloudOffline = "$($SelectUSBVolume.DriveLetter):\OSDCloud"
            Write-Host -ForegroundColor White "Downloading OSDCloud content to $OSDCloudOffline"
        } else {
            Write-Warning "Save-OSDCloud USB Requirements:"
            Write-Warning "8 GB Minimum"
            Write-Warning "NTFS File System"
            Break
        }
    }
    #===================================================================================================
    #   Screenshots
    #===================================================================================================
    if ($PSBoundParameters.ContainsKey('Screenshots')) {
        Start-ScreenPNGProcess -Directory "$env:TEMP\ScreenPNG"
    }
    #===================================================================================================
    #	Global Variables
    #===================================================================================================
    $Global:OSEdition = $OSEdition
    $Global:OSCulture = $OSCulture
    #===================================================================================================
    #	AutoPilot Profiles
    #===================================================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "AutoPilot Profiles"
    if ($MyInvocation.MyCommand.Name -eq 'Save-OSDCloud') {
        if (-NOT (Test-Path "$OSDCloudOffline\AutoPilot\Profiles")) {
            New-Item -Path "$OSDCloudOffline\AutoPilot\Profiles" -ItemType Directory -Force | Out-Null
        }
    }

    $GetOSDCloudAutoPilotProfiles = Get-OSDCloudAutoPilotProfiles

    if ($GetOSDCloudAutoPilotProfiles) {
        foreach ($Item in $GetOSDCloudAutoPilotProfiles) {
            Write-Host -ForegroundColor Yellow "$($Item.FullName)"
        }
    } else {
        Write-Warning "No AutoPilot Profiles were found in any PSDrive"
        Write-Warning "AutoPilot Profiles must be located in a <PSDrive>:\OSDCloud\AutoPilot\Profiles direcory"
    }
    #===================================================================================================
    #	PSGallery Modules
    #===================================================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "PowerShell Modules and Scripts"
    if (Test-WebConnection -Uri "https://www.powershellgallery.com") {
        if ($MyInvocation.MyCommand.Name -eq 'Save-OSDCloud') {
            if (-NOT (Test-Path "$OSDCloudOffline\PowerShell\Modules")) {
                New-Item -Path "$OSDCloudOffline\PowerShell\Modules" -ItemType Directory -Force | Out-Null
            }
            Write-Host -ForegroundColor DarkGray "Save-Module OSD"
            Save-Module -Name OSD -Path "$OSDCloudOffline\PowerShell\Modules"

            Write-Host -ForegroundColor DarkGray "Save-Module WindowsAutoPilotIntune"
            Save-Module -Name WindowsAutoPilotIntune -Path "$OSDCloudOffline\PowerShell\Modules"
            Write-Host -ForegroundColor DarkGray "Save-Module AzureAD"
            Write-Host -ForegroundColor DarkGray "Save-Module Microsoft.Graph.Intune"

            if (-NOT (Test-Path "$OSDCloudOffline\PowerShell\Scripts")) {
                New-Item -Path "$OSDCloudOffline\PowerShell\Scripts" -ItemType Directory -Force | Out-Null
            }
            Write-Host -ForegroundColor DarkGray "Save-Script Get-WindowsAutoPilotInfo"
            Save-Script -Name Get-WindowsAutoPilotInfo -Path "$OSDCloudOffline\PowerShell\Scripts"
        }
    }
    else {
        Write-Warning "Could not verify an Internet connection to the PowerShell Gallery"
        if ($MyInvocation.MyCommand.Name -eq 'Save-OSDCloud') {
            Write-Warning "OSDCloud will continue, but there may be issues"
        }
        
        if ($MyInvocation.MyCommand.Name -eq 'Start-OSDCloud') {
            Write-Warning "OSDCloud will continue, but there may be issues"
        }
    }
    #===================================================================================================
    #	Windows 10
    #===================================================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "Windows 10 x64"
    Write-Host -ForegroundColor White "OSBuild: $OSBuild"
    Write-Host -ForegroundColor White "OSCulture: $OSCulture"
    
    $GetFeatureUpdate = Get-FeatureUpdate -OSBuild $OSBuild -OSCulture $OSCulture

    if ($GetFeatureUpdate) {
        $GetFeatureUpdate = $GetFeatureUpdate | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash
    }
    else {
        Write-Warning "Unable to locate a Windows 10 Feature Update"
        Break
    }
    Write-Host -ForegroundColor White "CreationDate: $($GetFeatureUpdate.CreationDate)"
    Write-Host -ForegroundColor White "KBNumber: $($GetFeatureUpdate.KBNumber)"
    Write-Host -ForegroundColor White "Title: $($GetFeatureUpdate.Title)"
    Write-Host -ForegroundColor White "FileName: $($GetFeatureUpdate.FileName)"
    Write-Host -ForegroundColor White "SizeMB: $($GetFeatureUpdate.SizeMB)"
    Write-Host -ForegroundColor White "FileUri: $($GetFeatureUpdate.FileUri)"

    $GetOSDCloudOfflineFile = Get-OSDCloudOfflineFile -Name $GetFeatureUpdate.FileName | Select-Object -First 1

    if ($GetOSDCloudOfflineFile) {
        Write-Host -ForegroundColor Cyan "Offline: $($GetOSDCloudOfflineFile.FullName)"
    }
    elseif (Test-WebConnection -Uri $GetFeatureUpdate.FileUri) {
        if ($MyInvocation.MyCommand.Name -eq 'Save-OSDCloud') {
            Save-OSDDownload -SourceUrl $GetFeatureUpdate.FileUri -DownloadFolder "$OSDCloudOffline\OS" | Out-Null
            if (Test-Path $Global:OSDDownload.FullName) {
                Rename-Item -Path $Global:OSDDownload.FullName -NewName $GetFeatureUpdate.FileName -Force
            }
        }
    }
    else {
        Write-Warning "Could not verify an Internet connection for Windows 10 Feature Update"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
    #===================================================================================================
    #	Dell Driver Pack
    #===================================================================================================
    if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Dell Driver Pack"
        
        $GetMyDellDriverCab = Get-MyDellDriverCab
        if ($GetMyDellDriverCab) {
            Write-Host -ForegroundColor White "LastUpdate: $($GetMyDellDriverCab.LastUpdate)"
            Write-Host -ForegroundColor White "DriverName: $($GetMyDellDriverCab.DriverName)"
            Write-Host -ForegroundColor White "Generation: $($GetMyDellDriverCab.Generation)"
            Write-Host -ForegroundColor White "Model: $($GetMyDellDriverCab.Model)"
            Write-Host -ForegroundColor White "SystemSku: $($GetMyDellDriverCab.SystemSku)"
            Write-Host -ForegroundColor White "DriverVersion: $($GetMyDellDriverCab.DriverVersion)"
            Write-Host -ForegroundColor White "DriverReleaseId: $($GetMyDellDriverCab.DriverReleaseId)"
            Write-Host -ForegroundColor White "OsVersion: $($GetMyDellDriverCab.OsVersion)"
            Write-Host -ForegroundColor White "OsArch: $($GetMyDellDriverCab.OsArch)"
            Write-Host -ForegroundColor White "DownloadFile: $($GetMyDellDriverCab.DownloadFile)"
            Write-Host -ForegroundColor White "SizeMB: $($GetMyDellDriverCab.SizeMB)"
            Write-Host -ForegroundColor White "DriverUrl: $($GetMyDellDriverCab.DriverUrl)"
            Write-Host -ForegroundColor White "DriverInfo: $($GetMyDellDriverCab.DriverInfo)"

            $GetOSDCloudOfflineFile = Get-OSDCloudOfflineFile -Name $GetMyDellDriverCab.DownloadFile | Select-Object -First 1
        
            if ($GetOSDCloudOfflineFile) {
                Write-Host -ForegroundColor Cyan "Offline: $($GetOSDCloudOfflineFile.FullName)"
            }
            elseif (Test-MyDellDriverCabWebConnection) {
                if ($MyInvocation.MyCommand.Name -eq 'Save-OSDCloud') {
                    Save-OSDDownload -SourceUrl $GetMyDellDriverCab.DriverUrl -DownloadFolder "$OSDCloudOffline\DriverPacks" | Out-Null
                }
            }
            else {
                Write-Warning "Could not verify an Internet connection for the Dell Driver Pack"
                Write-Warning "OSDCloud will continue, but there may be issues"
            }
        }
        else {
            Write-Warning "Unable to determine a suitable Driver Pack for this Computer Model"
        }
    }
    #===================================================================================================
    #	Dell BIOS Update
    #===================================================================================================
    if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Dell BIOS Update"

        $GetMyDellBIOS = Get-MyDellBIOS
        if ($GetMyDellBIOS) {
            Write-Host -ForegroundColor White "ReleaseDate: $($GetMyDellBIOS.ReleaseDate)"
            Write-Host -ForegroundColor White "Name: $($GetMyDellBIOS.Name)"
            Write-Host -ForegroundColor White "DellVersion: $($GetMyDellBIOS.DellVersion)"
            Write-Host -ForegroundColor White "Url: $($GetMyDellBIOS.Url)"
            Write-Host -ForegroundColor White "Criticality: $($GetMyDellBIOS.Criticality)"
            Write-Host -ForegroundColor White "FileName: $($GetMyDellBIOS.FileName)"
            Write-Host -ForegroundColor White "SizeMB: $($GetMyDellBIOS.SizeMB)"
            Write-Host -ForegroundColor White "PackageID: $($GetMyDellBIOS.PackageID)"
            Write-Host -ForegroundColor White "SupportedModel: $($GetMyDellBIOS.SupportedModel)"
            Write-Host -ForegroundColor White "SupportedSystemID: $($GetMyDellBIOS.SupportedSystemID)"

            $GetOSDCloudOfflineFile = Get-OSDCloudOfflineFile -Name $GetMyDellBIOS.FileName | Select-Object -First 1
        
            if ($GetOSDCloudOfflineFile) {
                Write-Host -ForegroundColor Cyan "Offline: $($GetOSDCloudOfflineFile.FullName)"
            }
            elseif (Test-MyDellBiosWebConnection) {
                if ($MyInvocation.MyCommand.Name -eq 'Save-OSDCloud') {
                    Save-OSDDownload -SourceUrl $GetMyDellBIOS.Url -DownloadFolder "$OSDCloudOffline\BIOS" | Out-Null
                }
            }
            else {
                Write-Warning "Could not verify an Internet connection for the Dell Bios"
                Write-Warning "OSDCloud will continue, but there may be issues"
            }
        }
        else {
            Write-Warning "Unable to determine a suitable BIOS update for this Computer Model"
        }
    }
    #===================================================================================================
    #	Dell Flash64W
    #===================================================================================================
    if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Dell BIOS Flash64W"
        Write-Host -ForegroundColor White "Dell Flash64W 3.3.8"
        Write-Host -ForegroundColor White "FileName: Flash64W_Ver3.3.8.zip"
        Write-Host -ForegroundColor White "Destination: $OSDCloudOffline\BIOS\Flash64W_Ver3.3.8.zip"

        $GetOSDCloudOfflineFile = Get-OSDCloudOfflineFile -Name 'Flash64W_Ver3.3.8.zip' | Select-Object -First 1
    
        if ($GetOSDCloudOfflineFile) {
            Write-Host -ForegroundColor Cyan "Offline: $($GetOSDCloudOfflineFile.FullName)"
        }
        elseif (Test-WebConnection -Uri 'https://github.com/OSDeploy/OSDCloud/raw/main/Dell/Flash64W/Flash64W_Ver3.3.8.zip') {
            if ($MyInvocation.MyCommand.Name -eq 'Save-OSDCloud') {
                Save-OSDDownload -SourceUrl 'https://github.com/OSDeploy/OSDCloud/raw/main/Dell/Flash64W/Flash64W_Ver3.3.8.zip' -DownloadFolder "$OSDCloudOffline\BIOS" | Out-Null
            }
        }
        else {
            Write-Warning "Could not verify an Internet connection for Dell BIOS Flash64W"
            Write-Warning "OSDCloud will continue, but there may be issues"
        }
    }
    #===================================================================================================
    #	Save-OSDCloud Complete
    #===================================================================================================
    if ($MyInvocation.MyCommand.Name -eq 'Save-OSDCloud') {
		$Global:OSDCloudEndTime = Get-Date
		$Global:OSDCloudTimeSpan = New-TimeSpan -Start $Global:OSDCloudStartTime -End $Global:OSDCloudEndTime
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "Save-OSDCloud completed in $($Global:OSDCloudTimeSpan.ToString("mm' minutes 'ss' seconds'"))!"
        explorer $OSDCloudOffline
        Write-Host -ForegroundColor DarkGray "========================================================================="
    }
    #===================================================================================================
}