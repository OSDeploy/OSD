function Get-DataStore {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #   Get-Partition Information
    #=======================================================================
    $GetPartition = Get-Partition | `
    Where-Object {$_.DriveLetter -gt 0} | `
    Where-Object {$_.IsOffline -eq $false} | `
    Where-Object {$_.IsReadOnly -ne $true} | `
    Where-Object {$_.Size -gt 10000000000} | `
    Sort-Object -Property DriveLetter | `
    Select-Object -Property DriveLetter, DiskNumber
    #=======================================================================
    #   Get-Volume Information
    #=======================================================================
    $GetVolume = $(Get-Volume | `
    Sort-Object -Property DriveLetter | `
    Select-Object -Property DriveLetter,FileSystem,OperationalStatus,DriveType,FileSystemLabel,Size,SizeRemaining)
    #=======================================================================
    #   Create Object
    #=======================================================================
    $LocalResults = foreach ($Item in $GetPartition) {
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
    #=======================================================================
    #   Get-DriveInfo
    #=======================================================================
    $GetNetworkDrives = [System.IO.DriveInfo]::getdrives() | Where-Object {$_.DriveType -eq 'Network'} | Where-Object {$_.DriveFormat -eq 'NTFS'}
    $NetworkResults = foreach ($Item in $GetNetworkDrives) {
        $ObjectProperties = @{
            DiskNumber          = 99
            DriveLetter         = ($Item.Name).substring(0,1)
            FileSystem          = 'NTFS'
            OperationalStatus   = $Item.IsReady
            DriveType           = 'Network'
            FileSystemLabel     = $Item.VolumeLabel
            Size                = $Item.TotalSize
            SizeRemaining       = $Item.TotalFreeSpace

        }
        New-Object -TypeName PSObject -Property $ObjectProperties
    }
    #=======================================================================
    #   Return Results
    #=======================================================================
    $LocalResults = $LocalResults | Sort-Object -Property DriveLetter
    $LocalResults = $LocalResults | Where-Object {$_.FileSystem -eq 'NTFS'}
    [array]$Results = [array]$LocalResults + [array]$NetworkResults
    Return [array]$Results
}