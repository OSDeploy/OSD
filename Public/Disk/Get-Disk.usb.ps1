<#
.SYNOPSIS
Get-Disk with USB Disk results

.DESCRIPTION
Get-Disk with USB Disk results

.LINK
https://osd.osdeploy.com/module/functions
#>
function Get-Disk.usb {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #	Get-Disk.osd
    #=======================================================================
    $GetDisk = Get-Disk.osd -BusType USB
    #=======================================================================
    #	Return
    #=======================================================================
    Return $GetDisk
    #=======================================================================
}