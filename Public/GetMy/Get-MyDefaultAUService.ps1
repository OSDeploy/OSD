<#
.SYNOPSIS
Returns the Default AU Service from Microsoft.Update.ServiceManager

.DESCRIPTION
Returns the Default AU Service from Microsoft.Update.ServiceManager

.LINK
https://osd.osdeploy.com/module/functions/getmy

.LINK
https://twitter.com/byteben/status/1356893619811155968

.NOTES
21.2.3  Initial Release
        Credit Ben Whitmore | byteben.com | @byteben
21.2.9  Removed unnecessary Brief parameter
        Modified command
        
#>
function Get-MyDefaultAUService {
    [CmdletBinding()]
    param ()

    ((New-Object -ComObject Microsoft.Update.ServiceManager).Services | Where-Object {$_.IsDefaultAUService -eq $true}).Name
}