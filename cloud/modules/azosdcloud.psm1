<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module can be loaded in all Windows phases
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdcloud.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdcloud.psm1')
#>
#=================================================
#region Functions
function Get-AzOSDCloudBlobImage {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Get-AzOSDCloudBlobImage"

    if ($env:SystemDrive -eq 'X:') {
        $DebugLogs = "$env:SystemDrive\DebugLogs"
        if (-not (Test-Path $DebugLogs)) {
            New-Item $DebugLogs -ItemType Directory -Force | Out-Null
        }
    }

    if ($Global:AzureAD -or $Global:MgGraph) {
        Write-Host -ForegroundColor DarkGray    'Storage Accounts:          $Global:AzStorageAccounts'
        $Global:AzStorageAccounts = Get-AzStorageAccount
        if ($DebugLogs) {
            $Global:AzStorageAccounts | ConvertTo-Json | Out-File -FilePath "$DebugLogs\AzStorageAccounts.json" -Encoding ascii -Width 2000 -Force
        }
    
        Write-Host -ForegroundColor DarkGray    'OSDCloud Storage Accounts: $Global:AzOSDCloudStorageAccounts'
        $Global:AzOSDCloudStorageAccounts = Get-AzStorageAccount | Where-Object {$_.Tags.ContainsKey('OSDCloud')}
        #$Global:AzOSDCloudStorageAccounts = Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts'
        #$Global:AzOSDCloudStorageAccounts = Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts' | Where-Object {$_.Tags.ContainsKey('OSDCloud')}
        if ($DebugLogs) {
            $Global:AzOSDCloudStorageAccounts | ConvertTo-Json | Out-File -FilePath "$DebugLogs\AzOSDCloudStorageAccounts.json" -Encoding ascii -Width 2000 -Force
        }
    
        $Global:AzStorageContext = @{}
        $Global:AzOSDCloudBlobImage = @()
        $Global:AzOSDCloudBlobDriverPack = @()
    
        if ($Global:AzOSDCloudStorageAccounts) {
            Write-Host -ForegroundColor DarkGray    'Storage Contexts:          $Global:AzStorageContext'
            Write-Host -ForegroundColor DarkGray    'Blob Windows Images:       $Global:AzOSDCloudBlobImage'
            Write-Host ''
            Write-Host -ForegroundColor Cyan "Scanning for Windows Images"
            foreach ($Item in $Global:AzOSDCloudStorageAccounts) {
                $Global:AzCurrentStorageContext = New-AzStorageContext -StorageAccountName $Item.StorageAccountName
                $Global:AzStorageContext."$($Item.StorageAccountName)" = $Global:AzCurrentStorageContext
                #Get-AzStorageBlobByTag -TagFilterSqlExpression ""osdcloudimage""=""win10ltsc"" -Context $StorageContext
                #Get-AzStorageBlobByTag -Context $Global:AzCurrentStorageContext
        
                $StorageContainers = Get-AzStorageContainer -Context $Global:AzCurrentStorageContext
            
                if ($StorageContainers) {
                    foreach ($Container in $StorageContainers) {

                        if ($Container.Name -eq 'DriverPack') {
                            Write-Host -ForegroundColor DarkGray "Storage Account: $($Item.StorageAccountName) DriverPack Container: $($Container.Name)"
                            $Global:AzOSDCloudBlobDriverPack += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.cab -ErrorAction Ignore
                            $Global:AzOSDCloudBlobDriverPack += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.exe -ErrorAction Ignore
                            $Global:AzOSDCloudBlobDriverPack += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.zip -ErrorAction Ignore
                        }
                        else {
                            Write-Host -ForegroundColor DarkGray "Storage Account: $($Item.StorageAccountName) Image Container: $($Container.Name)"
                            $Global:AzOSDCloudBlobImage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.iso -ErrorAction Ignore | Where-Object {$_.Length -gt 3000000000}
                            $Global:AzOSDCloudBlobImage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.wim -ErrorAction Ignore | Where-Object {$_.Length -gt 3000000000}
                        }
                    }
                }
            }
            if ($DebugLogs) {
                $Global:AzStorageContext | ConvertTo-Json | Out-File -FilePath "$DebugLogs\AzStorageContext.json" -Encoding ascii -Width 2000 -Force
                $Global:AzOSDCloudBlobImage | ConvertTo-Json | Out-File -FilePath "$DebugLogs\AzOSDCloudBlobImage.json" -Encoding ascii -Width 2000 -Force
                $Global:AzOSDCloudBlobDriverPack | ConvertTo-Json | Out-File -FilePath "$DebugLogs\AzOSDCloudBlobDriverPack.json" -Encoding ascii -Width 2000 -Force
            }
        }
        else {
            Write-Warning 'Unable to find any Azure Storage Accounts'
            Write-Warning 'Make sure the OSDCloud Azure Storage Account has an OSDCloud Tag'
            Write-Warning 'Make sure this user has the Azure Reader role on the OSDCloud Azure Storage Account'
        }
    }
    else {
        Write-Warning 'Unable to connect to AzureAD'
        Write-Warning 'You may need to execute Connect-AzOSDCloud then Start-AzOSDCloud'
    }
}
function Start-AzOSDCloud {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-AzOSDCloud"
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
        Write-Warning 'You may need to execute Get-AzOSDCloudBlobImage then Start-AzOSDCloud'
    }
}
#endregion
#=================================================