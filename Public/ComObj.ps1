<#
.SYNOPSIS
Returns all ComObjects

.DESCRIPTION
Returns all ComObjects

.LINK
https://osd.osdeploy.com/module/functions/comobj
https://www.powershellmagazine.com/2013/06/27/pstip-get-a-list-of-all-com-objects-available/

.NOTES
21.2.3     Initial Release
I'm not quite sure this works as it is not listing the Microsoft Update stuff
#>
function Get-ComObjects {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
        ParameterSetName='FilterByName')]
        [string]$Filter,
 
        [Parameter(Mandatory=$true,
        ParameterSetName='ListAllComObjects')]
        [switch]$ListAll
    )
 
    $ListofObjects = Get-ChildItem HKLM:\Software\Classes -ErrorAction SilentlyContinue | Where-Object {
        $_.PSChildName -match '^\w+\.\w+$' -and (Test-Path -Path "$($_.PSPath)\CLSID")
    } | Select-Object -ExpandProperty PSChildName
 
    if ($Filter) {
        $ListofObjects | Where-Object {$_ -like $Filter}
    } else {
        $ListofObjects
    }
}
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
    param ()

    Return (New-Object -ComObject Microsoft.Update.AutoUpdate).Settings
}
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