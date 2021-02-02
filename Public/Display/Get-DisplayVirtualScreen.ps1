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
    Param ()
  
    Add-Type -Assembly System.Windows.Forms
    Return ([System.Windows.Forms.SystemInformation]::VirtualScreen | Select-Object Width, Height, X, Y, Left, Top, Right, Bottom, Size)
}