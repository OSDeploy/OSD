<#
.SYNOPSIS
Searches all PSDrives for Office Configuration Files [PSDrive]:\OSDCloud\ODT

.Description
Searches all PSDrives for Office Configuration Files [PSDrive]:\OSDCloud\ODT

.LINK
https://osdcloud.osdeploy.com

.NOTES
#>
function Find-OSDCloudODTFile {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #	Create the Array
    #=======================================================================
    $Results = @()
    #=======================================================================
    #	Search for AutoPilot Profiles
    #=======================================================================
    $Results = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        Get-ChildItem "$($_.Name):\OSDCloud\ODT\*\*\*.xml" -File -Force -ErrorAction Ignore
    }
    #=======================================================================
    #	Results
    #=======================================================================
    $Results | Sort-Object -Property Name -Descending -Unique
    #=======================================================================
}