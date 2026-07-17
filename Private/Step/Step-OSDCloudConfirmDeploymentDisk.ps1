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
    # Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Confirm Fixed Disk Availability"
    #=================================================
    try {
        $allFixedDisks = @(Get-LocalDisk | Sort-Object Number)
    }
    catch {
        $Global:OSDCloud.GetDiskFixed = @()
        $Global:OSDCloud.SectionPassed = $false
        throw "[$(Get-Date -format s)] Unable to query fixed disks: $($_.Exception.Message)"
    }

    if ($env:SystemDrive -eq 'X:') {
        # In WinPE, skip the boot media disk so only deployable disks remain.
        $Global:OSDCloud.GetDiskFixed = @($allFixedDisks | Where-Object { $_.IsBoot -ne $true })
    }
    else {
        $Global:OSDCloud.GetDiskFixed = $allFixedDisks
    }

    $Global:OSDCloud.SectionPassed = [bool]($Global:OSDCloud.GetDiskFixed)

    if ($Global:OSDCloud.SectionPassed -eq $true) {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Done."
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Fixed Disks Detected:"
        foreach ($disk in $Global:OSDCloud.GetDiskFixed) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Disk Number: $($disk.Number), Friendly Name: $($disk.FriendlyName), Size: $([math]::Round($disk.Size/1GB,2)) GB, Media Type: $($disk.MediaType)"
        }
    }
    else {
        Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] OSDCloud Failed"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Unable to locate a fixed disk suitable for deployment."
        throw "[$(Get-Date -format s)] Unable to locate a Fixed Disk. You may need to add additional HDC Drivers to WinPE"
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
