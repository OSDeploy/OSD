function Start-OSDWinPE {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0)]
        [ValidateSet(`
            'DisableFirewall',`
            'EnableFirewall',`
            'InitializeNetwork',`
            'InitializeNetwork NoWait',`
            'Reboot',`
            'Shutdown',`
            'UpdateBootInfo'`
        )]
        [string]$Action
    )

    if ($env:SystemDrive -eq 'X:') {
        Write-Verbose 'OSDWinPE: WinPE is running'
    } else {
        Write-Warning 'OSDWinPE: This function requires WinPE'
        Break
    }

    if ($Action -eq 'DisableFirewall') {
        Write-Verbose 'wpeutil DisableFirewall'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'DisableFirewall' -Wait
    }

    if ($Action -eq 'EnableFirewall') {
        Write-Verbose 'wpeutil EnableFirewall'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'DisableFirewall' -Wait
    }

    if ($Action -eq 'InitializeNetwork') {
        Write-Verbose 'wpeinit InitializeNetwork'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeinit -ArgumentList 'InitializeNetwork' -Wait
        Start-Sleep -Seconds 10
    }

    if ($Action -eq 'InitializeNetwork NoWait') {
        Write-Verbose 'wpeutil InitializeNetwork /NoWait'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeinit -ArgumentList ('InitializeNetwork','/NoWait')
    }

    if ($Action -eq 'Reboot') {
        Write-Verbose 'wpeutil Reboot'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'Reboot'
    }

    if ($Action -eq 'Shutdown') {
        Write-Verbose 'wpeutil Shutdown'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'Shutdown'
    }

    if ($Action -eq 'UpdateBootInfo') {
        Write-Verbose 'wpeutil UpdateBootInfo'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'UpdateBootInfo'
    }
}