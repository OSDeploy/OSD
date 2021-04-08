<#
.SYNOPSIS
Get-Disk with Fixed Disk results

.DESCRIPTION
Get-Disk with Fixed Disk results

.LINK
https://osd.osdeploy.com/module/functions
#>
function Get-Disk.fixed {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #	Get-Disk.osd
    #=======================================================================
    $GetDisk = Get-Disk.osd -BusTypeNot 'File Backed Virtual',MAX,'Microsoft Reserved',USB,Virtual
    #=======================================================================
    #	Return
    #=======================================================================
    Return $GetDisk
    #=======================================================================
}