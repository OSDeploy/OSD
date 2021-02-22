function Get-USBDisk {
    <#
    .SYNOPSIS
    Returns Get-Disk + MediaType with BusType USB

    .DESCRIPTION
    Returns Get-Disk + MediaType with BusType USB

    .PARAMETER Number
    Specifies the disk number for which to get the associated Disk object
    Alias = Disk, DiskNumber

    .LINK
    https://osd.osdeploy.com/module/disk/get-usbdisk

    .NOTES
    21.2.22     Initial Release
    #>
    [CmdletBinding()]
    param (
        [Alias('Disk','DiskNumber')]
        [uint32]$Number
    )
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
    $GetUSBDisk = Get-OSDDisk -BusType USB
    #======================================================================================================
    #	-Number
    #======================================================================================================
    if ($PSBoundParameters.ContainsKey('Number')) {
        $GetUSBDisk = $GetUSBDisk | Where-Object {$_.DiskNumber -eq $Number}
    }
    #======================================================================================================
    #	Return
    #======================================================================================================
    Return $GetUSBDisk
    #======================================================================================================
}