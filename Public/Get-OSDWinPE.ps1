function Get-OSDWinPE {
    [CmdletBinding()]
    Param (
        [switch]$DisableFirewall,
        [switch]$EnableFirewall,
        [switch]$InitializeNetwork,
        [switch]$InitializeNetworkNoWait,
        [switch]$Reboot,
        [switch]$Shutdown,
        [switch]$UpdateBootInfo
    )

    if ($env:SystemDrive -eq 'X:') {
        Write-Verbose 'OSDWinPE: WinPE is running'
    } else {
        Write-Warning 'OSDWinPE: This function requires WinPE'
        Break
    }
    if ($UpdateBootInfo.IsPresent) {
        Write-Verbose 'wpeutil UpdateBootInfo'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'UpdateBootInfo'
    }
    if ($InitializeNetwork.IsPresent) {
        Write-Verbose 'wpeinit InitializeNetwork'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeinit -ArgumentList 'InitializeNetwork' -Wait
        Start-Sleep -Seconds 10
    }
    if ($InitializeNetworkNoWait.IsPresent) {
        Write-Verbose 'wpeutil InitializeNetwork /NoWait'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeinit -ArgumentList ('InitializeNetwork','/NoWait')
    }
    if ($DisableFirewall.IsPresent) {
        Write-Verbose 'wpeutil DisableFirewall'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'DisableFirewall' -Wait
    }
    if ($EnableFirewall.IsPresent) {
        Write-Verbose 'wpeutil EnableFirewall'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'DisableFirewall' -Wait
    }
    if ($Reboot.IsPresent) {
        Write-Verbose 'wpeutil Reboot'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'Reboot'
    }
    if ($Shutdown.IsPresent) {
        Write-Verbose 'wpeutil Shutdown'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'Shutdown'
    }
}