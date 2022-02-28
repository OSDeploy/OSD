
function Remove-OSDCloudREBootmgr {
    <#
    .Synopsis
    OSDCloudRE: Removes OSDCloudRE from Boot Manager

    .Description
    OSDCloudRE: Removes OSDCloudRE from Boot Manager. Requires ADMIN righs

    .Example
    Add-OSDCloudREBootmgr

    .Link
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>
    
    [CmdletBinding()]
    [OutputType([System.Void])]
    param ()

    Block-StandardUser
    $null = bcdedit /displayorder '{766548eb-6165-4bfe-9db5-95af1965ba26}' /remove
}