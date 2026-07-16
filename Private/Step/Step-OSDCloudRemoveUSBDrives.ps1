function Step-OSDCloudRemoveUSBDrives {
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    if ($global:OSDCoreDevice.USBPartitions) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Removing USB Drive Letters. OK."
        foreach ($Item in $global:OSDCoreDevice.USBPartitions) {
            $Params = @{
                AccessPath      = "$($Item.DriveLetter):"
                DiskNumber      = $Item.DiskNumber
                PartitionNumber = $Item.PartitionNumber
                ErrorAction     = 'SilentlyContinue'
            }
            if ($env:SystemDrive -eq'X:') {
                Remove-PartitionAccessPath @Params
            }
            Start-Sleep -Seconds 3
        }
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
