<#
.SYNOPSIS
Saves the Clipboard Image as a file.  PNG extension is recommended

.DESCRIPTION
Saves the Clipboard Image as a file.  PNG extension is recommended

.LINK
https://osd.osdeploy.com/module/functions/general/save-clipboardimage

.NOTES
21.2.1  Initial Release
#>
function Save-ClipboardImage {
    [CmdletBinding()]
    param(
        #Path and Name of the file to save
        #PNG extension is recommend
        [Parameter(Mandatory = $true)]
        $SaveAs
    )

    #Test if the Clipboard contains an Image
    if (!(Get-Clipboard -Format Image)) {
        Write-Warning "Clipboard Image does not exist"
        Break
    }

    #Test if existing file is present
    if (Test-Path $SaveAs) {
        Write-Warning "Existing file '$SaveAs' will be overwritten"
    }

    Try {
        (Get-Clipboard -Format Image).Save($SaveAs)
    }
    Catch{
        Write-Warning "Clipboard Image does not exist"
        Break
    }

    #Make sure that a file was written
    if (!(Test-Path $SaveAs)) {
        Write-Warning "Clipboard Image could not be saved to '$SaveAs'"
    }

    #Return Get-Item Object
    Return Get-Item -Path $SaveAs
}
<#
.SYNOPSIS
Sets a Screenshot of the Primary Screen on the Clipboard.  Use Save-ClipboardImage to save the PNG

.DESCRIPTION
Sets a Screenshot of the Primary Screen on the Clipboard.  Use Save-ClipboardImage to save the PNG

.LINK
https://osd.osdeploy.com/module/functions/general/Set-ClipboardScreenshot

.NOTES
21.2.1  Initial Release
#>
function Set-ClipboardScreenshot {
    [CmdletBinding()]
    param ()

    #=================================================
    #	Load Assemblies
    #=================================================
    Add-Type -Assembly System.Drawing
    Add-Type -Assembly System.Windows.Forms
    #=================================================
    #	Display Information
    #=================================================
    $GetDisplayVirtualScreen = Get-DisplayVirtualScreen
    #=================================================
    #	Display Number
    #=================================================
    $GetDisplayPrimaryBitmapSize = Get-DisplayPrimaryBitmapSize
    #Write-Verbose "Width: $($GetDisplayPrimaryBitmapSize.Width)" -Verbose
    #Write-Verbose "Height: $($GetDisplayPrimaryBitmapSize.Height)" -Verbose
    $ScreenShotBitmap = New-Object System.Drawing.Bitmap $GetDisplayPrimaryBitmapSize.Width, $GetDisplayPrimaryBitmapSize.Height
    $ScreenShotGraphics = [System.Drawing.Graphics]::FromImage($ScreenShotBitmap)
    #Write-Verbose "X: $($GetDisplayVirtualScreen.X)" -Verbose
    #Write-Verbose "Y: $($GetDisplayVirtualScreen.Y)" -Verbose
    #Write-Verbose "Size: $($GetDisplayVirtualScreen.Size)" -Verbose
    $ScreenShotGraphics.CopyFromScreen($GetDisplayVirtualScreen.X, $GetDisplayVirtualScreen.Y, $GetDisplayVirtualScreen.X, $GetDisplayVirtualScreen.Y, $GetDisplayVirtualScreen.Size)
    #=================================================
    #	Copy the ScreenShot to the Clipboard
    #   https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.clipboard.setimage?view=net-5.0
    #=================================================
    [System.Windows.Forms.Clipboard]::SetImage($ScreenShotBitmap)
    Return Get-Clipboard -Format Image
}