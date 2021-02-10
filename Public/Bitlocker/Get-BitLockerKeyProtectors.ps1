function Get-BitLockerKeyProtectors {
    [CmdletBinding()]
    param (
        [switch]$ShowRecoveryPassword
    )

    $GetBitLockerVolume = Get-BitLockerVolume | Sort-Object -Property MountPoint | Where-Object {$_.VolumeStatus -eq 'FullyEncrypted'} | Where-Object {$_.LockStatus -eq 'Unlocked'} | Select-Object *

    $Results = foreach ($BitLockerVolume in $GetBitLockerVolume) {

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
                        #LockStatus              = $BitLockerVolume.LockStatus
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
                        #LockStatus              = $BitLockerVolume.LockStatus
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