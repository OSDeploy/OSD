<#
.SYNOPSIS
Returns Driver information from Online and Local sources

.DESCRIPTION
Returns Driver information from Online and Local sources.  Used by OSDDrivers Module
Value is returned as Global Variable $GetOSDDriver

.LINK
https://osd.osdeploy.com/module/functions/get-osddriver

.NOTES
19.12.5     David Segura @SeguraOSD
#>
function Get-OSDDriver {
    [CmdletBinding()]
    Param (
        #Limits the results to the specified DriverGroup
        [ValidateSet('AmdDisplay','DellFamily','DellModel','HpModel','IntelDisplay','IntelWireless','NvidiaDisplay')]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName)]
        [Alias('Group','OSDGroup')]
        [string]$DriverGroup,

        #Select results in GridView with PassThru
        [switch]$GridView
    )
    #======================================================================================================
    #	Execute Private Function
    #======================================================================================================
    $global:GetOSDDriver = @()
    if ($DriverGroup -eq 'AmdDisplay')      {$global:GetOSDDriver = Get-OSDDriverAmdDisplay}
    if ($DriverGroup -eq 'DellFamily')      {$global:GetOSDDriver = Get-OSDDriverDellFamily}
    if ($DriverGroup -eq 'DellModel')       {$global:GetOSDDriver = Get-OSDDriverDellModel}
    if ($DriverGroup -eq 'HpModel')         {$global:GetOSDDriver = Get-OSDDriverHpModel}
    if ($DriverGroup -eq 'IntelDisplay')    {$global:GetOSDDriver = Get-OSDDriverIntelDisplay}
    if ($DriverGroup -eq 'IntelWireless')   {$global:GetOSDDriver = Get-OSDDriverIntelWireless}
    if ($DriverGroup -eq 'NvidiaDisplay')   {$global:GetOSDDriver = Get-OSDDriverNvidiaDisplay}
    #======================================================================================================
    #	GridView
    #======================================================================================================
    if ($GridView.IsPresent) {
        $global:GetOSDDriver = $global:GetOSDDriver | Out-GridView -PassThru -Title 'Select Results with PassThru'
    }
    #======================================================================================================
    #	Return
    #======================================================================================================
    Return $global:GetOSDDriver
}