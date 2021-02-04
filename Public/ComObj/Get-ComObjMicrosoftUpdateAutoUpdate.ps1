<#
.SYNOPSIS
Returns (New-Object -ComObject Microsoft.Update.AutoUpdate).Settings

.DESCRIPTION
Returns (New-Object -ComObject Microsoft.Update.AutoUpdate).Settings

.LINK
https://osd.osdeploy.com/module/functions/update
https://twitter.com/byteben/status/1356893619811155968

.NOTES
Credit Ben Whitmore | byteben.com | @byteben
#>
function Get-ComObjMicrosoftUpdateAutoUpdate{
    [CmdletBinding()]
    Param ()

    Return (New-Object -ComObject Microsoft.Update.AutoUpdate).Settings
}