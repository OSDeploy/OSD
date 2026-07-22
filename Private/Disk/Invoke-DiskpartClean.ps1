function Invoke-DiskpartClean {
    <#
    .SYNOPSIS
    Cleans a disk by using DiskPart in WinPE.

    .DESCRIPTION
    The Invoke-DiskpartClean function runs a DiskPart clean operation against the specified disk number.
    This helper is intended for WinPE scenarios where Clear-Disk can be unreliable, especially in virtual machines.
    The function logs the DiskPart commands with verbose output, exits without action outside WinPE, and then runs
    DiskPart with select disk, clean, and exit commands.

    .PARAMETER DiskNumber
    Specifies the disk number to select and clean with DiskPart.

    .EXAMPLE
    Invoke-DiskpartClean -DiskNumber 0

    Cleans disk 0 when running in WinPE.

    .EXAMPLE
    Invoke-DiskpartClean -DiskNumber 1 -Verbose

    Displays the DiskPart commands that will be run, then cleans disk 1 when running in WinPE.

    .NOTES
    This function only performs the clean operation when the system drive is X:, indicating WinPE.
    DiskPart clean removes partition information from the selected disk.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$DiskNumber
    )
    #Virtual Machines have issues using PowerShell for Clear-Disk
    #$OSDDisk | Clear-Disk -RemoveOEM -RemoveData -Confirm:$true -PassThru -ErrorAction SilentlyContinue | Out-Null

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> select disk $DiskNumber"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> clean"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DISKPART> exit"

    #Abort if not in WinPE
    if ($env:SystemDrive -ne "X:") {Return}

$null = @"
select disk $DiskNumber
clean
exit 
"@ | diskpart.exe
}
