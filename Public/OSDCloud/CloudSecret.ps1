function Invoke-CloudSecret
{
    <#
    .SYNOPSIS
    Invoke a secret retrieved from Azure Key Vault.

    .DESCRIPTION
    Loads the named secret with Get-CloudSecret and either invokes it directly, writes it to a
    temporary file, or runs it elevated depending on the selected invoke mode.

    .PARAMETER VaultName
    Name of the Key Vault that contains the secret.

    .PARAMETER Name
    Name of the secret to read.

    .PARAMETER Invoke
    Choose how to run the secret content: Command, File, or FileRunas.

    .EXAMPLE
    Invoke-CloudSecret -VaultName contoso -Name Script
    Invokes the retrieved secret in the current session.

    .EXAMPLE
    Invoke-CloudSecret -VaultName contoso -Name Script -Invoke FileRunas
    Writes the secret to a temporary file and runs it elevated.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Updated help to repo standard

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
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
        $Name,

        [ValidateSet('Command','File','FileRunas')]
        [System.String]
        $Invoke = 'Command'
    )
    #=================================================
    #	Get-CloudSecret
    #=================================================
    [System.String]$GetCloudSecret = Get-CloudSecret -VaultName $VaultName -Name $Name
    #=================================================
    #	Invoke
    #=================================================
    if ($GetCloudSecret) {
        if ($Invoke -eq 'Command') {
            Invoke-Expression -Command $GetCloudSecret
        }
        if ($Invoke -eq 'File') {
            $GetCloudSecret | Out-File -FilePath "$env:TEMP\CloudSecret.ps1"
            & "$env:TEMP\CloudSecret.ps1"
            Remove-Item -Path "$env:TEMP\CloudSecret.ps1" -Force -ErrorAction Ignore | Out-Null
        }
        if ($Invoke -eq 'FileRunas') {
            $GetCloudSecret | Out-File -FilePath "$env:TEMP\CloudSecret.ps1"
            Start-Process powershell.exe -Verb Runas "& $env:TEMP\CloudSecret.ps1" -Wait
            Remove-Item -Path "$env:TEMP\CloudSecret.ps1" -Force -ErrorAction Ignore | Out-Null
        }
    }
}
function Set-CloudSecret
{
    <#
    .SYNOPSIS
    Convert content to an Azure Key Vault secret.

    .DESCRIPTION
    Reads content from a URL, the clipboard, a file, or a raw string and stores it in Azure Key
    Vault as a secret.

    .PARAMETER VaultName
    Name of the Key Vault that receives the secret.

    .PARAMETER Name
    Name of the secret to set.

    .PARAMETER Uri
    URI content to set as the Azure Key Vault secret.

    .PARAMETER Clipboard
    Clipboard text to set as the Azure Key Vault secret.

    .PARAMETER File
    File content to set as the Azure Key Vault secret.

    .PARAMETER String
    String content to set as the Azure Key Vault secret.

    .EXAMPLE
    Set-CloudSecret -VaultName contoso -Name Script -File .\script.ps1
    Uploads file contents to Key Vault.

    .EXAMPLE
    Set-CloudSecret -VaultName contoso -Name Script -Clipboard
    Stores clipboard contents in Key Vault.

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Updated help to repo standard

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
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
