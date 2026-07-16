function Get-OSDDrive {
    <#
    .SYNOPSIS
    Returns PSDrive data with OSD-specific USB and network flags.

    .DESCRIPTION
    Collects PSDrive and OSD volume data, then enriches drive objects with
    IsUSB and IsNetwork properties for deployment scripting.

    .PARAMETER IsLocal
    Optional local-only selector used by calling workflows.

    .EXAMPLE
    Get-OSDDrive
    Returns drives with IsUSB and IsNetwork properties.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-16 - Moved help block inside function and normalized required sections
    #>
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
    $GetOSDVolume = Get-OSDVolume | Select-Object -Property *
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
