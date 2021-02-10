<#
.SYNOPSIS
Creates an Object with all the BitLocker KeyProtector information

.DESCRIPTION
Creates an Object with all the BitLocker KeyProtector information

.PARAMETER ShowRecoveryPassword
Shows the Recovery Password in plain text

.LINK
https://osd.osdeploy.com/module/functions/bitlocker/get-mybitlockerkeyprotectors

.NOTES
Requires Administrative Rights
Requires BitLocker Module | Get-BitLockerVolume
21.2.10  Initial Release
#>
function Get-MyBitLockerKeyProtectors {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [switch]$ShowRecoveryPassword
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
        #   Get-BitLockerVolume
        #===================================================================================================
        #$BitLockerVolumes = Get-BitLockerVolume | Sort-Object -Property MountPoint | Where-Object {$_.VolumeStatus -eq 'FullyEncrypted'} | Where-Object {$_.LockStatus -eq 'Unlocked'} | Select-Object *
        $BitLockerVolumes = Get-BitLockerVolume | Sort-Object -Property MountPoint | Where-Object {$_.EncryptionMethod -ne ''} | Select-Object *
        #===================================================================================================
    }
    process {
        $Results = foreach ($BitLockerVolume in $BitLockerVolumes) {

            $ExternalKeyMatches = ($BitLockerVolume.KeyProtector | Where-Object {$_.KeyProtectorType -eq 'ExternalKey'}).Count
            if ($ExternalKeyMatches -eq 0) {Write-Warning "Mountpoint $($BitLockerVolume.Mountpoint) does not contain an ExternalKey"}
            if ($ExternalKeyMatches -gt 1) {Write-Warning "Mountpoint $($BitLockerVolume.Mountpoint) contains $ExternalKeyMatches ExternalKeys.  Ideally, this should be 1"}
    
            $RecoveryPasswordMatches = ($BitLockerVolume.KeyProtector | Where-Object {$_.KeyProtectorType -eq 'RecoveryPassword'}).Count
            if ($RecoveryPasswordMatches -eq 0) {Write-Warning "Mountpoint $($BitLockerVolume.Mountpoint) does not contain an RecoveryPassword"}
            if ($RecoveryPasswordMatches -gt 1) {Write-Warning "Mountpoint $($BitLockerVolume.Mountpoint) contains $RecoveryPasswordMatches RecoveryPassword.  Ideally, this should be 1"}
    
            foreach ($item in $BitLockerVolume.KeyProtector) {
    
                if ($ShowRecoveryPassword) {
                    [PSCustomObject] @{
                            ComputerName            = $BitLockerVolume.ComputerName
                            MountPoint              = $BitLockerVolume.MountPoint
                            #VolumeStatus            = $BitLockerVolume.VolumeStatus
                            #ProtectionStatus        = $BitLockerVolume.ProtectionStatus
                            LockStatus              = $BitLockerVolume.LockStatus
                            #EncryptionPercentage    = $BitLockerVolume.EncryptionPercentage
                            #WipePercentage          = $BitLockerVolume.WipePercentage
                            VolumeType              = $BitLockerVolume.VolumeType
                            #CapacityGB              = $BitLockerVolume.CapacityGB
                            KeyProtectorId          = $item.KeyProtectorId
                            KeyProtectorType        = $item.KeyProtectorType
                            RecoveryPassword        = $item.RecoveryPassword
                            AutoUnlockProtector     = $item.AutoUnlockProtector
                            KeyFileName             = $item.KeyFileName
                    }
                } else {
                    [PSCustomObject] @{
                            ComputerName            = $BitLockerVolume.ComputerName
                            MountPoint              = $BitLockerVolume.MountPoint
                            #VolumeStatus            = $BitLockerVolume.VolumeStatus
                            #ProtectionStatus        = $BitLockerVolume.ProtectionStatus
                            LockStatus              = $BitLockerVolume.LockStatus
                            #EncryptionPercentage    = $BitLockerVolume.EncryptionPercentage
                            #WipePercentage          = $BitLockerVolume.WipePercentage
                            VolumeType              = $BitLockerVolume.VolumeType
                            #CapacityGB              = $BitLockerVolume.CapacityGB
                            KeyProtectorId          = $item.KeyProtectorId
                            KeyProtectorType        = $item.KeyProtectorType
                            #RecoveryPassword        = $item.RecoveryPassword
                            AutoUnlockProtector     = $item.AutoUnlockProtector
                            KeyFileName             = $item.KeyFileName
                    }
                }
            }
        }
    
        Return $Results
    }
    end {}
}