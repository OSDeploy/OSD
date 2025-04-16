function Get-OSDCatalogOperatingSystems {
    <#
    .SYNOPSIS
    Returns the OSD Operating Systems Catalog

    .DESCRIPTION
    Returns the OSD Operating Systems Catalog

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param ()
    $Results = Import-Clixml -Path "$(Get-OSDCachePath)\os-catalogs\build-operatingsystems.xml"
    $Results
}