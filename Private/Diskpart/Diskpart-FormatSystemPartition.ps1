function Diskpart-FormatSystemPartition {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$DiskNumber,

        [Parameter(Position = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$PartitionNumber,

        [Parameter(Position = 2, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$FileSystem,

        [Parameter(Position = 3, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$LabelSystem,

        [Parameter(Position = 4, ValueFromPipelineByPropertyName = $true)]
        [string]$NewDriveLetter = 'S'
    )
    #Write-Warning "Format-Volume FileSystem NTFS NewFileSystemLabel $Label"
    #Format-Volume -ObjectId $PartitionSystem.ObjectId -FileSystem NTFS -NewFileSystemLabel "$Label" -Force -Confirm:$false

    Write-Verbose "DISKPART> select disk $DiskNumber"
    Write-Verbose "DISKPART> select partition $PartitionNumber"
    Write-Verbose "DISKPART> format fs=$FileSystem quick label='$LabelSystem'"
    Write-Verbose "DISKPART> assign letter s"
    Write-Verbose "DISKPART> exit"
    
    #Abort if not in WinPE
    if ($env:SystemDrive -ne "X:") {Return}

$null = @"
select disk $DiskNumber
select partition $PartitionNumber
format fs=$FileSystem quick label="$LabelSystem"
assign letter $NewDriveLetter
exit
"@ | diskpart.exe
}