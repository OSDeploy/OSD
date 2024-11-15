function Get-OSDCloudOperatingSystemsIndexMap {
    <#
    .SYNOPSIS
    Returns the Operating System Indexes used by OSDCloud

    .DESCRIPTION
    Returns the Operating System Indexes used by OSDCloud

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
    if ($OSArch -eq 'x64'){
        $Results = Get-Content -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudOperatingIndexMap.json") | ConvertFrom-Json
        $Results = $Results | Where-Object {$_.Architecture -eq 'x64'}
    }
    elseif ($OSArch -eq "ARM64"){
        $Results = Get-Content -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudOperatingIndexMap.json") | ConvertFrom-Json
        $Results = $Results | Where-Object {$_.Architecture -eq 'ARM64'}
    }
    $Results
}