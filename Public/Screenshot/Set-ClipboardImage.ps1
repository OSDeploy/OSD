<#
.SYNOPSIS
Sets a Screenshot of the Primary Screen on the Clipboard.  Use Save-ClipboardImage to save the PNG

.DESCRIPTION
Sets a Screenshot of the Primary Screen on the Clipboard.  Use Save-ClipboardImage to save the PNG

.LINK
https://osd.osdeploy.com/module/functions/general/set-clipboardimage

.NOTES
21.2.1  Initial Release
#>
function Set-ClipboardImage {
    [CmdletBinding()]
    Param ()

    #======================================================================================================
    #	Load Assemblies
    #======================================================================================================
    Add-Type -Assembly System.Drawing
    Add-Type -Assembly System.Windows.Forms
    #======================================================================================================
    #	Display Information
    #======================================================================================================
    $GetVirtualScreen = Get-VirtualScreen
    #======================================================================================================
    #	Display Number
    #======================================================================================================
    $GetPrimaryScreenSizePhysical = Get-PrimaryScreenSizePhysical
    #Write-Verbose "Width: $($GetPrimaryScreenSizePhysical.Width)" -Verbose
    #Write-Verbose "Height: $($GetPrimaryScreenSizePhysical.Height)" -Verbose
    $ScreenShotBitmap = New-Object System.Drawing.Bitmap $GetPrimaryScreenSizePhysical.Width, $GetPrimaryScreenSizePhysical.Height
    $ScreenShotGraphics = [System.Drawing.Graphics]::FromImage($ScreenShotBitmap)
    #Write-Verbose "X: $($GetVirtualScreen.X)" -Verbose
    #Write-Verbose "Y: $($GetVirtualScreen.Y)" -Verbose
    #Write-Verbose "Size: $($GetVirtualScreen.Size)" -Verbose
    $ScreenShotGraphics.CopyFromScreen($GetVirtualScreen.X, $GetVirtualScreen.Y, $GetVirtualScreen.X, $GetVirtualScreen.Y, $GetVirtualScreen.Size)
    #======================================================================================================
    #	Copy the ScreenShot to the Clipboard
    #   https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.clipboard.setimage?view=net-5.0
    #======================================================================================================
    [System.Windows.Forms.Clipboard]::SetImage($ScreenShotBitmap)
    Return Get-Clipboard -Format Image
}