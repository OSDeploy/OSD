<#
.SYNOPSIS
Saves all BitLocker ExternalKeys (BEK), KeyPackages (KPG), and RecoveryPasswords (TXT)

.DESCRIPTION
Saves all BitLocker ExternalKeys (BEK), KeyPackages (KPG), and RecoveryPasswords (TXT) to a Directory (Path)

.PARAMETER Path
Directory to save the BitLocker Keys.  This directory will be created if it does not exist

.LINK
https://osd.osdeploy.com/module/mybitlocker/backup-mybitlockerkeys

.NOTES
Requires Administrative Rights
Requires BitLocker Module | Get-BitLockerVolume
21.2.10  Initial Release
#>
function Backup-MyBitLockerKeys {
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
    }
    process {
        Save-MyBitLockerExternalKey -Path $Path
        Save-MyBitLockerKeyPackage -Path $Path
        Save-MyBitLockerRecoveryPassword -Path $Path
    }
    end {}
}