function Connect-OSDCloudAzure {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]
        $UseDeviceAuthentication
    )
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Connect-OSDCloudAzure"

    if ($env:SystemDrive -eq 'X:') {
        $UseDeviceAuthentication = $true
        $OSDCloudLogs = "$env:SystemDrive\OSDCloud\Logs"
        if (-not (Test-Path $OSDCloudLogs)) {
            New-Item $OSDCloudLogs -ItemType Directory -Force | Out-Null
        }
    }
    Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
    osdcloud-InstallPowerShellModule -Name 'AzureAD'
    osdcloud-InstallPowerShellModule -Name 'Az.Accounts'
    osdcloud-InstallPowerShellModule -Name 'Az.KeyVault'
    osdcloud-InstallPowerShellModule -Name 'Az.Resources'
    osdcloud-InstallPowerShellModule -Name 'Az.Storage'
    osdcloud-InstallPowerShellModule -Name 'Microsoft.Graph.Authentication'
    osdcloud-InstallPowerShellModule -Name 'Microsoft.Graph.DeviceManagement'

    Import-Module -Name 'Az.Accounts' -Force

    if ($UseDeviceAuthentication) {
        Connect-AzAccount -UseDeviceAuthentication -AuthScope Storage -ErrorAction Stop
    }
    else {
        Connect-AzAccount -AuthScope Storage -ErrorAction Stop
    }

    $Global:AzSubscription = Get-AzSubscription

    if (($Global:AzSubscription).Count -ge 2) {
        $i = $null
        $Results = foreach ($Item in $Global:AzSubscription) {
            $i++
    
            $ObjectProperties = @{
                Number  = $i
                Name    = $Item.Name
                Id      = $Item.Id
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
    
        $Results | Select-Object -Property Number, Name, Id | Format-Table | Out-Host
    
        do {
            $SelectReadHost = Read-Host -Prompt "Select an Azure Subscription by Number"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Results.Number))))
    
        $Results = $Results | Where-Object {$_.Number -eq $SelectReadHost}
    
        $Global:AzContext = Set-AzContext -Subscription $Results.Id
    }
    else {
        $Global:AzContext = Get-AzContext
    }

    if ($Global:AzContext) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Green 'Welcome to Azure OSDCloud!'
        $Global:AzAccount = $Global:AzContext.Account
        $Global:AzEnvironment = $Global:AzContext.Environment
        $Global:AzTenantId = $Global:AzContext.Tenant
        $Global:AzSubscription = $Global:AzContext.Subscription

        Write-Host -ForegroundColor Cyan        'Account:           ' $Global:AzAccount
        Write-Host -ForegroundColor Cyan        'AzEnvironment:     ' $Global:AzEnvironment
        Write-Host -ForegroundColor Cyan        'AzTenantId:        ' $Global:AzTenantId
        Write-Host -ForegroundColor Cyan        'AzSubscription:    ' $Global:AzSubscription
        if ($null -eq $Global:AzContext.Subscription) {
            Write-Warning 'You do not have access to an Azure Subscriptions'
            Write-Warning 'This is likely due to not having rights to Azure Resources or Azure Storage'
            Write-Warning 'Contact your Azure administrator to resolve this issue'
            Break
        }

        #Write-Host ''
        #Write-Host -ForegroundColor DarkGray    'Azure Context:             $Global:AzContext'
        #Write-Host -ForegroundColor DarkGray    'Access Tokens:             $Global:Az*AccessToken'
        #Write-Host -ForegroundColor DarkGray    'Headers:                   $Global:Az*Headers'
        #Write-Host ''

        if ($OSDCloudLogs) {
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzSubscription.json"
            $Global:AzSubscription | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzSubscription.json" -Encoding ascii -Width 2000 -Force

            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzContext.json"
            $Global:AzContext | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzContext.json" -Encoding ascii -Width 2000 -Force
        }
        #=================================================
        #	AAD Graph
        #=================================================
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Generating AadGraph Access Tokens"
        $Global:AzAadGraphAccessToken = Get-AzAccessToken -ResourceTypeName AadGraph
        $Global:AzAadGraphHeaders = @{
            'Authorization' = 'Bearer ' + $Global:AzAadGraphAccessToken.Token
            'Content-Type'  = 'application/json'
            'ExpiresOn'     = $Global:AzAadGraphAccessToken.ExpiresOn
        }
        if ($OSDCloudLogs) {
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzAadGraphAccessToken.json"
            $Global:AzAadGraphAccessToken | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzAadGraphAccessToken.json" -Encoding ascii -Width 2000 -Force

            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzAadGraphHeaders.json"
            $Global:AzAadGraphHeaders | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzAadGraphHeaders.json" -Encoding ascii -Width 2000 -Force
        }
        #=================================================
        #	Azure KeyVault
        #=================================================
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Generating KeyVault Access Tokens"
        $Global:AzKeyVaultAccessToken = Get-AzAccessToken -ResourceTypeName KeyVault
        $Global:AzKeyVaultHeaders = @{
            'Authorization' = 'Bearer ' + $Global:AzKeyVaultAccessToken.Token
            'Content-Type'  = 'application/json'
            'ExpiresOn'     = $Global:AzKeyVaultAccessToken.ExpiresOn
        }
        if ($OSDCloudLogs) {
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzKeyVaultAccessToken.json"
            $Global:AzKeyVaultAccessToken | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzKeyVaultAccessToken.json" -Encoding ascii -Width 2000 -Force

            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzKeyVaultHeaders.json"
            $Global:AzKeyVaultHeaders | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzKeyVaultHeaders.json" -Encoding ascii -Width 2000 -Force
        }
        #=================================================
        #	Azure MSGraph
        #=================================================
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Generating MSGraph Access Tokens"
        $Global:AzMSGraphAccessToken = Get-AzAccessToken -ResourceTypeName MSGraph
        $Global:AzMSGraphHeaders = @{
            'Authorization' = 'Bearer ' + $Global:AzMSGraphAccessToken.Token
            'Content-Type'  = 'application/json'
            'ExpiresOn'     = $Global:AzMSGraphHeaders.ExpiresOn
        }
        if ($OSDCloudLogs) {
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzMSGraphAccessToken.json"
            $Global:AzMSGraphAccessToken | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzMSGraphAccessToken.json" -Encoding ascii -Width 2000 -Force

            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzMSGraphHeaders.json"
            $Global:AzMSGraphHeaders | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzMSGraphHeaders.json" -Encoding ascii -Width 2000 -Force
        }
        #=================================================
        #	Azure Storage
        #=================================================
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Generating Storage Access Tokens"
        $Global:AzStorageAccessToken = Get-AzAccessToken -ResourceTypeName Storage
        $Global:AzStorageHeaders = @{
            'Authorization' = 'Bearer ' + $Global:AzStorageAccessToken.Token
            'Content-Type'  = 'application/json'
            'ExpiresOn'     = $Global:AzStorageHeaders.ExpiresOn
        }
        if ($OSDCloudLogs) {
            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzStorageAccessToken.json"
            $Global:AzStorageAccessToken | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzStorageAccessToken.json" -Encoding ascii -Width 2000 -Force

            Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzStorageHeaders.json"
            $Global:AzStorageHeaders | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzStorageHeaders.json" -Encoding ascii -Width 2000 -Force
        }
        #=================================================
        #	AzureAD
        #=================================================
        #$Global:MgGraph = Connect-MgGraph -AccessToken $Global:AzMSGraphAccessToken.Token -Scopes DeviceManagementConfiguration.Read.All,DeviceManagementServiceConfig.Read.All
        #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Connecting to AzureAD"
        #$Global:AzureAD = Connect-AzureAD -AadAccessToken $Global:AzAadGraphAccessToken.Token -AccountId $Global:AzContext.Account.Id
    }
    else {
        Write-Warning "Unable to get AzContext"
    }
}