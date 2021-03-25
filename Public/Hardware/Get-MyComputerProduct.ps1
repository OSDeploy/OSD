<#
.SYNOPSIS
Returns the ComputerSystem Product (SystemSku, BaseBoardProduct)

.DESCRIPTION
Returns the ComputerSystem Product (SystemSku, BaseBoardProduct)

.LINK
https://osd.osdeploy.com/module/functions/getmy

.NOTES
21.3.24     Initial Release
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