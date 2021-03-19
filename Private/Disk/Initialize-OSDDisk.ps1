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
function Initialize-OSDDisk {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object[]]$InputObject,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('F')]
        [switch]$Force
    )

    #=======================================================================
    #	OSD Module Information
    #=======================================================================
    $OSDVersion = $($MyInvocation.MyCommand.Module.Version)
    Write-Verbose "OSD $OSDVersion $($MyInvocation.MyCommand.Name)"
    #=======================================================================
    #	IsWinPE
    #=======================================================================
    if (-NOT (Get-OSDGather -Property IsWinPE)) {
        Write-Warning "WinPE is required for execution"
        Break
    }
    #=======================================================================
    #	IsAdmin
    #=======================================================================
    if (-NOT (Get-OSDGather -Property IsAdmin)) {
        Write-Warning "Administrative Rights are required for execution"
        Break
    }
    #=======================================================================
    #	PartitionStyle
    #=======================================================================
    if (Get-OSDGather -Property IsUEFI) {
        $PartitionStyle = 'GPT'
    } else {
        $PartitionStyle = 'MBR'
    }
    #=======================================================================
    #	Get Clear Disks
    #=======================================================================
    if ($InputObject) {
        $ClearDisks = $InputObject
    } else {
        $ClearDisks = Get-Disk.osd -BusTypeNot USB,Virtual -PartitionStyle RAW | `
        #Where-Object {($_.Size -gt 15GB)} | `
        Sort-Object Number
    }
    #=======================================================================
    #	Initialize-Disk
    #=======================================================================
    $InitializeOSDDisk = @()
    If ($ClearDisks) {
        if ($Force -eq $false) {
            Write-Host ""
            Write-Host "To Confirm Initialize-Disk on each of the following Disks, use the -Confirm -Force parameters"
            Write-Host "To Initialize-Disk ALL of the following Disks, use the -Force parameter"
            foreach ($Item in $ClearDisks) {
                Write-Host "Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.PartitionStyle)]" -ForegroundColor Green -BackgroundColor Black
            }
            Break
        }

        IF ($Force -EQ $true) {
            if ($ConfirmPreference -eq 'Low') {
                Write-Host ""
                Write-Warning "Confirm Initialize-Disk on each of the following Disks:"
                foreach ($Item in $ClearDisks) {
                    Write-Host "Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.PartitionStyle)]" -ForegroundColor Red -BackgroundColor Black
                }
                Write-Host ""
                Start-Sleep -Seconds 2
            }

            foreach ($Item in $ClearDisks) {
                if ($PSCmdlet.ShouldProcess("$PartitionStyle Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.PartitionStyle)]","Initialize-Disk")){
                    Write-Warning "Initializing Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.PartitionStyle)]"
                    $InitializeOSDDisk += $Item
                    Initialize-Disk -Number $Item.DiskNumber -PartitionStyle $PartitionStyle
                }
            }
            Return $InitializeOSDDisk
        } else {
            Write-Verbose "Disks are already initialized"
            Return $ClearDisks

        }
        #=======================================================================
    }
}