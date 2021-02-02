<#
.SYNOPSIS
Returns [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize

.DESCRIPTION
Returns [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize

.LINK
https://osd.osdeploy.com/module/functions/disres/get-primaryscreensizevirtual

.NOTES
21.2.1  Initial Release
#>
function Get-PrimaryScreenSizeVirtual {
    [CmdletBinding()]
    Param ()
  
    Add-Type -Assembly System.Windows.Forms
    Return ([System.Windows.Forms.SystemInformation]::PrimaryMonitorSize | Select-Object Width, Height)
}