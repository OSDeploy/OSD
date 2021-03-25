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
21.3.9  Updated Microsoft
21.2.2  Initial Release
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
        elseif ($GetMyComputerManufacturer -match 'Microsoft') {$GetMyComputerManufacturer = 'Microsoft'}
        elseif ($GetMyComputerManufacturer -match 'to be filled') {$GetMyComputerManufacturer = 'Generic'}
    }

    $GetMyComputerManufacturer
}