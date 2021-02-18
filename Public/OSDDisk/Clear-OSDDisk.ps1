<#
.SYNOPSIS
Clears all Local Disks for OS Deployment

.DESCRIPTION
Clears all Local Disks for OS Deployment
Before deploying an Operating System, it is important to clear all local disks
If this function is running from Windows, it will ALWAYS be in Sandbox mode, regardless of the -Force parameter

.PARAMETER Title
Title displayed during script execution
Default = Clear-OSDDisk
Alias = T

.PARAMETER Confirm
Required to confirm Clear-Disk

.PARAMETER Force
Sandbox mode is enabled by default to be non-destructive
This parameter will bypass Sandbox mode
Alias = F

.EXAMPLE
Clear-OSDDisk
Interactive = True
Sandbox     = True

.EXAMPLE
Clear-OSDDisk -Confirm
Interactive = True
Sandbox     = True

.EXAMPLE
Clear-OSDDisk -Force
Interactive = False
Sandbox     = False

.EXAMPLE
Clear-OSDDisk -Confirm -Force
Interactive = True
Sandbox     = False

.LINK
https://osd.osdeploy.com/module/osddisk/clear-osddisk

.NOTES
21.2.14     Initial Release
#>
function Clear-OSDDisk {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object[]]$InputObject,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('T')]
        [string]$Title = 'Clear-OSDDisk',

        [Parameter(ValueFromPipelineByPropertyName = $true)]
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
        #	IsWinPE
        #======================================================================================================
        if (-NOT (Get-OSDGather -Property IsWinPE)) {
            Write-Warning "WinPE is required for execution"
            Break
        }
        #======================================================================================================
        #	IsAdmin
        #======================================================================================================
        if (-NOT (Get-OSDGather -Property IsAdmin)) {
            Write-Warning "Administrative Rights are required for execution"
            Break
        }
        #======================================================================================================
        #	Get Dirty Disks
        #======================================================================================================
        $DirtyDisks = $null
        if ($InputObject) {
            $DirtyDisks = $InputObject
        } else {
            $DirtyDisks = Get-OSDDisk -BusTypeNot USB,Virtual -PartitionStyleNot RAW | `
            Where-Object {($_.Size -gt 15GB)} | `
            Sort-Object Number
        }
        #======================================================================================================
    }
    process {
        #======================================================================================================
        #	Clear-Disk
        #======================================================================================================
        $ClearOSDDisk = @()
        if ($DirtyDisks) {
            if ($Force -eq $false) {
                Write-Host ""
                Write-Host "To Confirm Clear-Disk on each of the following Disks, use the -Confirm -Force parameters"
                Write-Host "To Clear-Disk ALL of the following Disks, use the -Force parameter"
                foreach ($Item in $DirtyDisks) {
                    Write-Host "Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]" -ForegroundColor Green -BackgroundColor Black
                }
                Break
            }

            if ($Force -eq $true) {
                if ($ConfirmPreference -eq 'Low') {
                    Write-Host ""
                    Write-Host "Confirm Clear-Disk on each of the following Disks:"
                    foreach ($Item in $DirtyDisks) {
                        Write-Host "Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]" -ForegroundColor Red -BackgroundColor Black
                    }
                    Write-Host ""
                    Start-Sleep -Seconds 2
                }

                foreach ($Item in $DirtyDisks) {
                    if ($PSCmdlet.ShouldProcess("Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]","Clear-Disk")){
                        Write-Warning "Clearing Disk $($Item.Number) $($Item.BusType) $($Item.MediaType) $($Item.FriendlyName) [$($Item.PartitionStyle) $($Item.NumberOfPartitions) Partitions]"
                        $ClearOSDDisk += $Item
                        Diskpart-Clean -DiskNumber $Item.Number
                    }
                }
            }
            Return $ClearOSDDisk
        } else {
            Write-Verbose "Disks are already cleared"
            Return $DirtyDisks
        }
        #======================================================================================================
    }
    end {}
}