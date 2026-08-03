function Get-FirstAvailableDriveLetter {
    param()

    $GetVolume = Get-Volume
    # Get all available drive letters, and store in a temporary variable.
    $UsedDriveLetters = @($GetVolume | % { "$([char]$_.DriveLetter)"}) + @(Get-WmiObject -Class Win32_MappedLogicalDisk | %{$([char]$_.DeviceID.Trim(':'))})
    $TempDriveLetters = @(Compare-Object -DifferenceObject $UsedDriveLetters -ReferenceObject $( 67..90 | % { "$([char]$_)" } ) | ? { $_.SideIndicator -eq '<=' } | % { $_.InputObject })

    # For completeness, sort the output alphabetically
    $AvailableDriveLetter = ($TempDriveLetters | Sort-Object)
    $AvailableDriveLetter[0]
}
function Get-LastAvailableDriveLetter {
    param()

    $GetVolume = Get-Volume
    # Get all available drive letters, and store in a temporary variable.
    $UsedDriveLetters = @($GetVolume | % { "$([char]$_.DriveLetter)"}) + @(Get-WmiObject -Class Win32_MappedLogicalDisk | %{$([char]$_.DeviceID.Trim(':'))})
    $TempDriveLetters = @(Compare-Object -DifferenceObject $UsedDriveLetters -ReferenceObject $( 67..90 | % { "$([char]$_)" } ) | ? { $_.SideIndicator -eq '<=' } | % { $_.InputObject })

    # For completeness, sort the output alphabetically
    $AvailableDriveLetter = ($TempDriveLetters | Sort-Object -Descending)
    $AvailableDriveLetter[0]
}
function Invoke-DiskpartClean {
    <#
    .SYNOPSIS
    Cleans a disk by using DiskPart in WinPE.

    .DESCRIPTION
    Selects the specified disk and runs DiskPart clean from WinPE.
    This helper is intended for deployment scenarios where Clear-Disk can be unreliable, especially in virtual
    machines. It writes the exact DiskPart commands to verbose output and exits without action when the system is
    not running from X:.

    .PARAMETER DiskNumber
    Disk number to select and clean with DiskPart.

    .EXAMPLE
    Invoke-DiskpartClean -DiskNumber 0

    Cleans disk 0 when running in WinPE.

    .EXAMPLE
    Invoke-DiskpartClean -DiskNumber 1 -Verbose

    Displays the DiskPart commands that will be run, then cleans disk 1 when running in WinPE.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-21 - Refreshed help and verbose tracing for DiskPart clean
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$DiskNumber
    )
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Starting disk clean workflow for disk $DiskNumber"

    #Virtual Machines have issues using PowerShell for Clear-Disk
    #$OSDDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$true -PassThru -ErrorAction SilentlyContinue | Out-Null

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> select disk $DiskNumber"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> clean"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> exit"

    #Abort if not in WinPE
    if ($env:SystemDrive -ne "X:") {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Skipping disk clean because the system drive is not X:"
        return
    }

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Invoking DiskPart clean on disk $DiskNumber"

$null = @"
select disk $DiskNumber
clean
exit 
"@ | diskpart.exe
}
function Invoke-DiskpartFormatSystemPartition {
    <#
    .SYNOPSIS
    Formats a system partition by using DiskPart in WinPE.

    .DESCRIPTION
    Selects the requested disk and partition, then quick-formats it with DiskPart.
    This helper is intended for WinPE deployment scenarios and exits without action when the system is not
    running from X:. The function writes the exact DiskPart commands to verbose output before running them.

    .PARAMETER DiskNumber
    DiskPart disk number that contains the system partition to format.

    .PARAMETER PartitionNumber
    DiskPart partition number to format on the selected disk.

    .PARAMETER FileSystem
    File system to apply to the selected partition.

    .PARAMETER LabelSystem
    Volume label to assign during the DiskPart format operation.

    .EXAMPLE
    Invoke-DiskpartFormatSystemPartition -DiskNumber 0 -PartitionNumber 1 -FileSystem FAT32 -LabelSystem System

    Formats partition 1 on disk 0 as FAT32 with the label System when running in WinPE.

    .EXAMPLE
    Invoke-DiskpartFormatSystemPartition -DiskNumber 0 -PartitionNumber 2 -FileSystem NTFS -LabelSystem Windows -Verbose

    Displays the DiskPart commands that will be run, then formats partition 2 on disk 0 as NTFS with the label Windows when running in WinPE.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-21 - Refreshed help and verbose tracing for DiskPart format
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

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Starting system partition format workflow for disk $DiskNumber partition $PartitionNumber"

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> select disk $DiskNumber"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> select partition $PartitionNumber"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> format fs=$FileSystem quick label='$LabelSystem'"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> exit"

    #Abort if not in WinPE
    if ($env:SystemDrive -ne "X:") {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Skipping system partition format because the system drive is not X:"
        return
    }

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Invoking DiskPart format on disk $DiskNumber partition $PartitionNumber"

$null = @"
select disk $DiskNumber
select partition $PartitionNumber
format fs=$FileSystem quick label="$LabelSystem"
exit
"@ | diskpart.exe
}
