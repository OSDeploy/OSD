function step-preinstall-partitiontargetdisk {
    [CmdletBinding()]
    param (
        [System.String]
        $RecoveryPartitionForce = $global:OSDCloudWorkflowInvoke.RecoveryPartition.Force,

        [System.String]
        $RecoveryPartitionSkip = $global:OSDCloudWorkflowInvoke.RecoveryPartition.Skip,

        [Int32]
        $DiskNumber = $global:OSDCloudWorkflowInvoke.DiskPartition.DiskNumber
    )
    #=================================================
    $Message = "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Debug -Message $Message; Write-Verbose -Message $Message
    $Step = $global:OSDCloudCurrentStep
    #=================================================
    #region Main
    # Mental Math
    $RecoveryPartition = $true
    if ($IsVM -eq $true) { $RecoveryPartition = $false }
    if ($RecoveryPartitionSkip) { $RecoveryPartition = $false }
    if ($RecoveryPartitionForce) { $RecoveryPartition = $true }

    if ($RecoveryPartition -eq $false) {
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
        Write-Warning "[$(Get-Date -format s)] Failed to create a PSDrive FileSystem at C:\."
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Press Ctrl+C to exit OSDCloud"
        Start-Sleep -Seconds 86400
        exit
    }
    #endregion
    #=================================================
    $Message = "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    Write-Verbose -Message $Message; Write-Debug -Message $Message
    #=================================================
}