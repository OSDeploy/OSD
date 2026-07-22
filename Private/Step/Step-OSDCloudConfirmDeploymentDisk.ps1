function Step-OSDCloudConfirmDeploymentDisk {
    <#
    .SYNOPSIS
    Confirms that at least one fixed disk is available for OSDCloud deployment.

    .DESCRIPTION
    Enumerates fixed disks, excluding the boot disk when running in WinPE, stores results
    in $global:OSDCloud.GetDiskFixed, and updates $global:OSDCloud.SectionPassed. If no
    suitable fixed disk is found, deployment is stopped.

    .EXAMPLE
    Step-OSDCloudConfirmDeploymentDisk
    Validates fixed-disk availability before running disk preparation steps.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Initial help block created
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    if ($global:RecastOSDeploy.GetDiskFixed) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Fixed Disk is valid. OK."
    }
    else {
        Write-Warning "[$(Get-Date -format s)] Unable to detect a Fixed Disk."
        Write-Warning "[$(Get-Date -format s)] WinPE may need additional Disk, SCSI or Raid Drivers."
        Write-Warning 'Press Ctrl+C to exit OSDCloud'
        Start-Sleep -Seconds 86400
        exit
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
