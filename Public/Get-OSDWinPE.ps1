<#
.SYNOPSIS
Common WinPE Commands using wpeutil and Microsoft DaRT RemoteRecovery

.DESCRIPTION
Common WinPE Commands using wpeutil and Microsoft DaRT RemoteRecovery

.PARAMETER ImportModules
Copies PowerShell Modules found in <drive>:\Modules to System32 Modules

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
Version:
19.9.29 David Segura @SeguraOSD

Reference:
https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeutil-command-line-options
#>
function Get-OSDWinPE {
    [CmdletBinding()]
    Param (
        [switch]$ImportModules,
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
        Write-Verbose "OSDWinPE: Increase Console Screen Buffer"
        New-Item -Path "HKCU:\Console" -Force | Out-Null
        New-ItemProperty -Path HKCU:\Console ScreenBufferSize -Value 589889656 -PropertyType DWORD -Force | Out-Null
    }
    #======================================================================================================
    #	Import Root Modules
    #======================================================================================================
    if ($ImportModules.IsPresent) {
        $OSDSearchDrives = Get-PSDrive -PSProvider 'FileSystem'
        foreach ($OSDSearchDrive in $OSDSearchDrives) {
            $OSDSearchPath = "$($OSDSearchDrive.Root)Modules"
            if (Test-Path "$OSDSearchPath") {
                Write-Verbose "OSDSearchPath: $OSDSearchPath" -Verbose
                Get-ChildItem "$OSDSearchPath" | `
                Where-Object {$_.PSIsContainer} | `
                ForEach-Object {
                    Write-Verbose "ImportModules: $($_.FullName)"
                    Copy-Item -Path "$($_.FullName)" -Destination "$env:SystemDrive\Windows\System32\WindowsPowerShell\v1.0\Modules" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }
    #======================================================================================================
    #	wpeutil
    #======================================================================================================
    if ($InitializeNetwork.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil InitializeNetwork'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'InitializeNetwork' -Wait
        Start-Sleep -Seconds 10
    }
    if ($InitializeNetworkNoWait.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil InitializeNetwork /NoWait'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList ('InitializeNetwork','/NoWait')
    }
    if ($DisableFirewall.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil DisableFirewall'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'DisableFirewall' -Wait
    }
    if ($UpdateBootInfo.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil UpdateBootInfo'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'UpdateBootInfo'
    }
    if ($Reboot.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil Reboot'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'Reboot'
    }
    if ($Shutdown.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil Shutdown'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'Shutdown'
    }
    #======================================================================================================
    #	Microsoft DaRT
    #======================================================================================================
    if (($DartRemote.IsPresent) -and (Test-Path "$env:windir\System32\RemoteRecovery.exe")) {
        Write-Verbose 'OSDWinPE: Microsoft DaRT Remote Recovery'
        Start-Process -WindowStyle Minimized -FilePath RemoteRecovery.exe -ArgumentList '-nomessage'
    }
}