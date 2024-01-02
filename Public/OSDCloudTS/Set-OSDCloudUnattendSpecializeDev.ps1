function Set-OSDCloudUnattendSpecializeDev {
    [CmdletBinding()]
    param ()
#=================================================
#	UnattendXml
#=================================================
$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="offlineServicing">
    <component name="Microsoft-Windows-PnpCustomizationsNonWinPE" processorArchitecture="x86" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <DriverPaths>
            <PathAndCredentials wcm:keyValue="1" wcm:action="add">
                <Path>C:\Drivers</Path>
            </PathAndCredentials>
        </DriverPaths>
    </component>
    <component name="Microsoft-Windows-PnpCustomizationsNonWinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <DriverPaths>
            <PathAndCredentials wcm:keyValue="1" wcm:action="add">
                <Path>C:\Drivers</Path>
            </PathAndCredentials>
        </DriverPaths>
    </component>
    </settings>	
    <settings pass="specialize">
		<component name="Microsoft-Windows-Deployment"
                processorArchitecture="amd64"
                publicKeyToken="31bf3856ad364e35"
                language="neutral"
                versionScope="nonSxS"
                xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<RunSynchronous>
				<RunSynchronousCommand wcm:action="add">
					<Order>1</Order>
					<Description>OSDCloud Specialize</Description>
					<Path>Powershell -ExecutionPolicy Bypass -Command Invoke-OSDSpecializeDev -Verbose</Path>
				</RunSynchronousCommand>
			</RunSynchronous>
		</component>
	</settings>
</unattend>
'@
    #=================================================
    #	Block
    #=================================================
    Block-WinOS
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=================================================
    #	Directories
    #=================================================
    if (-NOT (Test-Path 'C:\Windows\Panther')) {
        New-Item -Path 'C:\Windows\Panther' -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    #=================================================
    #	Panther Unattend
    #=================================================
    $Panther = 'C:\Windows\Panther'
    $UnattendPath = "$Panther\Invoke-OSDSpecializeDev.xml"

    Write-Verbose "Setting $UnattendPath"
    $UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8 -Width 2000 -Force
    #=================================================
    #	Registry Unattend
    #   HKEY_LOCAL_MACHINE\System\Setup\UnattendFile
    #   Specifies a pointer in the registry to an answer file
    #   The answer file is not required to be named Unattend.xml
    #   https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-automation-overview
    #=================================================
    Write-Verbose "Setting Unattend in Offline Registry"
    Invoke-Exe reg load HKLM\TempSYSTEM "C:\Windows\System32\Config\SYSTEM"
    Invoke-Exe reg add HKLM\TempSYSTEM\Setup /v UnattendFile /d "C:\Windows\Panther\Invoke-OSDSpecializeDev.xml" /f
    Invoke-Exe reg unload HKLM\TempSYSTEM
    #=================================================
}
