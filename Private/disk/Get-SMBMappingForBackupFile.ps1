function Get-SMBMappingForBackupFile {
    [CmdletBinding()]
    param (
        [int] $IgnoreDisk = 0
    )
        #=================================================
        #   Get-Partition Information
        #=================================================
        $GetPartition = Get-Partition | `
        Where-Object {$_.DiskNumber -ne $IgnoreDisk} | `
        Where-Object {$_.DriveLetter -gt 0} | `
        Where-Object {$_.IsOffline -eq $false} | `
        Where-Object {$_.IsReadOnly -ne $true} | `
        Where-Object {$_.Size -gt 10000000000} | `
        Sort-Object -Property DriveLetter | `
        Select-Object -Property DriveLetter
        #=================================================
        #   Get-Volume Information
        #=================================================
        $GetVolume = $(Get-Volume | `
        Sort-Object -Property DriveLetter | `
        Select-Object -Property DriveLetter,FileSystem,OperationalStatus,DriveType,FileSystemLabel,Size,SizeRemaining)
        #=================================================
        #   Create Object
        #=================================================
        $Results = foreach ($Item in $GetPartition) {
            $GetVolumeProperties = $GetVolume | Where-Object {$_.DriveLetter -eq $Item.DriveLetter}
            $ObjectProperties = @{
                DriveLetter         = $GetVolumeProperties.DriveLetter
                FileSystem          = $GetVolumeProperties.FileSystem
                OperationalStatus   = $GetVolumeProperties.OperationalStatus
                DriveType           = $GetVolumeProperties.DriveType
                FileSystemLabel     = $GetVolumeProperties.FileSystemLabel
                Size                = $GetVolumeProperties.Size
                SizeRemaining       = $GetVolumeProperties.SizeRemaining

            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
        #=================================================
        #   Return Results
        #=================================================
        $Results = $Results | Sort-Object -Property DriveLetter
        $Results = $Results | Where-Object {$_.FileSystem -eq 'NTFS'}
        Return $Results
}