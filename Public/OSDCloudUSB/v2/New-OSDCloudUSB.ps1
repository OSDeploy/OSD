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
New-OSDCloudUSB -WorkspacePath C:\OSDCloud

.LINK
https://osdcloud.osdeploy.com
#>
function New-OSDCloudUSB {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,ValueFromPipelineByPropertyName)]
        [System.String]$WorkspacePath
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
    Write-Host -ForegroundColor DarkGray "========================================================================="
    $BootLabel = 'WinPE'
    $DataLabel = 'OSDCloud'
    $ErrorActionPreference = 'Stop'
    #=================================================
    #	New-Bootable.usb
    #=================================================
    $BootableUSB = New-Bootable.usb -BootLabel 'WinPE' -DataLabel 'OSDCloud'
    #=================================================
    #	Test USB Volumes
    #=================================================
    $WinPEVolume = Get-Partition.usb | Where-Object {($_.DiskNumber -eq $BootableUSB.DiskNumber) -and ($_.PartitionNumber -eq 2)}
    if (-NOT ($WinPEVolume)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to create OSDCloud WinPE Partition"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    $OSDCloudVolume = Get-Partition.usb | Where-Object {($_.DiskNumber -eq $BootableUSB.DiskNumber) -and ($_.PartitionNumber -eq 1)}
    if (-NOT ($OSDCloudVolume)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to create OSDCloud Data Partition"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
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
    if ((Test-Path -Path "$WorkspacePath\Media") -and (Test-Path -Path "$($WinPEVolume.DriveLetter):\")) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $WorkspacePath\Media to OSDCloud WinPE partition at $($WinPEVolume.DriveLetter):\"
        robocopy "$WorkspacePath\Media" "$($WinPEVolume.DriveLetter):\" *.* /e /ndl /njh /njs /np /r:0 /w:0 /b /zb
    }
    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-OSDCloudUSB is complete"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #=================================================
}