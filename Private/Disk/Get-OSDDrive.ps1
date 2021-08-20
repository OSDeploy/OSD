<#
.SYNOPSIS
Similar to Get-PSDrive, but adds IsUSB and IsNetwork Property

.DESCRIPTION
Similar to Get-PSDrive, but adds IsUSB and IsNetwork Property

.LINK
https://osd.osdeploy.com/module/functions/disk/get-osddrive

.NOTES
21.3.5      Initial Release
#>
function Get-OSDDrive {
    [CmdletBinding()]
    param (
        [string]$IsLocal
    )
    #=================================================
    #	PSBoundParameters
    #=================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #=================================================
    #	OSD Module and Command Information
    #=================================================
    $OSDVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Verbose "OSD $OSDVersion $($MyInvocation.MyCommand.Name)"
    #=================================================
    #	Get Variables
    #=================================================
    $GetOSDDrive = Get-PSDrive | Select-Object -Property *
    $GetOSDVolume = Get-Volume.osd | Select-Object -Property *
    #=================================================
    #	Add Property IsUSB
    #=================================================
    foreach ($Item in $GetOSDDrive) {
        if ($Item.Name -in ($GetOSDVolume | Where-Object {$_.IsUSB -eq $true}).DriveLetter) {
            $Item | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $true -Force
        } else {
            $Item | Add-Member -NotePropertyName 'IsUSB' -NotePropertyValue $false -Force
        }
    }
    #=================================================
    #	Add Property IsNetwork
    #=================================================
    foreach ($Item in $GetOSDDrive) {
        if ($Item.DisplayRoot -match "\\") {
            $Item | Add-Member -NotePropertyName 'IsNetwork' -NotePropertyValue $true -Force
        } else {
            $Item | Add-Member -NotePropertyName 'IsNetwork' -NotePropertyValue $false -Force
        }
    }
    #=================================================
    #	Return
    #=================================================
    Return $GetOSDDrive | Sort-Object Name | Select-Object Name, Root, DisplayRoot, Provider, IsNetwork, IsUSB, Used, Free, Description
    #=================================================
}