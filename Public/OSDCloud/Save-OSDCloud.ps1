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
        [string]$OSCulture = 'en-us',

        [switch]$Screenshot
    )

    #=======================================================================
    #	Start the Clock
    #=======================================================================
    $Global:OSDCloudStartTime = Get-Date
    #=======================================================================
    #   Screenshot
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('Screenshot')) {
        $Global:OSDCloudScreenshot = "$env:TEMP\ScreenPNG"
        Start-ScreenPNGProcess -Directory "$env:TEMP\ScreenPNG"
    }
    #=======================================================================
    #	Global Variables
    #=======================================================================
    $Global:OSDCloudOSEdition = $OSEdition
    $Global:OSDCloudOSCulture = $OSCulture
    #=======================================================================
    #   Require cURL
    #   Without cURL, we can't download the ESD, so if it's not present, then we need to exit
    #=======================================================================
    if (-NOT (Test-CommandCurlExe)) {
        Write-Host -ForegroundColor DarkGray    "========================================================================="
        Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
        Write-Warning                           "cURL is required for this process to work"
        Write-Warning                           "OSDCloud Failed!"
        Start-Sleep -Seconds 5
        Break
    }
    #=======================================================================
    #	Save-OSDCloud USB
    #=======================================================================
    Write-Host -ForegroundColor DarkGray        "========================================================================="
    Write-Host -ForegroundColor Yellow          "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan            "OSDCloud content can be saved to an 8GB+ NTFS USB Volume"
    Write-Host -ForegroundColor White           "Windows 10 will require about 4GB"
    Write-Host -ForegroundColor White           "Hardware Drivers will require between 1-2GB for Dell Systems"

    $GetUSBVolume = Get-Volume.usb | Where-Object {$_.FileSystem -eq 'NTFS'} | Where-Object {$_.SizeGB -ge 8} | Sort-Object DriveLetter -Descending
    if (-NOT ($GetUSBVolume)) {
        Write-Warning                           "Unfortunately, I don't see any USB Volumes that will work"
        Write-Warning                           "OSDCloud Failed!"
        Write-Host -ForegroundColor DarkGray    "========================================================================="
        Break
    }

    Write-Warning                               "USB Free Space is not verified before downloading yet, so this is on you!"
    Write-Host -ForegroundColor DarkGray        "========================================================================="
    if ($GetUSBVolume) {
        #$GetUSBVolume | Select-Object -Property DriveLetter, FileSystemLabel, SizeGB, SizeRemainingMB, DriveType | Format-Table
        $SelectUSBVolume = Select-Volume.usb -MinimumSizeGB 8 -FileSystem 'NTFS'
        $Global:OSDCloudOfflineFullName = "$($SelectUSBVolume.DriveLetter):\OSDCloud"
        Write-Host -ForegroundColor White       "OSDCloud content will be saved to $OSDCloudOfflineFullName"
    } else {
        Write-Warning                           "Save-OSDCloud USB Requirements:"
        Write-Warning                           "8 GB Minimum"
        Write-Warning                           "NTFS File System"
        Break
    }
    #=======================================================================
    #	AutoPilot Profiles
    #=======================================================================
    Write-Host -ForegroundColor DarkGray        "========================================================================="
    Write-Host -ForegroundColor Yellow          "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan            "AutoPilot Profiles"

    if (-NOT (Test-Path "$OSDCloudOfflineFullName\AutoPilot\Profiles")) {
        New-Item -Path "$OSDCloudOfflineFullName\AutoPilot\Profiles" -ItemType Directory -Force | Out-Null
        Write-Host "AutoPilot Profiles can be saved to $OSDCloudOfflineFullName\AutoPilot\Profiles"
    }

    $GetOSDCloudOfflineAutoPilotProfiles = Get-OSDCloudOfflineAutoPilotProfiles

    if ($GetOSDCloudOfflineAutoPilotProfiles) {
        foreach ($Item in $GetOSDCloudOfflineAutoPilotProfiles) {
            Write-Host -ForegroundColor White "$($Item.FullName)"
        }
    } else {
        Write-Warning "No AutoPilot Profiles were found in any <PSDrive>:\OSDCloud\AutoPilot\Profiles"
        Write-Warning "AutoPilot Profiles must be located in a $OSDCloudOfflineFullName\AutoPilot\Profiles direcory"
    }
    #=======================================================================
    #	Get-FeatureUpdate
    #=======================================================================
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Get-FeatureUpdate Windows 10 $Global:OSDCloudOSEdition x64 $OSBuild $OSCulture"
    
    $GetFeatureUpdate = Get-FeatureUpdate -OSBuild $OSBuild -OSCulture $OSCulture

    if (-NOT ($GetFeatureUpdate)) {
        Write-Warning "Unable to locate a Windows 10 Feature Update"
        Write-Warning "OSDCloud cannot continue"
        Break
    }

    $GetFeatureUpdate = $GetFeatureUpdate | Select-Object -Property CreationDate,KBNumber,Title,UpdateOS,UpdateBuild,UpdateArch,FileName, @{Name='SizeMB';Expression={[int]($_.Size /1024/1024)}},FileUri,Hash,AdditionalHash
    Write-Host -ForegroundColor White "CreationDate: $($GetFeatureUpdate.CreationDate)"
    Write-Host -ForegroundColor White "KBNumber: $($GetFeatureUpdate.KBNumber)"
    Write-Host -ForegroundColor White "Title: $($GetFeatureUpdate.Title)"
    Write-Host -ForegroundColor White "FileName: $($GetFeatureUpdate.FileName)"
    Write-Host -ForegroundColor White "SizeMB: $($GetFeatureUpdate.SizeMB)"
    Write-Host -ForegroundColor White "FileUri: $($GetFeatureUpdate.FileUri)"
    #=======================================================================
    #	Offline OS
    #=======================================================================
    $OSDCloudOfflineOS = Get-OSDCloudOfflineFile -Name $GetFeatureUpdate.FileName | Select-Object -First 1

    if ($OSDCloudOfflineOS) {
        $OSDCloudOfflineOSFullName = $OSDCloudOfflineOS.FullName
        Write-Host -ForegroundColor Cyan "Offline: $OSDCloudOfflineOSFullName"
    }
    elseif (Test-WebConnection -Uri $GetFeatureUpdate.FileUri) {
        $SaveFeatureUpdate = Save-FeatureUpdate -OSBuild $OSBuild -OSCulture $OSCulture -DownloadPath "$OSDCloudOfflineFullName\OS" | Out-Null
    }
    else {
        Write-Warning "Could not verify an Internet connection for the Windows Feature Update"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
    #=======================================================================
    #	Get Dell Driver Pack
    #=======================================================================
    if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
        Write-Host -ForegroundColor DarkGray    "========================================================================="
        Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
        Write-Host -ForegroundColor Cyan        "Get-MyDellDriverCab"
        
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

            $OSDCloudOfflineDriverPack = Get-OSDCloudOfflineFile -Name $GetMyDellDriverCab.DownloadFile | Select-Object -First 1
        
            if ($OSDCloudOfflineDriverPack) {
                Write-Host -ForegroundColor Cyan "Offline: $($OSDCloudOfflineDriverPack.FullName)"
            }
            elseif (Test-MyDellDriverCabWebConnection) {
                if ($MyInvocation.MyCommand.Name -eq 'Save-OSDCloud') {
                    Save-OSDDownload -SourceUrl $GetMyDellDriverCab.DriverUrl -DownloadFolder "$OSDCloudOfflineFullName\DriverPacks" | Out-Null
                }
            }
            else {
                Write-Warning "Could not verify an Internet connection for the Dell Driver Pack"
                Write-Warning "OSDCloud will continue, but there may be issues"
            }
        }
        else {
            Write-Warning "Unable to determine a suitable Driver Pack for this Computer Model"
            Write-Warning "OSDCloud will continue, but there may be issues"
        }
    }
    #=======================================================================
    #	Get Dell BIOS Update
    #=======================================================================
    if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
        Write-Host -ForegroundColor DarkGray    "========================================================================="
        Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
        Write-Host -ForegroundColor Cyan        "Get-MyDellBios"

        $GetMyDellBios = Get-MyDellBios
        if ($GetMyDellBios) {
            Write-Host -ForegroundColor White "ReleaseDate: $($GetMyDellBios.ReleaseDate)"
            Write-Host -ForegroundColor White "Name: $($GetMyDellBios.Name)"
            Write-Host -ForegroundColor White "DellVersion: $($GetMyDellBios.DellVersion)"
            Write-Host -ForegroundColor White "Url: $($GetMyDellBios.Url)"
            Write-Host -ForegroundColor White "Criticality: $($GetMyDellBios.Criticality)"
            Write-Host -ForegroundColor White "FileName: $($GetMyDellBios.FileName)"
            Write-Host -ForegroundColor White "SizeMB: $($GetMyDellBios.SizeMB)"
            Write-Host -ForegroundColor White "PackageID: $($GetMyDellBios.PackageID)"
            Write-Host -ForegroundColor White "SupportedModel: $($GetMyDellBios.SupportedModel)"
            Write-Host -ForegroundColor White "SupportedSystemID: $($GetMyDellBios.SupportedSystemID)"
            Write-Host -ForegroundColor White "Flash64W: $($GetMyDellBios.Flash64W)"

            $OSDCloudOfflineBios = Get-OSDCloudOfflineFile -Name $GetMyDellBios.FileName | Select-Object -First 1
            if ($OSDCloudOfflineBios) {
                Write-Host -ForegroundColor Cyan "Offline: $($OSDCloudOfflineBios.FullName)"
            }
            else {
                Save-MyDellBios -DownloadPath "$OSDCloudOfflineFullName\BIOS"
            }

            $OSDCloudOfflineFlash64W = Get-OSDCloudOfflineFile -Name 'Flash64W.exe' | Select-Object -First 1
            if ($OSDCloudOfflineFlash64W) {
                Write-Host -ForegroundColor Cyan "Offline: $($OSDCloudOfflineFlash64W.FullName)"
            }
            else {
                Save-MyDellBiosFlash64W -DownloadPath "$OSDCloudOfflineFullName\BIOS"
            }
        }
        else {
            Write-Warning "Unable to determine a suitable BIOS update for this Computer Model"
            Write-Warning "OSDCloud will continue, but there may be issues"
        }
    }
    #=======================================================================
    #	PSGallery Modules
    #=======================================================================
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "PowerShell Modules and Scripts"

    #Offline
    Write-Host "PowerShell Offline Modules and Scripts are located at $OSDCloudOfflineFullName\PowerShell\Offline"
    Write-Host "This is for Modules and Scripts that OSDCloud needs to add to the Offline OS"
    Write-Host ""
    if (-NOT (Test-Path "$OSDCloudOfflineFullName\PowerShell\Offline\Modules")) {
        New-Item -Path "$OSDCloudOfflineFullName\PowerShell\Offline\Modules" -ItemType Directory -Force | Out-Null
    }
    if (-NOT (Test-Path "$OSDCloudOfflineFullName\PowerShell\Offline\Scripts")) {
        New-Item -Path "$OSDCloudOfflineFullName\PowerShell\Offline\Scripts" -ItemType Directory -Force | Out-Null
    }

    #Required
    Write-Host "PowerShell Required Modules and Scripts are located at $OSDCloudOfflineFullName\PowerShell\Required"
    Write-Host "This is for Modules and Scripts that you want to add to the Offline OS"
    Write-Host ""
    if (-NOT (Test-Path "$OSDCloudOfflineFullName\PowerShell\Required\Modules")) {
        New-Item -Path "$OSDCloudOfflineFullName\PowerShell\Required\Modules" -ItemType Directory -Force | Out-Null
    }
    if (-NOT (Test-Path "$OSDCloudOfflineFullName\PowerShell\Required\Scripts")) {
        New-Item -Path "$OSDCloudOfflineFullName\PowerShell\Required\Scripts" -ItemType Directory -Force | Out-Null
    }

    if (Test-WebConnection -Uri "https://www.powershellgallery.com") {
        Write-Host -ForegroundColor DarkGray "Save-Module OSD to $OSDCloudOfflineFullName\PowerShell\Offline\Modules"
        Save-Module -Name OSD -Path "$OSDCloudOfflineFullName\PowerShell\Offline\Modules"

        Write-Host -ForegroundColor DarkGray "Save-Module WindowsAutoPilotIntune to $OSDCloudOfflineFullName\PowerShell\Offline\Modules"
        Save-Module -Name WindowsAutoPilotIntune -Path "$OSDCloudOfflineFullName\PowerShell\Offline\Modules"
        Write-Host -ForegroundColor DarkGray "Save-Module AzureAD to $OSDCloudOfflineFullName\PowerShell\Offline\Modules"
        Write-Host -ForegroundColor DarkGray "Save-Module Microsoft.Graph.Intune to $OSDCloudOfflineFullName\PowerShell\Offline\Modules"

        Write-Host -ForegroundColor DarkGray "Save-Script Get-WindowsAutoPilotInfo to $OSDCloudOfflineFullName\PowerShell\Offline\Scripts"
        Save-Script -Name Get-WindowsAutoPilotInfo -Path "$OSDCloudOfflineFullName\PowerShell\Offline\Scripts"
    }
    else {
        Write-Warning "Could not validate an Internet connection to the PowerShell Gallery"
        Write-Warning "OSDCloud cannot continue"
        Break
    }
    #=======================================================================
    #	Save-OSDCloud Complete
    #=======================================================================
    $Global:OSDCloudEndTime = Get-Date
    $Global:OSDCloudTimeSpan = New-TimeSpan -Start $Global:OSDCloudStartTime -End $Global:OSDCloudEndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($Global:OSDCloudTimeSpan.ToString("mm' minutes 'ss' seconds'"))!"
    explorer $OSDCloudOfflineFullName
    #=======================================================================
    if ($Global:OSDCloudScreenshot) {
        Start-Sleep 5
        Stop-ScreenPNGProcess
        Write-Host -ForegroundColor Cyan    "Screenshots: $Global:OSDCloudScreenshot"
    }
    #=======================================================================
}