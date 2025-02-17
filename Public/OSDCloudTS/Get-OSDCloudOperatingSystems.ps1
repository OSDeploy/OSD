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
    if ($OSArch -eq 'x64'){
        $Results = Get-Content -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudOperatingSystems.json") | ConvertFrom-Json
    }
    elseif ($OSArch -eq 'arm64') {
        $Results = Get-Content -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudOperatingSystemsARM64.json") | ConvertFrom-Json
    }
    $Results
}