<#
.SYNOPSIS
Returns the Default AU Service

.DESCRIPTION
Returns the Default AU Service

.LINK
https://osd.osdeploy.com/module/functions/getmy
https://twitter.com/byteben/status/1356893619811155968

.NOTES
Credit Ben Whitmore | byteben.com | @byteben
#>
function Get-MyDefaultAUService {
    [CmdletBinding()]
    param (
        #Normalize the Return
        [switch]$Brief
    )

    Return (New-Object -ComObject Microsoft.Update.ServiceManager).Services | Where-Object {$_.IsDefaultAUService -eq $true} | Select-Object -ExpandProperty Name
}