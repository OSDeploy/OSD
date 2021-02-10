<#
.SYNOPSIS
Saves all BitLocker ExternalKeys (BEK)

.DESCRIPTION
Saves all BitLocker ExternalKeys (BEK) to a Directory (Path)

.PARAMETER Path
Directory to save the BitLocker Keys.  This directory will be created if it does not exist

.LINK
https://osd.osdeploy.com/module/functions/bitlocker/save-mybitlockerexternalkey

.NOTES
Requires Administrative Rights
Requires BitLocker Module | Get-BitLockerVolume
21.2.10  Initial Release
#>
function Save-MyBitLockerExternalKey {
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
        $BitLockerKeyProtectors = Get-MyBitLockerKeyProtectors | Sort-Object -Property MountPoint | Where-Object {$_.LockStatus -eq 'Unlocked'} | Where-Object {$_.KeyProtectorType -eq 'ExternalKey'}
        #===================================================================================================
    }
    process {
        foreach ($BitLockerKeyProtector in $BitLockerKeyProtectors) {
            foreach ($Item in $Path) {
                manage-bde.exe -protectors -get $BitLockerKeyProtector.MountPoint -Type ExternalKey -SaveExternalKey $Item
            }
        }
    }
    end {}
}