function Get-OSDCloudDriverPackList {
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
    $Results = Get-Content -Path (Join-Path (Get-Module OSD).ModuleBase "Catalogs\driverpack.json") | ConvertFrom-Json
    $Results
}