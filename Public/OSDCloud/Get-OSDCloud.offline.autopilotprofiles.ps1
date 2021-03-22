function Get-OSDCloud.offline.autopilotprofiles {
    [CmdletBinding()]
    param (
        [string]$Name
    )
    $OSDCloudAutoOfflinePilotProfiles = @()
    $OSDCloudAutoOfflinePilotProfiles = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        Get-ChildItem "$($_.Name):\OSDCloud\AutoPilot\Profiles" -Include *.json -File -Recurse -Force -ErrorAction Ignore
    }
    $OSDCloudAutoOfflinePilotProfiles
}