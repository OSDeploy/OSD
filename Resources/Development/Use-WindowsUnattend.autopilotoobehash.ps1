function Use-WindowsUnattend.autopilotoobehash {
    [CmdletBinding()]
    param ()
$SpecializeCmd = @'
@echo on

REM Set OOBE Startup
reg add HKLM\SYSTEM\Setup /v CmdLine /d "PowerShell -ExecutionPolicy Bypass -Command Start-OSDCloud.windeploy.oobe" /F

REM Starting Specialize Phase
%WinDir%\System32\oobe\windeploy.exe

REM Set OOBE Startup
reg add HKLM\SYSTEM\Setup /v CmdLine /d "PowerShell -ExecutionPolicy Bypass -Command Start-OSDCloud.windeploy.oobe" /F
'@

$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
<settings pass="specialize">
<component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<RunSynchronous>

    <RunSynchronousCommand wcm:action="add">
    <Order>1</Order>
    <Description>OSDCloud</Description>
    <Path>C:\Windows\Setup\Scripts\Specialize.cmd</Path>
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
    #	Setup Scripts Specialize.cmd
    #=================================================
    $SetupScripts = 'C:\Windows\Setup\Scripts'
    if (-NOT (Test-Path $SetupScripts)) {
        New-Item -Path $SetupScripts -ItemType Directory -Force | Out-Null
    }

    $SpecializeCmdPath = "C:\Windows\Setup\Scripts\Specialize.cmd"
    Write-Verbose -Verbose "Setting OSDCloud Specialize.cmd at $SpecializeCmdPath"
    $SpecializeCmd | Out-File -FilePath $SpecializeCmdPath -Width 2000 -Force
    #=================================================
    #	Panther Unattend.xml
    #=================================================
    $Panther = 'C:\Windows\Panther'
    if (-NOT (Test-Path $Panther)) {
        New-Item -Path $Panther -ItemType Directory -Force | Out-Null
    }

    $UnattendPath = "$Panther\Unattend.xml"
    Write-Verbose -Verbose "Setting OSDCloud Unattend.xml at $UnattendPath"
    $UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8 -Width 2000 -Force
    #=================================================
    #	Use-WindowsUnattend
    #=================================================
    Write-Verbose -Verbose "Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath"
    Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath -Verbose

    Copy-PSModuleToFolder -Name OSD -Destination 'C:\Program Files\WindowsPowerShell\Modules'

    reg load HKLM\OfflineSystem C:\Windows\System32\Config\SYSTEM
    reg add HKLM\OfflineSystem\Setup /v CmdLine /d "C:\Windows\Setup\Scripts\Specialize.cmd" /F
    reg unload HKLM\OfflineSystem

    Notepad $UnattendPath
    #=================================================
}