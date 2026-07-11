<#
.SYNOPSIS
Development function to get the contents of a PSCloudScript. Optionally allows for execution by command or file
.DESCRIPTION
Development function to get the contents of a PSCloudScript. Optionally allows for execution by command or file
.LINK
https://osd.osdeploy.com
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

    $Result = $null
    #=================================================
    #	FromUriContent
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'FromUriContent')
    {
        
        if ($Uri -match 'github')
        {
            [System.Array]$ResolvedUrl = Get-GithubRawUrl -Uri $Uri
        }
        elseif (([System.Uri]$Uri).AbsoluteUri)
        {
            [System.String]$ResolvedUrl = ([System.Uri]$Uri).AbsoluteUri
        }
        else
        {
            [System.String]$ResolvedUrl = $Uri
        }

        foreach ($Item in $ResolvedUrl)
        {
            try
            {
                $WebRequest = Invoke-WebRequest $Item -UseBasicParsing -Method Head -ErrorAction SilentlyContinue
                if ($WebRequest.StatusCode -eq 200)
                {
                    if ($ResolvedUrl -is [System.Array])
                    {
                        [Array]$Result += (Invoke-RestMethod -Uri $Item)
                    }
                    else
                    {
                        $Result = (Invoke-RestMethod -Uri $Item)
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
            if (! ($Name)) {
                $Name = Get-AzKeyVaultSecret -VaultName "$VaultName" | Select-Object -ExpandProperty Name
            }
            if ($Name) {
                foreach ($Item in $Name) {
                    Write-Verbose "Get-AzKeyVaultSecret -VaultName $VaultName -Name $Item"
                    [array]$Result += Get-AzKeyVaultSecret -VaultName "$VaultName" -Name "$Item" -AsPlainText
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
                $Result = Get-Clipboard -Format Text -Raw
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
                $Result = Get-Content $File -Raw
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
        $Result = $String
    }
    #=================================================
    #	FromGitHubRepo
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'FromGitHubRepo')
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

        if ($GitHubApiContent.count -eq 1)
        {
            $Result = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($GitHubApiContent.content))
        }
        else
        {
            foreach ($Item in $GitHubApiContent)
            {
                [array]$Result += Invoke-RestMethod $Item.download_url
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