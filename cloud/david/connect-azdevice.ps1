$InstalledModule = Import-Module Az.Accounts -PassThru -ErrorAction Ignore
if (-not $InstalledModule) {
    Write-Host -ForegroundColor DarkGray 'Install-Module Az.Accounts [Global]'
    Install-Module Az.Accounts -Force -Scope AllUsers
}
$InstalledModule = Import-Module Microsoft.Graph.DeviceManagement -PassThru -ErrorAction Ignore
if (-not $InstalledModule) {
    Write-Host -ForegroundColor DarkGray 'Install-Module Microsoft.Graph.DeviceManagement [Global]'
    Install-Module Microsoft.Graph.DeviceManagement -Force -Scope AllUsers
}

$InstalledModule = Import-Module Microsoft.Graph.Intune -PassThru -ErrorAction Ignore
if (-not $InstalledModule) {
    Write-Host -ForegroundColor DarkGray 'Install-Module Microsoft.Graph.Intune [Global]'
    Install-Module Microsoft.Graph.Intune -Force -Scope AllUsers
}

Connect-AzAccount -Device -AuthScope KeyVault
$Global:AzContext = Get-AzContext

$Global:AzAccount = $Global:AzContext.Account
$Global:AzEnvironment = $Global:AzContext.Environment
$Global:AzSubscription = $Global:AzContext.Subscription
$Global:AzTenantId = $Global:AzContext.Tenant

$Global:AccessTokenAadGraph = Get-AzAccessToken -ResourceTypeName AadGraph
$Global:HeadersAadGraph = @{
    'Authorization' = 'Bearer ' + $Global:AccessTokenAadGraph.Token
    'Content-Type'  = 'application/json'
    'ExpiresOn'     = $Global:AccessTokenAadGraph.ExpiresOn
}

$Global:AccessTokenKeyVault = Get-AzAccessToken -ResourceTypeName KeyVault
$Global:HeadersKeyVault = @{
    'Authorization' = 'Bearer ' + $Global:AccessTokenKeyVault.Token
    'Content-Type'  = 'application/json'
    'ExpiresOn'     = $Global:AccessTokenKeyVault.ExpiresOn
}

$Global:AccessTokenMSGraph = Get-AzAccessToken -ResourceTypeName MSGraph
$Global:HeadersMSGraph = @{
    'Authorization' = 'Bearer ' + $Global:HeadersMSGraph.Token
    'Content-Type'  = 'application/json'
    'ExpiresOn'     = $Global:HeadersMSGraph.ExpiresOn
}

$Global:AccessTokenStorage = Get-AzAccessToken -ResourceTypeName Storage
$Global:HeadersStorage = @{
    'Authorization' = 'Bearer ' + $Global:HeadersStorage.Token
    'Content-Type'  = 'application/json'
    'ExpiresOn'     = $Global:HeadersStorage.ExpiresOn
}

Write-Verbose -Verbose 'Azure Access Tokens have been saved to $Global:AccessToken*'
Write-Verbose -Verbose 'Azure Auth Headers have been saved to $Global:Headers*'


#$Global:MgGraph = Connect-MgGraph -AccessToken $Global:AccessTokenMSGraph.Token -Scopes DeviceManagementConfiguration.Read.All,DeviceManagementServiceConfig.Read.All
$Global:AzureAD = Connect-AzureAD -AadAccessToken $Global:AccessTokenAadGraph.Token -AccountId $Global:AzContext.Account.Id
