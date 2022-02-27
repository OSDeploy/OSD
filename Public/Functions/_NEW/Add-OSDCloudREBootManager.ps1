function Add-OSDCloudREBootManager {
    <#
    .Synopsis
    OSDCloudRE: Adds OSDCloudRE as the last entry in the Boot Manager

    .Description
    OSDCloudRE: Adds OSDCloudRE as the last entry in the Boot Manager. Requires ADMIN righs

    .Example
    Add-OSDCloudREBootManager

    .Link
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>
    
    [CmdletBinding()]
    [OutputType([System.Void])]
    param ()

    Block-StandardUser
    $null = bcdedit /displayorder '{766548eb-6165-4bfe-9db5-95af1965ba26}' /addlast
}