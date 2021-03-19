<#
.SYNOPSIS
Returns a Intel Display Driver Object

.DESCRIPTION
Returns a Intel Display Driver Object
Requires BITS for downloading the Downloads
Requires Internet access for downloading the Downloads

.LINK
https://osddrivers.osdeploy.com/functions/get-drivernvidia
#>
function Get-DriverNvidia {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet ('Win10 x64','Win10 x86','Win7 x64','Win7 x86')]
        [string]$OperatingSystem = 'Win10 x64'

    )
    #=======================================================================
    #   Uri
    #=======================================================================
    #http://www.nvidia.com/Download/API/lookupValueSearch.aspx?TypeID=1


    #http://www.nvidia.com/Download/API/lookupValueSearch.aspx?TypeID=2
    $psid = 73

    #http://www.nvidia.com/Download/API/lookupValueSearch.aspx?TypeID=3
    $pfid = 824

    #http://www.nvidia.com/Download/API/lookupValueSearch.aspx?TypeID=4
    if ($OperatingSystem -eq 'Win10 x64') {$osid = 57}
    if ($OperatingSystem -eq 'Win10 x86') {$osid = 56}
    if ($OperatingSystem -eq 'Win7 x64') {$osid = 19}
    if ($OperatingSystem -eq 'Win7 x86') {$osid = 18}

    #http://www.nvidia.com/Download/API/lookupValueSearch.aspx?TypeID=5
    #$lid = 1

    #$Uri = "https://www.nvidia.com/Download/processFind.aspx?psid=$($psid)&pfid=$($pfid)&osid=$($osid)&lid=$($lid)&qnf=0&lang=en-us"
    #$Uri = "https://www.nvidia.com/Download/processDriver.aspx?psid=$($psid)&pfid=$($pfid)&osid=$($osid)&lid=$($lid)&qnf=1"

    #https://www.nvidia.com/Download/processFind.aspx?lang=en-us&lid=1&osid=57&dtcid=0
    #https://www.nvidia.com/Download/processFind.aspx?lang=en-us&lid=1&osid=57&dtcid=1
    #https://www.nvidia.com/Download/processFind.aspx?lang=en-us&lid=1&osid=57
    #https://www.nvidia.com/Download/index.aspx?lang=en-us&lid=1&osid=57

    #&dtcid=0   Standard
    #&dtcid=1   DCH



    #https://www.nvidia.com/Download/processFind.aspx?lang=en-us&lid=1&osid=57&psid=73


    #Windows 7 x86 Standard     https://www.nvidia.com/Download/processFind.aspx?lang=en-us&lid=1&osid=18
    #Windows 7 x64 Standard     https://www.nvidia.com/Download/processFind.aspx?lang=en-us&lid=1&osid=19
    #Windows 10 x86 Standard    https://www.nvidia.com/Download/processFind.aspx?lang=en-us&lid=1&osid=56
    #Windows 10 x64 Standard    https://www.nvidia.com/Download/processFind.aspx?lang=en-us&lid=1&osid=57
    #Windows 10 x64 DCH         https://www.nvidia.com/Download/processFind.aspx?lang=en-us&lid=1&osid=57&dtcid=1


<#     <LookupValue ParentID="74">
    <Name>Quadro K2000M</Name>
    <Value>649</Value>
    </LookupValue> #>


    Write-Host "$Uri"
    Break
}