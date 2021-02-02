function New-SystemDrawingBitmapPrimary {
    [CmdletBinding()]
    Param ()
    
    Return New-Object System.Drawing.Bitmap $GetDisplayPrimaryPhysical.Width, $GetDisplayPrimaryPhysical.Height
}
function New-SystemDrawingBitmap {
  [CmdletBinding()]
  Param ()
  
  Return New-Object System.Drawing.Bitmap $Device.Bounds.Width, $Device.Bounds.Height
}
function New-SSGraphics {
  [CmdletBinding()]
  Param ()
  
  Return [System.Drawing.Graphics]::FromImage($ScreenShotBitmap)
}