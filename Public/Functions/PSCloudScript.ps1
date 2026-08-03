<#
.SYNOPSIS
Development function to get the contents of a PSCloudScript. Optionally allows for execution by command or file.

.DESCRIPTION
Development function to get the contents of a PSCloudScript. Optionally allows for execution by command or file.

.EXAMPLE
Get-PSCloudScript -Uri 'https://example.com/script.ps1'

.LINK
https://osd.osdeploy.com

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Improved readability and help metadata without changing behavior
#>
function Get-PSCloudScript
{
    [CmdletBinding(DefaultParameterSetName='FromUriContent')]
    param
    (
        [Parameter(Mandatory, ParameterSetName='FromUriContent',Position=0)]
        [ValidateNotNull()]
        # Uri content to use as a PSCloudScript
        [System.String]
        $Uri,

        [Parameter(Mandatory, ParameterSetName='FromAzKeyVaultSecret')]
        [ValidateNotNull()]
        [System.String]
        # Specifies the name of the key vault to which the secret belongs. This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.
        $VaultName,

        [Parameter(ParameterSetName='FromAzKeyVaultSecret')]
        [ValidateNotNull()]
        [System.String[]]
        # Specifies the name of the secret to get the content to use as a PSCloudScript
        $Name,

        [Parameter(Mandatory, ParameterSetName='FromClipboard')]
        # Clipboard raw text to use as a PSCloudScript
        [System.Management.Automation.SwitchParameter]
        $Clipboard,

        [Parameter(Mandatory, ParameterSetName='FromFile')]
        # File content to use as a PSCloudScript
        [System.IO.FileInfo]
        $File,

        [Parameter(Mandatory, ParameterSetName='FromString')]
        # String to use as a PSCloudScript
        [System.String]
        $String,

        [Parameter(Mandatory, ParameterSetName='FromGitHubRepo')]
        [ValidateNotNull()]
        [System.String]
        # GitHub Organization
        $RepoOwner,

        [Parameter(Mandatory, ParameterSetName='FromGitHubRepo')]
        [ValidateNotNull()]
        [System.String]
        # GitHub Repo
        $RepoName,

        [Parameter(Mandatory=$false, ParameterSetName='FromGitHubRepo')]
        [System.String]
        # GitHub Path
        $GithubPath = $null,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Command','File','FileRunas')]
        [System.String]
        $Invoke
    )

    Write-Warning 'PSCloudScript functions are currently under development'
    Write-Warning 'Functionality is subject to change until this warning is removed'

    $result = $null
    #=================================================
    #	FromUriContent
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'FromUriContent')
    {

        if ($Uri -match 'github')
        {
            [System.Array]$resolvedUrl = Get-GithubRawUrl -Uri $Uri
        }
        elseif (([System.Uri]$Uri).AbsoluteUri)
        {
            [System.String]$resolvedUrl = ([System.Uri]$Uri).AbsoluteUri
        }
        else
        {
            [System.String]$resolvedUrl = $Uri
        }

        foreach ($item in $resolvedUrl)
        {
            try
            {
                $webRequest = Invoke-WebRequest $item -UseBasicParsing -Method Head -ErrorAction SilentlyContinue
                if ($webRequest.StatusCode -eq 200)
                {
                    if ($resolvedUrl -is [System.Array])
                    {
                        [Array]$result += (Invoke-RestMethod -Uri $item)
                    }
                    else
                    {
                        $result = (Invoke-RestMethod -Uri $item)
                    }
                }
            }
            catch
            {
                Write-Warning $_
            }
        }
    }
    #=================================================
    #	FromAzKeyVaultSecret
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'FromAzKeyVaultSecret') {

        $module = Import-Module Az.Accounts -PassThru -ErrorAction Ignore
        if (-not $module) {
            Install-Module Az.Accounts -Force
        }

        $module = Import-Module Az.KeyVault -PassThru -ErrorAction Ignore
        if (-not $module) {
            Install-Module Az.KeyVault -Force
        }

        if (!(Get-AzContext -ErrorAction Ignore)) {
            Connect-AzAccount -DeviceCode
        }

        if (Get-AzContext -ErrorAction Ignore) {
            if (! ($Name)) {
                $Name = Get-AzKeyVaultSecret -VaultName "$VaultName" | Select-Object -ExpandProperty Name
            }
            if ($Name) {
                foreach ($item in $Name) {
                    Write-Verbose "Get-AzKeyVaultSecret -VaultName $VaultName -Name $item"
                    [array]$result += Get-AzKeyVaultSecret -VaultName "$VaultName" -Name "$item" -AsPlainText
                }
            }
        }
        else {
            Write-Error "Authenticate to Azure using 'Connect-AzAccount -DeviceCode'"
        }
    }
    #=================================================
    #	FromClipboard
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'FromClipboard')
    {
        if (Get-Clipboard -ErrorAction Ignore)
        {
            try
            {
                $result = Get-Clipboard -Format Text -Raw
            }
            catch
            {
                Write-Warning $_
            }
        }
    }
    #=================================================
    #	FromFile
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'FromFile')
    {
        if (Test-Path $File)
        {
            try
            {
                $result = Get-Content $File -Raw
            }
            catch
            {
                Write-Warning $_
            }
        }
    }
    #=================================================
    #	FromString
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'FromString')
    {
        $result = $String
    }
    #=================================================
    #	FromGitHubRepo
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'FromGitHubRepo')
    {
        $Uri = "https://api.github.com/repos/$RepoOwner/$RepoName/contents/$GithubPath"
        Write-Verbose $Uri

        $gitHubApiRateLimit = Invoke-RestMethod -UseBasicParsing -Uri 'https://api.github.com/rate_limit' -Method Get
        Write-Warning "You have used $($gitHubApiRateLimit.rate.used) of your $($gitHubApiRateLimit.rate.limit) GitHub API Requests"

        $Params = @{
            Method = 'GET'
            Uri = $Uri
            UseBasicParsing = $true
        }

        $gitHubApiContent = @()
        try {
            $gitHubApiContent = Invoke-RestMethod @Params -ErrorAction Stop
        }
        catch {
            Write-Error $_
            Break
        }

        if ($gitHubApiContent.count -eq 1)
        {
            $result = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($gitHubApiContent.content))
        }
        else
        {
            foreach ($item in $gitHubApiContent)
            {
                [array]$result += Invoke-RestMethod $item.download_url
            }
        }


    }
    #=================================================
    #	Invoke
    #=================================================
    if ($result)
    {
        foreach ($item in $result)
        {
            if ($Invoke -eq 'Command')
            {
                Invoke-Expression -Command $item
            }
            elseif ($Invoke -eq 'File')
            {
                $item | Out-File -FilePath "$env:TEMP\PSCloudScript.ps1"
                & "$env:TEMP\PSCloudScript.ps1"
                Remove-Item -Path "$env:TEMP\PSCloudScript.ps1" -Force -ErrorAction Ignore | Out-Null
            }
            elseif ($Invoke -eq 'FileRunas')
            {
                $item | Out-File -FilePath "$env:TEMP\PSCloudScript.ps1"
                Start-Process powershell.exe -Verb Runas "& $env:TEMP\PSCloudScript.ps1" -Wait
                Remove-Item -Path "$env:TEMP\PSCloudScript.ps1" -Force -ErrorAction Ignore | Out-Null
            }
            else
            {
                $item
            }
        }
    }
}
