<#
.Synopsis
Converts a value to an Azure Key Vault Secret
.Description
Converts a value to an Azure Key Vault Secret
.Notes
.Link
https://osd.osdeploy.com
#>
function ConvertTo-PSKeyVaultSecret
{
    [CmdletBinding(DefaultParameterSetName='FromString', PositionalBinding=$false)]
    param
    (
        [Parameter(Mandatory)]
        [Alias('Vault')]
        # Specifies the name of the key vault to which the secret belongs. This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.
        [System.String]
        $VaultName,
        
        [Parameter(Mandatory)]
        [Alias('Secret','SecretName')]
        # Specifies the name of the secret to get.
        [System.String]
        $Name,

        [Parameter(ParameterSetName='FromClipboard', Mandatory)]
        # Clipboard text to store as the Azure Key Vault secret
        [System.Management.Automation.SwitchParameter]
        $Clipboard,

        [Parameter(ParameterSetName='FromFile', Mandatory)]
        # File selected to store the contents as the Azure Key Vault secret
        [System.IO.FileInfo]$File,

        [Parameter(ParameterSetName='FromString', Mandatory)]
        # String to store as the Azure Key Vault secret
        [System.String]
        $String,

        [Parameter(ParameterSetName='FromUriContent', Mandatory)]
        # Uri to store as the Azure Key Vault secret
        [System.Uri]
        $Uri
    )
    $RawString = $null

    $Module = Import-Module Az.Accounts -PassThru -ErrorAction Ignore
    if (-not $Module)
    {
        Install-Module Az.Accounts -Force
    }
    
    $Module = Import-Module Az.KeyVault -PassThru -ErrorAction Ignore
    if (-not $Module)
    {
        Install-Module Az.KeyVault -Force
    }
    
    if (!(Get-AzContext -ErrorAction Ignore))
    {
        Connect-AzAccount -DeviceCode
    }
    
    if (Get-AzContext -ErrorAction Ignore)
    {
        if ($PSCmdlet.ParameterSetName -eq 'FromClipboard')
        {
            if (Get-Clipboard -ErrorAction Ignore)
            {
                try
                {
                    $RawString = Get-Clipboard -Format Text -Raw
                }
                catch
                {
                    Write-Warning $_
                }
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'FromFile')
        {
            if (Test-Path $File)
            {
                try
                {
                    $RawString = Get-Content $File -Raw
                }
                catch
                {
                    Write-Warning $_
                }
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'FromString')
        {
            if ($String)
            {
                $RawString = $String
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'FromUriContent')
        {
            $GithubRawUrl = (Get-GithubRawUrl -Uri $Uri)

            foreach ($Item in $GithubRawUrl)
            {
                try
                {
                    $WebRequest = Invoke-WebRequest "$Item" -UseBasicParsing -Method Head -MaximumRedirection 0 -ErrorAction SilentlyContinue
                    if ($WebRequest.StatusCode -eq 200)
                    {
                        if ($RawString) {[System.String]$RawString += "`n"}
                        [System.String]$RawString += Invoke-RestMethod -Uri $Item
                    }
                }
                catch
                {
                    Write-Warning $_
                }
            }
        }
        if ($RawString)
        {
            try
            {
                $SecretValue = ConvertTo-SecureString -String $RawString -AsPlainText -Force
                Set-AzKeyVaultSecret -VaultName $VaultName -Name $Name -SecretValue $SecretValue -ContentType 'text/plain'
            }
            catch
            {
                Write-Warning $_
            }
        }
    }
}