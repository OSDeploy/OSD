function Get-OSDCloudOperatingSystemsIndexes {
    <#
    .SYNOPSIS
    Returns the Operating Systems used by OSDCloud

    .DESCRIPTION
    Returns the Operating Systems used by OSDCloud

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet('x64','ARM64')]
        [System.String]
        $OSArch = 'x64'
    )

    if ($OSArch -eq 'x64') {
        $OfflineCatalog = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
            Get-ChildItem "$($_.Root)OSDCloud\Catalogs" -Include "CloudOperatingSystemsIndexes.json" -File -Force -Recurse -ErrorAction Ignore
        }
        if ($OfflineCatalog) {
            foreach ($Item in $OfflineCatalog) {
                Write-Warning "$($Item.FullName) is imported instead of the cache under $(Get-OSDModulePath)."
                $Results = Get-Content -Path "$($Item.FullName)" | ConvertFrom-Json -ErrorAction "Stop"
            }
        } else {
            $Results = Get-Content -Path "$(Get-OSDCachePath)\archive-cloudoperatingsystems\CloudOperatingSystemsIndexes.json" | ConvertFrom-Json
        }
    }
    elseif ($OSArch -eq "ARM64") {
        $OfflineCatalog = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
            Get-ChildItem "$($_.Root)OSDCloud\Catalogs" -Include "CloudOperatingSystemsARM64Indexes.json" -File -Force -Recurse -ErrorAction Ignore
        }
        if ($OfflineCatalog) {
            foreach ($Item in $OfflineCatalog) {
                Write-Warning "$($Item.FullName) is imported instead of the cache under $(Get-OSDModulePath)."
                $Results = Get-Content -Path "$($Item.FullName)" | ConvertFrom-Json -ErrorAction "Stop"
            }
        } else {
            $Results = Get-Content -Path "$(Get-OSDCachePath)\archive-cloudoperatingsystems\CloudOperatingSystemsARM64Indexes.json" | ConvertFrom-Json
        }
    }

    return $Results
}