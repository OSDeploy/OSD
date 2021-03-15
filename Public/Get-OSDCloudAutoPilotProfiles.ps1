function Get-OSDCloudAutoPilotProfiles {
    [CmdletBinding()]
    param (
        [string]$Name
    )
    $OSDCloudAutoPilotProfiles = @()
    $OSDCloudAutoPilotProfiles = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        Get-ChildItem "$($_.Name):\OSDCloud\AutoPilot\Profiles" -Include *.json -File -Recurse -ErrorAction Ignore
    }
    $OSDCloudAutoPilotProfiles
}