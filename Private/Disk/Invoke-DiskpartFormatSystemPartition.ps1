function Invoke-DiskpartFormatSystemPartition {
    <#
    .SYNOPSIS
    Formats a system partition by using DiskPart in WinPE.

    .DESCRIPTION
    The Invoke-DiskpartFormatSystemPartition function selects the specified disk and partition, then formats
    the partition with the requested file system and volume label by using DiskPart. This helper is intended
    for WinPE deployment scenarios and exits without action outside WinPE.

    .PARAMETER DiskNumber
    Specifies the DiskPart disk number that contains the system partition to format. The function uses this
    value in the DiskPart select disk command before selecting and formatting the target partition.

    .PARAMETER PartitionNumber
    Specifies the DiskPart partition number to format on the selected disk. The function uses this value in
    the DiskPart select partition command before running the quick format operation.

    .PARAMETER FileSystem
    Specifies the file system to apply to the selected partition. This value is passed to DiskPart as the
    format fs value, such as FAT32 for an EFI system partition or NTFS for a Windows system partition.

    .PARAMETER LabelSystem
    Specifies the volume label to assign during the DiskPart format operation. This value is passed to
    DiskPart as the label value and becomes the formatted partition's volume label.

    .EXAMPLE
    Invoke-DiskpartFormatSystemPartition -DiskNumber 0 -PartitionNumber 1 -FileSystem FAT32 -LabelSystem System

    Formats partition 1 on disk 0 as FAT32 with the label System when running in WinPE.

    .EXAMPLE
    Invoke-DiskpartFormatSystemPartition -DiskNumber 0 -PartitionNumber 2 -FileSystem NTFS -LabelSystem Windows -Verbose

    Displays the DiskPart commands that will be run, then formats partition 2 on disk 0 as NTFS with the label Windows when running in WinPE.

    .NOTES
    This function only performs the format operation when the system drive is X:, indicating WinPE.
    DiskPart format replaces the file system on the selected partition.
    #>
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

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> select disk $DiskNumber"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> select partition $PartitionNumber"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> format fs=$FileSystem quick label='$LabelSystem'"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> exit"

    #Abort if not in WinPE
    if ($env:SystemDrive -ne "X:") {Return}

$null = @"
select disk $DiskNumber
select partition $PartitionNumber
format fs=$FileSystem quick label="$LabelSystem"
exit
"@ | diskpart.exe
}
