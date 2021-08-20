<#
.SYNOPSIS
Get-Partition with IsUSB Property

.DESCRIPTION
Get-Partition with IsUSB Property

.LINK
https://osd.osdeploy.com/module/functions/disk/get-partition

.NOTES
21.3.5      Initial Release
#>
function Get-Partition.osd {
    [CmdletBinding()]
    param ()
    #=================================================
    #	PSBoundParameters
    #=================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #=================================================
    #	Get Variables
    #=================================================
    $GetDisk = Get-Disk.osd -BusType USB
    $GetPartition = Get-Partition | Sort-Object DiskNumber, PartitionNumber
    #=================================================
    #	Add Property IsUSB
    #=================================================
    foreach ($Partition in $GetPartition) {
        if ($Partition.DiskNumber -in $($GetDisk).DiskNumber) {
            $Partition | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $true -Force
        } else {
            $Partition | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $false -Force
        }
    }
    #=================================================
    #	Return
    #=================================================
    Return $GetPartition
    #=================================================
}
<#
.SYNOPSIS
Get-Partition for Fixed Disks

.DESCRIPTION
Get-Partition for Fixed Disks

.LINK
https://osd.osdeploy.com/module/functions/disk/get-partition

.NOTES
21.3.5     Initial Release
#>
function Get-Partition.fixed {
    [CmdletBinding()]
    param ()

    #=================================================
    #	Return
    #=================================================
    Return (Get-Partition.osd | Where-Object {$_.IsUSB -eq $false})
    #=================================================
}
<#
.SYNOPSIS
Get-Partition for USB Disks

.DESCRIPTION
Get-Partition for USB Disks

.LINK
https://osd.osdeploy.com/module/functions/disk/get-partition

.NOTES
21.3.5     Initial Release
#>
function Get-Partition.usb {
    [CmdletBinding()]
    param ()

    #=================================================
    #	Return
    #=================================================
    Return (Get-Partition.osd | Where-Object {$_.IsUSB -eq $true})
    #=================================================
}