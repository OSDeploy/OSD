Install-Module Microsoft.Graph.DeviceManagement -Force
Install-Module WindowsAutopilotIntune -Force
#Install-Module Microsoft.Graph.Intune -Force

Write-Verbose -Verbose 'Connect-MgGraph -Device -Scopes "DeviceManagementConfiguration.Read.All","DeviceManagementServiceConfig.Read.All"'
Connect-MgGraph -Device -Scopes DeviceManagementConfiguration.Read.All,DeviceManagementServiceConfig.Read.All,DeviceManagementServiceConfiguration.Read.All

Write-Verbose -Verbose 'Select-MgProfile -Name beta'
Select-MgProfile -Name beta

Write-Verbose -Verbose '$Global:MgContext'
$Global:MgContext = Get-MgContext
$Global:MgContext

Write-Verbose -Verbose '$Global:ClientId'
$Global:MgClientId = $Global:MgContext.ClientId
$Global:MgClientId

Write-Verbose -Verbose '$Global:TenantId'
$Global:MgTenantId = $Global:MgContext.TenantId
$Global:MgTenantId

Write-Verbose -Verbose '$Global:Scopes'
$Global:MgScopes = $Global:MgContext.Scopes
$Global:MgScopes

Connect-AzAccount -TenantId $Global:MgTenantId -ClientId $Global:MgClientId -AuthScope Storage