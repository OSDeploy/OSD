<#
.SYNOPSIS
Returns an Array of Microsoft Updates from the Microsoft Update Catalog

.DESCRIPTION
Returns an Array of Microsoft Updates from the Microsoft Update Catalog

.LINK
https://osd.osdeploy.com/
#>
function Get-WindowsUpdateManifests {
    [CmdletBinding()]
    #$ManifestPath = "$($MyInvocation.MyCommand.Module.ModuleBase)\Manifests\MSCatalog"
    $ManifestPath = "$($env:ProgramData)\OSDeploy\OSD-MicrosoftUpdate"
    $ManifestFiles = Get-ChildItem -Path "$ManifestPath\*" -Include '*.json' -Recurse | Select-Object -Property *

    $WindowsUpdateManifests = @()
    foreach ($Manifest in $ManifestFiles) {
        $WindowsUpdateManifest = @()
        $WindowsUpdateManifest = Get-Content $Manifest.FullName | ConvertFrom-Json
        if ($WindowsUpdateManifest.SupersededBy.KB) {
            Continue
        }

        $WindowsUpdateManifests += $WindowsUpdateManifest
    }

    Return $WindowsUpdateManifests | Sort-Object -Property LastModified
}