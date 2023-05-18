<#
.SYNOPSIS
Updates the Intel Drivers Catalogs in the OSD Module

.DESCRIPTION
Updates the Intel Drivers Catalogs in the OSD Module

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Update-IntelDriversCatalog {
    [CmdletBinding()]
    param ()
    Get-IntelEthernetDriverPack -UpdateModuleCatalog
    Get-IntelGraphicsDriverPack -UpdateModuleCatalog
    Get-IntelRadeonDriverPack -UpdateModuleCatalog
    Get-IntelWirelessDriverPack -UpdateModuleCatalog
}