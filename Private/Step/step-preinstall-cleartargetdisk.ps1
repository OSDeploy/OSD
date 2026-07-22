function step-preinstall-cleartargetdisk {
    [CmdletBinding()]
    param (
        # We should always confirm to Clear-Disk as this is destructive
        [System.Boolean]
        $Confirm = $true
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    #region Main
    if ($global:OSDCloudDeploy.Force -eq $true) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Force was specified. Clear-Disk confirmation prompts are disabled"
        $Confirm = $false
    }

    # If Confirm is set to false, we need to check if there are multiple disks
    if (($Confirm -eq $false) -and ($global:OSDCloudDeploy.Force -ne $true) -and (($global:OSDCloudWorkflowInvoke.GetDiskFixed | Measure-Object).Count -ge 2)) {
        Write-Warning "[$(Get-Date -format s)] OSDCloud has detected more than 1 Fixed Disk is installed. Clear-Disk with Confirm is required"
        $Confirm = $true
    }

    Clear-DeviceLocalDisk -Force -NoResults -Confirm:$Confirm -ErrorAction Stop
    #endregion
    #=================================================
    $Message = "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    Write-Verbose -Message $Message; Write-Debug -Message $Message
    #=================================================
}
