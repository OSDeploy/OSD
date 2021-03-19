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

    #=======================================================================
    #	Return
    #=======================================================================
    Return (Get-Partition.osd | Where-Object {$_.IsUSB -eq $false})
    #=======================================================================
}