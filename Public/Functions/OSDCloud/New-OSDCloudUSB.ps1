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
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Workspace"
            Break
        }
    
        if (-NOT (Test-Path $WorkspacePath)) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Workspace at $WorkspacePath"
            Break
        }
    
        if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud WinPE at $WorkspacePath\Media\sources\boot.wim"
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
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to get the properties of $fromIsoFile"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
            Break
        }
        #=================================================
        #   Mount fromIsoFile
        #=================================================
        $Volumes = (Get-Volume).Where({$_.DriveLetter}).DriveLetter

        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mounting OSDCloudISO at $fromIsoFileFullName"
        $MountDiskImage = Mount-DiskImage -ImagePath $fromIsoFileFullName
        Start-Sleep -Seconds 3
        $MountDiskImageDriveLetter = (Compare-Object -ReferenceObject $Volumes -DifferenceObject (Get-Volume).Where({$_.DriveLetter}).DriveLetter).InputObject

        if ($MountDiskImageDriveLetter) {
            $WinpeSourcePath = "$($MountDiskImageDriveLetter):\"
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to mount $MountDiskImage"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
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
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloudISO downloaded to $fromIsoFileFullName"
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to download OSDCloudISO"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
            Break
        }
        #=================================================
        #   Mount OSDCloudISO
        #=================================================
        $Volumes = (Get-Volume).Where({$_.DriveLetter}).DriveLetter

        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mounting OSDCloudISO"
        $MountDiskImage = Mount-DiskImage -ImagePath $fromIsoFileFullName
        Start-Sleep -Seconds 3
        $MountDiskImageDriveLetter = (Compare-Object -ReferenceObject $Volumes -DifferenceObject (Get-Volume).Where({$_.DriveLetter}).DriveLetter).InputObject

        if ($MountDiskImageDriveLetter) {
            $WinpeSourcePath = "$($MountDiskImageDriveLetter):\"
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to mount $MountDiskImage"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
            Break
        }
    }
    #=================================================
    #	Test WinpeSourcePath
    #=================================================
    if (-NOT ($WinpeSourcePath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Media"
        Break
    }

    if (-NOT (Test-Path $WinpeSourcePath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Media at $WinpeSourcePath"
        Break
    }

    if (-NOT (Test-Path "$WinpeSourcePath\sources\boot.wim")) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud WinPE at $WinpeSourcePath\sources\boot.wim"
        Break
    }
    #=================================================
    #	New-Bootable.usb
    #=================================================
    $BootableUSB = New-Bootable.usb -BootLabel $BootLabel -DataLabel $DataLabel
    #=================================================
    #	Test USB Volumes
    #=================================================
    $WinPEPartition = Get-Partition.usb | Where-Object {($_.DiskNumber -eq $BootableUSB.DiskNumber) -and ($_.PartitionNumber -eq 2)}
    if (-NOT ($WinPEPartition)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to create OSDCloud WinPE Partition"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
        Break
    }
    $OSDCloudPartition = Get-Partition.usb | Where-Object {($_.DiskNumber -eq $BootableUSB.DiskNumber) -and ($_.PartitionNumber -eq 1)}
    if (-NOT ($OSDCloudPartition)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to create OSDCloud Data Partition"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
        Break
    }
    #=================================================
    #	WinpeDestinationPath
    #=================================================
    $WinpeDestinationPath = "$($WinPEPartition.DriveLetter):\"
    if (-NOT ($WinpeDestinationPath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find Destination Path at $WinpeDestinationPath"
        Break
    }
    #=================================================
    #	Update WinPE Volume
    #=================================================
    if ((Test-Path -Path "$WinpeSourcePath") -and (Test-Path -Path "$WinpeDestinationPath")) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $WinpeSourcePath to OSDCloud WinPE partition at $WinpeDestinationPath"
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
        Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Dismounting $($MountDiskImage.ImagePath)"
        $null = Dismount-DiskImage -ImagePath $MountDiskImage.ImagePath
    }
    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-OSDCloudUSB is complete"
    #=================================================
}