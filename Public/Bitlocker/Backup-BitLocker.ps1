<#
.SYNOPSIS
Generates a key package for a drive.

.DESCRIPTION
Generates a key package for a drive. The key package can be used in conjunction with the repair tool to repair corrupted drives.

.PARAMETER Path
Path to save the KeyPackage.  The Path must exist

.LINK
https://osd.osdeploy.com/module/functions/bitlocker/backup-bitlocker

.NOTES
21.2.10  Initial Release
#>
function Backup-BitLocker {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName)]
        [string]$Path
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
        #   Test-Path
        #===================================================================================================
        if (-NOT (Test-Path $Path)) {
            Write-Warning "Could not find Path at $Path"
            Break
        }
        #===================================================================================================
    }
    process {
        Save-BitLockerExternalKey -Path $Path
        Save-BitLockerKeyPackage -Path $Path
        Save-BitLockerRecoveryPassword -Path $Path
    }
    end {}
}