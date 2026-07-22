function Step-OSDCloudPartitionDeploymentDisk {
    [CmdletBinding()]
    param (
        [Int32]
        $DiskNumber = $global:RecastOSDCloud.DeploymentDiskObject.DiskNumber
    )
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Skip. Not running in WinPE (X:)"
        return
    }
    #=================================================
    if ($global:OSDCoreDevice.IsVM -eq $true) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Recovery Partition will not be created. OK."
        New-OSDCloudDisk -PartitionStyle GPT -NoRecoveryPartition -Force -ErrorAction Stop
        Write-Host "=========================================================================" -ForegroundColor DarkCyan
        Write-Host "| SYSTEM | MSR |                    WINDOWS                             |" -ForegroundColor DarkCyan
        Write-Host "=========================================================================" -ForegroundColor DarkCyan
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] 2GB Recovery Partition will be created. OK."
        if ($DiskNumber) {
            New-OSDCloudDisk -PartitionStyle GPT -DiskNumber $DiskNumber -SizeRecovery 2000MB -Force -ErrorAction Stop
        }
        else {
            New-OSDCloudDisk -PartitionStyle GPT -SizeRecovery 2000MB -Force -ErrorAction Stop
        }
        Write-Host "=========================================================================" -ForegroundColor DarkCyan
        Write-Host "| SYSTEM | MSR |                    WINDOWS                  | RECOVERY |" -ForegroundColor DarkCyan
        Write-Host "=========================================================================" -ForegroundColor DarkCyan
    }
    Start-Sleep -Seconds 5

    # Make sure that there is a PSDrive
    if (!(Get-PSDrive -Name 'C')) {
        throw "[$(Get-Date -format s)] Failed to create a PSDrive FileSystem at C:\."
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
