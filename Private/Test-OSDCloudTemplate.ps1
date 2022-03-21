function Test-OSDCloudTemplate {
    <#
    .SYNOPSIS
    Tests if the OSDCloud Template is valid.

    .DESCRIPTION
    Tests if the OSDCloud Template is valid.
    
    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param ()

    $TemplatePath = Get-OSDCloudTemplate

    if ($null -eq $TemplatePath) {
        $false
    }
    elseif (-NOT (Test-Path "$TemplatePath")) {
        $false
    }
    elseif (-NOT (Test-Path "$TemplatePath\Media")) {
        $false
    }
    elseif (-NOT (Test-Path "$TemplatePath\Media\sources\boot.wim")) {
        $false
    }
    else {
        $true
    }
}