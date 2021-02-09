<#
.SYNOPSIS
Displays Power Plan information using powercfg /LIST

.DESCRIPTION
Displays Power Plan information using powercfg /LIST.  Optionally Set an Active Power Plan

.EXAMPLE
OSDPower
Returns Power Plan information using powercfg /LIST
Option 1: Get-OSDPower
Option 2: Get-OSDPower LIST
Option 3: Get-OSDPower -Property LIST

.EXAMPLE
OSDPower High
Sets the active Power Plan to High Performance
Option 1: Get-OSDPower High
Option 2: Get-OSDPower -Property High

.LINK
https://osd.osdeploy.com/module/functions/general/get-osdpower

.NOTES
19.10.1     David Segura @SeguraOSD
#>
function Get-OSDPower {
    [CmdletBinding()]
    param (
        #Powercfg option (Low, Balanced, High, LIST, QUERY)
        #Default is LIST
        [Parameter(Position = 0)]
        [ValidateSet('Low','Balanced','High','LIST','QUERY')]
        [string]$Property = 'LIST'
    )

    if ($Property -eq 'Low') {
        Write-Verbose 'OSDPower: Enable Power Saver Power Plan'
        Start-Process -WindowStyle Hidden -FilePath powercfg.exe -ArgumentList ('-SetActive','a1841308-3541-4fab-bc81-f71556f20b4a') -Wait
    }
    if ($Property -eq 'Balanced') {
        Write-Verbose 'OSDPower: Enable Balanced Power Plan'
        Start-Process -WindowStyle Hidden -FilePath powercfg.exe -ArgumentList ('-SetActive','381b4222-f694-41f0-9685-ff5bb260df2e') -Wait
    }
    if ($Property -eq 'High') {
        Write-Verbose 'OSDPower: Enable High Performance Power Plan'
        Start-Process -WindowStyle Hidden -FilePath powercfg.exe -ArgumentList ('-SetActive','8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c') -Wait
    }
    if ($Property -eq 'LIST') {
        Write-Verbose 'OSDPower: Lists all power schemes'
        powercfg.exe /LIST
    }
    if ($Property -eq 'QUERY') {
        Write-Verbose 'OSDPower: Displays the contents of a power scheme'
        powercfg.exe /QUERY
    }
}