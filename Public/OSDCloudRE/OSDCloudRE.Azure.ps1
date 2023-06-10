function Get-OSDCloudREAzureResources {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Get-OSDCloudREAzureResources"

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
        $Global:AzOSDCloudBlobBootImage = @()
        $Global:AzOSDCloudBootImage = @()
    
        if ($Global:AzOSDCloudStorageAccounts) {
            #Write-Host -ForegroundColor DarkGray    'Storage Contexts:          $Global:AzStorageContext'
            #Write-Host -ForegroundColor DarkGray    'Blob Windows Images:       $Global:AzOSDCloudBlobImage'
            #Write-Host ''
            Write-Host -ForegroundColor Cyan "Searching Azure Storage for OSDCloudRE Resources"
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
                        if ($Container.Name -eq 'BootImage') {
                            Write-Host -ForegroundColor DarkGray "BootImage Container: $($Item.StorageAccountName)/$($Container.Name)"
                            $Global:AzOSDCloudBlobBootImage += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.iso -ErrorAction Ignore

                        }
                    }
                }
            }
            if ($OSDCloudLogs) {
                $Global:AzStorageContext | ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzStorageContext.json" -Encoding ascii -Width 2000 -Force
                $Global:AzOSDCloudBlobBootImage| ConvertTo-Json | Out-File -FilePath "$OSDCloudLogs\AzOSDCloudBlobDriverPack.json" -Encoding ascii -Width 2000 -Force
            }
            if ($null -eq $Global:AzOSDCloudBlobBootImage) {
                Write-Warning 'Unable to find a Boot Image on any of the OSDCloud Azure Storage Containers'
                Write-Warning 'Make sure you have a ISO Boot Image in the OSDCloud Azure Storage Container named BootImage'
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
function Start-OSDCloudREAzure {
    <#
    .SYNOPSIS
    OSDCloudRE: Creates a new OSDCloudRE Volume from Azure

    .DESCRIPTION
    OSDCloudRE: Creates a new OSDCloudRE Volume from Azure

    .EXAMPLE
    Start-OSDCloudREAzure

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]
        #Clears previous variables
        $Force
    )
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-OSDCloudREAzure"
    
    if ($env:SystemDrive -ne 'X:') {
        if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
            Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)

            Connect-OSDCloudAzure
            Get-OSDCloudREAzureResources

            if ($Global:AzOSDCloudBlobBootImage) {
                & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\OSDCloudREAzure\MainWindow.ps1"
                Start-Sleep -Seconds 2
        
                if ($Global:StartOSDCloudRE.AzOSDCloudBootImage) {
                    Write-Host -ForegroundColor DarkGray "========================================================================="
                    Write-Host -ForegroundColor Green "Invoke-OSDCloudRE"
                    Invoke-OSDCloudRE
                }
                else {
                    Write-Warning "Unable to get an ISO Boot Image from Start-OSDCloudREAzure"
                }
            }
            else {
                Write-Warning 'Start-OSDCloudREAzure could not find any Boot Images in Azure'
                Break
            }
        }
        else {
            Write-Warning 'Start-OSDCloudREAzure must be run with Admin Rights'
            Break
        }
    }
    else {
        Write-Warning "Start-OSDCloudREAzure must be run from Windows"
        Break
    }
}