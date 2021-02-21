<#
.SYNOPSIS
Returns the Bios SerialNumber

.DESCRIPTION
Returns the Bios SerialNumber

.LINK
https://osd.osdeploy.com/module/functions/getmy

.NOTES
21.2.2     Initial Release
#>
function Get-MyBiosSerialNumber {
    [CmdletBinding()]
    param (
        #Normalize the Return
        [switch]$Brief
    )

    $GetMyBiosSerialNumber = ((Get-CimInstance -ClassName Win32_BIOS).SerialNumber).Trim()

    if ($Brief -eq $true) {
        if ($null -eq $GetMyBiosSerialNumber) {$GetMyBiosSerialNumber = 'Unknown'}
        elseif ($GetMyBiosSerialNumber -eq '') {$GetMyBiosSerialNumber = 'Unknown'}

        #Allow only a-z A-Z 0-9
        $GetMyBiosSerialNumber = $GetMyBiosSerialNumber -replace '_'
        $GetMyBiosSerialNumber = $GetMyBiosSerialNumber -replace '\W'
    }

    Return $GetMyBiosSerialNumber
}
<#
.SYNOPSIS
Returns the Bios Version

.DESCRIPTION
Returns the Bios Version

.LINK
https://osd.osdeploy.com/module/functions/getmy

.NOTES
21.2.2     Initial Release
#>
function Get-MyBiosVersion {
    [CmdletBinding()]
    param ()

    Return ((Get-CimInstance -ClassName Win32_BIOS).SMBIOSBIOSVersion).Trim()
}
<#
.SYNOPSIS
Returns the Computer Manufacturer

.DESCRIPTION
Returns the Computer Manufacturer

.PARAMETER Brief
Returns a brief Computer Manufacturer

.LINK
https://osd.osdeploy.com/module/functions/getmy

.NOTES
21.2.2     Initial Release
#>
function Get-MyComputerManufacturer {
    [CmdletBinding()]
    param (
        #Normalize the Return
        [switch]$Brief
    )
    $GetMyComputerManufacturer = ((Get-CimInstance -ClassName CIM_ComputerSystem).Manufacturer).Trim()
    
    if ($Brief -eq $true) {
        if ($null -eq $GetMyComputerManufacturer) {$GetMyComputerManufacturer = 'Unknown'}
        elseif ($GetMyComputerManufacturer -eq '') {$GetMyComputerManufacturer = 'Unknown'}
        elseif ($GetMyComputerManufacturer -match 'Dell') {$GetMyComputerManufacturer = 'Dell'}
        elseif ($GetMyComputerManufacturer -match 'Lenovo') {$GetMyComputerManufacturer = 'Lenovo'}
        elseif ($GetMyComputerManufacturer -match 'Hewlett Packard') {$GetMyComputerManufacturer = 'HP'}
        elseif ($GetMyComputerManufacturer -match 'HP') {$GetMyComputerManufacturer = 'HP'}
        elseif ($GetMyComputerManufacturer -match 'to be filled') {$GetMyComputerManufacturer = 'Generic'}
    }

    Return $GetMyComputerManufacturer
}
<#
.SYNOPSIS
Returns the Computer Model

.DESCRIPTION
Returns the Computer Model

.LINK
https://osd.osdeploy.com/module/functions/getmy

.NOTES
21.2.2     Initial Release
#>
function Get-MyComputerModel {
    [CmdletBinding()]
    param (
        #Normalize the Return
        [switch]$Brief
    )

    if ((Get-MyComputerManufacturer -Brief) -match 'Lenovo') {
        $GetMyComputerModel = ((Get-CimInstance -ClassName Win32_ComputerSystemProduct).Version).Trim()
    } else {
        $GetMyComputerModel = ((Get-CimInstance -ClassName CIM_ComputerSystem).Model).Trim()
    }

    if ($Brief -eq $true) {
        if ($null -eq $GetMyComputerModel) {$GetMyComputerModel = 'Unknown'}
        elseif ($GetMyComputerModel -eq '') {$GetMyComputerModel = 'Unknown'}
        elseif ($GetMyComputerModel -match 'to be filled') {$GetMyComputerModel = 'Generic'}
    }

    Return $GetMyComputerModel
}
<#
.SYNOPSIS
Returns the Default AU Service from Microsoft.Update.ServiceManager

.DESCRIPTION
Returns the Default AU Service from Microsoft.Update.ServiceManager

.LINK
https://osd.osdeploy.com/module/functions/getmy

.LINK
https://twitter.com/byteben/status/1356893619811155968

.NOTES
21.2.3  Initial Release
        Credit Ben Whitmore | byteben.com | @byteben
21.2.9  Removed unnecessary Brief parameter
        Modified command
        
#>
function Get-MyDefaultAUService {
    [CmdletBinding()]
    param ()

    ((New-Object -ComObject Microsoft.Update.ServiceManager).Services | Where-Object {$_.IsDefaultAUService -eq $true}).Name
}