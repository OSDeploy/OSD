<#
.SYNOPSIS
Calulates the Bitmap Screen Size (PrimaryMonitorSize x ScreenScaling)

.DESCRIPTION
Calulates the Bitmap Screen Size (PrimaryMonitorSize x ScreenScaling)

.LINK
https://osd.osdeploy.com/module/functions/display/get-displayprimarybitmapsize

.NOTES
21.2.1  Initial Release
#>
function Get-DisplayPrimaryBitmapSize {
    [CmdletBinding()]
    Param ()
  
    $GetDisplayPrimaryMonitorSize = Get-DisplayPrimaryMonitorSize
    $GetDisplayPrimaryScaling = Get-DisplayPrimaryScaling

    foreach ($Item in $GetDisplayPrimaryMonitorSize) {
        [int32]$Item.Width = [math]::round($(($Item.Width * $GetDisplayPrimaryScaling) / 100), 0)
        [int32]$Item.Height = [math]::round($(($Item.Height * $GetDisplayPrimaryScaling) / 100), 0)
    }

    Return $GetDisplayPrimaryMonitorSize
}