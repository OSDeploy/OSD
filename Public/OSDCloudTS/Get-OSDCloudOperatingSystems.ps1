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
    $FullResults = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\CloudOperatingSystems.json" | ConvertFrom-Json
    if ($OSArch -eq 'x64'){
        $Results = $FullResults | Where-Object {$_.Architecture -eq "x64"}
    }
    elseif ($OSArch -eq "arm64"){
        $Results = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\CloudOperatingSystemsARM64.json" | ConvertFrom-Json
    }
    $Results
}