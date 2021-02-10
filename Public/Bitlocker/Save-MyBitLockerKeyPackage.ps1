<#
.SYNOPSIS
Saves all BitLocker KeyPackages (KPG)

.DESCRIPTION
Saves all BitLocker KeyPackages (KPG) to a Directory (Path). The key package can be used in conjunction with the repair tool to repair corrupted drives.

.PARAMETER Path
Directory to save the BitLocker Keys.  This directory will be created if it does not exist

.LINK
https://osd.osdeploy.com/module/functions/bitlocker/save-mybitlockerkeypackage

.LINK
https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/manage-bde-keypackage

.NOTES
21.2.10  Initial Release
#>
function Save-MyBitLockerKeyPackage {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string[]]$Path
    )
    begin {
        #===================================================================================================
        #   Require Admin Rights
        #===================================================================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #===================================================================================================
        #   Get-Command Get-BitLockerVolume
        #===================================================================================================
        if (-NOT (Get-Command Get-BitLockerVolume -ErrorAction Ignore)) {
            Write-Warning "$($MyInvocation.MyCommand) requires Get-BitLockerVolume which is not present on this system"
            Break
        }
        #===================================================================================================
        #   Test-Path
        #===================================================================================================
        foreach ($Item in $Path) {
            if (-NOT (Test-Path $Item)) {
                New-Item $Item -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
        }
        #===================================================================================================
        #   Get-BitLockerKeyProtectors
        #===================================================================================================
        $BitLockerKeyProtectors = Get-MyBitLockerKeyProtectors -ShowRecoveryPassword | Sort-Object -Property MountPoint | Where-Object {$_.LockStatus -eq 'Unlocked'} | Where-Object {$_.KeyProtectorType -ne 'Tpm'}
        #===================================================================================================
    }
    process {
        foreach ($BitLockerKeyProtector in $BitLockerKeyProtectors) {
            foreach ($Item in $Path) {
                manage-bde.exe -KeyPackage $BitLockerKeyProtector.MountPoint -id $BitLockerKeyProtector.KeyProtectorId -Path $Item
            }
        }
    }
    end {}
}