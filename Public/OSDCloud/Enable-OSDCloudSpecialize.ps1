function Enable-OSDCloudSpecialize {
    [CmdletBinding()]
    param ()
$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Description>OSDCloud Specialize</Description>
                    <Path>Powershell -ExecutionPolicy Bypass -Command Start-OSDCloudSpecialize -Verbose</Path>
                </RunSynchronousCommand>
            </RunSynchronous>
        </component>
    </settings>
</unattend>
'@
    #=======================================================================
    #	Block
    #=======================================================================
    Block-WinOS
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5  
    #=======================================================================
    #	Set Unattend in the Registry
    #   HKEY_LOCAL_MACHINE\System\Setup\UnattendFile
    #   Specifies a pointer in the registry to an answer file
    #   The answer file is not required to be named Unattend.xml
    #   https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-automation-overview
    #=======================================================================  
    reg load HKLM\TempSYSTEM "C:\Windows\System32\Config\SYSTEM"
    reg add HKLM\TempSYSTEM\Setup /v UnattendFile /d "C:\Windows\Panther\Start-OSDCloudSpecialize.xml" /f
    reg unload HKLM\TempSYSTEM
    #=======================================================================
    #	Set Unattend
    #=======================================================================
    $UnattendXml | Out-File -FilePath "C:\Windows\Panther\Start-OSDCloudSpecialize.xml" -Encoding utf8 -Force
    #=======================================================================
}