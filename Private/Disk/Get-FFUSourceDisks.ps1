function Get-FFUSourceDisks {
    [CmdletBinding()]
    param ()
    Get-Disk.fixed | Where-Object {$_.NumberOfPartitions -ge '1'} | Where-Object {$_.OperationalStatus -eq 'Online'} | Where-Object {$_.Size -gt 0} | Where-Object {$_.IsOffline -eq $false} | Where-Object {$_.IsBoot -eq $false}
}