<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module is designed for OOBE
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/secrets.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/secrets.psm1')
#>
#=================================================
#region Functions
function osdcloud-GetKeyVaultSecretList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [System.String]
        # Specifies the name of the key vault to which the secret belongs. This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.
        $VaultName
    )
    osdcloud-InstallModuleAzAccounts
    osdcloud-InstallModuleAzKeyVault

    if (!(Get-AzContext -ErrorAction Ignore)) {
        Connect-AzAccount -DeviceCode
    }

    if (Get-AzContext -ErrorAction Ignore) {
        Get-AzKeyVaultSecret -VaultName "$VaultName" | Select-Object -ExpandProperty Name
    }
    else {
        Write-Error "Authenticate to Azure using 'Connect-AzAccount -DeviceCode'"
    }
}
New-Alias -Name 'ListSecrets' -Value 'osdcloud-GetKeyVaultSecretList' -Description 'OSDCloud' -Force
function osdcloud-InvokeKeyVaultSecret {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [System.String]
        # Specifies the name of the key vault to which the secret belongs. This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.
        $VaultName,

        [Parameter(Mandatory=$true, Position=1)]
        [System.String]
        # Specifies the name of the secret to get the content to use as a PSCloudScript
        $Name
    )
    osdcloud-InstallModuleAzAccounts
    osdcloud-InstallModuleAzKeyVault

    if (!(Get-AzContext -ErrorAction Ignore)) {
        Connect-AzAccount -DeviceCode
    }

    if (Get-AzContext -ErrorAction Ignore) {
        $Result = Get-AzKeyVaultSecret -VaultName "$VaultName" -Name "$Name" -AsPlainText
        if ($Result) {
            Invoke-Expression -Command $Result
        }
    }
    else {
        Write-Error "Authenticate to Azure using 'Connect-AzAccount -DeviceCode'"
    }
}
New-Alias -Name 'InvokeSecret' -Value 'osdcloud-InvokeKeyVaultSecret' -Description 'OSDCloud' -Force
#endregion
#=================================================