<#
.SYNOPSIS
Returns [System.Windows.Forms.Screen]::AllScreens

.DESCRIPTION
Returns [System.Windows.Forms.Screen]::AllScreens

.LINK
https://osd.osdeploy.com/module/functions/display/get-displayallscreens

.NOTES
21.2.1  Initial Release
#>
function Get-DisplayAllScreens {
    [CmdletBinding()]
    param ()
  
    Add-Type -Assembly System.Windows.Forms
    Return ([System.Windows.Forms.Screen]::AllScreens | Select-Object * | Sort-Object DeviceName)
}
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
    param ()
  
    $GetDisplayPrimaryMonitorSize = Get-DisplayPrimaryMonitorSize
    $GetDisplayPrimaryScaling = Get-DisplayPrimaryScaling

    foreach ($Item in $GetDisplayPrimaryMonitorSize) {
        [int32]$Item.Width = [math]::round($(($Item.Width * $GetDisplayPrimaryScaling) / 100), 0)
        [int32]$Item.Height = [math]::round($(($Item.Height * $GetDisplayPrimaryScaling) / 100), 0)
    }

    Return $GetDisplayPrimaryMonitorSize
}
<#
.SYNOPSIS
Returns [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize

.DESCRIPTION
Returns [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize

.LINK
https://osd.osdeploy.com/module/functions/display/get-displayprimarymonitorsize

.NOTES
21.2.1  Initial Release
#>
function Get-DisplayPrimaryMonitorSize {
    [CmdletBinding()]
    param ()
  
    Add-Type -Assembly System.Windows.Forms
    Return ([System.Windows.Forms.SystemInformation]::PrimaryMonitorSize | Select-Object Width, Height)
}
<#
.SYNOPSIS
Returns the Primary Screen Scaling in Percent

.DESCRIPTION
Returns the Primary Screen Scaling in Percent

.LINK
https://osd.osdeploy.com/module/functions/display/get-displayPrimaryScaling

.NOTES
21.2.1  Initial Release
#>
function Get-DisplayPrimaryScaling {
    [CmdletBinding()]
    param ()
  
    #Add-Type -Assembly System.Drawing
      # Get DPI Scaling
      #[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
  
    Add-Type @'
using System; 
using System.Runtime.InteropServices;
using System.Drawing;

public class DPI {  
[DllImport("gdi32.dll")]
static extern int GetDeviceCaps(IntPtr hdc, int nIndex);

public enum DeviceCap {
VERTRES = 10,
DESKTOPVERTRES = 117
} 

public static float scaling() {
Graphics g = Graphics.FromHwnd(IntPtr.Zero);
IntPtr desktop = g.GetHdc();
int LogicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.VERTRES);
int PhysicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.DESKTOPVERTRES);

return (float)PhysicalScreenHeight / (float)LogicalScreenHeight;
}
}
'@ -ReferencedAssemblies 'System.Drawing.dll' -ErrorAction Stop
    Return [DPI]::scaling() * 100
}
<#
.SYNOPSIS
Returns [System.Windows.Forms.SystemInformation]::VirtualScreen which is a combination of all screens and placement

.DESCRIPTION
Returns [System.Windows.Forms.SystemInformation]::VirtualScreen which is a combination of all screens and placement

.LINK
https://osd.osdeploy.com/module/functions/display/get-displayvirtualscreen

.NOTES
21.2.1  Initial Release
#>
function Get-DisplayVirtualScreen {
    [CmdletBinding()]
    param ()
  
    Add-Type -Assembly System.Windows.Forms
    Return ([System.Windows.Forms.SystemInformation]::VirtualScreen | Select-Object Width, Height, X, Y, Left, Top, Right, Bottom, Size)
}