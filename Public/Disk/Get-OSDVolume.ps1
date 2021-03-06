<#
.SYNOPSIS
Similar to Get-Volume, but adds property IsUSB

.DESCRIPTION
Similar to Get-Volume, but adds property IsUSB

.LINK
https://osd.osdeploy.com/module/functions/disk/get-usbvolume

.NOTES
21.3.3      Added SizeGB and SizeRemainingMB
21.2.25     Initial Release
#>
function Get-OSDVolume {
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
    $GetUSBPartition = Get-USBPartition
    $GetVolume = Get-Volume | Sort-Object DriveLetter
    #======================================================================================================
    #	Add Property IsUSB
    #======================================================================================================
    foreach ($Volume in $GetVolume) {
        if ($Volume.Path -in $($GetUSBPartition).AccessPaths) {
            $Volume | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $true -Force
        } else {
            $Volume | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $false -Force
        }
    }
    #======================================================================================================
    #	Return
    #======================================================================================================
    Return $GetVolume | Sort-Object DriveLetter | Select-Object -Property DriveLetter, FileSystemLabel, FileSystem, `
                        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}}, `
                        @{Name='SizeRemainingMB';Expression={[int]($_.SizeRemaining / 1000000)}}, `
                        IsUSB, DriveType, OperationalStatus, HealthStatus
    #======================================================================================================
}