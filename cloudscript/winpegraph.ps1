Install-Module Microsoft.Graph.DeviceManagement -Force
Install-Module Microsoft.Graph.Intune -Force

Write-Verbose -Verbose 'Connect-MgGraph -Device -Scopes DeviceManagementConfiguration.ReadWrite.All'
Connect-MgGraph -Device -Scopes DeviceManagementConfiguration.ReadWrite.All

Write-Verbose -Verbose 'Select-MgProfile -Name beta'
Select-MgProfile -Name beta

Write-Verbose -Verbose 'Get-MgContext'
Get-MgContext

Write-Verbose -Verbose '(Get-MgContext).Scopes'
(Get-MgContext).Scopes

Write-Verbose -Verbose 'Get-MgDeviceManagementScript | Format-List'
Get-MgDeviceManagementScript | Format-List