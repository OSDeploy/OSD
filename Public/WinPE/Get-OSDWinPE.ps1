<#
.SYNOPSIS
Common WinPE Commands using wpeutil and Microsoft DaRT RemoteRecovery

.DESCRIPTION
Common WinPE Commands using wpeutil and Microsoft DaRT RemoteRecovery

.LINK
https://osd.osdeploy.com/module/functions/winpe/get-osdwinpe

.NOTES
19.10.1     David Segura @SeguraOSD
#>
function Get-OSDWinPE {
    [CmdletBinding()]
    param (
        #Find and Copy PowerShell Modules to WinPE
        #Searches all PSDrives for <drive>:\Modules directory
        #Searches all PSDrives for <drive>:\Content\Modules directory
        #Copies Modules to X:\Program Files\WindowsPowerShell\Modules
        [Alias('Modules','AddModules')]
        [System.Management.Automation.SwitchParameter]$GetModules,

        #Find and Run PowerShell Scripts
        #Searches all PSDrives for <drive>:\<$GetScript>
        #Searches all PSDrives for <drive>:\Content\Scripts\<$GetScript>
        #Calls found scripts in the current PS Session
        [Alias('Script','CallScript')]
        [string[]]$GetScripts,

        #wpeutil InitializeNetwork
        #Initializes network components and drivers and sets the computer name to a randomly-chosen value
        [Alias('Network')]
        [System.Management.Automation.SwitchParameter]$InitializeNetwork,

        #wpeutil InitializeNetwork /NoWait
        #Initializes network components and drivers and sets the computer name to a randomly-chosen value
        #The /NoWait option will skip the time where your PC would otherwise wait to acquire an IP address
        #If you don't use /NoWait, Windows PE will wait to acquire an address before it finishes loading your WinPE session
        #/NoWait is helpful for environments that don't use DHCP
        [Alias('NetworkNoWait')]
        [System.Management.Automation.SwitchParameter]$InitializeNetworkNoWait,

        #wpeutil WaitForNetwork
        #Waits for the network card to be initialized
        #Use this command when creating scripts to make sure that the network card has been fully initialized before continuing
        [Alias('WaitNetwork')]
        [System.Management.Automation.SwitchParameter]$WaitForNetwork,

        #wpeutil WaitForRemovableStorage
        #During the Windows PE startup sequence, this command will block startup until the removable storage devices, such as USB hard drives, are initialized
        [Alias('WaitUSB')]
        [System.Management.Automation.SwitchParameter]$WaitForRemovableStorage,

        #wpeutil DisableFirewall
        #Disables the Firewall
        [Alias('Disable')]
        [System.Management.Automation.SwitchParameter]$DisableFirewall,

        #wpeutil UpdateBootInfo
        #Populates the registry with information about how Windows PE boots
        #After you run this command, query the registry. For example:
        #reg query HKLM\System\CurrentControlSet\Control /v PEBootType
        #The results of this operation might change after loading additional driver support.
        #To determine where Windows PE is booted from, examine the following:
        #   PEBootType: Error, Flat, Remote, Ramdisk:SourceIdentified Ramdisk:SourceUnidentified, Ramdisk:OpticalDrive
        #   PEBootTypeErrorCode: HRESULT code
        #   PEBootServerName: Windows Deployment Services server name
        #   PEBootServerAddr: Windows Deployment Services server IP address
        #   PEBootRamdiskSourceDrive: Source drive letter, if available.
        #   PEFirmwareType: Firmware boot mode: 0x1 for BIOS, 0x2 for UEFI.
        #If you are not booting Windows Deployment Services, the best way to determine where Windows PE booted from is to first check for PEBootRamdiskSourceDrive registry key
        #If it is not present, scan the drives of the correct PEBootType and look for some kind of tag file that identifies the boot drive
        [Alias('Update')]
        [System.Management.Automation.SwitchParameter]$UpdateBootInfo,

        #RemoteRecovery.exe -nomessage
        #Microsoft Diagnostic and Recovery Toolset Remote Recovery
        [Alias('Remote')]
        [System.Management.Automation.SwitchParameter]$RemoteRecovery,

        #wpeutil Reboot
        #Reboots the computer
        [System.Management.Automation.SwitchParameter]$Reboot,
        
        #wpeutil Shutdown
        #Shutdown the computer
        [System.Management.Automation.SwitchParameter]$Shutdown
    )
    #=================================================
    #	Blocks
    #=================================================
    Block-WinOS
    #=================================================
    #	Increase the Console Screen Buffer size
    #=================================================
    if (!(Test-Path "HKCU:\Console")) {
        Write-Verbose "OSDWinPE: Increase Console Screen Buffer"
        New-Item -Path "HKCU:\Console" -Force | Out-Null
        New-ItemProperty -Path HKCU:\Console ScreenBufferSize -Value 589889656 -PropertyType DWORD -Force | Out-Null
    }
    #=================================================
    #	GetModules
    #=================================================
    if ($GetModules.IsPresent) {
        $GetPSDrive = Get-PSDrive -PSProvider 'FileSystem'
        foreach ($PSDrive in $GetPSDrive) {
            $OSDSearchPath = @("$($PSDrive.Root)Modules","$($PSDrive.Root)Content\Modules")
            foreach ($Item in $OSDSearchPath) {
                if (Test-Path "$Item") {
                    Get-ChildItem "$Item" | `
                    Where-Object {$_.PSIsContainer} | `
                    ForEach-Object {
                        Write-Verbose "Copying Module at $($_.FullName) to X:\Program Files\WindowsPowerShell\Modules"
                        Copy-Item -Path "$($_.FullName)" -Destination "X:\Program Files\WindowsPowerShell\Modules" -Recurse -Force -ErrorAction SilentlyContinue
                        Import-Module -Name "$($_.Name)" -Force -ErrorAction SilentlyContinue
                    }
                }
            }
        }
    }
    #=================================================
    #	GetScripts
    #=================================================
    if ($GetScripts) {
        $GetPSDrive = Get-PSDrive -PSProvider 'FileSystem'

        foreach ($Item in $GetScripts) {
            foreach ($PSDrive in $GetPSDrive) {
                $ScriptFullName = @("$($PSDrive.Root)$Item","$($PSDrive.Root)Content\Scripts\$Item")

                foreach ($ScriptName in $ScriptFullName) {
                    if (Test-Path $ScriptName) {
                        $FoundScript = Get-Item $ScriptName | Select-Object -Property FullName
                        Write-Verbose "Executing PowerShell Script $($FoundScript.FullName)"
                        & "$($FoundScript.FullName)" -ErrorAction SilentlyContinue
                    }
                }
            }
        }
    }
    #=================================================
    #	wpeutil
    #=================================================
    if ($InitializeNetwork.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil InitializeNetwork'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'InitializeNetwork' -Wait
        Start-Sleep -Seconds 10
    }
    if ($InitializeNetworkNoWait.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil InitializeNetwork /NoWait'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList ('InitializeNetwork','/NoWait')
    }
    if ($WaitForNetwork.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil WaitForNetwork'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'WaitForNetwork' -Wait
    }
    if ($WaitForRemovableStorage.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil WaitForRemovableStorage'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'WaitForRemovableStorage' -Wait
    }
    if ($DisableFirewall.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil DisableFirewall'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'DisableFirewall' -Wait
    }
    if ($UpdateBootInfo.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil UpdateBootInfo'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'UpdateBootInfo'
    }
    #=================================================
    #	Microsoft DaRT
    #=================================================
    if (($RemoteRecovery.IsPresent) -and (Test-Path "$env:windir\System32\RemoteRecovery.exe")) {
        Write-Verbose 'OSDWinPE: Microsoft DaRT Remote Recovery'
        Start-Process -WindowStyle Minimized -FilePath RemoteRecovery.exe -ArgumentList '-nomessage'
    }
    #=================================================
    #	Reboot Shutdown
    #=================================================
    if ($Reboot.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil Reboot'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'Reboot'
    }
    if ($Shutdown.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil Shutdown'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'Shutdown'
    }
}