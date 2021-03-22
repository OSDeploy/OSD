function Use-WindowsUnattend.audit {
    [CmdletBinding()]
    param (
        [string]$AutoPilotSwitches
    )

$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <Reseal>
                <Mode>Audit</Mode>
            </Reseal>
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

    Write-Verbose -Verbose "Setting Unattend.xml at $UnattendPath"
    $UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8
    #=======================================================================
    #	Use-WindowsUnattend
    #=======================================================================
    Write-Verbose -Verbose "Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath"
    Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath -Verbose
    
    #Write-Verbose -Verbose "Copy-PSModuleToFolder -Name OSD to C:\Program Files\WindowsPowerShell\Modules"
    #Copy-PSModuleToFolder -Name OSD -Destination 'C:\Program Files\WindowsPowerShell\Modules'

    #Notepad $UnattendPath
    #=======================================================================
}