function Show-OSDCloudREDrive {
    <#
    .SYNOPSIS
    OSDCloudRE: Shows the OSDCloudRE Drive
    
    .DESCRIPTION
    OSDCloudRE: Shows the OSDCloudRE Drive
    
    .EXAMPLE
    Show-OSDCloudREDrive
    
    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>

    [CmdletBinding()]
    [OutputType([System.Void])]
    param ()
    Write-Verbose $MyInvocation.MyCommand

    Block-StandardUser
    $OSDCloudREPartition = Get-OSDCloudREPartition

    if ($OSDCloudREPartition) {
$null = @"
select disk $($OSDCloudREPartition.DiskNumber)
select partition $($OSDCloudREPartition.PartitionNumber)
set id="ebd0a0a2-b9e5-4433-87c0-68b6b72699c7"
gpt attributes=0x0000000000000000
assign letter=o
rescan
exit
"@ | diskpart.exe
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloudRE partition"
    }
}