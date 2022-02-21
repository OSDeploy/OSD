function New-AzOSDCloudUSB {
    [CmdletBinding()]
    param ()
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
    Write-Host -ForegroundColor DarkGray "========================================================================="
    $BootLabel = 'WinPE'
    $DataLabel = 'OSDCloud'
    $ErrorActionPreference = 'Stop'
    #=================================================
    #	Get-AzOSDCloudISOUrl
    #=================================================
    $AzOSDCloudISOUrl = 'iso.osdcloud.com'
    $AzOSDCloudISO = Save-WebFile -SourceUrl $AzOSDCloudISOUrl -DestinationDirectory (Join-Path $HOME 'Downloads')

    if ($AzOSDCloudISO) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) AzOSDCloudISO downloaded to $($AzOSDCloudISO.FullName)"
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to download AzOSDCloudISO"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    #=================================================
    #	New-Bootable.usb
    #=================================================
    $BootableUSB = New-Bootable.usb -BootLabel 'WinPE' -DataLabel 'OSDCloud'
    #=================================================
    #	Test USB Volumes
    #=================================================
    $WinPEPartition = Get-Partition.usb | Where-Object {($_.DiskNumber -eq $BootableUSB.DiskNumber) -and ($_.PartitionNumber -eq 2)}
    if (-NOT ($WinPEPartition)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to create OSDCloud WinPE Partition"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    $OSDCloudPartition = Get-Partition.usb | Where-Object {($_.DiskNumber -eq $BootableUSB.DiskNumber) -and ($_.PartitionNumber -eq 1)}
    if (-NOT ($OSDCloudPartition)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to create OSDCloud Data Partition"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    #=================================================
    #   Mount AzOSDCloudISO
    #=================================================
    $Volumes = (Get-Volume).Where({$_.DriveLetter}).DriveLetter
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mounting AzOSDCloudISO"
    $MountAzOSDCloudISO = Mount-DiskImage -ImagePath $AzOSDCloudISO.FullName
    Start-Sleep -s 3
    #=================================================
    #   Updating OSDCloud WinPE
    #=================================================
    $ISO = (Compare-Object -ReferenceObject $Volumes -DifferenceObject (Get-Volume).Where({$_.DriveLetter}).DriveLetter).InputObject

    if ((Test-Path -Path "$($ISO):\") -and (Test-Path -Path "$($WinPEPartition.DriveLetter):\")) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying AzOSDCloudISO $($ISO):\ to OSDCloud WinPE partition at $($WinPEPartition.DriveLetter):\"
        robocopy "$($ISO):\" "$($WinPEPartition.DriveLetter):\" *.* /e /ndl /njh /njs /np /r:0 /w:0 /b /zb
    }
    #=================================================
    #   Dismount AzOSDCloudISO
    #=================================================
    Start-Sleep -s 3
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Dismounting AzOSDCloudISO"
    $DismountAzOSDCloudISO = Dismount-DiskImage -ImagePath $AzOSDCloudISO.FullName
    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-AzOSDCloudUSB is complete"
    #=================================================
    Break



    Break












    #=================================================
    #	WorkspacePath
    #=================================================
    if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
        Set-OSDCloud.workspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    }
    $WorkspacePath = Get-OSDCloud.workspace -ErrorAction Stop

    if (-NOT ($WorkspacePath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Workspace at $WorkspacePath"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }

    if (-NOT (Test-Path $WorkspacePath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Workspace at $WorkspacePath"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }

    if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud WinPE at $WorkspacePath\Media\sources\boot.wim"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    #=================================================
    #	Update WinPE Volume
    #=================================================
    if ((Test-Path -Path "$WorkspacePath\Media") -and (Test-Path -Path "$($WinPEPartition.DriveLetter):\")) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $WorkspacePath\Media to OSDCloud WinPE partition at $($WinPEPartition.DriveLetter):\"
        robocopy "$WorkspacePath\Media" "$($WinPEPartition.DriveLetter):\" *.* /e /ndl /njh /njs /np /r:0 /w:0 /b /zb
    }
    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-OSDCloudUSB is complete"
    #=================================================














    #=================================================
    Write-Verbose "Mounting the ISO ..."
    #=================================================
    Mount-DiskImage -ImagePath $ISOFile
    
    #=================================================
    Write-Verbose "Waiting 5 Seconds ..."
    #=================================================
    Start-Sleep -s 5

    $ISO = (Compare-Object -ReferenceObject $Volumes -DifferenceObject (Get-Volume).Where({$_.DriveLetter}).DriveLetter).InputObject
    #=================================================
    Write-Verbose "Dismounting Disk Image ..."
    #=================================================
    Dismount-DiskImage -ImagePath $ISOFile
}