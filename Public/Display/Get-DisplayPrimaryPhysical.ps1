<#
.SYNOPSIS
Calulates the Screen Resolution by VirtualScreen x ScreenScaling

.DESCRIPTION
Calulates the Screen Resolution by VirtualScreen x ScreenScaling

.LINK
https://osd.osdeploy.com/module/functions/display/get-displayprimaryphysical

.NOTES
21.2.1  Initial Release
#>
function Get-DisplayPrimaryPhysical {
    [CmdletBinding()]
    Param ()
  
    $GetDisplayVirtualScreen = Get-DisplayVirtualScreen
    $GetDisplayPrimaryScaling = Get-DisplayPrimaryScaling

    foreach ($Item in $GetDisplayVirtualScreen) {
        [int32]$Item.Width = [math]::round($(($Item.Width * $GetDisplayPrimaryScaling) / 100), 0)
        [int32]$Item.Height = [math]::round($(($Item.Height * $GetDisplayPrimaryScaling) / 100), 0)
    }

    Return $GetDisplayVirtualScreen
}