function Invoke-AzOSDAzureConfig {
    <#
    .SYNOPSIS
    Deploy OSDCloud Azure infrastructure with Bicep or Terraform.

    .DESCRIPTION
    Prepares the local OSDCloud workspace, installs the required IaC tools, authenticates to Azure
    or the Azure CLI based on the selected parameter set, and deploys either the Bicep template or
    the Terraform configuration in C:\OSDCloud.

    .PARAMETER Location
    Azure region used by the Bicep deployment path.

    .PARAMETER ResourceGroupName
    Name of the resource group created and deployed by the Bicep path.

    .PARAMETER AzOSDUserNameStart
    Optional prefix passed through the Bicep parameter set for related OSDCloud Azure workflows.

    .PARAMETER UseTerraform
    Select the Terraform deployment path.

    .EXAMPLE
    Invoke-AzOSDAzureConfig -Location eastus -ResourceGroupName rg-osdcloud
    Runs the Bicep deployment path for the selected Azure region and resource group.

    .EXAMPLE
    Invoke-AzOSDAzureConfig -UseTerraform $true
    Runs the Terraform deployment path from C:\OSDCloud.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Updated help to repo standard

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .LINK
    https://github.com/OSDeploy/OSD/blob/master/Docs/Invoke-AzOSDAzureConfig.md
    #>
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
        $initialFolder = Get-Location
        $OSDCLOUDWorkspace = Set-Location C:\OSDCloud

        Install-azOSDIacTools
        if(   $PSCmdlet.ParameterSetName -eq 'Bicep'){

            $global:Connect=Connect-AzAccount -UseDeviceAuthentication  -ErrorAction Stop

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

        set-location $initialFolder

    }

}
