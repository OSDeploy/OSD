function Get-USBVolume {
    <#
    .SYNOPSIS
    Returns Get-Volume for USB Devices

    .DESCRIPTION
    Returns Get-Volume for USB Devices

    .LINK
    https://osd.osdeploy.com/module/osddisk/get-usbvolume

    .NOTES
    21.2.25     Initial Release
    #>
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
                    Select-Object -Property DriveType, DriveLetter, FileSystemLabel, FileSystem, Size, SizeRemaining, OperationalStatus, HealthStatus
    #======================================================================================================
    #	Return
    #======================================================================================================
    Return $GetUSBVolume
    #======================================================================================================
}