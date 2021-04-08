<#
.SYNOPSIS
Clear-Disk on Fixed Disks

.DESCRIPTION
Clear-Disk on Fixed Disks
-DiskNumber: Single Disk execution
-Force: Required for execution
-Initialize: Initializes RAW as MBR or GPT PartitionStyle
-PartitionStyle: Overrides the automatic selection of MBR or GPT

.PARAMETER Input
Get-Disk.fixed Object

.PARAMETER DiskNumber
Specifies the disk number for which to get the associated Disk object
Alias = Disk, Number

.PARAMETER Force
Required for execution
Alias = F

.PARAMETER Initialize
Initializes the cleared disk as MBR or GPT
Alias = I

.PARAMETER PartitionStyle
Override the automatic Partition Style of the Initialized Disk
EFI Default = GPT
BIOS Default = MBR
Alias = PS

.EXAMPLE
Clear-Disk.fixed
Informational.  Executes Get-Help Clear-Disk.fixed
Always displayed if the -Force parameter is not used

.EXAMPLE
Clear-Disk.fixed -Force
Interactive.  Prompted to Confirm Clear-Disk for each Local Disk

.EXAMPLE
Clear-Disk.fixed -Force -Confirm:$false
Non-Interactive. Clears all Local Disks without being prompted to Confirm

.LINK
https://osd.osdeploy.com/module/functions/disk

.NOTES
21.3.3      Added SizeGB
21.2.22     Initial Release
#>
function Clear-Disk.fixed {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,

        [Alias('Disk','Number')]
        [uint32]$DiskNumber,

        [Alias('I')]
        [switch]$Initialize,

        [Alias('PS')]
        [ValidateSet('GPT','MBR')]
        [string]$PartitionStyle,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('F')]
        [switch]$Force,

        [switch]$NoResults,

        [Alias('W','Warn','Warning')]
        [switch]$ShowWarning
    )
    #=======================================================================
    #	PSBoundParameters
    #=======================================================================
    $IsConfirmPresent   = $PSBoundParameters.ContainsKey('Confirm')
    $IsForcePresent     = $PSBoundParameters.ContainsKey('Force')
    $IsVerbosePresent   = $PSBoundParameters.ContainsKey('Verbose')
    #=======================================================================
    #	Block
    #=======================================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    #=======================================================================
    #	Enable Verbose if Force parameter is not $true
    #=======================================================================
    if ($IsForcePresent -eq $false) {
        $VerbosePreference = 'Continue'
    }
    #=======================================================================
    #	Get-Disk
    #=======================================================================
    if ($Input) {
        $GetDisk = $Input
    } else {
        $GetDisk = Get-Disk.fixed | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number
    }
    #=======================================================================
    #	Get DiskNumber
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('DiskNumber')) {
        $GetDisk = $GetDisk | Where-Object {$_.DiskNumber -eq $DiskNumber}
    }
    #=======================================================================
    #	-PartitionStyle
    #=======================================================================
    if (-NOT ($PSBoundParameters.ContainsKey('PartitionStyle'))) {
        if (Get-OSDGather -Property IsUEFI) {
            Write-Verbose "IsUEFI = $true"
            $PartitionStyle = 'GPT'
        } else {
            Write-Verbose "IsUEFI = $false"
            $PartitionStyle = 'MBR'
        }
    }
    Write-Verbose "PartitionStyle = $PartitionStyle"
    #=======================================================================
    #	Get-Help
    #=======================================================================
    if ($IsForcePresent -eq $false) {
        Get-Help $($MyInvocation.MyCommand.Name)
    }
    #=======================================================================
    #	Display Disk Information
    #=======================================================================
    $GetDisk | Select-Object -Property DiskNumber, BusType,`
    @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
    FriendlyName,Model, PartitionStyle,`
    @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
    Format-Table | Out-Host
    
    if ($IsForcePresent -eq $false) {
        Break
    }
    #=======================================================================
    #	Display Warning
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('ShowWarning')) {
        Write-Warning "All data on the cleared Disk will be cleared and all data will be lost"
        pause
    }
    #=======================================================================
    #	Clear-Disk
    #=======================================================================
    $ClearDisk = @()
    foreach ($Item in $GetDisk) {
        if ($PSCmdlet.ShouldProcess(
            "Disk $($Item.Number) $($Item.BusType) $([int]($Item.Size / 1000000000))GB $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]",
            "Clear-Disk"
        ))
        {
            Write-Warning "Cleaning Disk $($Item.Number) $($Item.BusType) $([int]($Item.Size / 1000000000))GB $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]"
            Diskpart-Clean -DiskNumber $Item.Number

            if ($Initialize -eq $true) {
                Write-Warning "Initializing $PartitionStyle Disk $($Item.Number) $($Item.BusType) $([int]($Item.Size / 1000000000))GB $($Item.FriendlyName)"
                $Item | Initialize-Disk -PartitionStyle $PartitionStyle
            }
            
            $ClearDisk += Get-Disk.osd -Number $Item.Number
        }
    }
    #=======================================================================
    #	Return
    #=======================================================================
    if ($PSBoundParameters.ContainsKey('NoResults')) {
        #Don't return results
    }
    else {
        $ClearDisk | Select-Object -Property DiskNumber, BusType,`
        @{Name='SizeGB';Expression={[int]($_.Size / 1000000000)}},`
        FriendlyName, Model, PartitionStyle,`
        @{Name='Partitions';Expression={$_.NumberOfPartitions}} | `
        Format-Table | Out-Host
    }
    #=======================================================================
}