<#
.SYNOPSIS
Saves all BitLocker RecoveryPasswords (TXT)

.DESCRIPTION
Saves all BitLocker RecoveryPasswords (TXT) to a Directory (Path)

.PARAMETER Path
Directory to save the BitLocker Keys.  This directory will be created if it does not exist

.LINK
https://osd.osdeploy.com/module/functions/bitlocker/save-mybitlockerrecoverypassword

.NOTES
Requires Administrative Rights
Requires BitLocker Module | Get-BitLockerVolume
21.2.10  Initial Release
#>
function Save-MyBitLockerRecoveryPassword {
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
        $BitLockerKeyProtectors = Get-MyBitLockerKeyProtectors -ShowRecoveryPassword | Sort-Object -Property MountPoint | Where-Object {$_.LockStatus -eq 'Unlocked'} | Where-Object {$_.KeyProtectorType -eq 'RecoveryPassword'}
        #===================================================================================================
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