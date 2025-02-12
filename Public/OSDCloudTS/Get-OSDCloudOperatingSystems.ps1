function Get-OSDCloudOperatingSystems {
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
    $FullResults = Get-Content -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudOperatingSystems.json")  | ConvertFrom-Json
    if ($OSArch -eq 'x64'){
        $Results = $FullResults | Where-Object {$_.Architecture -eq "x64"}
    }
    elseif ($OSArch -eq "ARM64"){
        $Results = $FullResults | Where-Object {$_.Architecture -eq "ARM64"}
    }
    $Results
}