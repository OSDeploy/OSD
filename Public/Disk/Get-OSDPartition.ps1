<#
.SYNOPSIS
Similar to Get-Partition, but adds IsUSB Property

.DESCRIPTION
Similar to Get-Partition, but adds IsUSB Property

.LINK
https://osd.osdeploy.com/module/functions/disk/get-osdpartition

.NOTES
21.3.5      Initial Release
#>
function Get-OSDPartition {
    [CmdletBinding()]
    param ()
    #======================================================================================================
    #	PSBoundParameters
    #======================================================================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #======================================================================================================
    #	OSD Module and Command Information
    #======================================================================================================
    $OSDVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Verbose "OSD $OSDVersion $($MyInvocation.MyCommand.Name)"
    #======================================================================================================
    #	Get Variables
    #======================================================================================================
    $GetUSBDisk = Get-USBDisk
    $GetPartition = Get-Partition | Sort-Object DiskNumber, PartitionNumber
    #======================================================================================================
    #	Add Property IsUSB
    #======================================================================================================
    foreach ($Partition in $GetPartition) {
        if ($Partition.DiskNumber -in $($GetUSBDisk).DiskNumber) {
            $Partition | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $true -Force
        } else {
            $Partition | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $false -Force
        }
    }
    #======================================================================================================
    #	Return
    #======================================================================================================
    Return $GetPartition
    #======================================================================================================
}

