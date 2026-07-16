function Get-CloudSecret
{
    <#
    .SYNOPSIS
    Read a secret from Azure Key Vault.

    .DESCRIPTION
    Connects to Azure if needed and returns the named Key Vault secret as plain text.

    .PARAMETER VaultName
    Name of the Key Vault that contains the secret.

    .PARAMETER Name
    Name of the secret to read.

    .EXAMPLE
    Get-CloudSecret -VaultName contoso -Name Script
    Returns the secret text from the specified vault.

    .OUTPUTS
    System.String

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Updated help to repo standard

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNull()]
        [System.String]
        # Specifies the name of the key vault to which the secret belongs. This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.
        $VaultName,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNull()]
        [System.String]
        # Specifies the name of the secret to get the content to use as a PSCloudScript
        $Name
    )
    $GetAzKeyVaultSecret = $null
    #=================================================
    #	FromAzKeyVaultSecret
    #=================================================
    $Module = Import-Module Az.KeyVault -PassThru -ErrorAction Ignore
    if (-not $Module) {
        Install-Module Az.KeyVault -Force
    }

    $Module = Import-Module Az.Accounts -PassThru -ErrorAction Ignore
    if (-not $Module) {
        Install-Module Az.Accounts -Force
    }

    if (!(Get-AzContext -ErrorAction Ignore)) {
        if ($env:SystemDrive -eq 'X:') {
            $null = Connect-AzAccount -DeviceCode
        }
        else {
            $null = Connect-AzAccount -DeviceCode
        }
    }

    if (Get-AzContext -ErrorAction Ignore) {
        $GetAzKeyVaultSecret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $Name -AsPlainText
        Return $GetAzKeyVaultSecret
    }
    else {
        Write-Warning "Authenticate to Azure using 'Connect-AzAccount -DeviceCode'"
        Break
    }
}
