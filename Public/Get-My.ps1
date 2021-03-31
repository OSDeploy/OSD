<#
.SYNOPSIS
Returns the Bios SerialNumber

.DESCRIPTION
Returns the Bios SerialNumber

.PARAMETER Brief
Returns a short version removing soem non-standard characters

.LINK
https://osd.osdeploy.com/module/functions/getmy

.NOTES
#>
function Get-MyBiosSerialNumber {
    [CmdletBinding()]
    param (
        #Normalize the Return
        [switch]$Brief
    )

    $Result = ((Get-CimInstance -ClassName Win32_BIOS).SerialNumber).Trim()

    if ($Brief -eq $true) {
        if ($null -eq $Result) {$Result = 'Unknown'}
        elseif ($Result -eq '') {$Result = 'Unknown'}

        #Allow only a-z A-Z 0-9
        $Result = $Result -replace '_'
        $Result = $Result -replace '\W'
    }
    $Result
}
<#
.SYNOPSIS
Returns the Bios Version

.DESCRIPTION
Returns the Bios Version

.LINK
https://osd.osdeploy.com/module/functions/getmy

.NOTES
#>
function Get-MyBiosVersion {
    [CmdletBinding()]
    param ()

    ((Get-CimInstance -ClassName Win32_BIOS).SMBIOSBIOSVersion).Trim()
}
<#
.SYNOPSIS
Returns the Computer Manufacturer

.DESCRIPTION
Returns the Computer Manufacturer

.PARAMETER Brief
Returns a shortened Computer Manufacturer

.LINK
https://osd.osdeploy.com/module/functions/getmy

.NOTES
#>
function Get-MyComputerManufacturer {
    [CmdletBinding()]
    param (
        [switch]$Brief
    )
    $Result = ((Get-CimInstance -ClassName CIM_ComputerSystem).Manufacturer).Trim()
    
    if ($Brief -eq $true) {
        if ($null -eq $Result) {$Result = 'Unknown'}
        elseif ($Result -eq '') {$Result = 'Unknown'}
        elseif ($Result -match 'Dell') {$Result = 'Dell'}
        elseif ($Result -match 'Lenovo') {$Result = 'Lenovo'}
        elseif ($Result -match 'Hewlett Packard') {$Result = 'HP'}
        elseif ($Result -match 'HP') {$Result = 'HP'}
        elseif ($Result -match 'Microsoft') {$Result = 'Microsoft'}
        elseif ($Result -match 'Panasonic') {$Result = 'Panasonic'}
        elseif ($Result -match 'to be filled') {$Result = 'Generic'}
    }
    $Result
}
<#
.SYNOPSIS
Returns the Computer Model

.DESCRIPTION
Returns the Computer Model

.PARAMETER Brief
Returns a modified Computer Model for Generic and Unknown

.LINK
https://osd.osdeploy.com/module/functions/getmy

.NOTES
#>
function Get-MyComputerModel {
    [CmdletBinding()]
    param (
        #Normalize the Return
        [switch]$Brief
    )

    if ((Get-MyComputerManufacturer -Brief) -match 'Lenovo') {
        $Result = ((Get-CimInstance -ClassName Win32_ComputerSystemProduct).Version).Trim()
    } else {
        $Result = ((Get-CimInstance -ClassName CIM_ComputerSystem).Model).Trim()
    }

    if ($Brief -eq $true) {
        if ($null -eq $Result) {$Result = 'Unknown'}
        elseif ($Result -eq '') {$Result = 'Unknown'}
        elseif ($Result -match 'to be filled') {$Result = 'Generic'}
    }
    $Result
}
<#
.SYNOPSIS
Returns the ComputerSystem Product (SystemSku, BaseBoardProduct)

.DESCRIPTION
Returns the ComputerSystem Product (SystemSku, BaseBoardProduct)

.LINK
https://osd.osdeploy.com/module/functions/getmy

.NOTES
#>
function Get-MyComputerProduct {
    [CmdletBinding()]
    param ()

    $Manufacturer = Get-MyComputerManufacturer -Brief

    if ($Manufacturer -match 'Dell') {
        ((Get-WmiObject -Class Win32_ComputerSystem).SystemSKUNumber).Trim()
    }
    elseif ($Manufacturer -match 'HP')  {
        ((Get-WmiObject -Class Win32_BaseBoard).Product).Trim()
    }
    elseif ($Manufacturer -match 'Lenovo')  {
        ((Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Model).SubString(0, 4)).Trim()
    }
    elseif ($Manufacturer -match 'Microsoft')  {
        (Get-WmiObject -Namespace root\wmi -Class MS_SystemInformation | Select-Object -ExpandProperty SystemSKU).Replace("_", " ")
    }
    else {
        (Get-CIMInstance -ClassName MS_SystemInformation -NameSpace root\WMI).BaseBoardProduct
    }
}



