<#
.SYNOPSIS
Gets the supported Display Resolution of the Video Adapters

.DESCRIPTION
Gets the supported Display Resolution of the Video Adapters

.LINK
https://osd.osdeploy.com/module/functions/get-disresvc

.NOTES
21.1.27    David Segura @SeguraOSD
#>
function Get-DisResVC {
    [CmdletBinding()]
    Param ()
    
    Return (Get-CimInstance -Class CIM_VideoControllerResolution | `
    Where-Object {$_.ScanMode -eq 4} | `
    Where-Object {$_.HorizontalResolution -ge 800} | `
    Select-Object -Property SettingID, Caption, HorizontalResolution, VerticalResolution, NumberOfColors, RefreshRate | `
    Sort-Object -Property HorizontalResolution, VerticalResolution -Descending)
}