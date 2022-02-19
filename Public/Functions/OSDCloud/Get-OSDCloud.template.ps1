function Get-OSDCloud.template {
    [CmdletBinding()]
    param ()

    $TemplatePath = "$env:ProgramData\OSDCloud"
    
    if (-NOT (Test-Path "$TemplatePath")) {Return $null}
    if (-NOT (Test-Path "$TemplatePath\Media" )) {Return $null}
    if (-NOT (Test-Path "$TemplatePath\Media\sources\boot.wim" )) {Return $null}

    Return $TemplatePath
}