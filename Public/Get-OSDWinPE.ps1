<#
.SYNOPSIS
Common WinPE Commands

.DESCRIPTION
Common WinPE Commands using wpeinit wpeutil and Microsoft DaRT RemoteRecovery

.PARAMETER PolicyBypass
Set-ExecutionPolicy Bypass

.PARAMETER InitializeNetwork
wpeutil InitializeNetwork

.PARAMETER InitializeNetworkNoWait
wpeutil InitializeNetwork /NoWait

.PARAMETER DisableFirewall
wpeutil DisableFirewall

.PARAMETER UpdateBootInfo
wpeutil UpdateBootInfo

.PARAMETER DartRemote
Requires Microsoft DaRT RemoteRecovery.exe

.PARAMETER Reboot
wpeutil Reboot

.PARAMETER Shutdown
wpeutil Shutdown

.EXAMPLE
OSDWinPE PolicyBypass; OSDWinPE InitializeNetwork; OSDWinPE DisableFirewall; OSDWinPE UpdateBootInfo; OSDWinPE DartRemote

.LINK
https://osd.osdeploy.com/module/functions/get-osdwinpe

.NOTES
19.9.29 Contributed by David Segura @SeguraOSD
#>
function Get-OSDWinPE {
    [CmdletBinding()]
    Param (
        [switch]$PolicyBypass,
        [switch]$InitializeNetwork,
        [switch]$InitializeNetworkNoWait,
        [switch]$DisableFirewall,
        [switch]$UpdateBootInfo,
        [switch]$DartRemote,
        [switch]$Reboot,
        [switch]$Shutdown
    )

    if (Get-OSDValue -Property IsWinPE) {
        Write-Verbose 'OSDWinPE: WinPE is running'
    } else {
        Write-Warning 'OSDWinPE: This function requires WinPE'
        Break
    }
    #======================================================================================================
    #	Customize: Increase the Console Screen Buffer size
    #======================================================================================================
    if (!(Test-Path "HKCU:\Console")) {
        Write-Host "OSDWinPE: Increase Console Screen Buffer" -ForegroundColor Gray
        New-Item -Path "HKCU:\Console" -Force | Out-Null
        New-ItemProperty -Path HKCU:\Console ScreenBufferSize -Value 589889656 -PropertyType DWORD -Force | Out-Null
    }
    if ($PolicyBypass.IsPresent) {
        Write-Verbose 'OSDWinPE: Set-ExecutionPolicy Bypass'
        PowerShell -Command "Set-ExecutionPolicy Bypass"
    }
    if ($InitializeNetwork.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil InitializeNetwork'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'InitializeNetwork' -Wait
        Start-Sleep -Seconds 10
    }
    if ($InitializeNetworkNoWait.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil InitializeNetwork /NoWait'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList ('InitializeNetwork','/NoWait')
    }
    if ($DisableFirewall.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil DisableFirewall'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'DisableFirewall' -Wait
    }
    if ($UpdateBootInfo.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil UpdateBootInfo'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'UpdateBootInfo'
    }
    if (($DartRemote.IsPresent) -and (Test-Path "$env:windir\System32\RemoteRecovery.exe")) {
        Write-Verbose 'OSDWinPE: Microsoft DaRT Remote Recovery'
        Start-Process -WindowStyle Minimized -FilePath RemoteRecovery.exe -ArgumentList '-nomessage'
    }
    if ($Reboot.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil Reboot'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'Reboot'
    }
    if ($Shutdown.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil Shutdown'
        Write-Verbose 'https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'Shutdown'
    }
}