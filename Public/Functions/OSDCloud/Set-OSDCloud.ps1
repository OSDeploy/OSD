function Set-OSDCloudUnattendAuditMode {
    [CmdletBinding()]
    param ()
#=================================================
#	UnattendXml
#=================================================
$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Description>OSDCloud Specialize</Description>
                    <Path>Powershell -ExecutionPolicy Bypass -Command Invoke-OSDSpecialize -Verbose</Path>
                </RunSynchronousCommand>
            </RunSynchronous>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <Reseal>
                <Mode>Audit</Mode>
            </Reseal>
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
        New-Item -Path 'C:\Windows\Panther'-ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    #=================================================
    #	Panther Unattend
    #=================================================
    $Panther = 'C:\Windows\Panther'
    $UnattendPath = "$Panther\Unattend.xml"

    Write-Verbose -Verbose "Setting $UnattendPath"
    $UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8 -Width 2000 -Force
    #=================================================
    #	Use-WindowsUnattend
    #=================================================
    Write-Verbose -Verbose "Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath"
    Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath -Verbose
    Notepad $UnattendPath
    #=================================================
}
function Set-OSDCloudUnattendAuditModeAutopilot {
    [CmdletBinding()]
    param ()
#=================================================
#	UnattendXml
#=================================================
$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Description>OSDCloud Specialize</Description>
                    <Path>Powershell -ExecutionPolicy Bypass -Command Invoke-OSDSpecialize -Verbose</Path>
                </RunSynchronousCommand>
            </RunSynchronous>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <Reseal>
                <Mode>Audit</Mode>
            </Reseal>
        </component>
    </settings>
    <settings pass="auditUser">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                <Order>1</Order>
                <Description>Set ExecutionPolicy RemoteSigned</Description>
                <Path>PowerShell -WindowStyle Hidden -Command "Set-ExecutionPolicy RemoteSigned -Force"</Path>
                </RunSynchronousCommand>

                <RunSynchronousCommand wcm:action="add">
                <Order>2</Order>
                <Description>WaitWebConnection</Description>
                <Path>PowerShell -Command "Wait-WebConnection powershellgallery.com -Verbose"</Path>
                </RunSynchronousCommand>

                <RunSynchronousCommand wcm:action="add">
                <Order>3</Order>
                <Description>Save Get-WindowsAutopilotInfo</Description>
                <Path>PowerShell -Command "Install-Script -Name Get-WindowsAutopilotInfo -Verbose -Force"</Path>
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
        New-Item -Path 'C:\Windows\Panther'-ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    #=================================================
    #	Panther Unattend
    #=================================================
    $Panther = 'C:\Windows\Panther'
    $UnattendPath = "$Panther\Unattend.xml"

    Write-Verbose -Verbose "Setting $UnattendPath"
    $UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8 -Width 2000 -Force
    #=================================================
    #	Copy PSModule
    #=================================================
    Write-Verbose -Verbose "Copy-PSModuleToFolder -Name OSD to C:\Program Files\WindowsPowerShell\Modules"
    Copy-PSModuleToFolder -Name OSD -Destination 'C:\Program Files\WindowsPowerShell\Modules'
    #=================================================
    #	Use-WindowsUnattend
    #=================================================
    Write-Verbose -Verbose "Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath"
    Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath -Verbose
    Notepad $UnattendPath
    #=================================================
}
function Set-OSDCloudUnattendSpecialize {
    [CmdletBinding()]
    param ()
#=================================================
#	UnattendXml
#=================================================
$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
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
					<Path>Powershell -ExecutionPolicy Bypass -Command Invoke-OSDSpecialize -Verbose</Path>
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
    $UnattendPath = "$Panther\Invoke-OSDSpecialize.xml"

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
    Invoke-Exe reg add HKLM\TempSYSTEM\Setup /v UnattendFile /d "C:\Windows\Panther\Invoke-OSDSpecialize.xml" /f
    Invoke-Exe reg unload HKLM\TempSYSTEM
    #=================================================
}