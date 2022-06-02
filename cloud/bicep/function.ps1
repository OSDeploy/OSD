function invoke-AzOSDAzureBicepConfig {
    [CmdletBinding()]
    param (
       [Parameter(Mandatory=$true, Position=0)]
       [ValidateSet('eastasia', 'southeastasia', "centralus",'eastus','eastus2','westus','northcentralus','southcentralus','northeurope','westeurope','japanwest','japaneast','brazilsouth','australiaeast','australiasoutheast','southindia','centralindia','westindia','canadacentral','canadaeast','uksouth','ukwest','westcentralus','germanywestcentral','norwaywest','norwayeast','brazilsoutheast','westus3','swedencentral')]
       $Location,
       [Parameter(Mandatory=$true, Position=0)]
       [string]$ResourceGroupName,
       [Parameter(Mandatory=$true, Position=0)]
       [string]$AzOSDUserNameStart

    )
    
    begin {
        $global:Connect=Connect-AzAccount

    }
    
    process {
        $global:AzOSDressourceGroup=New-AzResourceGroup  -Name $ResourceGroupName  -Location $Location
        write-host "Resource Group Created $($global:AzOSDressourceGroup.ResourceGroupName)"
        
        $Script:AzOSDSubscription = ($global:AzOSDressourceGroup.ResourceId.split('/'))[2]
        $global:AzOSDressourceGroupDeployment=New-AzResourceGroupDeployment -Name OSDdemo -ResourceGroupName $ResourceGroupName -TemplateFile .\azOSDBicep.bicep  -location $Location
        
        New-AzRoleAssignment -ObjectID (Get-AzADUser -StartsWith "$AzOSDUserNameStart").Id `
        -RoleDefinitionName "Storage Blob Data Reader" `
        -Scope  "/subscriptions/9b288c1f-ce3f-4769-8d64-b9daa3ceb471/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/osdcloudbicepdemo2" | out-null
    
        New-AzRoleAssignment -ObjectID (Get-AzADUser -StartsWith "$AzOSDUserNameStart").Id `
        -RoleDefinitionName "Storage Blob Data Reader" `
        -Scope  "/subscriptions/9b288c1f-ce3f-4769-8d64-b9daa3ceb471/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/osdscripts2" | out-null
            
    $containersImages = @(
        "server",
        "retail",
        "insiders",
        "driverpack",
        "bootimage"
    )
    $containerScripts = @(
        "scripts",
        "packages",
        "unattend",
        "others"
    )
    foreach ($container in $containersImages) {
        New-AzRoleAssignment -ObjectID (Get-AzADUser -StartsWith "$AzOSDUserNameStart").Id `
        -RoleDefinitionName "Storage Blob Data Reader" `
        -Scope  "/subscriptions/$Script:AzOSDSubscription/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/osdcloudbicepdemo2/blobServices/default/containers/$container" | out-null

    }

    foreach ($container in $containerScripts) {
        New-AzRoleAssignment -ObjectID (Get-AzADUser -StartsWith "$AzOSDUserNameStart").Id `
        -RoleDefinitionName "Storage Blob Data Reader" `
        -Scope  "/subscriptions/$Script:AzOSDSubscription/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/osdscripts2/blobServices/default/containers/$container" | out-null

    }

}
    end {
        Logout-AzAccount | out-null
    }
    
}

invoke-AzOSDAzureBicepConfig -Location westeurope -ResourceGroupName DemoAzOSDCloud3 -AzOSDUserNameStart "osd"