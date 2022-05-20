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

    if ($Global:AzureAD -or $Global:MgGraph) {
        Write-Host -ForegroundColor DarkGray    'Storage Accounts:          $Global:AzStorageAccounts'
        $Global:AzStorageAccounts = Get-AzStorageAccount
    
        Write-Host -ForegroundColor DarkGray    'OSDCloud Storage Accounts: $Global:AzOSDCloudStorageAccounts'
        $Global:AzOSDCloudStorageAccounts = Get-AzStorageAccount | Where-Object {$_.Tags.ContainsKey('OSDScripts')}
    
        Write-Host -ForegroundColor DarkGray    'Storage Contexts:          $Global:AzStorageContext'
        Write-Host -ForegroundColor DarkGray    'Blob PowerShell Scripts:       $Global:AzOSDCloudBlobScript'
        Write-Host ''
        $Global:AzStorageContext = @{}
        $Global:AzOSDCloudBlobScript = @()
    
        if ($Global:AzOSDCloudStorageAccounts) {
            Write-Host -ForegroundColor Cyan "Scanning for PowerShell Script"
            foreach ($Item in $Global:AzOSDCloudStorageAccounts) {
                $Global:AzCurrentStorageContext = New-AzStorageContext -StorageAccountName $Item.StorageAccountName
                $Global:AzStorageContext."$($Item.StorageAccountName)" = $Global:AzCurrentStorageContext      
                $StorageContainers = Get-AzStorageContainer -Context $Global:AzCurrentStorageContext
                if ($StorageContainers) {
                    foreach ($Container in $StorageContainers) {
                        Write-Host -ForegroundColor DarkGray "Storage Account: $($Item.StorageAccountName) Container: $($Container.Name)"
                        $Global:AzOSDCloudBlobScript += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.ps1 -ErrorAction Ignore
                        #$Global:AzOSDCloudBlobScript += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.ppkg -ErrorAction Ignore
                        #$Global:AzOSDCloudBlobScript += Get-AzStorageBlob -Context $Global:AzCurrentStorageContext -Container $Container.Name -Blob *.xml -ErrorAction Ignore

                    }
                }
            }
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
        Write-Warning 'You may need to execute Connect-AzOSDCloud '
    }
}
function Start-AzOSDPADbeta {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-AzOSDPAD"
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

        $Global:AzOSDCloudGlobalScripts = $Global:AzOSDCloudBlobScript | Where-Object {$_.Name -eq $Results.Blob}
        $Global:AzOSDCloudGlobalScripts = $Global:AzOSDCloudGlobalScripts | Where-Object {$_.BlobClient.BlobContainerName -eq $Results.Container}
        $Global:AzOSDCloudGlobalScripts = $Global:AzOSDCloudGlobalScripts | Where-Object {$_.BlobClient.AccountName -eq $Results.StorageAccount}
            # Path for Test only
        $Global:AzOSDCloudGlobalScripts | Select-Object * | Export-Clixml "d:\OSD\AzOSDCloudScript.xml"
        $Global:AzOSDCloudGlobalScripts | Select-Object * | ConvertTo-Json | Out-File "d:\OSD\AzOSDCloudScripts.json"
        #=================================================
        #   Invoke-OSDCloud.ps1
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Green "Invoke-OSDCloud ... Starting in 5 seconds..."
        Start-Sleep -Seconds 5
        #Invoke-OSDCloud
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