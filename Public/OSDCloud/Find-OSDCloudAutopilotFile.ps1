<#
.SYNOPSIS
Searches all PSDrives for Autopilot Profiles [PSDrive]:\OSDCloud\Autopilot\Profiles

.Description
Searches all PSDrives for Autopilot Profiles [PSDrive]:\OSDCloud\Autopilot\Profiles

.LINK
https://osdcloud.osdeploy.com

.NOTES
21.4.6  Modified function to display Unique results
21.4.6  Removed Name parameter as that served no purpose
#>
function Find-OSDCloudAutopilotFile {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #	Create the Array
    #=======================================================================
    $Results = @()
    #=======================================================================
    #	Search for Autopilot Profiles
    #=======================================================================
    $Results = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        Get-ChildItem "$($_.Name):\OSDCloud\Autopilot\Profiles" -Include *.json -File -Recurse -Force -ErrorAction Ignore
    }
    #=======================================================================
    #	Results
    #=======================================================================
    $Results = $Results | Sort-Object -Property Name -Unique
    $Results
    #=======================================================================
}