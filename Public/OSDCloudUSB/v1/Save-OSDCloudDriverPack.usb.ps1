<#
.SYNOPSIS
Downloads a Manufacturer Driver Pack by selection using Out-Gridview to an OSDCloud USB

.DESCRIPTION
Downloads a Manufacturer Driver Pack by selection using Out-Gridview to an OSDCloud USB

.PARAMETER Manufacturer
Computer Manufacturer of the Driver Pack

.LINK
https://www.osdcloud.com/build/media/save-osdclouddriverpack.usb
#>
function Save-OSDCloudDriverPack.usb {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Dell','HP','Lenovo','Microsoft')]
        [System.String]$Manufacturer
    )
    #=================================================
    #	Start the Clock
    #=================================================
    $Global:OSDCloudStartTime = Get-Date
    #=================================================
    #	Block
    #=================================================
    Block-PowerShellVersionLt5
    Block-NoCurl
    Block-WinPE
    #=================================================
    #   Header
    #=================================================
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Cyan        "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name)" -NoNewline
    Write-Host -ForegroundColor Cyan        " | Manufacturer: $Manufacturer | Product: $Product"
    Write-Host -ForegroundColor Cyan        "OSDCloud content can be saved to an 8GB+ NTFS USB Volume"
    Write-Host -ForegroundColor White       "DriverPacks will require up to 2GB each"
    #=================================================
    #   Get-Volume.usb
    #=================================================
    $GetUSBVolume = Get-Volume.usb | Where-Object {$_.FileSystem -eq 'NTFS'} | Where-Object {$_.SizeGB -ge 8} | Sort-Object DriveLetter -Descending
    
    if (-NOT ($GetUSBVolume)) {
        Write-Warning                           "Unfortunately, I don't see any USB Volumes that will work"
        Write-Warning                           "OSDCloud Failed!"
        Write-Host -ForegroundColor DarkGray    "================================================"
        Break
    }

    Write-Warning                               "USB Free Space is not verified before downloading yet, so this is on you!"
    Write-Host -ForegroundColor DarkGray        "================================================"
    
    if ($GetUSBVolume) {
        #$GetUSBVolume | Select-Object -Property DriveLetter, FileSystemLabel, SizeGB, SizeRemainingMB, DriveType | Format-Table
        $SelectUSBVolume = Select-Volume.usb -MinimumSizeGB 8 -FileSystem 'NTFS'
        $Global:OSDCloudOfflineFullName = "$($SelectUSBVolume.DriveLetter):\OSDCloud"
        Write-Host -ForegroundColor White       "OSDCloud content will be saved to $OSDCloudOfflineFullName"
    }
    else {
        Write-Warning                           "Save-OSDCloud.usb Requirements:"
        Write-Warning                           "8 GB Minimum"
        Write-Warning                           "NTFS File System"
        Break
    }
    #=================================================
    #	Save-MyDriverPack
    #=================================================
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Cyan        "Save-MyDriverPack"
    
    $DownloadPath = "$OSDCloudOfflineFullName\DriverPacks\$Manufacturer"
    
    switch ($Manufacturer) {
        Dell {Get-DellDriverPack -DownloadPath $DownloadPath}
        HP {Get-HPDriverPack -DownloadPath $DownloadPath}
        Lenovo {Get-LenovoDriverPack -DownloadPath $DownloadPath}
        Microsoft {Get-MicrosoftDriverPack -DownloadPath $DownloadPath}
    }
    #=================================================
    #	Save-OSDCloud.usb Complete
    #=================================================
    $Global:OSDCloudEndTime = Get-Date
    $Global:OSDCloudTimeSpan = New-TimeSpan -Start $Global:OSDCloudStartTime -End $Global:OSDCloudEndTime
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($Global:OSDCloudTimeSpan.ToString("mm' minutes 'ss' seconds'"))!"
    #=================================================
}