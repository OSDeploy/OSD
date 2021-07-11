<#
.SYNOPSIS
Returns the Bios SerialNumber

.DESCRIPTION
Returns the Bios SerialNumber

.PARAMETER Brief
Returns a short version removing soem non-standard characters

.LINK
https://osd.osdeploy.com/module/functions

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
https://osd.osdeploy.com/module/functions

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
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-MyComputerManufacturer {
    [CmdletBinding()]
    param (
        [switch]$Brief
    )
    #Should always opt for CIM over WMI
    $MyComputerManufacturer = ((Get-CimInstance -ClassName CIM_ComputerSystem).Manufacturer).Trim()
    Write-Verbose $MyComputerManufacturer

    #Sometimes vendors are not always consistent, i.e. Dell or Dell Inc.
    #So need to detmine the Brief Manufacturer to normalize results
    if ($Brief -eq $true) {
        if ($MyComputerManufacturer -match 'Dell') {$MyComputerManufacturer = 'Dell'}
        if ($MyComputerManufacturer -match 'Lenovo') {$MyComputerManufacturer = 'Lenovo'}
        if ($MyComputerManufacturer -match 'Hewlett') {$MyComputerManufacturer = 'HP'}
        if ($MyComputerManufacturer -match 'Packard') {$MyComputerManufacturer = 'HP'}
        if ($MyComputerManufacturer -match 'HP') {$MyComputerManufacturer = 'HP'}
        if ($MyComputerManufacturer -match 'Microsoft') {$MyComputerManufacturer = 'Microsoft'}
        if ($MyComputerManufacturer -match 'Panasonic') {$MyComputerManufacturer = 'Panasonic'}
        if ($MyComputerManufacturer -match 'to be filled') {$MyComputerManufacturer = 'OEM'}
        if ($null -eq $MyComputerManufacturer) {$MyComputerManufacturer = 'OEM'}
    }
    $MyComputerManufacturer
}
<#
.SYNOPSIS
Returns the Computer Model

.DESCRIPTION
Returns the Computer Model

.PARAMETER Brief
Returns a modified Computer Model for Generic and Unknown

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-MyComputerModel {
    [CmdletBinding()]
    param (
        #Normalize the Return
        [switch]$Brief
    )

    $MyComputerManufacturer = Get-MyComputerManufacturer -Brief

    if ($MyComputerManufacturer -eq 'Lenovo') {
        $MyComputerModel = ((Get-CimInstance -ClassName Win32_ComputerSystemProduct).Version).Trim()
    }
    else {
        $MyComputerModel = ((Get-CimInstance -ClassName CIM_ComputerSystem).Model).Trim()
    }
    Write-Verbose $MyComputerModel

    if ($Brief -eq $true) {
        if ($MyComputerModel -eq '') {$MyComputerModel = 'OEM'}
        if ($MyComputerModel -match 'to be filled') {$MyComputerModel = 'OEM'}
        if ($null -eq $MyComputerModel) {$MyComputerModel = 'OEM'}
    }
    $MyComputerModel
}
<#
.SYNOPSIS
Returns the ComputerSystem Product (SystemSku, BaseBoardProduct)

.DESCRIPTION
Returns the ComputerSystem Product (SystemSku, BaseBoardProduct)

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-MyComputerProduct {
    [CmdletBinding()]
    param ()

    $MyComputerManufacturer = Get-MyComputerManufacturer -Brief

    if ($MyComputerManufacturer -eq 'Dell') {
        ((Get-CimInstance -ClassName CIM_ComputerSystem).SystemSKUNumber).Trim()
    }
    elseif ($MyComputerManufacturer -eq 'HP')  {
        ((Get-WmiObject -Class Win32_BaseBoard).Product).Trim()
    }
    elseif ($MyComputerManufacturer -eq 'Lenovo')  {
        #Thanks Maurice
        ((Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Model).SubString(0, 4)).Trim()
    }
    elseif ($MyComputerManufacturer -eq 'Microsoft')  {
        #Surface_Book
        #Surface_Pro_3
        (Get-CimInstance -ClassName CIM_ComputerSystem).SystemSKUNumber
        #Surface Book
        #Surface Pro 3
        #((Get-WmiObject -Class Win32_BaseBoard).Product).Trim()
    }
    else {
        Get-MyComputerModel -Brief
    }
}
