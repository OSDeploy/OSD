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

    #=======================================================================
    #	Return
    #=======================================================================
    Return (Get-Partition.osd | Where-Object {$_.IsUSB -eq $true})
    #=======================================================================
}