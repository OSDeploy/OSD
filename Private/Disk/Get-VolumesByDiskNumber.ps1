function Get-VolumesByDiskNumber {
    [CmdletBinding()]
    param ()
        #=================================================
        #   Get-Partition Information
        #=================================================
        $GetPartition = Get-Partition | `
        Sort-Object -Property DriveLetter | `
        Select-Object -Property DriveLetter, DiskNumber
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
                
                DiskNumber          = $Item.DiskNumber
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