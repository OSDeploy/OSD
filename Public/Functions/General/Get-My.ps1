<#
.SYNOPSIS
Returns the Win32_BIOS SerialNumber

.DESCRIPTION
Returns the Win32_BIOS SerialNumber

.PARAMETER Brief
Returns a short version removing soem non-standard characters

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-MyBiosSerialNumber {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Brief
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
https://osd.osdeploy.com

.NOTES
#>
function Get-MyBiosVersion {
    [CmdletBinding()]
    param ()

    $CimBios = Get-CimInstance -ClassName Win32_BIOS
    if ($CimBios.Manufacturer -match 'Lenovo') {
        $SystemBiosMajorVersion = $CimBios.SystemBiosMajorVersion
        $SystemBiosMinorVersion = $CimBios.SystemBiosMinorVersion
        $MyBiosVersion = "$SystemBiosMajorVersion.$SystemBiosMinorVersion"
        Return $MyBiosVersion
    }
    else {
        ((Get-CimInstance -ClassName Win32_BIOS).SMBIOSBIOSVersion).Trim()
    }
}
<#
.SYNOPSIS
Returns the Computer Manufacturer

.DESCRIPTION
Returns the Computer Manufacturer

.PARAMETER Brief
Returns a shortened Computer Manufacturer

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-MyComputerManufacturer {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Brief
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
https://osd.osdeploy.com

.NOTES
#>
function Get-MyComputerModel {
    [CmdletBinding()]
    param (
        #Normalize the Return
        [System.Management.Automation.SwitchParameter]$Brief
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
https://osd.osdeploy.com

.NOTES
#>
function Get-MyComputerProduct {
    [CmdletBinding()]
    param ()

    $MyComputerManufacturer = Get-MyComputerManufacturer -Brief

    if ($MyComputerManufacturer -eq 'Dell') {
        $Result = (Get-CimInstance -ClassName CIM_ComputerSystem).SystemSKUNumber
    }
    elseif ($MyComputerManufacturer -eq 'HP')  {
        $Result = (Get-CimInstance -ClassName Win32_BaseBoard).Product
    }
    elseif ($MyComputerManufacturer -eq 'Lenovo')  {
        #Thanks Maurice
        $Result = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty Model).SubString(0, 4)
    }
    elseif ($MyComputerManufacturer -eq 'Microsoft')  {
        #Surface_Book
        #Surface_Pro_3
        $Result = (Get-CimInstance -ClassName CIM_ComputerSystem).SystemSKUNumber
        #Surface Book
        #Surface Pro 3
        #((Get-WmiObject -Class Win32_BaseBoard).Product).Trim()
    }
    else {
        $Result = Get-MyComputerModel -Brief
    }
    
    if ($null -eq $Result) {
        $Result = 'Unknown'
    }

    ($Result).Trim()
}
