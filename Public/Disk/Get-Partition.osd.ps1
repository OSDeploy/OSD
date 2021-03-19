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
    #=======================================================================
    #	PSBoundParameters
    #=======================================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #=======================================================================
    #	Get Variables
    #=======================================================================
    $GetDisk = Get-Disk.osd -BusType USB
    $GetPartition = Get-Partition | Sort-Object DiskNumber, PartitionNumber
    #=======================================================================
    #	Add Property IsUSB
    #=======================================================================
    foreach ($Partition in $GetPartition) {
        if ($Partition.DiskNumber -in $($GetDisk).DiskNumber) {
            $Partition | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $true -Force
        } else {
            $Partition | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $false -Force
        }
    }
    #=======================================================================
    #	Return
    #=======================================================================
    Return $GetPartition
    #=======================================================================
}

