<#
.SYNOPSIS
Generates a key package for a drive.

.DESCRIPTION
Generates a key package for a drive. The key package can be used in conjunction with the repair tool to repair corrupted drives.

.PARAMETER Path
Path to save the KeyPackage.  The Path must exist

.LINK
https://osd.osdeploy.com/module/functions/bitlocker/save-bitlockerkeypackage

.LINK
https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/manage-bde-keypackage

.NOTES
21.2.10  Initial Release
#>
function Save-BitLockerKeyPackage {
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
        #   Get-BitLockerKeyProtectors
        #===================================================================================================
        $Results = Get-BitLockerKeyProtectors -ShowRecoveryPassword | Sort-Object -Property MountPoint | Where-Object {$_.KeyProtectorType -ne 'Tpm'}
        #===================================================================================================
    }
    process {
        foreach ($Item in $Results) {
            manage-bde.exe -KeyPackage $Item.MountPoint -id $Item.KeyProtectorId -Path $Path
        }
    }
    end {}
}