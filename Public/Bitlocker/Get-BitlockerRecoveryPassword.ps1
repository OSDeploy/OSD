function Get-BitlockerRecoveryPassword {
    [CmdletBinding()]
    param ()

    $GetBitLockerVolume = Get-BitLockerVolume | Sort-Object MountPoint | Where-Object VolumeStatus -eq FullyEncrypted | Where-Object LockStatus -eq Unlocked | Select-Object *

    $Text = @"
BitLocker Drive Encryption recovery key 
To verify that this is the correct recovery key, compare the start of the following identifier with the identifier value displayed on your PC.
Identifier:
	$KeyProtectorId
If the above identifier matches the one displayed by your PC, then use the following key to unlock your drive.
Recovery Key:
	$RecoveryPassword
If the above identifier doesn't match the one displayed by your PC, then this isn't the right key to unlock your drive.
Try another recovery key, or refer to https://go.microsoft.com/fwlink/?LinkID=260589 for additional assistance.
"@

    $Results = foreach ($BitLockerVolume in $GetBitLockerVolume) {
        foreach ($item in $BitLockerVolume.KeyProtector) {
            if ($item.KeyProtectorType -eq 'RecoveryPassword') {
                [PSCustomObject] @{
                        #ComputerName         = $BitLockerVolume.ComputerName
                        MountPoint           = $BitLockerVolume.MountPoint
                        VolumeStatus         = $BitLockerVolume.VolumeStatus
                        ProtectionStatus     = $BitLockerVolume.ProtectionStatus
                        LockStatus           = $BitLockerVolume.LockStatus
                        #EncryptionPercentage = $BitLockerVolume.EncryptionPercentage
                        #WipePercentage       = $BitLockerVolume.WipePercentage
                        VolumeType           = $BitLockerVolume.VolumeType
                        CapacityGB           = $BitLockerVolume.CapacityGB
                        KeyProtectorId       = $item.KeyProtectorId  -replace "{" -replace "}"
                        #KeyProtectorType     = $item.KeyProtectorType
                        RecoveryPassword     = $item.RecoveryPassword
                }
            }
        }
    }

    Return $Results

<#     foreach ($Item in $Results) {
        $ComputerName = $Item.ComputerName
        $MountPoint = $Item.MountPoint
        $KeyProtectorId = $Item.KeyProtectorId
        $RecoveryPassword = $item.RecoveryPassword
        New-Item -Path "H:\$ComputerName MountPoint $($MountPoint -replace ":") $KeyProtectorId.TXT" -Force | Out-Null
        $Text | Set-Content "H:\$ComputerName MountPoint $($MountPoint -replace ":") $KeyProtectorId.TXT" -Force
        manage-bde -protectors -get $MountPoint -SaveExternalKey H:\
    } #>
}