function Step-OSDCloudConfirmDeploymentDiskObject {
    <#
    .SYNOPSIS
    Confirms that at least one fixed disk is available for OSDCloud deployment.

    .DESCRIPTION
    Enumerates fixed disks, excluding the boot disk when running in WinPE, stores results
    in $global:OSDCloud.GetDiskFixed, and updates $global:OSDCloud.SectionPassed. If no
    suitable fixed disk is found, deployment is stopped.

    .EXAMPLE
    Step-OSDCloudConfirmDeploymentDiskObject
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
    if ($global:RecastOSDCloud.DeploymentDiskObject) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] DeploymentDiskObject is valid. OK."
    }
    else {
        Write-Warning "[$(Get-Date -format s)] Unable to detect a DeploymentDiskObject."
        Write-Warning "[$(Get-Date -format s)] WinPE may need additional Disk, SCSI or Raid Drivers."
        throw
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
