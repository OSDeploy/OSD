function Get-OSDCloudREVolume {
    <#
    .Synopsis
    OSDCloudRE: Gets the OSDCloudRE Volume object

    .Description
    OSDCloudRE: Gets the OSDCloudRE Volume object

    .Example
    Get-OSDCloudREVolume

    .Link
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>
    
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param ()
    
    Get-Volume | Where-Object {$_.FileSystemLabel -match 'OSDCloudRE'}
}