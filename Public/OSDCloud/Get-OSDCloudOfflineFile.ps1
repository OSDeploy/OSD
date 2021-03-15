function Get-OSDCloudOfflineFile {
    [CmdletBinding()]
    param (
        [string]$Name
    )
    $OSDCloudOfflineFile = @()
    $OSDCloudOfflineFile = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        Get-ChildItem "$($_.Name):\OSDCloud\" -Include "$Name" -File -Recurse -Force -ErrorAction Ignore
    }
    $OSDCloudOfflineFile
}