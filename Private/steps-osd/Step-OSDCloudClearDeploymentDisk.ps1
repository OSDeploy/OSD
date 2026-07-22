function Step-OSDCloudClearDeploymentDisk {
    [CmdletBinding()]
    param (
        # We should always confirm to Clear-Disk as this is destructive
        [System.Boolean]
        $Confirm = $true
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Skip. Not running in WinPE (X:)"
        return
    }
    #=================================================
    # If Confirm is set to false, we need to check if there are multiple disks
    if (($Confirm -eq $false) -and (($global:RecastOSDeploy.DeploymentDiskObject | Measure-Object).Count -ge 2)) {
        Write-Warning "[$(Get-Date -format s)] OSDCloud has detected more than 1 Fixed Disk is installed. Clear-Disk with Confirm is required"
        $Confirm = $true
    }

    Clear-DeviceLocalDisk -Force -NoResults -Confirm:$Confirm -ErrorAction Stop
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
