function Use-WindowsUnattend.specialize {
    [CmdletBinding()]
    param (
        [string]$AutopilotSwitches
    )
#https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-deployment-runsynchronous
$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
<settings pass="specialize">
<component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<RunSynchronous>
<RunSynchronousCommand wcm:action="add">
<Order>1</Order>
<Description>OSDWinSetup</Description>
<Path>cmd /c C:\Windows\Setup\Scripts\Specialize.cmd</Path>
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
    #   Specialize.cmd
    #=================================================
    Write-Verbose "Adding C:\Windows\Setup\Scripts\Specialize.cmd"

    if (-NOT (Test-Path 'C:\Windows\Setup\Scripts')) {
        New-Item -Path 'C:\Windows\Setup\Scripts' -ItemType Directory -Force | Out-Null
    }

$Specialize = @'
pause
'@

    $Specialize | Out-File -FilePath 'C:\Windows\Setup\Scripts\Specialize.cmd' -Encoding ascii -Width 2000 -Force
    #=================================================
    #	Panther Unattend.xml
    #=================================================
    $Panther = 'C:\Windows\Panther'
    $UnattendPath = "$Panther\Specialize.xml"

    if (-NOT (Test-Path $Panther)) {
        New-Item -Path $Panther -ItemType Directory -Force | Out-Null
    }

    Write-Verbose -Verbose "Setting Specialize.xml at $UnattendPath"
    $UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8 -Width 2000 -Force
    #=================================================
    #	Use-WindowsUnattend
    #=================================================
    Write-Verbose -Verbose "Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath"
    Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath -Verbose
    
    #Write-Verbose -Verbose "Copy-PSModuleToFolder -Name OSD to C:\Program Files\WindowsPowerShell\Modules"
    #Copy-PSModuleToFolder -Name OSD -Destination 'C:\Program Files\WindowsPowerShell\Modules'

    Notepad 'C:\Windows\Setup\Scripts\Specialize.cmd'
    #=================================================
}