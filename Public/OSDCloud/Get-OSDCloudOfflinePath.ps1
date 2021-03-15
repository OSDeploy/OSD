function Get-OSDCloudOfflinePath {
    [CmdletBinding()]
    param ()
    $OSDCloudOfflinePath = @()
    $OSDCloudOfflinePath = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Get-Item "$($_.Name):\OSDCloud" -Force -ErrorAction Ignore
    }
    $OSDCloudOfflinePath
}