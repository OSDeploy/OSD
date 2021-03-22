function Use-WindowsUnattend.autopilot.audit {
    [CmdletBinding()]
    param (
        [string]$AutoPilotSwitches
    )
$Notes = @'
<RunSynchronousCommand wcm:action="add">
<Order>2</Order>
<Description>Start PowerShell</Description>
<Path>Start PowerShell.exe</Path>
</RunSynchronousCommand>

<RunSynchronousCommand wcm:action="add">
<Order>3</Order>
<Description>Configure AutoPilot</Description>
<Path>PowerShell.exe -File "C:\Program Files\WindowsPowerShell\Scripts\Get-WindowsAutoPilotInfo.ps1" -Online -TenantId someone.onmicrosoft.com -GroupTag Enterprise</Path>
</RunSynchronousCommand>

<RunSynchronousCommand wcm:action="add">
<Order>4</Order>
<Description>Save Get-WindowsAutoPilotInfo</Description>
<Path>PowerShell -Command "Install-Script -Name Get-WindowsAutoPilotInfo -Verbose -Force"</Path>
</RunSynchronousCommand>

<RunSynchronousCommand wcm:action="add">
<Order>5</Order>
<Description>Start PowerShell Wait</Description>
<Path>Start /WAIT PowerShell.exe</Path>
</RunSynchronousCommand>

<RunSynchronousCommand wcm:action="add">
<Order>6</Order>
<Description>Set ExecutionPolicy RemoteSigned</Description>
<Path>PowerShell -WindowStyle Hidden -Command "Set-ExecutionPolicy RemoteSigned -Force"</Path>
</RunSynchronousCommand>

<RunSynchronousCommand wcm:action="add">
<Order>7</Order>
<Description>Sysprep OOBE Reboot</Description>
<Path>%SystemRoot%\System32\Sysprep\Sysprep.exe /OOBE /Reboot</Path>
</RunSynchronousCommand>
'@

$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="generalize">
        <component name="Microsoft-Windows-PnpSysprep" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <PersistAllDeviceInstalls>true</PersistAllDeviceInstalls>
        </component>
    </settings>
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <!-- Random ComputerName, will be replaced by specialize script -->
            <ComputerName></ComputerName>
            <TimeZone>Central Standard Time</TimeZone>
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
                <Description>Save Get-WindowsAutoPilotInfo</Description>
                <Path>PowerShell -Command "Install-Script -Name Get-WindowsAutoPilotInfo -Verbose -Force"</Path>
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
    #	Panther Unattend.xml
    #=======================================================================
    $Panther = 'C:\Windows\Panther'
    $UnattendPath = "$Panther\Unattend.xml"

    if (-NOT (Test-Path $Panther)) {
        New-Item -Path $Panther -ItemType Directory -Force | Out-Null
    }

    Write-Verbose -Verbose "Setting AutoPilot Unattend.xml at $UnattendPath"
    $UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8
    #=======================================================================
    #	Use-WindowsUnattend
    #=======================================================================
    Write-Verbose -Verbose "Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath"
    Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath -Verbose
    
    Write-Verbose -Verbose "Copy-PSModuleToFolder -Name OSD to C:\Program Files\WindowsPowerShell\Modules"
    Copy-PSModuleToFolder -Name OSD -Destination 'C:\Program Files\WindowsPowerShell\Modules'

    Notepad $UnattendPath
    #=======================================================================
}