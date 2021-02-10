<#
.SYNOPSIS
Unlocks all BitLocker Locked Volumes given a Directory containing ExternalKeys (BEK)

.DESCRIPTION
Unlocks all BitLocker Locked Volumes given a Directory containing ExternalKeys (BEK)

.PARAMETER Path
Directory containing BitLocker ExternalKeys (BEK)

.PARAMETER Recurse
Searches the Path for BitLocker ExternalKeys (BEK) in subdirectories

.LINK
https://osd.osdeploy.com/module/functions/bitlocker/unlock-mybitlockerexternalkey

.NOTES
Requires Administrative Rights
Requires BitLocker Module | Get-BitLockerVolume
21.2.10  Initial Release
#>
function Unlock-MyBitLockerExternalKey {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [string[]]$Path,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [switch]$Recurse
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
                Write-Warning "Unable to validate Path at $Item"
                Break
            }
        }
        #===================================================================================================
        #   Get-MyBitLockerKeyProtectors
        #===================================================================================================
        $BitLockerKeyProtectors = Get-MyBitLockerKeyProtectors | Sort-Object -Property MountPoint | Where-Object {$_.LockStatus -eq 'Locked'} | Where-Object {$_.KeyProtectorType -eq 'ExternalKey'} | Select-Object *
        $BitLockerKeyProtectors
        if ($null -eq $BitLockerKeyProtectors) {
            Write-Warning "No BitLocker Volumes with a LockStatus of Locked could be found"
            Break
        }
        #===================================================================================================
    }
    process {
        foreach ($BitLockerKeyProtector in $BitLockerKeyProtectors) {

            $ExternalKeyName = (($BitLockerKeyProtector).KeyProtectorId -replace "{" -replace "}") + ".BEK"

            if ($Recurse) {
                $RecoveryKeyPath = (Get-ChildItem -Path $Path -Force -Recurse | Where-Object {$_.Name -eq $ExternalKeyName} | Select-Object -First 1).FullName
            } else {
                $RecoveryKeyPath = (Get-ChildItem -Path $Path -Force | Where-Object {$_.Name -eq $ExternalKeyName} | Select-Object -First 1).FullName
            }

            if ($RecoveryKeyPath) {
                Write-Verbose "MountPoint: $($BitLockerKeyProtector.MountPoint)" -Verbose
                Write-Verbose "RecoveryKeyPath: $RecoveryKeyPath" -Verbose
                Unlock-BitLocker -MountPoint $BitLockerKeyProtector.MountPoint -RecoveryKeyPath $RecoveryKeyPath
            } else {
                Write-Warning "Unable to find a ExternalKey $ExternalKeyName"
            }
        }
    }
    end {}
}