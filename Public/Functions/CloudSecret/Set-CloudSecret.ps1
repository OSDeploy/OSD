<#
.SYNOPSIS
Converts a value to an Azure Key Vault Secret
.DESCRIPTION
Converts a value to an Azure Key Vault Secret
.NOTES
.LINK
https://osd.osdeploy.com
#>
function Set-CloudSecret
{
    [CmdletBinding(DefaultParameterSetName='FromUriContent')]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [Alias('Vault')]
        [System.String]
        # Specifies the name of the key vault to which the secret belongs. This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.
        $VaultName,
        
        [Parameter(Mandatory, Position = 1)]
        [Alias('Secret','SecretName')]
        # Specifies the name of the secret to set
        [System.String]
        $Name,

        [Parameter(ParameterSetName='FromUriContent', Mandatory)]
        [System.Uri]
        # Uri content to set as the Azure Key Vault secret
        $Uri,

        [Parameter(ParameterSetName='FromClipboard', Mandatory)]
        [System.Management.Automation.SwitchParameter]
        # Clipboard raw text to set as the Azure Key Vault secret
        $Clipboard,

        [Parameter(ParameterSetName='FromFile', Mandatory)]
        [System.IO.FileInfo]
        # File content to set as the Azure Key Vault secret
        $File,

        [Parameter(ParameterSetName='FromString', Mandatory)]
        [System.String]
        # String to set as the Azure Key Vault secret
        $String
    )
    $RawString = $null
    #=================================================
    #	Import Az Modules
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
        #=================================================
        #	FromUriContent
        #=================================================
        if ($PSCmdlet.ParameterSetName -eq 'FromUriContent') {
            $GithubRawUrl = (Get-GithubRawUrl -Uri $Uri)

            foreach ($Item in $GithubRawUrl) {
                try {
                    $WebRequest = Invoke-WebRequest "$Item" -UseBasicParsing -Method Head -MaximumRedirection 0 -ErrorAction SilentlyContinue
                    if ($WebRequest.StatusCode -eq 200) {
                        if ($RawString) {[System.String]$RawString += "`n"}
                        [System.String]$RawString += Invoke-RestMethod -Uri $Item
                    }
                }
                catch {
                    Write-Warning $_
                }
            }
        }
        #=================================================
        #	FromClipboard
        #=================================================
        if ($PSCmdlet.ParameterSetName -eq 'FromClipboard') {
            if (Get-Clipboard -ErrorAction Ignore) {
                try {
                    $RawString = Get-Clipboard -Format Text -Raw
                }
                catch {
                    Write-Warning $_
                }
            }
        }
        #=================================================
        #	FromFile
        #=================================================
        if ($PSCmdlet.ParameterSetName -eq 'FromFile') {
            if (Test-Path $File) {
                try {
                    $RawString = Get-Content $File -Raw
                }
                catch {
                    Write-Warning $_
                }
            }
        }
        #=================================================
        #	FromString
        #=================================================
        if ($PSCmdlet.ParameterSetName -eq 'FromString') {
            if ($String) {
                $RawString = $String
            }
        }
        #=================================================
        #	Set-AzKeyVaultSecret
        #=================================================
        if ($RawString) {
            try {
                $SecretValue = ConvertTo-SecureString -String $RawString -AsPlainText -Force
                Set-AzKeyVaultSecret -VaultName $VaultName -Name $Name -SecretValue $SecretValue -ContentType 'text/plain'
            }
            catch {
                Write-Warning $_
            }
        }
    }
}