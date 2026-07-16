function Get-ComObjects {
    <#
    .SYNOPSIS
    Lists registered COM ProgIDs from the local machine registry.

    .DESCRIPTION
    Enumerates COM object ProgIDs under HKLM:\Software\Classes that map to a CLSID.
    Use -ListAll to return the full list, or -Filter to return matching entries.

    .PARAMETER Filter
    Wildcard pattern used to match ProgID names (for example, Microsoft.Update.*).

    .PARAMETER ListAll
    Returns all discovered COM ProgIDs without applying a name filter.

    .EXAMPLE
    Get-ComObjects -ListAll
    Returns all COM ProgIDs that contain a CLSID registration.

    .EXAMPLE
    Get-ComObjects -Filter 'Microsoft.Update.*'
    Returns only COM ProgIDs that match the specified wildcard pattern.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-13 - Added standardized comment-based help
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
        ParameterSetName='FilterByName')]
        [string]$Filter,

        [Parameter(Mandatory=$true,
        ParameterSetName='ListAllComObjects')]
        [System.Management.Automation.SwitchParameter]$ListAll
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
function Get-ComObjMicrosoftUpdateAutoUpdate{
    <#
    .SYNOPSIS
    Gets Microsoft Update automatic update settings through COM.

    .DESCRIPTION
    Creates the Microsoft.Update.AutoUpdate COM object and returns its Settings
    object for inspection of current automatic update configuration.

    .EXAMPLE
    Get-ComObjMicrosoftUpdateAutoUpdate
    Returns Windows Update automatic update settings from the local device.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-13 - Added standardized comment-based help
    #>
    [CmdletBinding()]
    param ()

    Return (New-Object -ComObject Microsoft.Update.AutoUpdate).Settings
}
function Get-ComObjMicrosoftUpdateInstaller {
    <#
    .SYNOPSIS
    Creates and returns the Microsoft Update installer COM object.

    .DESCRIPTION
    Instantiates the Microsoft.Update.Installer COM object so callers can query
    or manage update installation behavior through the Windows Update API.

    .EXAMPLE
    Get-ComObjMicrosoftUpdateInstaller
    Returns a Microsoft.Update.Installer COM object instance.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-13 - Added standardized comment-based help
    #>
    [CmdletBinding()]
    param ()

    Return New-Object -ComObject Microsoft.Update.Installer
}
function Get-ComObjMicrosoftUpdateServiceManager {
    <#
    .SYNOPSIS
    Gets Windows Update service registration details through COM.

    .DESCRIPTION
    Creates the Microsoft.Update.ServiceManager COM object and returns the
    registered update Services collection from the local device.

    .EXAMPLE
    Get-ComObjMicrosoftUpdateServiceManager
    Returns registered Windows Update services from the local system.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-13 - Added standardized comment-based help
    #>
    [CmdletBinding()]
    param ()

    Return (New-Object -ComObject Microsoft.Update.ServiceManager).Services
}
