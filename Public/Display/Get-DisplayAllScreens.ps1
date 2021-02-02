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
    Param ()
  
    Add-Type -Assembly System.Windows.Forms
    Return ([System.Windows.Forms.Screen]::AllScreens | Select-Object * | Sort-Object DeviceName)
}