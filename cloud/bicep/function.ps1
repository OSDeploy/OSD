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
        

}
    end {
        Logout-AzAccount | out-null
    }
    
}

invoke-AzOSDAzureBicepConfig -Location westeurope -ResourceGroupName DemoAzOSDCloud3 -AzOSDUserNameStart "osd"