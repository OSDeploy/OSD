<#
.SYNOPSIS
Returns (New-Object -ComObject Microsoft.Update.ServiceManager).Services

.DESCRIPTION
Returns (New-Object -ComObject Microsoft.Update.ServiceManager).Services

.LINK
https://osd.osdeploy.com/module/functions/update
https://twitter.com/byteben/status/1356893619811155968

.NOTES
Credit Ben Whitmore | byteben.com | @byteben
#>
function Get-ComObjMicrosoftUpdateServiceManager{
    [CmdletBinding()]
    param ()

    Return (New-Object -ComObject Microsoft.Update.ServiceManager).Services
}