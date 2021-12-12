function Add-WindowsDriver.offlineservicing {
    [CmdletBinding()]
    param (
        [string]$Path = 'C:\Drivers'
    )
$UnattendXml = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="offlineServicing">
        <component name="Microsoft-Windows-PnpCustomizationsNonWinPE" processorArchitecture="x86" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DriverPaths>
                <PathAndCredentials wcm:keyValue="1" wcm:action="add">
                    <Path>$Path</Path>
                </PathAndCredentials>
            </DriverPaths>
        </component>
        <component name="Microsoft-Windows-PnpCustomizationsNonWinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DriverPaths>
                <PathAndCredentials wcm:keyValue="1" wcm:action="add">
                    <Path>$Path</Path>
                </PathAndCredentials>
            </DriverPaths>
        </component>
    </settings>
</unattend>
"@
    #=================================================
    #	Block
    #=================================================
    Block-WinOS
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5    
    #=================================================
    #	Use-WindowsUnattend
    #=================================================
    $Random = Get-Random
    $UnattendXml | Out-File -FilePath "$env:TEMP\$Random.xml" -Encoding utf8 -Width 2000 -Force
    Use-WindowsUnattend -Path 'C:\' -UnattendPath "$env:TEMP\$Random.xml"
    #=================================================
}