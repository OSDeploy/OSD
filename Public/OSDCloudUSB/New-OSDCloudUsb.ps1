<#
.SYNOPSIS
Creates an OSDCloud USB Drive
Clear, Initialize, Partition (WinPE and OSDCloud), and Format a USB Disk
Requires Admin Rights

.Description
Creates an OSDCloud USB Drive
Clear, Initialize, Partition (WinPE and OSDCloud), and Format a USB Disk
Requires Admin Rights

.PARAMETER WorkspacePath
Directory for the Workspace.  Contains the Media directory

.EXAMPLE
New-OSDCloudUSB -WorkspacePath C:\OSDCloud

.LINK
https://osdcloud.osdeploy.com

.NOTES
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
    #=================================================
    #	Set Variables
    #=================================================
    $ErrorActionPreference = 'Stop'
    $BootLabel = 'WinPE'
    $DataLabel = 'OSDCloud'
    #=================================================
    #	Set Workspace
    #=================================================
    if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
        Set-OSDCloud.workspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    }
    $WorkspacePath = Get-OSDCloud.workspace -ErrorAction Stop
    #=================================================
    #	Test Workspace
    #=================================================
    if (-NOT ($WorkspacePath)) {
        Write-Warning "Unable to find an OSDCloud Workspace at $WorkspacePath"
        Get-Help New-OSDCloudUSB -Examples
        Break
    }

    if (-NOT (Test-Path $WorkspacePath)) {
        Write-Warning "Unable to find an OSDCloud Workspace at $WorkspacePath"
        Get-Help New-OSDCloudUSB -Examples
        Break
    }

    if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "Unable to find an OSDCloud WinPE at $WorkspacePath\Media\sources\boot.wim"
        Get-Help New-OSDCloudUSB -Examples
        Break
    }
    #=================================================
    #	New-Bootable.usb
    #=================================================
    $BootableUSB = New-Bootable.usb -BootLabel 'WinPE' -DataLabel 'OSDCloud'
    #=================================================
    #	Get-Partition.usb
    #=================================================
    $UsbBootPartition = Get-Partition.usb | Where-Object {($_.DiskNumber -eq $BootableUSB.DiskNumber) -and ($_.PartitionNumber -eq 2)}
    if (-NOT ($UsbBootPartition)) {
        Write-Warning "Something went very very wrong in this process"
        Break
    }
    $UsbDataPartition = Get-Partition.usb | Where-Object {($_.DiskNumber -eq $BootableUSB.DiskNumber) -and ($_.PartitionNumber -eq 1)}
    if (-NOT ($UsbDataPartition)) {
        Write-Warning "Something went very very wrong in this process"
        Break
    }
    #=================================================
    #	Copy OSDCloud
    #=================================================
    Update-OSDCloudUSB
    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Update-OSDCloudUSB is complete"
    Write-Host -ForegroundColor DarkGray "========================================================================="
}