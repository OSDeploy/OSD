function Get-OSDCloudREPartition {
    <#
    .SYNOPSIS
    OSDCloudRE: Gets the OSDCloudRE Partition object
    
    .DESCRIPTION
    OSDCloudRE: Gets the OSDCloudRE Partition object
    
    .EXAMPLE
    Get-OSDCloudREPartition
    
    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>
    
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param ()

    Get-OSDCloudREVolume | Get-Partition
}