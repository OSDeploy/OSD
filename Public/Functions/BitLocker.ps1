function Backup-MyBitLockerKeys {
    <#
    .SYNOPSIS
    Saves available BitLocker key materials to one or more folders.

    .DESCRIPTION
    Calls helper functions to export external keys, key packages, and recovery
    passwords for BitLocker-protected volumes.

    .PARAMETER Path
    One or more destination folders used to store exported key materials.

    .EXAMPLE
    Backup-MyBitLockerKeys -Path 'D:\BitLockerBackup'
    Exports BitLocker key materials to D:\BitLockerBackup.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string[]]$Path
    )
    begin {
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Elevated Administrator rights are required"
        }
        #=================================================
        #   Get-Command Get-BitLockerVolume
        #=================================================
        if (-not (Get-Command -Name Get-BitLockerVolume -ErrorAction Ignore)) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] requires Get-BitLockerVolume, which is not present on this system"
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
    <#
    .SYNOPSIS
    Returns BitLocker key protector details for encrypted volumes.

    .DESCRIPTION
    Enumerates BitLocker volumes and returns protector metadata, with optional
    inclusion of recovery password values.

    .PARAMETER ShowRecoveryPassword
    Includes recovery password values in the output when specified.

    .EXAMPLE
    Get-MyBitLockerKeyProtectors
    Lists key protector details without recovery password values.

    .EXAMPLE
    Get-MyBitLockerKeyProtectors -ShowRecoveryPassword
    Lists key protector details including recovery password values.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter]$ShowRecoveryPassword
    )
    begin {
        #=================================================
        #   Require Admin Rights
        #=================================================
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Elevated Administrator rights are required"
        }
        #=================================================
        #   Get-Command Get-BitLockerVolume
        #=================================================
        if (-not (Get-Command -Name Get-BitLockerVolume -ErrorAction Ignore)) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] requires Get-BitLockerVolume, which is not present on this system"
        }
        #=================================================
        #   Get-BitLockerVolume
        #=================================================
        #$BitLockerVolumes = Get-BitLockerVolume | Sort-Object -Property MountPoint | Where-Object {$_.VolumeStatus -eq 'FullyEncrypted'} | Where-Object {$_.LockStatus -eq 'Unlocked'}
        $BitLockerVolumes = Get-BitLockerVolume | Sort-Object -Property MountPoint | Where-Object { $_.EncryptionMethod -ne '' }
        #=================================================
    }
    process {
        $Results = foreach ($BitLockerVolume in $BitLockerVolumes) {

            $ExternalKeyMatches = @($BitLockerVolume.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'ExternalKey' }).Count
            if ($ExternalKeyMatches -eq 0) { Write-Warning "Mountpoint $($BitLockerVolume.Mountpoint) does not contain an ExternalKey" }
            if ($ExternalKeyMatches -gt 1) { Write-Warning "Mountpoint $($BitLockerVolume.Mountpoint) contains $ExternalKeyMatches ExternalKeys.  Ideally, this should be 1" }

            $RecoveryPasswordMatches = @($BitLockerVolume.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }).Count
            if ($RecoveryPasswordMatches -eq 0) { Write-Warning "Mountpoint $($BitLockerVolume.Mountpoint) does not contain an RecoveryPassword" }
            if ($RecoveryPasswordMatches -gt 1) { Write-Warning "Mountpoint $($BitLockerVolume.Mountpoint) contains $RecoveryPasswordMatches RecoveryPassword.  Ideally, this should be 1" }

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
                }
                else {
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
    <#
    .SYNOPSIS
    Saves BitLocker external key protectors (.BEK) to destination folders.

    .DESCRIPTION
    Finds unlocked volumes with external key protectors and exports their
    external key files to one or more target paths.

    .PARAMETER Path
    One or more destination folders used to store exported external keys.

    .EXAMPLE
    Save-MyBitLockerExternalKey -Path 'D:\BitLockerBackup'
    Exports external key files to D:\BitLockerBackup.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string[]]$Path
    )
    begin {
        #=================================================
        #   Require Admin Rights
        #=================================================
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Elevated Administrator rights are required"
        }
        #=================================================
        #   Get-Command Get-BitLockerVolume
        #=================================================
        if (-not (Get-Command -Name Get-BitLockerVolume -ErrorAction Ignore)) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] requires Get-BitLockerVolume, which is not present on this system"
        }
        #=================================================
        #   Test-Path
        #=================================================
        foreach ($Item in $Path) {
            if (-NOT (Test-Path -LiteralPath $Item)) {
                New-Item $Item -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
        }
        #=================================================
        #   Get-BitLockerKeyProtectors
        #=================================================
        $BitLockerKeyProtectors = Get-MyBitLockerKeyProtectors |
            Sort-Object -Property MountPoint |
            Where-Object { $_.LockStatus -eq 'Unlocked' -and $_.KeyProtectorType -eq 'ExternalKey' }
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
    <#
    .SYNOPSIS
    Saves BitLocker key packages to destination folders.

    .DESCRIPTION
    Enumerates unlocked BitLocker volumes and exports key package data for each
    non-TPM protector to one or more target paths.

    .PARAMETER Path
    One or more destination folders used to store exported key packages.

    .EXAMPLE
    Save-MyBitLockerKeyPackage -Path 'D:\BitLockerBackup'
    Exports key package files to D:\BitLockerBackup.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string[]]$Path
    )
    begin {
        #=================================================
        #   Require Admin Rights
        #=================================================
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Elevated Administrator rights are required"
        }
        #=================================================
        #   Get-Command Get-BitLockerVolume
        #=================================================
        if (-not (Get-Command -Name Get-BitLockerVolume -ErrorAction Ignore)) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] requires Get-BitLockerVolume, which is not present on this system"
        }
        #=================================================
        #   Test-Path
        #=================================================
        foreach ($Item in $Path) {
            if (-NOT (Test-Path -LiteralPath $Item)) {
                New-Item $Item -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
        }
        #=================================================
        #   Get-BitLockerKeyProtectors
        #=================================================
        $BitLockerKeyProtectors = Get-MyBitLockerKeyProtectors -ShowRecoveryPassword |
            Sort-Object -Property MountPoint |
            Where-Object { $_.LockStatus -eq 'Unlocked' -and $_.KeyProtectorType -ne 'Tpm' }
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
    <#
    .SYNOPSIS
    Saves BitLocker recovery passwords to text files.

    .DESCRIPTION
    Exports recovery password protector values from unlocked volumes and writes
    them as recovery key text files in one or more destination folders.

    .PARAMETER Path
    One or more destination folders used to store recovery password files.

    .EXAMPLE
    Save-MyBitLockerRecoveryPassword -Path 'D:\BitLockerBackup'
    Exports recovery password text files to D:\BitLockerBackup.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string[]]$Path
    )
    begin {
        #=================================================
        #   Require Admin Rights
        #=================================================
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Elevated Administrator rights are required"
        }
        #=================================================
        #   Get-Command Get-BitLockerVolume
        #=================================================
        if (-not (Get-Command -Name Get-BitLockerVolume -ErrorAction Ignore)) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] requires Get-BitLockerVolume, which is not present on this system"
        }
        #=================================================
        #   Test-Path
        #=================================================
        foreach ($Item in $Path) {
            if (-NOT (Test-Path -LiteralPath $Item)) {
                New-Item $Item -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
        }
        #=================================================
        #   Get-BitLockerKeyProtectors
        #=================================================
        $BitLockerKeyProtectors = Get-MyBitLockerKeyProtectors -ShowRecoveryPassword |
            Sort-Object -Property MountPoint |
            Where-Object { $_.LockStatus -eq 'Unlocked' -and $_.KeyProtectorType -eq 'RecoveryPassword' }
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
    <#
    .SYNOPSIS
    Unlocks BitLocker volumes using external key files.

    .DESCRIPTION
    Searches one or more paths for matching .BEK files and unlocks locked
    BitLocker volumes that use external key protectors.

    .PARAMETER Path
    One or more folders to search for matching .BEK external key files.

    .PARAMETER Recurse
    Searches subdirectories under each path for matching key files.

    .EXAMPLE
    Unlock-MyBitLockerExternalKey -Path 'D:\BitLockerBackup'
    Unlocks volumes using matching .BEK files in the specified folder.

    .EXAMPLE
    Unlock-MyBitLockerExternalKey -Path 'D:\BitLockerBackup' -Recurse
    Unlocks volumes using matching .BEK files found recursively.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    #>
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
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Elevated Administrator rights are required"
        }
        #=================================================
        #   Get-Command Get-BitLockerVolume
        #=================================================
        if (-not (Get-Command -Name Get-BitLockerVolume -ErrorAction Ignore)) {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] requires Get-BitLockerVolume, which is not present on this system"
        }
        #=================================================
        #   Test-Path
        #=================================================
        foreach ($Item in $Path) {
            if (-NOT (Test-Path -LiteralPath $Item)) {
                Write-Warning "Unable to validate Path at $Item"
                Break
            }
        }
        #=================================================
        #   Get-MyBitLockerKeyProtectors
        #=================================================
        $BitLockerKeyProtectors = Get-MyBitLockerKeyProtectors |
            Sort-Object -Property MountPoint |
            Where-Object { $_.LockStatus -eq 'Locked' -and $_.KeyProtectorType -eq 'ExternalKey' }
        $BitLockerKeyProtectors
        if (-NOT $BitLockerKeyProtectors) {
            Write-Warning "No BitLocker Volumes with a LockStatus of Locked could be found"
            Break
        }
        #=================================================
    }
    process {
        foreach ($BitLockerKeyProtector in $BitLockerKeyProtectors) {

            $ExternalKeyName = (($BitLockerKeyProtector).KeyProtectorId -replace "{" -replace "}") + ".BEK"

            if ($Recurse) {
                $RecoveryKeyPath = Get-ChildItem -Path $Path -Force -Recurse -File -Filter $ExternalKeyName -ErrorAction Ignore |
                    Select-Object -ExpandProperty FullName -First 1
            } else {
                $RecoveryKeyPath = Get-ChildItem -Path $Path -Force -File -Filter $ExternalKeyName -ErrorAction Ignore |
                    Select-Object -ExpandProperty FullName -First 1
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
