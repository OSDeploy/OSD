function Backup-MyBitLockerKeys {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string[]]$Path
    )
    begin {
        #=================================================
        #   Require Admin Rights
        #=================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #=================================================
        #   Get-Command Get-BitLockerVolume
        #=================================================
        if (-NOT (Get-Command Get-BitLockerVolume -ErrorAction Ignore)) {
            Write-Warning "$($MyInvocation.MyCommand) requires Get-BitLockerVolume which is not present on this system"
            Break
        }
        #=================================================
    }
    process {
        Save-MyBitLockerExternalKey -Path $Path
        Save-MyBitLockerKeyPackage -Path $Path
        Save-MyBitLockerRecoveryPassword -Path $Path
    }
    end {}
}
function Get-MyBitLockerKeyProtectors {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter]$ShowRecoveryPassword
    )
    begin {
        #=================================================
        #   Require Admin Rights
        #=================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #=================================================
        #   Get-Command Get-BitLockerVolume
        #=================================================
        if (-NOT (Get-Command Get-BitLockerVolume -ErrorAction Ignore)) {
            Write-Warning "$($MyInvocation.MyCommand) requires Get-BitLockerVolume which is not present on this system"
            Break
        }
        #=================================================
        #   Get-BitLockerVolume
        #=================================================
        #$BitLockerVolumes = Get-BitLockerVolume | Sort-Object -Property MountPoint | Where-Object {$_.VolumeStatus -eq 'FullyEncrypted'} | Where-Object {$_.LockStatus -eq 'Unlocked'} | Select-Object *
        $BitLockerVolumes = Get-BitLockerVolume | Sort-Object -Property MountPoint | Where-Object {$_.EncryptionMethod -ne ''} | Select-Object *
        #=================================================
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
function Save-MyBitLockerExternalKey {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string[]]$Path
    )
    begin {
        #=================================================
        #   Require Admin Rights
        #=================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #=================================================
        #   Get-Command Get-BitLockerVolume
        #=================================================
        if (-NOT (Get-Command Get-BitLockerVolume -ErrorAction Ignore)) {
            Write-Warning "$($MyInvocation.MyCommand) requires Get-BitLockerVolume which is not present on this system"
            Break
        }
        #=================================================
        #   Test-Path
        #=================================================
        foreach ($Item in $Path) {
            if (-NOT (Test-Path $Item)) {
                New-Item $Item -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
        }
        #=================================================
        #   Get-BitLockerKeyProtectors
        #=================================================
        $BitLockerKeyProtectors = Get-MyBitLockerKeyProtectors | Sort-Object -Property MountPoint | Where-Object {$_.LockStatus -eq 'Unlocked'} | Where-Object {$_.KeyProtectorType -eq 'ExternalKey'}
        #=================================================
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
function Save-MyBitLockerKeyPackage {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string[]]$Path
    )
    begin {
        #=================================================
        #   Require Admin Rights
        #=================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #=================================================
        #   Get-Command Get-BitLockerVolume
        #=================================================
        if (-NOT (Get-Command Get-BitLockerVolume -ErrorAction Ignore)) {
            Write-Warning "$($MyInvocation.MyCommand) requires Get-BitLockerVolume which is not present on this system"
            Break
        }
        #=================================================
        #   Test-Path
        #=================================================
        foreach ($Item in $Path) {
            if (-NOT (Test-Path $Item)) {
                New-Item $Item -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
        }
        #=================================================
        #   Get-BitLockerKeyProtectors
        #=================================================
        $BitLockerKeyProtectors = Get-MyBitLockerKeyProtectors -ShowRecoveryPassword | Sort-Object -Property MountPoint | Where-Object {$_.LockStatus -eq 'Unlocked'} | Where-Object {$_.KeyProtectorType -ne 'Tpm'}
        #=================================================
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
function Save-MyBitLockerRecoveryPassword {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string[]]$Path
    )
    begin {
        #=================================================
        #   Require Admin Rights
        #=================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #=================================================
        #   Get-Command Get-BitLockerVolume
        #=================================================
        if (-NOT (Get-Command Get-BitLockerVolume -ErrorAction Ignore)) {
            Write-Warning "$($MyInvocation.MyCommand) requires Get-BitLockerVolume which is not present on this system"
            Break
        }
        #=================================================
        #   Test-Path
        #=================================================
        foreach ($Item in $Path) {
            if (-NOT (Test-Path $Item)) {
                New-Item $Item -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
        }
        #=================================================
        #   Get-BitLockerKeyProtectors
        #=================================================
        $BitLockerKeyProtectors = Get-MyBitLockerKeyProtectors -ShowRecoveryPassword | Sort-Object -Property MountPoint | Where-Object {$_.LockStatus -eq 'Unlocked'} | Where-Object {$_.KeyProtectorType -eq 'RecoveryPassword'}
        #=================================================
    }
    process {
        foreach ($BitLockerKeyProtector in $BitLockerKeyProtectors) {
            foreach ($Item in $Path) {
                $ComputerName = $BitLockerKeyProtector.ComputerName
                $MountPoint = $BitLockerKeyProtector.MountPoint -replace ":"
                $KeyProtectorId = $BitLockerKeyProtector.KeyProtectorId -replace "{" -replace "}"
                $RecoveryPassword = $BitLockerKeyProtector.RecoveryPassword
        
$TextContent = @"
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
        
                New-Item -Path "$Item\$ComputerName MountPoint $MountPoint $KeyProtectorId.TXT" -Force
                $TextContent | Set-Content "$Item\$ComputerName MountPoint $MountPoint $KeyProtectorId.TXT" -Force
            }
        }
    }
    end {}
}
function Unlock-MyBitLockerExternalKey {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [string[]]$Path,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter]$Recurse
    )
    begin {
        #=================================================
        #   Require Admin Rights
        #=================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
            Break
        }
        #=================================================
        #   Get-Command Get-BitLockerVolume
        #=================================================
        if (-NOT (Get-Command Get-BitLockerVolume -ErrorAction Ignore)) {
            Write-Warning "$($MyInvocation.MyCommand) requires Get-BitLockerVolume which is not present on this system"
            Break
        }
        #=================================================
        #   Test-Path
        #=================================================
        foreach ($Item in $Path) {
            if (-NOT (Test-Path $Item)) {
                Write-Warning "Unable to validate Path at $Item"
                Break
            }
        }
        #=================================================
        #   Get-MyBitLockerKeyProtectors
        #=================================================
        $BitLockerKeyProtectors = Get-MyBitLockerKeyProtectors | Sort-Object -Property MountPoint | Where-Object {$_.LockStatus -eq 'Locked'} | Where-Object {$_.KeyProtectorType -eq 'ExternalKey'} | Select-Object *
        $BitLockerKeyProtectors
        if ($null -eq $BitLockerKeyProtectors) {
            Write-Warning "No BitLocker Volumes with a LockStatus of Locked could be found"
            Break
        }
        #=================================================
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