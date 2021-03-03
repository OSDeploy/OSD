<#
.SYNOPSIS
Returns Get-Volume for USB Devices

.DESCRIPTION
Returns Get-Volume for USB Devices

.LINK
https://osd.osdeploy.com/module/functions/disk/get-usbvolume

.NOTES
21.3.3      Added SizeGB and SizeRemainingMB
21.2.25     Initial Release
#>
function Get-USBVolume {
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
    #	Get-OSDDisk
    #======================================================================================================
    $GetUSBVolume = Get-Volume | Where-Object {$_.DriveType -eq 'Removable'} | `
                    Select-Object -Property DriveType, DriveLetter, FileSystemLabel, FileSystem, `
                    @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}}, `
                    @{Name='SizeRemainingMB';Expression={[int]($_.SizeRemaining / 1000000)}}, `
                    OperationalStatus, HealthStatus
    #======================================================================================================
    #	Return
    #======================================================================================================
    Return $GetUSBVolume
    #======================================================================================================
}