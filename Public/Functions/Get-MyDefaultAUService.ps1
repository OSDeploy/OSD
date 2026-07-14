<#
.SYNOPSIS
Returns the Default AU Service from Microsoft.Update.ServiceManager

.DESCRIPTION
Returns the Default AU Service from Microsoft.Update.ServiceManager

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.LINK
https://twitter.com/byteben/status/1356893619811155968

.NOTES
21.2.3  Initial Release
        Credit Ben Whitmore | byteben.com | @byteben
21.2.9  Removed unnecessary Brief parameter
        Modified command
        
#>
function Get-MyDefaultAUService {
<#
.SYNOPSIS
Gets MyDefaultAUService information.

.DESCRIPTION
Returns MyDefaultAUService data for the current system or OSD session context.

.EXAMPLE
Get-MyDefaultAUService
Demonstrates a common way to run Get-MyDefaultAUService.

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding()]
    param ()

    ((New-Object -ComObject Microsoft.Update.ServiceManager).Services | Where-Object {$_.IsDefaultAUService -eq $true}).Name
}
