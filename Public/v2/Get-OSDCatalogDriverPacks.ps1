function Get-OSDCatalogDriverPacks {
    <#
    .SYNOPSIS
    Returns the DriverPacks used by OSDCloud

    .DESCRIPTION
    Returns the DriverPacks used by OSDCloud

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param ()
    $Results = Import-Clixml -Path "$(Get-OSDModulePath)\cache\driverpack-catalogs\build-driverpacks.xml"
    $Results
}