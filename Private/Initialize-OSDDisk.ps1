function Initialize-OSDDisk {
    [CmdletBinding()]
    param (
        #Number of the Disk to prepare
        #Alias = Disk DiskNumber
        [Parameter(Position = 0)]
        [Alias('Disk','DiskNumber')]
        [int]$Number = 0
    )
    #======================================================================================================
    #	Initialize-OSDDisk
    #======================================================================================================
    if (Get-OSDGather IsUEFI) {
        Write-Verbose "Initialize-Disk Number $Number PartitionStyle GPT"
        Initialize-Disk -Number $Number -PartitionStyle GPT -ErrorAction SilentlyContinue
    } else {
        Write-Verbose "Initialize-Disk Number $Number PartitionStyle MBR"
        Initialize-Disk -Number $Number -PartitionStyle MBR -ErrorAction SilentlyContinue
    }
}