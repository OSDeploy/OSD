<#
.SYNOPSIS
Returns the CIM_VideoControllerResolution Properties for the Primary Screen

.DESCRIPTION
Returns the CIM_VideoControllerResolution Properties for the Primary Screen

.LINK
https://osd.osdeploy.com/module/functions/display/get-cimvideocontrollerresolution

.NOTES
21.2.1  Initial Release
#>
function Get-CIMVideoControllerResolution {
    [CmdletBinding()]
    Param (

        #Returns Interlaced resolutions
        [switch]$Interlaced=$false
    )

    $Results = (Get-CimInstance -Class CIM_VideoControllerResolution | Select-Object -Property * | `
    Select-Object SettingID, Caption, HorizontalResolution, VerticalResolution, NumberOfColors, RefreshRate, ScanMode | `
    Sort-Object HorizontalResolution, VerticalResolution -Descending)

    #HorizontalResolution -ge 800
    $Results = $Results | Where-Object {$_.HorizontalResolution -ge 800}

    if ($Interlaced -eq $true) {
        #Interlaced
        $Results = $Results | Where-Object {$_.ScanMode -eq 5}
    } else {
        $Progressive
        $Results = $Results | Where-Object {$_.ScanMode -eq 4}
    }


    Return $Results
}