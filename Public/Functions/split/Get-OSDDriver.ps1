<#
.SYNOPSIS
Returns Driver information from Online and Local sources

.DESCRIPTION
Returns Driver information from Online and Local sources.  Used by OSDDrivers Module
Value is returned as Global Variable $GetOSDDriver

.LINK
https://osd.osdeploy.com/module/functions/driver/get-osddriver
#>
function Get-OSDDriver {
    [CmdletBinding()]
    param (
        #Limits the results to the specified OSDGroup
        [ValidateSet('AmdDisplay','DellFamily','DellModel','HpModel','IntelDisplay','IntelRadeonDisplay','IntelWireless','NvidiaDisplay')]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName)]
        [Alias('Group')]
        [string]$OSDGroup,

        #Select results in GridView with PassThru
        [System.Management.Automation.SwitchParameter]$GridView
    )
    #=================================================
    #	Information
    #=================================================
    Write-Verbose 'Get-OSDDriver: Results are saved in the Global Variable $GetOSDDriver for this PowerShell session'
    $global:GetOSDDriver = @()
    #=================================================
    #	Execute Private Function
    #=================================================
    if ($OSDGroup -eq 'AmdDisplay') {
        Write-Verbose "Get-OSDDriver: $OSDGroup Drivers are generated from OSD Local Catalogs and may not always have the latest versions"
        $global:GetOSDDriver = Get-OSDDriverAmdDisplay
    }
    if ($OSDGroup -eq 'DellFamily') {
        Write-Verbose "Get-OSDDriver: $OSDGroup Drivers are pulled in real time from the vendor's website and should always have the latest versions"
        $global:GetOSDDriver = Get-OSDDriverDellFamily
    }
    if ($OSDGroup -eq 'DellModel') {
        Write-Verbose "Get-OSDDriver: $OSDGroup Drivers are pulled in real time from the vendor's Catalogs and should always have the latest versions"
        $global:GetOSDDriver = Get-OSDDriverDellModel
    }
    if ($OSDGroup -eq 'HpModel') {
        Write-Verbose "Get-OSDDriver: $OSDGroup Drivers are pulled in real time from the vendor's Catalogs and should always have the latest versions"
        $global:GetOSDDriver = Get-OSDDriverHpModel
    }
    if ($OSDGroup -eq 'IntelDisplay') {
        Write-Verbose "Get-OSDDriver: $OSDGroup Drivers are pulled in real time from the vendor's website and should always have the latest versions"
        $global:GetOSDDriver = Get-OSDCatalogIntelDisplayDriver
    }
    if ($OSDGroup -eq 'IntelRadeonDisplay') {
        Write-Verbose "Get-OSDDriver: $OSDGroup Drivers are pulled in real time from the vendor's website and should always have the latest versions"
        $global:GetOSDDriver = Get-OSDCatalogIntelRadeonDisplayDriver
    }
    if ($OSDGroup -eq 'IntelWireless') {
        Write-Verbose "Get-OSDDriver: $OSDGroup Drivers are pulled in real time from the vendor's website and should always have the latest versions"
        $global:GetOSDDriver = Get-OSDCatalogIntelWirelessDriver
    }
    if ($OSDGroup -eq 'NvidiaDisplay') {
        Write-Verbose "Get-OSDDriver: $OSDGroup Drivers are generated from OSD Local Catalogs and may not always have the latest versions"
        $global:GetOSDDriver = Get-OSDDriverNvidiaDisplay
    }
    #=================================================
    #	GridView
    #=================================================
    if ($GridView.IsPresent) {
        $global:GetOSDDriver = $global:GetOSDDriver | Out-GridView -PassThru -Title 'Select Results with PassThru'
    }
    #=================================================
    #	Return
    #=================================================
    Return $global:GetOSDDriver
}