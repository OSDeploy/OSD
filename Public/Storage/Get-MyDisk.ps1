function Get-MyDisk {
    [CmdletBinding()]
    param ()

    $GetDisk = Get-Disk | Sort-Object DiskNumber
    $GetPhysicalDisk = Get-PhysicalDisk | Sort-Object DeviceId

    $MyDisk = foreach ($Disk in $GetDisk) {
        foreach ($PhysicalDisk in $GetPhysicalDisk | Where-Object {$_.DeviceId -eq $Disk.Number}) {
            [PSCustomObject] @{
                Number          = $Disk.Number
                'Size(GB)'      = [double]($Disk.Size / 1GB).ToString("#.##")
                BusType         = $Disk.BusType
                MediaType       = $PhysicalDisk.MediaType
                Name            = $Disk.FriendlyName
            }
        }
    }

    Return $MyDisk
}