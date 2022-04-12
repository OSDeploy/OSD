function Get-OSDCloudOSList {
    <#
    .SYNOPSIS
    Returns the Operating Systems used by OSDCloud

    .DESCRIPTION
    Returns the Operating Systems used by OSDCloud

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    
    [CmdletBinding()]
    param ()
    $Results = Get-Content -Path (Join-Path (Get-Module OSD).ModuleBase "Catalogs\os.json") | ConvertFrom-Json
    $Results
}