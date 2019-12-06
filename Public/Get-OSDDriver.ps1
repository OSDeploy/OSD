<#
.SYNOPSIS
Returns Driver information from Online and Local sources

.DESCRIPTION
Returns Driver information from Online and Local sources.  Used by OSDDrivers Module
Value is returned as Global Variable $GetOSDDriver

.LINK
https://osd.osdeploy.com/module/functions/get-osddriver

.NOTES
19.12.6     David Segura @SeguraOSD
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
    #	Information
    #======================================================================================================
    Write-Verbose 'OSD: Results are saved in the Global Variable $GetOSDDriver for this PowerShell session' -Verbose
    $global:GetOSDDriver = @()
    #======================================================================================================
    #	Execute Private Function
    #======================================================================================================
    if ($DriverGroup -eq 'AmdDisplay') {
        Write-Verbose "OSD: $DriverGroup Drivers are generated from OSD Local Catalogs and may not always have the latest versions" -Verbose
        $global:GetOSDDriver = Get-OSDDriverAmdDisplay
    }
    if ($DriverGroup -eq 'DellFamily') {
        Write-Verbose "OSD: $DriverGroup Drivers are pulled in real time from the vendor's website and should always have the latest versions" -Verbose
        $global:GetOSDDriver = Get-OSDDriverDellFamily
    }
    if ($DriverGroup -eq 'DellModel') {
        Write-Verbose "OSD: $DriverGroup Drivers are pulled in real time from the vendor's Catalogs and should always have the latest versions" -Verbose
        $global:GetOSDDriver = Get-OSDDriverDellModel
    }
    if ($DriverGroup -eq 'HpModel') {
        Write-Verbose "OSD: $DriverGroup Drivers are pulled in real time from the vendor's Catalogs and should always have the latest versions" -Verbose
        $global:GetOSDDriver = Get-OSDDriverHpModel
    }
    if ($DriverGroup -eq 'IntelDisplay') {
        Write-Verbose "OSD: $DriverGroup Drivers are pulled in real time from the vendor's website and should always have the latest versions" -Verbose
        $global:GetOSDDriver = Get-OSDDriverIntelDisplay
    }
    if ($DriverGroup -eq 'IntelWireless') {
        Write-Verbose "OSD: $DriverGroup Drivers are pulled in real time from the vendor's website and should always have the latest versions" -Verbose
        $global:GetOSDDriver = Get-OSDDriverIntelWireless
    }
    if ($DriverGroup -eq 'NvidiaDisplay') {
        Write-Verbose "OSD: $DriverGroup Drivers are generated from OSD Local Catalogs and may not always have the latest versions" -Verbose
        $global:GetOSDDriver = Get-OSDDriverNvidiaDisplay
    }
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