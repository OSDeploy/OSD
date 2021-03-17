function Test-OSDCloud.workspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $WorkspacePath
    )
    
    if (-NOT (Test-Path "$WorkspacePath")) {Return $false}
    if (-NOT (Test-Path "$WorkspacePath\Media" )) {Return $false}
    if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim" )) {Return $false}

    Return $true
}