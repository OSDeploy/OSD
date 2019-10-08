<#
.SYNOPSIS
Common WinPE Commands using wpeutil and Microsoft DaRT RemoteRecovery

.DESCRIPTION
Common WinPE Commands using wpeutil and Microsoft DaRT RemoteRecovery

.LINK
https://osd.osdeploy.com/module/functions/get-osdwinpe

.NOTES
19.10.1     David Segura @SeguraOSD
#>
function Get-OSDWinPE {
    [CmdletBinding()]
    Param (
        #PowerShell Module Parameter
        #Searches all Drives for <drive>:\Modules directory
        #Copies Modules content to System32 $PSModulesPath
        [Alias('Modules')]
        [switch]$AddModules,

        #PowerShell Module Parameter
        #Imports a PowerShell Module by Name
        #PowerShell Module must exist in $PSModulePath
        [Alias('Import')]
        [string[]]$ImportModule,

        #PowerShell Script Parameter
        #Searches all Drives for <drive>:\$ImportModule file
        #Calls <drive>:\$ImportModule in the current PS Session
        [Alias('Script')]
        [string]$CallScript,

        #wpeutil InitializeNetwork
        #Initializes network components and drivers and sets the computer name to a randomly-chosen value
        [Alias('Network')]
        [switch]$InitializeNetwork,

        #wpeutil InitializeNetwork /NoWait
        #Initializes network components and drivers and sets the computer name to a randomly-chosen value
        #The /NoWait option will skip the time where your PC would otherwise wait to acquire an IP address
        #If you don't use /NoWait, Windows PE will wait to acquire an address before it finishes loading your WinPE session
        #/NoWait is helpful for environments that don't use DHCP
        [Alias('NetworkNoWait')]
        [switch]$InitializeNetworkNoWait,

        #wpeutil WaitForNetwork
        #Waits for the network card to be initialized
        #Use this command when creating scripts to make sure that the network card has been fully initialized before continuing
        [Alias('WaitNetwork')]
        [switch]$WaitForNetwork,

        #wpeutil WaitForRemovableStorage
        #During the Windows PE startup sequence, this command will block startup until the removable storage devices, such as USB hard drives, are initialized
        [Alias('WaitUSB')]
        [switch]$WaitForRemovableStorage,

        #wpeutil DisableFirewall
        #Disables the Firewall
        [Alias('Disable')]
        [switch]$DisableFirewall,

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
        [switch]$UpdateBootInfo,

        #RemoteRecovery.exe -nomessage
        #Microsoft Diagnostic and Recovery Toolset Remote Recovery
        [Alias('Remote')]
        [switch]$RemoteRecovery,

        #wpeutil Reboot
        #Reboots the computer
        [switch]$Reboot,
        
        #wpeutil Shutdown
        #Shutdown the computer
        [switch]$Shutdown
    )
    #======================================================================================================
    #	IsWinPE
    #======================================================================================================
    if (Get-OSDGather -Property IsWinPE) {Write-Verbose 'OSDWinPE: WinPE is running'}
    else {Write-Warning 'OSDWinPE: This function requires WinPE'; Break}
    #======================================================================================================
    #	Increase the Console Screen Buffer size
    #======================================================================================================
    if (!(Test-Path "HKCU:\Console")) {
        Write-Verbose "OSDWinPE: Increase Console Screen Buffer"
        New-Item -Path "HKCU:\Console" -Force | Out-Null
        New-ItemProperty -Path HKCU:\Console ScreenBufferSize -Value 589889656 -PropertyType DWORD -Force | Out-Null
    }
    #======================================================================================================
    #	CallScript
    #======================================================================================================
    if ($CallScript) {
        $OSDCallScripts = @()

        #Get all available Drives
        $OSDSearchDrives = Get-PSDrive -PSProvider 'FileSystem'

        foreach ($OSDSearchDrive in $OSDSearchDrives) {
            $FoundCallScript = "$($OSDSearchDrive.Root)$CallScript"

            Write-Verbose "Found PowerShell Script: $FoundCallScript"
            if (Test-Path $FoundCallScript) {$OSDCallScripts += Get-Item $FoundCallScript | Select-Object -Property FullName}
        }

        #Call found scripts
        foreach ($OSDCallScript in $OSDCallScripts) {
            Write-Verbose "Call: $($OSDCallScript.FullName)"
            & "$($OSDCallScript.FullName)" -ErrorAction SilentlyContinue
        }
    }
    #======================================================================================================
    #	AddModules
    #======================================================================================================
    if ($AddModules.IsPresent) {
        $OSDSearchDrives = Get-PSDrive -PSProvider 'FileSystem'
        foreach ($OSDSearchDrive in $OSDSearchDrives) {
            $OSDSearchPath = "$($OSDSearchDrive.Root)Modules"
            if (Test-Path "$OSDSearchPath") {
                Write-Verbose "Module Search Path: $OSDSearchPath"
                Get-ChildItem "$OSDSearchPath" | `
                Where-Object {$_.PSIsContainer} | `
                ForEach-Object {
                    Write-Verbose "Add Module: $($_.FullName)"
                    Copy-Item -Path "$($_.FullName)" -Destination "$PSHome\Modules" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }
    #======================================================================================================
    #	ImportModule
    #======================================================================================================
    foreach ($item in $ImportModule) {
        try {Import-Module -Name "$Item" -Force}
        catch {Write-Warning "Unable to Import Module $Item"}
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
    #======================================================================================================
    #	Microsoft DaRT
    #======================================================================================================
    if (($RemoteRecovery.IsPresent) -and (Test-Path "$env:windir\System32\RemoteRecovery.exe")) {
        Write-Verbose 'OSDWinPE: Microsoft DaRT Remote Recovery'
        Start-Process -WindowStyle Minimized -FilePath RemoteRecovery.exe -ArgumentList '-nomessage'
    }
    #======================================================================================================
    #	Reboot Shutdown
    #======================================================================================================
    if ($Reboot.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil Reboot'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'Reboot'
    }
    if ($Shutdown.IsPresent) {
        Write-Verbose 'OSDWinPE: wpeutil Shutdown'
        Start-Process -WindowStyle Hidden -FilePath wpeutil -ArgumentList 'Shutdown'
    }
}