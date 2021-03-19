<#
.SYNOPSIS
Get-Volume for Fixed Disks

.DESCRIPTION
Get-Volume for Fixed Disks

.LINK
https://osd.osdeploy.com/module/functions/disk/get-volume

.NOTES
21.3.3      Added SizeGB and SizeRemainingMB
21.2.25     Initial Release
#>
function Get-Volume.fixed {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #	Return
    #=======================================================================
    Return (Get-Volume.osd | Where-Object {$_.IsUSB -eq $false})
    #=======================================================================
}