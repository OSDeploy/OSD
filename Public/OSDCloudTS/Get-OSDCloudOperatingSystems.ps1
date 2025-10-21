function Get-OSDCloudOperatingSystems {
    <#
    .SYNOPSIS
    Returns the Operating Systems used by OSDCloud

    .DESCRIPTION
    Returns the Operating Systems used by OSDCloud

    .NOTES
    25.2.17 Removed unnecessary Default ParameterSet Name
    #>
    
    [CmdletBinding()]
    param (
        [ValidateSet('x64','arm64')]
        [System.String]
        $OSArch = 'x64'
    )
    $OfflineCatalog = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Get-ChildItem "$($_.Root)OSDCloud\Catalogs" -Include "CloudOperatingSystems.json" -File -Force -Recurse -ErrorAction Ignore
    }
    if ($OfflineCatalog) {
        foreach ($Item in $OfflineCatalog) {
            Write-Warning "$($Item.FullName) is imported instead of the cache under $(Get-OSDModulePath)."
            $FullResults = Get-Content -Path "$($Item.FullName)" | ConvertFrom-Json -ErrorAction "Stop"
        }
        $Results = $FullResults | Where-Object {$_.Architecture -eq $OSArch}
    } else {
        $FullResults = Get-Content -Path "$(Get-OSDModulePath)\cache\archive-cloudoperatingsystems\CloudOperatingSystems.json" | ConvertFrom-Json
        $Results = $FullResults | Where-Object {$_.Architecture -eq $OSArch}
    }
    $Results
}