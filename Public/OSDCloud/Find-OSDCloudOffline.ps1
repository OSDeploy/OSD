function Find-OSDCloudOfflineFile {
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
function Find-OSDCloudOfflinePath {
    [CmdletBinding()]
    param ()
    $OSDCloudOfflinePath = @()
    $OSDCloudOfflinePath = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -ne 'C'} | ForEach-Object {
        Get-Item "$($_.Name):\OSDCloud" -Force -ErrorAction Ignore
    }
    $OSDCloudOfflinePath
}
function Find-OSDCloudOffline.wim {
    [CmdletBinding()]
    param (
        [string]$Name = '*.wim'
    )
    $Results = @()
    $Results = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        Get-ChildItem "$($_.Name):\OSDCloud\WIM\" -Include "$Name" -File -Recurse -Force -ErrorAction Ignore
    }
    $Results
}