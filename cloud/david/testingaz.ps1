$Global:AzContext = Get-AzContext
if (!($Global:AzContext)) {
    $null = Connect-AzAccount -Device -AuthScope Storage -ErrorAction Ignore
    $Global:AzContext = Get-AzContext
}

if ($Global:AzContext) {
    Write-Host -ForegroundColor Green 'Connected to Azure'
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan 'Azure Context ($Global:AzContext)'
    $Global:AzContext | Format-list

    $Global:AzAccount = $Global:AzContext.Account
    $Global:AzEnvironment = $Global:AzContext.Environment
    $Global:AzSubscription = $Global:AzContext.Subscription
    $Global:AzTenantId = $Global:AzContext.Tenant
    #=================================================
    #	AAD Graph
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan '$Global:AccessTokenAadGraph'
    $Global:AccessTokenAadGraph = Get-AzAccessToken -ResourceTypeName AadGraph
    $Global:AccessTokenAadGraph

    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan '$Global:HeadersAadGraph'
    $Global:HeadersAadGraph = @{
        'Authorization' = 'Bearer ' + $Global:AccessTokenAadGraph.Token
        'Content-Type'  = 'application/json'
        'ExpiresOn'     = $Global:AccessTokenAadGraph.ExpiresOn
    }
    $Global:HeadersAadGraph
    #=================================================
    #	Azure KeyVault
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan '$Global:AccessTokenKeyVault'
    $Global:AccessTokenKeyVault = Get-AzAccessToken -ResourceTypeName KeyVault
    $Global:AccessTokenKeyVault

    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan '$Global:HeadersKeyVault'
    $Global:HeadersKeyVault = @{
        'Authorization' = 'Bearer ' + $Global:AccessTokenKeyVault.Token
        'Content-Type'  = 'application/json'
        'ExpiresOn'     = $Global:AccessTokenKeyVault.ExpiresOn
    }
    $Global:HeadersKeyVault
    #=================================================
    #	Azure MSGraph
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan '$Global:AccessTokenMSGraph'
    $Global:AccessTokenMSGraph = Get-AzAccessToken -ResourceTypeName MSGraph
    $Global:AccessTokenMSGraph

    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan '$Global:HeadersMSGraph'
    $Global:HeadersMSGraph = @{
        'Authorization' = 'Bearer ' + $Global:AccessTokenMSGraph.Token
        'Content-Type'  = 'application/json'
        'ExpiresOn'     = $Global:HeadersMSGraph.ExpiresOn
    }
    $Global:HeadersMSGraph
    #=================================================
    #	Azure Storage
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan '$Global:AccessTokenStorage'
    $Global:AccessTokenStorage = Get-AzAccessToken -ResourceTypeName Storage
    $Global:AccessTokenStorage

    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan '$Global:HeadersStorage'
    $Global:HeadersStorage = @{
        'Authorization' = 'Bearer ' + $Global:AccessTokenStorage.Token
        'Content-Type'  = 'application/json'
        'ExpiresOn'     = $Global:HeadersStorage.ExpiresOn
    }
    $Global:HeadersStorage
    #=================================================
    #	AzureAD
    #=================================================
    #Write-Verbose -Verbose 'Azure Access Tokens have been saved to $Global:AccessToken*'
    #Write-Verbose -Verbose 'Azure Auth Headers have been saved to $Global:Headers*'
    #$Global:MgGraph = Connect-MgGraph -AccessToken $Global:AccessTokenMSGraph.Token -Scopes DeviceManagementConfiguration.Read.All,DeviceManagementServiceConfig.Read.All,DeviceManagementServiceConfiguration.Read.All
    $Global:AzureAD = Connect-AzureAD -AadAccessToken $Global:AccessTokenAadGraph.Token -AccountId $Global:AzContext.Account.Id

    $Global:AzStorageContext = @{}
    $Global:BlobImages = @()

    $Global:OSDCloudStorageAccounts = Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts' | Where-Object {$_.Tags.Keys -contains 'osdcloud'}
    Break
    foreach ($Item in $Global:OSDCloudStorageAccounts) {
        $Global:LastStorageContext = New-AzStorageContext -StorageAccountName $Item.ResourceName
        $Global:AzStorageContext."$($Item.ResourceName)" = $Global:LastStorageContext
        #Get-AzStorageBlobByTag -TagFilterSqlExpression ""osdcloudimage""=""win10ltsc"" -Context $StorageContext
        #Get-AzStorageBlobByTag -Context $Global:LastStorageContext
        "&where=Status = 'In Progress'"
    }
}