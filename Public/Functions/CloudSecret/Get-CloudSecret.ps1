<#
.SYNOPSIS
Development function to get the contents of a PSCloudScript. Optionally allows for execution by command or file
.DESCRIPTION
Development function to get the contents of a PSCloudScript. Optionally allows for execution by command or file
.LINK
https://osd.osdeploy.com
#>
function Get-CloudSecret
{
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
    $Result = $null
    #=================================================
    #	FromAzKeyVaultSecret
    #=================================================
    $Module = Import-Module Az.Accounts -PassThru -ErrorAction Ignore
    if (-not $Module) {
        Install-Module Az.Accounts -Force
    }
    
    $Module = Import-Module Az.KeyVault -PassThru -ErrorAction Ignore
    if (-not $Module) {
        Install-Module Az.KeyVault -Force
    }

    if (!(Get-AzContext -ErrorAction Ignore)) {
        Connect-AzAccount -DeviceCode
    }

    if (Get-AzContext -ErrorAction Ignore) {
        $Result = Get-AzKeyVaultSecret -VaultName $VaultName -Name $Name -AsPlainText
        $Result
    }
    else {
        Write-Error "Authenticate to Azure using 'Connect-AzAccount -DeviceCode'"
    }
}