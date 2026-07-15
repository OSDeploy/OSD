function Step-OSDCloudVerifyDisk {
    <#
    .SYNOPSIS
    Verifies that at least one fixed disk is available for OSDCloud deployment.

    .DESCRIPTION
    Enumerates fixed disks, excluding the boot disk when running in WinPE, stores results
    in $Global:OSDCloud.GetDiskFixed, and updates $Global:OSDCloud.SectionPassed. If no
    suitable fixed disk is found, deployment is stopped.

    .EXAMPLE
    Step-OSDCloudVerifyDisk
    Validates fixed-disk availability before running disk preparation steps.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Initial help block created
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-SectionHeader 'Validate Fixed Disks'
    $Global:OSDCloud.SectionPassed = $false
    if ($env:SystemDrive -ne 'X:') {
        $Global:OSDCloud.GetDiskFixed = Get-LocalDisk | Sort-Object Number
    }
    else {
        $Global:OSDCloud.GetDiskFixed = Get-LocalDisk | Where-Object {$_.IsBoot -eq $false} | Sort-Object Number
    }

    if ($Global:OSDCloud.GetDiskFixed) {
        $Global:OSDCloud.SectionPassed = $true
    }
    else {
        $Global:OSDCloud.SectionPassed = $false
    }

    if ($Global:OSDCloud.SectionPassed -eq $false) {
        Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] OSDCloud Failed"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Unable to locate a Fixed Disk. You may need to add additional HDC Drivers to WinPE"
        Write-Host -ForegroundColor Yellow "[$(Get-Date -format s)] Press Ctrl+C to exit"
        Start-Sleep -Seconds 86400
        Exit
    }
    else {
        #Write-SectionSuccess
    }
    #=================================================
}
