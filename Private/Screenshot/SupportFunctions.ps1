function New-SystemDrawingBitmapPrimary {
    [CmdletBinding()]
    param ()
    
    Return New-Object System.Drawing.Bitmap $GetDisplayPrimaryBitmapSize.Width, $GetDisplayPrimaryBitmapSize.Height
}
function New-SystemDrawingBitmap {
  [CmdletBinding()]
  param ()
  
  Return New-Object System.Drawing.Bitmap $Device.Bounds.Width, $Device.Bounds.Height
}
function New-SSGraphics {
  [CmdletBinding()]
  param ()
  
  Return [System.Drawing.Graphics]::FromImage($ScreenShotBitmap)
}