function Show-OSDCloudREDrive {
    <#
    .Synopsis
    OSDCloudRE: Shows the OSDCloudRE Drive
    
    .Description
    OSDCloudRE: Shows the OSDCloudRE Drive
    
    .Example
    Show-OSDCloudREDrive
    
    .Link
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>

    [CmdletBinding()]
    [OutputType([System.Void])]
    param ()

    Block-StandardUser
    $OSDCloudREPartition = Get-OSDCloudREPartition

    if ($OSDCloudREPartition) {
$null = @"
select disk $($OSDCloudREPartition.DiskNumber)
select partition $($OSDCloudREPartition.PartitionNumber)
set id="ebd0a0a2-b9e5-4433-87c0-68b6b72699c7"
gpt attributes=0x0000000000000000
rescan
assign letter=o
exit
"@ | diskpart.exe
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloudRE partition"
    }
}