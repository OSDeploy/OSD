<#
.Synopsis
Runs an Azure Key Vault Secret using PowerShell Invoke-Expression
.Description
Runs an Azure Key Vault Secret using PowerShell Invoke-Expression
.Link
https://osd.osdeploy.com
#>
function Invoke-AzKeyVaultSecret
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.String]
        # Specifies the name of the key vault to which the secret belongs. This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.
        $VaultName,

        [Parameter()]
        [ValidateNotNull()]
        [System.String[]]
        # Specifies the name of the secret to get.
        $Name,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )
    
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
        if (! ($Force))
        {
            Write-Warning 'Use the -Force parameter to Invoke-Expression'
        }
        if (! ($Name))
        {
            $Name = Get-AzKeyVaultSecret -VaultName "$VaultName" | Select-Object -ExpandProperty Name
        }
        if ($Name)
        {
            foreach ($Item in $Name)
            {
                if ($Force)
                {
                    Write-Verbose "Invoke-Expression -Command (Get-AzKeyVaultSecret -VaultName $VaultName -Name $Item -AsPlainText)" -Verbose
                    Invoke-Expression -Command (Get-AzKeyVaultSecret -VaultName "$VaultName" -Name "$Item" -AsPlainText)
                }
                else
                {
                    Write-Verbose "Invoke-Expression -Command (Get-AzKeyVaultSecret -VaultName $VaultName -Name $Item -AsPlainText)" -Verbose
                    Write-Verbose $(Get-AzKeyVaultSecret -VaultName "$VaultName" -Name "$Item" -AsPlainText)
                }
            }
        }
    }
    else
    {
        Write-Error "Authenticate to Azure using 'Connect-AzAccount -DeviceCode'"
    }
}
<#
.Synopsis
Converts a value to an Azure Key Vault Secret
.Description
Converts a value to an Azure Key Vault Secret
.Notes
.Link
https://osd.osdeploy.com
#>
function ConvertTo-AzKeyVaultSecret
{
    [CmdletBinding(DefaultParameterSetName='ByString', PositionalBinding=$false)]
    param
    (
        [Parameter(Mandatory)]
        [Alias('Vault')]
        [System.String]
        # Specifies the name of the key vault to which the secret belongs. This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.
        $VaultName,
        
        [Parameter(Mandatory)]
        [Alias('Secret')]
        [System.String]
        # Specifies the name of the secret to get.
        $Name,

        [Parameter(ParameterSetName='ByClipboard', Mandatory)]
        [System.Management.Automation.SwitchParameter]
        # Clipboard text to store as the Azure Key Vault secret
        $Clipboard,

        [Parameter(ParameterSetName='ByFileContent', Mandatory)]
        # File selected to store the contents as the Azure Key Vault secret
        [System.IO.FileInfo]$File,

        [Parameter(ParameterSetName='ByString', Mandatory)]
        [System.String]
        # String to store as the Azure Key Vault secret
        $String,

        [Parameter(ParameterSetName='ByUriContent', Mandatory)]
        [System.Uri]
        # Uri to store as the Azure Key Vault secret
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
        if ($PSCmdlet.ParameterSetName -eq 'ByClipboard')
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
        if ($PSCmdlet.ParameterSetName -eq 'ByFileContent')
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
        if ($PSCmdlet.ParameterSetName -eq 'ByString')
        {
            if ($String)
            {
                $RawString = $String
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'ByUriContent')
        {
            try
            {
                $WebRequest = Invoke-WebRequest "$Uri" -UseBasicParsing -Method Head -MaximumRedirection 0 -ErrorAction SilentlyContinue
                if ($WebRequest.StatusCode -eq 200)
                {
                    $RawString = (Invoke-WebRequest -Uri $Uri -UseBasicParsing).Content
                }
            }
            catch
            {
                Write-Warning $_
            }
        }
        if ($RawString)
        {
            try
            {
                $SecretValue = ConvertTo-SecureString -String $RawString -AsPlainText -Force
                Set-AzKeyVaultSecret -VaultName $VaultName -Name $Name -SecretValue $SecretValue
            }
            catch
            {
                Write-Warning $_
            }
        }
    }
}