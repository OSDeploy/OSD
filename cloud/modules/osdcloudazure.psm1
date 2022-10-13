<#
.SYNOPSIS
    OSDCloud Azure Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Azure Cloud Module for functions.osdcloud.com
.NOTES
    This module can be loaded in all Windows phases
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/osdcloudazure.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/osdcloudazure.psm1')
#>
#=================================================
#region Functions
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

    osdcloud-InstallModuleAzureAD
    osdcloud-InstallModuleAzAccounts
        #Connect-AzAccount
        #Get-AzSubscription
        #Set-AzContext
        #Get-AzContext
        #Get-AzAccessToken
    osdcloud-InstallModuleAzKeyVault
    osdcloud-InstallModuleAzResources
    osdcloud-InstallModuleAzStorage
    osdcloud-InstallModuleMSGraphAuthentication
    osdcloud-InstallModuleMSGraphDeviceManagement

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
            #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzSubscription.json"
            $Global:AzSubscription | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzSubscription.json" -Encoding ascii -Width 2000 -Force

            #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzContext.json"
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
            #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzAadGraphAccessToken.json"
            $Global:AzAadGraphAccessToken | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzAadGraphAccessToken.json" -Encoding ascii -Width 2000 -Force

            #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzAadGraphHeaders.json"
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
            #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzKeyVaultAccessToken.json"
            $Global:AzKeyVaultAccessToken | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzKeyVaultAccessToken.json" -Encoding ascii -Width 2000 -Force

            #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzKeyVaultHeaders.json"
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
            #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzMSGraphAccessToken.json"
            $Global:AzMSGraphAccessToken | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzMSGraphAccessToken.json" -Encoding ascii -Width 2000 -Force

            #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzMSGraphHeaders.json"
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
            #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzStorageAccessToken.json"
            $Global:AzStorageAccessToken | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzStorageAccessToken.json" -Encoding ascii -Width 2000 -Force

            #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Logging $OSDCloudLogs\AzStorageHeaders.json"
            $Global:AzStorageHeaders | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzStorageHeaders.json" -Encoding ascii -Width 2000 -Force
        }
        #=================================================
        #	AzureAD
        #=================================================
        #$Global:MgGraph = Connect-MgGraph -AccessToken $Global:AzMSGraphAccessToken.Token -Scopes DeviceManagementConfiguration.Read.All,DeviceManagementServiceConfig.Read.All,DeviceManagementServiceConfiguration.Read.All
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Connecting to AzureAD"
        $Global:AzureAD = Connect-AzureAD -AadAccessToken $Global:AzAadGraphAccessToken.Token -AccountId $Global:AzContext.Account.Id
    }
    else {
        Write-Warning "Unable to get AzContext"
    }
}
function Get-OSDCloudAzureResources {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Get-OSDCloudAzureResources"

    if ($env:SystemDrive -eq 'X:') {
        $OSDCloudLogs = "$env:SystemDrive\OSDCloud\Logs"
        if (-not (Test-Path $OSDCloudLogs)) {
            New-Item $OSDCloudLogs -ItemType Directory -Force | Out-Null
        }
    }

    if ($Global:AzureAD -or $Global:MgGraph) {
        #Write-Host -ForegroundColor DarkGray    'Storage Accounts:          $Global:AzStorageAccounts'
        $Global:AzStorageAccounts = Get-AzStorageAccount
        if ($OSDCloudLogs) {
            #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $OSDCloudLogs\AzStorageAccounts.json"
            $Global:AzStorageAccounts | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzStorageAccounts.json" -Encoding ascii -Width 2000 -Force
        }
    
        #Write-Host -ForegroundColor DarkGray    'OSDCloud Storage Accounts: $Global:AzOSDCloudStorageAccounts'
        $Global:AzOSDCloudStorageAccounts = Get-AzStorageAccount | Where-Object {$_.Tags.ContainsKey('OSDCloud')}
        #$Global:AzOSDCloudStorageAccounts = Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts'
        #$Global:AzOSDCloudStorageAccounts = Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts' | Where-Object {$_.Tags.ContainsKey('OSDCloud')}
        if ($OSDCloudLogs) {
            #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $OSDCloudLogs\AzOSDCloudStorageAccounts.json"
            $Global:AzOSDCloudStorageAccounts | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudStorageAccounts.json" -Encoding ascii -Width 2000 -Force
        }
    
        $Global:AzStorageContext = @{}
        $Global:AzOSDCloudAutopilotFile = @()
        $Global:AzOSDCloudBootImage = @()
        $Global:AzOSDCloudBlobImage = @()
        $Global:AzOSDCloudBlobDriverPack = @()
        $Global:AzOSDCloudBlobPackage = @()
        $Global:AzOSDCloudBlobScript = @()
    
        if ($Global:AzOSDCloudStorageAccounts) {
            #Write-Host -ForegroundColor DarkGray    'Storage Contexts:          $Global:AzStorageContext'
            #Write-Host -ForegroundColor DarkGray    'Blob Windows Images:       $Global:AzOSDCloudBlobImage'
            #Write-Host ''
            Update-AzConfig -DisplayBreakingChangeWarning $false
            Write-Host -ForegroundColor Cyan "Searching Azure Storage for OSDCloud Resources"
            foreach ($Item in $Global:AzOSDCloudStorageAccounts) {
                $Global:AzCurrentStorageContext = New-AzStorageContext -StorageAccountName $Item.StorageAccountName
                $Global:AzStorageContext."$($Item.StorageAccountName)" = $Global:AzCurrentStorageContext
                #Get-AzStorageBlobByTag -TagFilterSqlExpression ""osdcloudimage""=""win10ltsc"" -Context $StorageContext
                #Get-AzStorageBlobByTag -Context $Global:AzCurrentStorageContext
        
                $AzOSDCloudStorageContainers = Get-AzStorageContainer -Context $Global:AzCurrentStorageContext
                if ($OSDCloudLogs) {
                    #Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $OSDCloudLogs\AzOSDCloudStorageContainers.json"
                    $Global:AzOSDCloudStorageContainers | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudStorageContainers.json" -Encoding ascii -Width 2000 -Force
                }
            
                if ($AzOSDCloudStorageContainers) {
                    foreach ($Container in $AzOSDCloudStorageContainers) {
                        if ($Container.Name -eq 'bin') {
                            #Container is for Scripts and Provisioning
                            Write-Host -ForegroundColor DarkGray "OSDCloud Global Container: $($Item.StorageAccountName)/$($Container.Name)"
                            $Global:AzOSDCloudBlobPackage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.ppkg -ErrorAction Ignore
                            $Global:AzOSDCloudBlobScript += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.ps1 -ErrorAction Ignore
                        }
                        elseif ($Container.Name -eq 'bootimage') {
                            Write-Host -ForegroundColor DarkGray "BootImage Container: $($Item.StorageAccountName)/$($Container.Name)"
                            $Global:AzOSDCloudBlobBootImage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.iso -ErrorAction Ignore
                        }
                        elseif ($Container.Name -eq 'driverpack') {
                            Write-Host -ForegroundColor DarkGray "DriverPack Container: $($Item.StorageAccountName)/$($Container.Name)"
                            $Global:AzOSDCloudBlobDriverPack += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.cab -ErrorAction Ignore
                            $Global:AzOSDCloudBlobDriverPack += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.exe -ErrorAction Ignore
                            $Global:AzOSDCloudBlobDriverPack += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.msi -ErrorAction Ignore
                            $Global:AzOSDCloudBlobDriverPack += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.zip -ErrorAction Ignore
                        }
                        else {
                            Write-Host -ForegroundColor DarkGray "Image Container: $($Item.StorageAccountName)/$($Container.Name)"
                            $Global:AzOSDCloudBlobImage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.esd -ErrorAction Ignore | Where-Object {$_.Length -gt 3000000000}
                            $Global:AzOSDCloudBlobImage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.iso -ErrorAction Ignore | Where-Object {$_.Length -gt 3000000000}
                            $Global:AzOSDCloudBlobImage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.wim -ErrorAction Ignore | Where-Object {$_.Length -gt 3000000000}

                            $Global:AzOSDCloudAutopilotFile += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob AutoPilotConfigurationFile.json -ErrorAction Ignore
                            $Global:AzOSDCloudBlobPackage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.ppkg -ErrorAction Ignore
                            $Global:AzOSDCloudBlobScript += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.ps1 -ErrorAction Ignore
                        }
                    }
                }
            }
            if ($OSDCloudLogs) {
                $Global:AzStorageContext | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzStorageContext.json" -Encoding ascii -Width 2000 -Force
                $Global:AzOSDCloudAutopilotFile | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudAutopilotFile.json" -Encoding ascii -Width 2000 -Force
                $Global:AzOSDCloudBlobImage | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudBlobImage.json" -Encoding ascii -Width 2000 -Force
                $Global:AzOSDCloudBlobBootImage| ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudBlobDriverPack.json" -Encoding ascii -Width 2000 -Force
                $Global:AzOSDCloudBlobDriverPack | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudBlobDriverPack.json" -Encoding ascii -Width 2000 -Force
                $Global:AzOSDCloudBlobPackage | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudBlobPackage.json" -Encoding ascii -Width 2000 -Force
                $Global:AzOSDCloudBlobScript | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudBlobScript.json" -Encoding ascii -Width 2000 -Force
            }
            if ($null -eq $Global:AzOSDCloudBlobImage) {
                Write-Warning 'Unable to find a WIM on any of the OSDCloud Azure Storage Containers'
                Write-Warning 'Make sure you have a WIM Windows Image in the OSDCloud Azure Storage Container'
                Write-Warning 'Make sure this user has the Azure Storage Blob Data Reader role to the OSDCloud Container'
                Write-Warning 'You may need to execute Get-OSDCloudAzureResources then Start-OSDCloudAzure'
                Break
            }
        }
        else {
            Write-Warning 'Unable to find any Azure Storage Accounts'
            Write-Warning 'Make sure the OSDCloud Azure Storage Account has an OSDCloud Tag'
            Write-Warning 'Make sure this user has the Azure Reader role on the OSDCloud Azure Storage Account'
            Break
        }
    }
    else {
        Write-Warning 'Unable to connect to AzureAD'
        Write-Warning 'You may need to execute Connect-OSDCloudAzure then Start-OSDCloudAzure'
        Break
    }
}
function Start-OSDCloudAzureCLI {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-OSDCloudAzureCLI"
    if ($Global:AzOSDCloudBlobImage) {
        $i = $null
        $Results = foreach ($Item in $Global:AzOSDCloudBlobImage) {
            $i++
            
            $BlobClient = $Global:AzOSDCloudStorageAccounts | Where-Object {$_.StorageAccountName -eq $Item.BlobClient.AccountName}

            $ObjectProperties = @{
                Number          = $i
                StorageAccount  = $Item.BlobClient.AccountName
                Tag             = ($BlobClient | Select-Object -ExpandProperty Tags).Get_Item('OSDCloud')
                Container       = $Item.BlobClient.BlobContainerName
                Blob            = $Item.Name
                Location        = $BlobClient | Select-Object -ExpandProperty Location
                ResourceGroup   = $BlobClient | Select-Object -ExpandProperty ResourceGroupName
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }

        $Results | Select-Object -Property Number, StorageAccount, Tag, Container, Blob, Location, ResourceGroup | Format-Table | Out-Host

        do {
            $SelectReadHost = Read-Host -Prompt "Select a Windows Image to apply by Number"
        }
        until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Results.Number))))

        $Results = $Results | Where-Object {$_.Number -eq $SelectReadHost}
        $Results

        $Global:AzOSDCloudImage = $Global:AzOSDCloudBlobImage | Where-Object {$_.Name -eq $Results.Blob}
        $Global:AzOSDCloudImage = $Global:AzOSDCloudImage | Where-Object {$_.BlobClient.BlobContainerName -eq $Results.Container}
        $Global:AzOSDCloudImage = $Global:AzOSDCloudImage | Where-Object {$_.BlobClient.AccountName -eq $Results.StorageAccount}
        $Global:AzOSDCloudImage | Select-Object * | Export-Clixml "$env:SystemDrive\AzOSDCloudImage.xml"
        $Global:AzOSDCloudImage | Select-Object * | ConvertTo-Json | Out-File "$env:SystemDrive\AzOSDCloudImage.json"
        #=================================================
        #   Invoke-OSDCloud.ps1
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Green "Invoke-OSDCloud ... Starting in 5 seconds..."
        Start-Sleep -Seconds 5
        Invoke-OSDCloud
    }
    else {
        Write-Warning 'Unable to find a WIM on any of the OSDCloud Azure Storage Containers'
        Write-Warning 'Make sure you have a WIM Windows Image in the OSDCloud Azure Storage Container'
        Write-Warning 'Make sure this user has the Azure Storage Blob Data Reader role to the OSDCloud Container'
        Write-Warning 'You may need to execute Get-OSDCloudAzureResources then Start-OSDCloudAzureCLI'
    }
}
#endregion
#=================================================
New-Alias -Name 'Connect-AzWinPE' -Value 'Connect-OSDCloudAzure' -Description 'OSDCloud' -Force
New-Alias -Name 'Connect-AzureWinPE' -Value 'Connect-OSDCloudAzure' -Description 'OSDCloud' -Force