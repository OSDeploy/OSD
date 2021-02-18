<#
.SYNOPSIS
Initializes any RAW Disks.  Automatically selects GPT or MBR

.DESCRIPTION
Initializes any RAW Disks.  Automatically selects GPT or MBR

.EXAMPLE
Initialize-OSDDisk
Interactive = True
Sandbox     = True

.EXAMPLE
Initialize-OSDDisk -Confirm
Interactive = True
Sandbox     = True

.EXAMPLE
Initialize-OSDDisk -Force
Interactive = False
Sandbox     = False

.EXAMPLE
Initialize-OSDDisk -Confirm -Force
Interactive = True
Sandbox     = False

.LINK
https://osd.osdeploy.com/module/osddisk/initialize-osddisk

.NOTES
21.2.14     Initial Release
#>
function New-OSDPartition {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('T')]
        [string]$Title = 'New-OSDPartition',

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('F')]
        [switch]$Force
    )

    begin {
        #======================================================================================================
        #	OSD Module Information
        #======================================================================================================
        $OSDVersion = $($MyInvocation.MyCommand.Module.Version)
        Write-Verbose "OSD $OSDVersion $Title"
        #======================================================================================================
        #	Set Defaults
        #======================================================================================================
        $GetOSDDisk = $null
        $Sandbox = $true
        #======================================================================================================
        #	Get all Fixed Disks larger than 15GB
        #======================================================================================================
        $GetOSDDisk = Get-OSDDisk -BusTypeNot USB,Virtual -PartitionStyleNot RAW | `
        Where-Object {($_.Size -gt 15GB)} | `
        Sort-Object Number
        #======================================================================================================
        #	No Fixed Disks
        #======================================================================================================
        if ($null -eq $GetOSDDisk) {
            Write-Verbose "0 fixed disks are present"
            Return $null
        }
        #======================================================================================================
        #	Get RAW Disks
        #======================================================================================================
        $RawDisks = $GetOSDDisk | Where-Object {$_.PartitionStyle -eq 'RAW'}
        #======================================================================================================
        #	No RAW Disks
        #======================================================================================================
        if ($null -eq $RawDisks) {
            Write-Verbose "No fixed disks need to be initialized"
            Return $null
        }
        #======================================================================================================
        #	Force Validation
        #======================================================================================================
        if ($Force.IsPresent) {$Sandbox = $false}
        #======================================================================================================
        #	IsWinPE
        #======================================================================================================
        if (-NOT (Get-OSDGather -Property IsWinPE)) {
            Write-Warning "WinPE is required for execution"
            $Sandbox = $true
        }
        #======================================================================================================
        #	IsAdmin
        #======================================================================================================
        if (-NOT (Get-OSDGather -Property IsAdmin)) {
            Write-Warning "Administrative Rights are required for execution"
            $Sandbox = $true
        }
        #======================================================================================================
        #	PartitionStyle
        #======================================================================================================
        if (Get-OSDGather -Property IsUEFI) {
            $PartitionStyle = 'GPT'
        } else {
            $PartitionStyle = 'MBR'
        }
        #======================================================================================================
        #	Sandbox
        #======================================================================================================
        if ($Sandbox -eq $true) {
            Write-Warning "$Title is running in Sandbox (non-desctructive)"
            Write-Warning "Disks will not be initialized while in Sandbox"
            Write-Warning "-Force parameter is required to bypass Sandbox"
            Write-Warning "-Confirm parameter is enabled in Sandbox"
            $ConfirmPreference = 'Low'
        }
        #======================================================================================================
    }
    process {
        #======================================================================================================
        #	Initialize-Disk
        #======================================================================================================
        Write-Warning "The"


        foreach ($item in $RawDisks) {
            Write-Host "Initialize-Disk $PartitionStyle on target Disk $($item.Number) $($item.BusType) $($item.FriendlyName) [$($item.PartitionStyle)]" -ForegroundColor Yellow

            if ($PSCmdlet.ShouldProcess("$PartitionStyle Disk $($item.Number) $($item.BusType) $($item.FriendlyName) [$($item.PartitionStyle)]","Initialize-Disk")){
                Write-Warning "$($item.Number) $($item.BusType) $($item.FriendlyName) [$($item.PartitionStyle)] ... Initializing Disk"
                if ($Sandbox -eq $false) {
                    Initialize-Disk -Number $item.DiskNumber -PartitionStyle $PartitionStyle
                }
            }
        }
        #======================================================================================================
    }
    end {Return $null}
}