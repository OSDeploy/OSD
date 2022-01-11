<#
.Synopsis
Runs an Azure Key Vault Secret using PowerShell Invoke-Expression
.Description
Runs an Azure Key Vault Secret using PowerShell Invoke-Expression
.Link
https://osd.osdeploy.com
#>
function Get-PSCloudScript
{
    [CmdletBinding(DefaultParameterSetName='ByUriContent', PositionalBinding=$false)]
    param
    (
        [Parameter(Mandatory, ParameterSetName='ByAzKeyVaultSecret')]
        [ValidateNotNull()]
        [System.String]
        # Specifies the name of the key vault to which the secret belongs. This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.
        $VaultName,

        [Parameter(ParameterSetName='ByAzKeyVaultSecret')]
        [ValidateNotNull()]
        [System.String[]]
        # Specifies the name of the secret to get.
        $Name,

        [Parameter(Mandatory, ParameterSetName='ByClipboard')]
        # Clipboard text to store as the Azure Key Vault secret
        [System.Management.Automation.SwitchParameter]
        $Clipboard,

        [Parameter(Mandatory, ParameterSetName='ByFileContent')]
        # File selected to store the contents as the Azure Key Vault secret
        [System.IO.FileInfo]$File,

        [Parameter(Mandatory, ParameterSetName='ByString')]
        # String to store as the Azure Key Vault secret
        [System.String]
        $String,
        
        [Parameter(Mandatory, ParameterSetName='ByGithubRepo',Position=0)]
        [ValidateNotNull()]
        [System.String]
        # Specifies the name of the key vault to which the secret belongs. This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.
        $RepoOwner,
        
        [Parameter(Mandatory, ParameterSetName='ByGithubRepo',Position=1)]
        [ValidateNotNull()]
        [System.String]
        # Specifies the name of the key vault to which the secret belongs. This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.
        $RepoName,
        
        [Parameter(Mandatory=$false, ParameterSetName='ByGithubRepo',Position=2)]
        [ValidateNotNull()]
        [System.String]
        # Specifies the name of the key vault to which the secret belongs. This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.
        $GithubPath,

        [Parameter(Mandatory, ParameterSetName='ByUriContent')]
        # Uri to store as the Azure Key Vault secret
        [System.Uri]
        $Uri,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Command','File','FileRunas')]
        [System.String]
        $Invoke
    )
    Write-Warning 'PSCloudScript functions are currently under development'
    Write-Warning 'Functionality is subject to change until this warning is removed'

    $Result = $null
    #=================================================
    #	ByAzKeyVaultSecret
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'ByAzKeyVaultSecret')
    {
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
            if (! ($Name))
            {
                $Name = Get-AzKeyVaultSecret -VaultName "$VaultName" | Select-Object -ExpandProperty Name
            }
            if ($Name)
            {
                foreach ($Item in $Name)
                {
                    Write-Verbose "Get-AzKeyVaultSecret -VaultName $VaultName -Name $Item"
                    [array]$Result += Get-AzKeyVaultSecret -VaultName "$VaultName" -Name "$Item" -AsPlainText
                }
            }
        }
        else
        {
            Write-Error "Authenticate to Azure using 'Connect-AzAccount -DeviceCode'"
        }
    }
    #=================================================
    #	ByClipboard
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'ByClipboard')
    {
        if (Get-Clipboard -ErrorAction Ignore)
        {
            try
            {
                $Result = Get-Clipboard -Format Text -Raw
            }
            catch
            {
                Write-Warning $_
            }
        }
    }
    #=================================================
    #	ByFileContent
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'ByFileContent')
    {
        if (Test-Path $File)
        {
            try
            {
                $Result = Get-Content $File -Raw
            }
            catch
            {
                Write-Warning $_
            }
        }
    }
    #=================================================
    #	ByGithubRepo
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'ByGithubRepo')
    {
        $Uri = "https://api.github.com/repos/$RepoOwner/$RepoName/contents/$GithubPath"
        Write-Verbose $Uri

        $GitHubApiRateLimit = Invoke-RestMethod -UseBasicParsing -Uri 'https://api.github.com/rate_limit' -Method Get
        Write-Warning "You have used $($GitHubApiRateLimit.rate.used) of your $($GitHubApiRateLimit.rate.limit) GitHub API Requests"

        $Params = @{
            Method = 'GET'
            Uri = $Uri
            UseBasicParsing = $true
        }

        $GitHubApiContent = @()
        try {
            $GitHubApiContent = Invoke-RestMethod @Params -ErrorAction Stop
        }
        catch {
            Write-Error $_
            Break
        }

        $Result = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($GitHubApiContent.content))
    }
    #=================================================
    #	ByUriContent
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'ByUriContent')
    {
        
        if ($Uri -match 'github.com')
        {
            $Result = Get-GithubRawContent -Uri $Uri
        }
        else 
        {
            try
            {
                $WebRequest = Invoke-WebRequest $GithubRawUrl -UseBasicParsing -Method Head -ErrorAction SilentlyContinue
                if ($WebRequest.StatusCode -eq 200)
                {
                    $Result = (Invoke-WebRequest -Uri $GithubRawUrl -UseBasicParsing).Content
                }
            }
            catch
            {
                Write-Warning $_
            }

        }
    }
    #=================================================
    #	Invoke
    #=================================================
    if ($Result)
    {
        foreach ($Item in $Result)
        {
            if ($Invoke -eq 'Command')
            {
                Invoke-Expression -Command $Item
            }
            elseif ($Invoke -eq 'File')
            {
                $Item | Out-File -FilePath "$env:TEMP\PSCloudScript.ps1"
                & "$env:TEMP\PSCloudScript.ps1"
                Remove-Item -Path "$env:TEMP\PSCloudScript.ps1" -Force -ErrorAction Ignore | Out-Null
            }
            elseif ($Invoke -eq 'FileRunas')
            {
                $Item | Out-File -FilePath "$env:TEMP\PSCloudScript.ps1"
                Start-Process powershell.exe -Verb Runas "& $env:TEMP\PSCloudScript.ps1" -Wait
                Remove-Item -Path "$env:TEMP\PSCloudScript.ps1" -Force -ErrorAction Ignore | Out-Null
            }
            else
            {
                $Item
            }
        }
    }
}