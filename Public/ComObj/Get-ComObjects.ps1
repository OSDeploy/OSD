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