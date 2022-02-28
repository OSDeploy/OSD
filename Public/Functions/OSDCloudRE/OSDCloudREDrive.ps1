function Hide-OSDCloudREDrive {
    <#
    .Synopsis
    OSDCloudRE: Hides the OSDCloudRE Drive
    
    .Description
    OSDCloudRE: Hides the OSDCloudRE Drive
    
    .Example
    Hide-OSDCloudREDrive
    
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
remove
set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac"
gpt attributes=0x8000000000000001
exit
"@ | diskpart.exe
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloudRE partition"
    }
}
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