function Step-OSDCloudRestoreUSBDriveLetter {
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    #region Main
    if ($global:OSDCoreDevice.USBPartitions) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Restoring USB Drive Letters. OK."
        foreach ($Item in $global:OSDCoreDevice.USBPartitions) {
            $Params = @{
                AssignDriveLetter = $true
                DiskNumber        = $Item.DiskNumber
                PartitionNumber   = $Item.PartitionNumber
                ErrorAction       = 'SilentlyContinue'
            }
            if ($env:SystemDrive -eq'X:') {
                Add-PartitionAccessPath @Params
            }
            Start-Sleep -Seconds 5
        }
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
