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

    if ($Global:AzContext) {
        #Write-Host -ForegroundColor DarkGray    'Storage Accounts:          $Global:AzStorageAccounts'
        $Global:AzStorageAccounts = Get-AzStorageAccount
        if ($OSDCloudLogs) {
            #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] $OSDCloudLogs\AzStorageAccounts.json"
            $Global:AzStorageAccounts | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzStorageAccounts.json" -Encoding ascii -Width 2000 -Force
        }
    
        #Write-Host -ForegroundColor DarkGray    'OSDCloud Storage Accounts: $Global:AzOSDCloudStorageAccounts'
        $Global:AzOSDCloudStorageAccounts = Get-AzStorageAccount | Where-Object {$_.Tags.ContainsKey('OSDCloud')}
        #$Global:AzOSDCloudStorageAccounts = Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts'
        #$Global:AzOSDCloudStorageAccounts = Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts' | Where-Object {$_.Tags.ContainsKey('OSDCloud')}
        if ($OSDCloudLogs) {
            #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] $OSDCloudLogs\AzOSDCloudStorageAccounts.json"
            $Global:AzOSDCloudStorageAccounts | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudStorageAccounts.json" -Encoding ascii -Width 2000 -Force
        }
    
        $Global:AzStorageContext = @{}
        $Global:AzOSDCloudBlobAutopilotFile = @()
        $Global:AzOSDCloudBlobBootImage = @()
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
                    #Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] $OSDCloudLogs\AzOSDCloudStorageContainers.json"
                    $Global:AzOSDCloudStorageContainers | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudStorageContainers.json" -Encoding ascii -Width 2000 -Force
                }
            
                if ($AzOSDCloudStorageContainers) {
                    foreach ($Container in $AzOSDCloudStorageContainers) {
                        if ($Container.Name -like "provision*") {
                            #Provision Containers apply to all deployments in the selected Storage Account
                            Write-Host -ForegroundColor DarkGray "OSDCloud Provision Container: $($Item.StorageAccountName)/$($Container.Name)"
                            $Global:AzOSDCloudBlobAutopilotFile += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob AutoPilotConfigurationFile.json -ErrorAction Ignore
                            $Global:AzOSDCloudBlobPackage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.ppkg -ErrorAction Ignore
                            $Global:AzOSDCloudBlobScript += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob Invoke*.ps1 -ErrorAction Ignore
                        }
                        elseif ($Container.Name -like "bootimage*") {
                            Write-Host -ForegroundColor DarkGray "OSDCloud BootImage Container: $($Item.StorageAccountName)/$($Container.Name)"
                            $Global:AzOSDCloudBlobBootImage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.iso -ErrorAction Ignore
                        }
                        elseif ($Container.Name -like "driverpack*") {
                            Write-Host -ForegroundColor DarkGray "OSDCloud DriverPack Container: $($Item.StorageAccountName)/$($Container.Name)"
                            $Global:AzOSDCloudBlobDriverPack += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.cab -ErrorAction Ignore
                            $Global:AzOSDCloudBlobDriverPack += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.exe -ErrorAction Ignore
                            $Global:AzOSDCloudBlobDriverPack += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.msi -ErrorAction Ignore
                            $Global:AzOSDCloudBlobDriverPack += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.zip -ErrorAction Ignore
                        }
                        elseif ($Container.Name -like "temp*") {
                            #Temp Containers are not used and should be where you store content that will not be used in a Container Task Sequence
                            Write-Host -ForegroundColor DarkGray "OSDCloud Temp Container: $($Item.StorageAccountName)/$($Container.Name)"
                        }
                        else {
                            Write-Host -ForegroundColor DarkGray "OSDCloud Image Container: $($Item.StorageAccountName)/$($Container.Name)"
                            $Global:AzOSDCloudBlobImage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.esd -ErrorAction Ignore | Where-Object {$_.Length -gt 3000000000}
                            $Global:AzOSDCloudBlobImage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.iso -ErrorAction Ignore | Where-Object {$_.Length -gt 3000000000}
                            $Global:AzOSDCloudBlobImage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.wim -ErrorAction Ignore | Where-Object {$_.Length -gt 3000000000}

                            $Global:AzOSDCloudBlobAutopilotFile += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob AutoPilotConfigurationFile.json -ErrorAction Ignore
                            $Global:AzOSDCloudBlobPackage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.ppkg -ErrorAction Ignore
                            $Global:AzOSDCloudBlobScript += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob Invoke*.ps1 -ErrorAction Ignore
                        }
                    }
                }
            }
            if ($OSDCloudLogs) {
                $Global:AzStorageContext | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzStorageContext.json" -Encoding ascii -Width 2000 -Force
                $Global:AzOSDCloudBlobAutopilotFile | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudBlobAutopilotFile.json" -Encoding ascii -Width 2000 -Force
                $Global:AzOSDCloudBlobBootImage| ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudBlobBootImage.json" -Encoding ascii -Width 2000 -Force
                $Global:AzOSDCloudBlobDriverPack | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudBlobDriverPack.json" -Encoding ascii -Width 2000 -Force
                $Global:AzOSDCloudBlobImage | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudBlobImage.json" -Encoding ascii -Width 2000 -Force
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