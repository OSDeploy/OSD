<#
.SYNOPSIS
Returns Get-OSDPartition without USB Drives

.DESCRIPTION
Returns Get-OSDPartition without USB Drives

.LINK
https://osd.osdeploy.com/module/functions/disk/get-localpartition

.NOTES
21.3.5     Initial Release
#>
function Get-LocalPartition {
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
    $GetLocalPartition = Get-OSDPartition | Where-Object {$_.IsUSB -eq $false}
    #======================================================================================================
    #	Return
    #======================================================================================================
    Return $GetLocalPartition
    #======================================================================================================
}