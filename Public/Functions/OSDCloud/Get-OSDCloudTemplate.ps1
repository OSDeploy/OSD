function Get-OSDCloudTemplate {
    <#
    .SYNOPSIS
    Returns the path to the OSDCloud Template.  This is typically $env:ProgramData\OSDCloud

    .DESCRIPTION
    Returns the path to the OSDCloud Template.  This is typically $env:ProgramData\OSDCloud

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    
    [CmdletBinding()]
    param ()

    $TemplatePath = "$env:ProgramData\OSDCloud"
    
    if (-NOT (Test-Path "$TemplatePath")) {Return $null}
    if (-NOT (Test-Path "$TemplatePath\Media" )) {Return $null}
    if (-NOT (Test-Path "$TemplatePath\Media\sources\boot.wim" )) {Return $null}

    Return $TemplatePath
}