function Step-OSDCloudNewDisk {
    <#
    .SYNOPSIS
    Creates the target operating system disk layout for OSDCloud deployment.

    .DESCRIPTION
    Executes New-OSDisk logic using either DiskPart or standard partition creation,
    supports optional recovery partition skipping and explicit target disk selection,
    validates that C: exists afterward, and captures debug disk state when enabled.

    .EXAMPLE
    Step-OSDCloudNewDisk
    Creates new partitions based on current OSDCloud settings.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Initial help block created
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    # Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Skip. Not running in WinPE (X:)"
        return
    }
    #=================================================
    # New Partitions will be created using Microsoft Standard Layout
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] New-OSDisk"
    if ($Global:OSDCloud.SkipNewOSDisk -eq $false) {
        if ($Global:OSDCloud.DebugMode -eq $true){
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Capturing Disk Information Pre Modifications"
            $OSDISKPre = (Get-OSDGather -Full).DiskPartition
        }
        # Uses DiskPart instead of PS to create partitions, I think I'm going to depricate this soon.
        if ($Global:OSDCloud.DiskPart -eq $true) {
            Start-OSDDiskPart
            Write-Host "=========================================================================" -ForegroundColor Cyan
            Write-Host "| SYSTEM | MSR |                    WINDOWS                  | RECOVERY |" -ForegroundColor Cyan
            Write-Host "=========================================================================" -ForegroundColor Cyan
            $LocalVolumes = Get-Volume | Where-Object {$_.DriveType -eq "Fixed"}
            Write-Output $LocalVolumes
        }
        else {
            if ($Global:OSDCloud.SkipRecoveryPartition -eq $true) {
                New-OSDisk -PartitionStyle GPT -NoRecoveryPartition -Force -ErrorAction Stop
                Write-Host "=========================================================================" -ForegroundColor Cyan
                Write-Host "| SYSTEM | MSR |                    WINDOWS                             |" -ForegroundColor Cyan
                Write-Host "=========================================================================" -ForegroundColor Cyan
            }
            else {
                if ($Null -ne $Global:OSDCloud.OSInstallDiskNumber){
                    New-OSDisk -PartitionStyle GPT -DiskNumber $Global:OSDCloud.OSInstallDiskNumber -Force -ErrorAction Stop
                }
                else {New-OSDisk -PartitionStyle GPT -Force -ErrorAction Stop}

                Write-Host "=========================================================================" -ForegroundColor Cyan
                Write-Host "| SYSTEM | MSR |                    WINDOWS                  | RECOVERY |" -ForegroundColor Cyan
                Write-Host "=========================================================================" -ForegroundColor Cyan
                #Wait a few seconds to make sure the Disk is set
                Start-Sleep -Seconds 5
            }
        }

        #Make sure that there is a PSDrive
        if (-NOT (Get-PSDrive -Name 'C')) {
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] OSDCloud Failed"
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] New-OSDisk didn't work. There is no PSDrive FileSystem at C:\"
            Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] Press Ctrl+C to exit"
            Start-Sleep -Seconds 86400
            Exit
        }
        if ($Global:OSDCloud.DebugMode -eq $true){
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Capturing Disk Information Post Modifications"
            $OSDISKPost = (Get-OSDGather -Full).DiskPartition
        }
    }
    #=================================================
}
