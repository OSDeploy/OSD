function Restart-OSDCloudRE {
    <#
    .Synopsis
    OSDCloudRE: Launch OSDCloudRE on next boot

    .Description
    OSDCloudRE: Launch OSDCloudRE on next boot by editing the BCD bootsequence for {766548eb-6165-4bfe-9db5-95af1965ba26}

    .Example
    Restart-OSDCloudRE

    .Link
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>
    
    [CmdletBinding()]
    [OutputType([System.Void])]
    param ()

    Block-StandardUser
    Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) bcdedit /bootsequence {766548eb-6165-4bfe-9db5-95af1965ba26}"
    try {
        $null = bcdedit /bootsequence '{766548eb-6165-4bfe-9db5-95af1965ba26}'
        Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloudRE set for next boot"
    }
    catch {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloudRE could not be set for next boot"
    }
}