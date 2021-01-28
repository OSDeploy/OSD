<#
.SYNOPSIS
Returns the Computer SerialNumber

.DESCRIPTION
Returns the Computer SerialNumber

.LINK

.NOTES
21.1.28    Initial Release
#>
function Get-AvailableBackupDriveLetters {
    [CmdletBinding()]
    Param (
        [int] $IgnoreDisk = 0
    )

    begin {
        $AvailableBackupDriveLetters = Get-Partition | `
        Where-Object {$_.DiskNumber -ne $IgnoreDisk} | `
        Where-Object {$_.DriveLetter -gt 0} | `
        Where-Object {$_.IsOffline -eq $false} | `
        Where-Object {$_.IsReadOnly -ne $true} | `
        Where-Object {$_.Size -gt 10000000000} | `
        Sort-Object -Property DriveLetter | Select-Object -ExpandProperty DriveLetter
    }
    process {
    }
    end {
        Return $AvailableBackupDriveLetters
    }
}