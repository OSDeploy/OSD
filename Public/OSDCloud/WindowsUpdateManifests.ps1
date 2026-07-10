function Get-WindowsUpdateManifests {
    <#
    .SYNOPSIS
    Returns an Array of Microsoft Updates from the Microsoft Update Catalog

    .DESCRIPTION
    Returns an Array of Microsoft Updates from the Microsoft Update Catalog

    .EXAMPLE
    Get-WindowsUpdateManifests

    .NOTES
    Author: David Segura - Recast Software
    2026-07-09 - Standardized comment-based help metadata and links.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .LINK
    https://osd.osdeploy.com/
    #>
    [CmdletBinding()]
    param ()

    $ManifestPath = "$(Get-OSDModulePath)\cache\archive-osd-manifests\mscatalog"
    #$ManifestPath = "$($env:ProgramData)\OSDeploy\OS-UpdateCatalog"
    $ManifestFiles = Get-ChildItem -Path "$ManifestPath\*" -Include '*.json' -Recurse | Select-Object -Property *

    $WindowsUpdateManifests = @()
    foreach ($Manifest in $ManifestFiles) {
        $WindowsUpdateManifest = @()
        $WindowsUpdateManifest = Get-Content $Manifest.FullName | ConvertFrom-Json
        if ($WindowsUpdateManifest.SupersededBy.KB) {
            #Continue
        }

        $WindowsUpdateManifests += $WindowsUpdateManifest
    }

    Return $WindowsUpdateManifests | Sort-Object -Property LastModified
}
