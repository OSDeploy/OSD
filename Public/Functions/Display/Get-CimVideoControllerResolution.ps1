<#
.SYNOPSIS
Returns the CIM_VideoControllerResolution Properties for the Primary Screen

.DESCRIPTION
Returns the CIM_VideoControllerResolution Properties for the Primary Screen

.LINK
https://osd.osdeploy.com/module/functions/cim

.NOTES
21.2.1  Initial Release
#>
function Get-CimVideoControllerResolution {
    [CmdletBinding()]
    param (

        #Returns Interlaced resolutions
        [System.Management.Automation.SwitchParameter]$Interlaced=$false
    )

    $GetMyVideoControllerResolution = (Get-CimInstance -Class CIM_VideoControllerResolution | Select-Object -Property * | `
    Select-Object SettingID, Caption, HorizontalResolution, VerticalResolution, NumberOfColors, RefreshRate, ScanMode | `
    Sort-Object HorizontalResolution, VerticalResolution -Descending)

    #HorizontalResolution -ge 800
    $GetMyVideoControllerResolution = $GetMyVideoControllerResolution | Where-Object {$_.HorizontalResolution -ge 800}

    if ($Interlaced -eq $true) {
        #Interlaced
        $GetMyVideoControllerResolution = $GetMyVideoControllerResolution | Where-Object {$_.ScanMode -eq 5}
    }
    else {
        $Progressive
        $GetMyVideoControllerResolution = $GetMyVideoControllerResolution | Where-Object {$_.ScanMode -eq 4}
    }

    Return $GetMyVideoControllerResolution
}