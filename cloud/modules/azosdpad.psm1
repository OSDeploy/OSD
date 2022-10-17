<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module can be loaded in all Windows phases
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdpad.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdpad.psm1')
#>
#=================================================
#region Functions
function Get-AzOSDCloudScript {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Get-AzOSDCloudScript"
    Write-Host -ForegroundColor DarkGray "========================================================================="

    if ($Global:AzureAD -or $Global:MgGraph) {
        Write-Host -ForegroundColor DarkGray    'Storage Accounts:          $Global:AzStorageAccounts'
        $Global:AzStorageAccounts = Get-AzStorageAccount
  
        Write-Host -ForegroundColor DarkGray    'OSDCloud Storage Accounts: $Global:AzOSDCloudStorageAccounts'
        $Global:AzOSDCloudStorageAccounts = Get-AzStorageAccount | Where-Object {$_.Tags.ContainsKey('OSDScripts')}
    
        Write-Host -ForegroundColor DarkGray    'Storage Contexts:          $Global:AzStorageContext'
        Write-Host -ForegroundColor DarkGray    'Blob PowerShell Scripts:   $Global:AzOSDCloudBlobScript'
        Write-Host ''
        $Global:AzStorageContext = @{}
        $Global:AzOSDCloudBlobScript = @()
    
        if ($Global:AzOSDCloudStorageAccounts) {
            Write-Host -ForegroundColor Cyan "Scanning for PowerShell Script"
            foreach ($Item in $Global:AzOSDCloudStorageAccounts) {
                $Global:AzCurrentStorageContext = New-AzStorageContext -StorageAccountName $Item.StorageAccountName
                $Global:StorageContainers = Get-AzStorageContainer -Context $Global:AzCurrentStorageContext
                $Global:AzStorageContext."$($Item.StorageAccountName)" = $Global:AzCurrentStorageContext      
                if ($StorageContainers) {
                    foreach ($Container in $StorageContainers) {
                        Write-Host -ForegroundColor DarkGray "Storage Account: $($Item.StorageAccountName) Container: $($Container.Name)"
                        $Global:AzOSDCloudBlobScript += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.ps1 -ErrorAction Ignore
                        $Global:AzOSDCloudBlobScript += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.ppkg -ErrorAction Ignore
                        $Global:AzOSDCloudBlobScript += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.xml -ErrorAction Ignore

                    }
                }
            }
            Write-Host -ForegroundColor DarkGray "We found " -NoNewline
            write-host -ForegroundColor Cyan "$($Global:AzOSDCloudBlobScript.count) " -NoNewline
            write-host -ForegroundColor DarkGray "scripts on the storage account " -NoNewline
            write-host -ForegroundColor Cyan "$($Global:AzOSDCloudStorageAccounts.StorageAccountName)"
            Write-Host -ForegroundColor DarkGray "========================================================================="

            # return $Global:AzOSDCloudBlobScript
        }
        else {
            Write-Warning 'Unable to find any Azure Storage Accounts'
            Write-Warning 'Make sure the OSDCloud Azure Storage Account has an OSDScripts Tag'
            Write-Warning 'Make sure this user has the Azure Reader role on the OSDCloud Azure Storage Account'
        }
    }
    else {
        Write-Warning 'Unable to connect to AzureAD'
        Write-Warning 'You may need to execute Connect-OSDCloudAzure '
    }
}
function Start-AzOSDPAD {
    [CmdletBinding()]
    param ()

   # Connect to AzureAD Tennant 
    Connect-OSDcloudAzure

    # Get OSDCloud Scripts from Azure Storage Account with OSDScripts Tag
    Get-AzOSDCloudScript

    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-AzOSDPAD"
    Write-Host -ForegroundColor DarkGray "========================================================================="

    if ($Global:AzOSDCloudBlobScript) {
        $i = $null
        $Results = foreach ($Item in $Global:AzOSDCloudBlobScript) {
            $i++
            
            $BlobClient = $Global:AzOSDCloudStorageAccounts | Where-Object {$_.StorageAccountName -eq $Item.BlobClient.AccountName}

            $ObjectProperties = @{
                Number          = $i
                StorageAccount  = $Item.BlobClient.AccountName
                Tag             = ($BlobClient | Select-Object -ExpandProperty Tags).Get_Item('OSDScripts')
                Container       = $Item.BlobClient.BlobContainerName
                Blob            = $Item.Name
                Location        = $BlobClient | Select-Object -ExpandProperty Location
                ResourceGroup   = $BlobClient | Select-Object -ExpandProperty ResourceGroupName
                URL             = $Item.BlobClient.Uri
                ContentHash     = $Item.BlobProperties.ContentHash
                LastModified    = $Item.ICloudBlob.Properties.LastModified
                
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }

        $Results | Select-Object -Property Number, StorageAccount, Tag, Container, Blob, Location, ResourceGroup, URL | Format-Table | Out-Host

        $Global:AzOSDCloudGlobalScripts = $Results
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Green "Start-AzOSDPad"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        
        #wrong Path just for me
        & "C:\Users\$env:username\Documents\github\OSD\\Projects\azosdpadnew.ps1" 
        # & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\azosdpad.ps1"
         Start-Sleep -Seconds 2


    }
    else {
        Write-Warning 'Unable to find scripts on any of the OSDScripts Azure Storage Containers'
        Write-Warning 'Make sure you have a scripts file or unattened in the OSDScripts Azure Storage Container'
        Write-Warning 'Make sure this user has the Azure Storage Blob Data Reader role to the OSDCloud Container'
        Write-Warning 'You may need to execute Get-AzOSDCloudBScript'
    }
}

#endregion
#=================================================