function Get-OSDCloudOperatingSystemsIndexMap {
    <#
    .SYNOPSIS
    Returns the Operating System Indexes used by OSDCloud

    .DESCRIPTION
    Returns the Operating System Indexes used by OSDCloud

    .PARAMETER OSArch
    Specifies the OS architecture to filter results. Valid values are 'x64' and 'ARM64'.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'Default')]
        [ValidateSet('x64', 'ARM64')]
        [System.String]
        $OSArch = 'x64'
    )

    $OfflineCatalog = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Get-ChildItem "$($_.Root)OSDCloud\Catalogs" -Include "CloudOperatingIndexMap.json" -File -Force -Recurse -ErrorAction Ignore
    }
    if ($OfflineCatalog) {
        foreach ($Item in $OfflineCatalog) {
            Write-Warning "$($Item.FullName) is imported instead of the cache under $(Get-OSDModulePath)."
            $indexMapPath =  (Get-Item -Path "$($Item.FullName)").FullName
        }
    } else {
        $indexMapPath = "$(Get-OSDCachePath)\archive-cloudoperatingindexmap\CloudOperatingIndexMap.json"
    }
    $Results = Get-Content -Path $indexMapPath -Encoding UTF8 | ConvertFrom-Json # as of OSD 25.6.10.1 encoding of the json is UTF8
    $Results = $Results | Where-Object { $_.Architecture -eq $OSArch }
    
    return $Results
}
