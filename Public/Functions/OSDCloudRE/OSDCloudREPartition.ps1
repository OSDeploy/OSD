function Get-OSDCloudREPartition {
    <#
    .Synopsis
    OSDCloudRE: Gets the OSDCloudRE Partition object
    
    .Description
    OSDCloudRE: Gets the OSDCloudRE Partition object
    
    .Example
    Get-OSDCloudREPartition
    
    .Link
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>
    
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param ()

    Get-OSDCloudREVolume | Get-Partition
}