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