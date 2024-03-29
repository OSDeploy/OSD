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
    if ($OSArch -eq 'x64'){
        $Results = Get-Content -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudOperatingSystemsIndexes.json") | ConvertFrom-Json
    }
    elseif ($OSArch -eq "ARM64"){
        $Results = Get-Content -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudOperatingSystemsARM64Indexes.json") | ConvertFrom-Json
    }
    $Results
}