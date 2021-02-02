<#
.SYNOPSIS
Calulates the Screen Resolution by VirtualScreen x ScreenScaling

.DESCRIPTION
Calulates the Screen Resolution by VirtualScreen x ScreenScaling

.LINK
https://osd.osdeploy.com/module/functions/disres/get-primaryscreensizephysical

.NOTES
21.2.1  Initial Release
#>
function Get-PrimaryScreenSizePhysical {
    [CmdletBinding()]
    Param ()
  
    $GetPrimaryScreenSizeVirtual = Get-PrimaryScreenSizeVirtual
    $GetPrimaryScreenScaling = Get-PrimaryScreenScaling

    foreach ($Item in $GetPrimaryScreenSizeVirtual) {
        [int32]$Item.Width = [math]::round($(($Item.Width * $GetPrimaryScreenScaling) / 100), 0)
        [int32]$Item.Height = [math]::round($(($Item.Height * $GetPrimaryScreenScaling) / 100), 0)
    }

    Return $GetPrimaryScreenSizeVirtual
}