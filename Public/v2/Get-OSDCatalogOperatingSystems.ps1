function Get-OSDCatalogOperatingSystems {
    <#
    .SYNOPSIS
    Returns the OSDCatalog Operating Systems

    .DESCRIPTION
    Returns the OSDCatalog Operating Systems

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param ()
    $Results = Import-Clixml -Path "$(Get-OSDCatalogsPath)\main\build-operatingsystems.xml"
    $Results
}