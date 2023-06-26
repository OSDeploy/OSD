<#PSScriptInfo
.VERSION 23.6.1.2
.GUID 0ce87b09-62cd-4272-b0c5-4c76cf14b916
.AUTHOR David Segura
.COMPANYNAME David Segura
.COPYRIGHT (c) 2023 David Segura. All rights reserved.
.TAGS WinPE
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/PwshHub
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
#>
#Requires -Modules @{ ModuleName="OSD"; ModuleVersion="23.5.26.1" }
#Requires -RunAsAdministrator
<#
.DESCRIPTION
Clears the Local Disk(s) and creates a new OS Disk.  Automatically selects MBR or UEFI based on the Boot method
#>
[CmdletBinding()]
param()

# Make sure we are in WinPE
if ($env:SystemDrive -eq 'X:') {

    # Remove attached USB Drives
    if (Get-USBDisk) {
        do {
            Write-Warning "Remove all attached USB Drives New-OSDisk is complete"
            pause
        }
        while (Get-USBDisk)
    }

    # Clears all Local Disks
    # Automatically creates the Partition Layout with Recovery Partition based on the Boot Method
    # Will prompt for confirmation before clearing the disks
    New-OSDisk -Force -ErrorAction Stop
}

<#
Other options for New-OSDisk

New-OSDisk -PartitionStyle GPT -Force
    System = 260MB
    MSR = 16MB
    Windows = *
    Recovery = 990MB
=========================================================================
| SYSTEM | MSR |                    WINDOWS                  | RECOVERY |
=========================================================================

New-OSDisk -PartitionStyle GPT -Force -NoRecoveryPartition
    System = 260MB
    MSR = 16MB
    Windows = *
This layout is ideal for Generation 2 Virtual Machines
=========================================================================
| SYSTEM | MSR |                    WINDOWS                             |
=========================================================================

New-OSDisk -PartitionStyle MBR -Force
    System = 260MB
    Windows = *
    Recovery = 990MB
=========================================================================
| SYSTEM |                          WINDOWS                  | RECOVERY |
=========================================================================

New-OSDisk -PartitionStyle MBR -Force -NoRecoveryPartition
    System = 260MB
    Windows = *
This layout is ideal for Generation 1 Virtual Machines
=========================================================================
| SYSTEM |                          WINDOWS                             |
=========================================================================
#>