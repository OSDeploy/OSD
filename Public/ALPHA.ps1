function Test-AuditModeAutoPilot {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TenantName,

        [Parameter(Mandatory = $true)]
        [string]$GroupTag
    )
#=======================================================================
#   Unattend.xml for Audit Mode
#=======================================================================
$UnattendAuditModeAutoPilot = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
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
                    <Description>Set ExecutionPolicy Bypass</Description>
                    <Path>PowerShell -WindowStyle Hidden -Command "Set-ExecutionPolicy Bypass -Force"</Path>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Order>2</Order>
                    <Description>Configure AutoPilot</Description>
                    <Path>PowerShell.exe -File "C:\Program Files\WindowsPowerShell\Scripts\Upload-WindowsAutopilotDeviceInfo.ps1" -Online -Assign</Path>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Order>3</Order>
                    <Description>Set ExecutionPolicy RemoteSigned</Description>
                    <Path>PowerShell -WindowStyle Hidden -Command "Set-ExecutionPolicy RemoteSigned -Force"</Path>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Order>4</Order>
                    <Description>Sysprep OOBE Reboot</Description>
                    <Path>%SystemRoot%\System32\Sysprep\Sysprep.exe /OOBE /Reboot</Path>
                </RunSynchronousCommand>
            </RunSynchronous>
        </component>
    </settings>
</unattend>
"@
#=======================================================================
#   Do the Work
#=======================================================================
    $PathPanther = 'C:\Windows\Panther'
    if (-NOT (Test-Path $PathPanther)) {
        New-Item -Path $PathPanther -ItemType Directory -Force | Out-Null
    }

    $UnattendPath = Join-Path $PathPanther 'Unattend.xml'
    Write-Host -ForegroundColor Cyan "Setting $UnattendPath"
    $UnattendAuditModeAutoPilot | Out-File -FilePath $UnattendPath -Encoding utf8

    Write-Host -ForegroundColor Cyan "Applying Use-WindowsUnattend $UnattendPath ... this may take a while!"
    Use-WindowsUnattend -Path 'C:\' -UnattendPath $UnattendPath
#=======================================================================
#   Cross Fingers
#=======================================================================
}
function Test-UseWindowsUnattend {
    [CmdletBinding()]
    param ()
    Use-WindowsUnattend -Path 'C:\' -UnattendPath 'C:\Windows\Panther\Unattend.xml'
}