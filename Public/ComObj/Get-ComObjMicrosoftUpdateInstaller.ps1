<#
.SYNOPSIS
Returns New-Object -ComObject Microsoft.Update.Installer

.DESCRIPTION
Returns New-Object -ComObject Microsoft.Update.Installer

.LINK
https://osd.osdeploy.com/module/functions/update
https://twitter.com/byteben/status/1356893619811155968

.NOTES
Credit Ben Whitmore | byteben.com | @byteben
#>
function Get-ComObjMicrosoftUpdateInstaller {
    [CmdletBinding()]
    param ()

    Return New-Object -ComObject Microsoft.Update.Installer
}