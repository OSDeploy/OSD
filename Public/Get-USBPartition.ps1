<#
.SYNOPSIS
Returns Get-OSDPartition with Property IsUSB

.DESCRIPTION
Returns Get-OSDPartition with Property IsUSB

.LINK
https://osd.osdeploy.com/module/functions/disk/get-usbpartition

.NOTES
21.3.5     Initial Release
#>
function Get-USBPartition {
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
    #	Get-OSDPartition
    #======================================================================================================
    $GetUSBPartition = Get-OSDPartition | Where-Object {$_.IsUSB -eq $true}
    #======================================================================================================
    #	Return
    #======================================================================================================
    Return $GetUSBPartition
    #======================================================================================================
}