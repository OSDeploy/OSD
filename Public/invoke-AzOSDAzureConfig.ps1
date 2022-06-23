function invoke-AzOSDAzureConfig {
    [CmdletBinding()]
    param (
       [Parameter(ParameterSetName = 'Bicep')]
       [ValidateSet('eastasia', 'southeastasia', "centralus",'eastus','eastus2','westus','northcentralus','southcentralus','northeurope','westeurope','japanwest','japaneast','brazilsouth','australiaeast','australiasoutheast','southindia','centralindia','westindia','canadacentral','canadaeast','uksouth','ukwest','westcentralus','germanywestcentral','norwaywest','norwayeast','brazilsoutheast','westus3','swedencentral')]
       $Location,
       [Parameter(ParameterSetName = 'Bicep')]
       [string]$ResourceGroupName,
       [Parameter(ParameterSetName = 'Bicep')]
       [string]$AzOSDUserNameStart,
       [Parameter(ParameterSetName = 'Terraform')]
       [Bool]$UseTerraform = $true


    )
    
    begin {
        Install-azOSDIacTools
        if(   $PSCmdlet.ParameterSetName -eq 'Bicep'){

            $global:Connect=Connect-AzAccount
           
           }
        elseif ( $PSCmdlet.ParameterSetName -eq 'Terraform') {
            $global:Connect = az login --use-device-code
        }

    }
    
    process {
        Write-Host "============================================================" -ForegroundColor Gray
        Write-Host "Starting Infrastructure As code for OSDCloud" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Gray
        write-host ""

        if(   $PSCmdlet.ParameterSetName -eq 'Bicep'){
            
            Write-Host "Provider: " -ForegroundColor Gray -NoNewline
            Write-Host "Bicep" -ForegroundColor Green 
            $global:AzOSDressourceGroup=New-AzResourceGroup  -Name $ResourceGroupName  -Location $Location
            $global:AzOSDressourceGroupDeployment=New-AzResourceGroupDeployment -Name azOSDCloud -ResourceGroupName $ResourceGroupName -TemplateFile .\bicep\azosdbicep.bicep  -location $Location
            Write-Host "Status: " -ForegroundColor Gray -NoNewline
            Write-Host "Finished" -ForegroundColor Green 

               
           }
        elseif ( $PSCmdlet.ParameterSetName -eq 'Terraform') {
            Write-Host "Provider: " -ForegroundColor Gray -NoNewline
            Write-Host "Terraform" -ForegroundColor Green 
            Set-Location .\terraform
            terraform init
            terraform apply -auto-approve
            Write-Host "Status: " -ForegroundColor Gray -NoNewline
            Write-Host "Finished" -ForegroundColor Green 

        }


}
    end {
        Write-Host "============================================================" -ForegroundColor Gray
        Write-Host "End Infrastructure As code for OSDCloud" -ForegroundColor Green
        Write-Host "Logout from Azure" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Gray
        write-host ""

        if(   $PSCmdlet.ParameterSetName -eq 'Bicep'){

    
            Logout-AzAccount | out-null
           
           }
        elseif ( $PSCmdlet.ParameterSetName -eq 'Terraform') {
            az logout
        }

    }
    
}


