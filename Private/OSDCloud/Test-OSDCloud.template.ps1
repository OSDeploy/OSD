function Test-OSDCloud.template {
    [CmdletBinding()]
    param ()

    $TemplatePath = "$env:ProgramData\OSDCloud"
    
    if (-NOT (Test-Path "$TemplatePath")) {Return $false}
    if (-NOT (Test-Path "$TemplatePath\Media" )) {Return $false}
    if (-NOT (Test-Path "$TemplatePath\Media\sources\boot.wim" )) {Return $false}

    Return $true
}