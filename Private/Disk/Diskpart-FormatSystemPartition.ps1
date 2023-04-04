function Diskpart-FormatSystemPartition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$DiskNumber,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$PartitionNumber,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$FileSystem,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$LabelSystem
    )
    #Write-Warning "Format-Volume FileSystem NTFS NewFileSystemLabel $Label"
    #Format-Volume -ObjectId $PartitionSystem.ObjectId -FileSystem NTFS -NewFileSystemLabel "$Label" -Force -Confirm:$false

    Write-Verbose "DISKPART> select disk $DiskNumber"
    Write-Verbose "DISKPART> select partition $PartitionNumber"
    Write-Verbose "DISKPART> format fs=$FileSystem quick label='$LabelSystem'"
    Write-Verbose "DISKPART> assign letter=S"
    Write-Verbose "DISKPART> exit"
    
    #Abort if not in WinPE
    if ($env:SystemDrive -ne "X:") {Return}

$null = @"
select disk $DiskNumber
select partition $PartitionNumber
format fs=$FileSystem quick label="$LabelSystem"
assign letter=S
exit
"@ | diskpart.exe
}
