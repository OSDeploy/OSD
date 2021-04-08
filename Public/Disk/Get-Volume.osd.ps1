<#
.SYNOPSIS
Get-Volume with IsUSB Property

.DESCRIPTION
Get-Volume with IsUSB Property

.LINK
https://osd.osdeploy.com/module/functions/disk/get-volume

.NOTES
#>
function Get-Volume.osd {
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
    $GetPartition = Get-Partition.usb
    $GetVolume = Get-Volume | Sort-Object DriveLetter
    #=======================================================================
    #	Add Property IsUSB
    #=======================================================================
    foreach ($Volume in $GetVolume) {
        if ($Volume.Path -in $($GetPartition).AccessPaths) {
            $Volume | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $true -Force
        } else {
            $Volume | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $false -Force
        }
    }
    #=======================================================================
    #	Return
    #=======================================================================
    Return $GetVolume | Sort-Object DriveLetter | Select-Object -Property DriveLetter, FileSystemLabel, FileSystem, `
                        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}}, `
                        @{Name='SizeRemainingGB';Expression={[int]($_.SizeRemaining / 1000000000)}}, `
                        @{Name='SizeRemainingMB';Expression={[int]($_.SizeRemaining / 1000000)}}, `
                        IsUSB, DriveType, OperationalStatus, HealthStatus
    #=======================================================================
}