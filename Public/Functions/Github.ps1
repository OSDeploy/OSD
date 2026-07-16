function Get-GithubRawContent {
    <#
    .SYNOPSIS
    Retrieves content from GitHub or Gist raw URLs.

    .DESCRIPTION
    Resolves one or more GitHub/Gist URLs to raw content URLs and retrieves the
    content for each URL using Invoke-RestMethod. Failed URLs emit warnings while
    successful responses continue to stream to the pipeline.

    .PARAMETER Uri
    A GitHub, Gist, raw URL, or other absolute URI to retrieve content from.

    .EXAMPLE
    Get-GithubRawContent -Uri 'https://github.com/OSDeploy/OSD/blob/master/README.md'
    Retrieves the raw README.md content.

    .EXAMPLE
    'https://gist.github.com/user/0123456789abcdef' | Get-GithubRawContent
    Retrieves content for each file in the gist.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-13 - Improved error handling and pipeline support
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Url')]
        [System.Uri[]]
        $Uri
    )

    process {
        foreach ($CurrentUri in $Uri) {
            $GithubRawUrl = Get-GithubRawUrl -Uri $CurrentUri

            foreach ($Item in $GithubRawUrl) {
                if (-not $Item) {
                    continue
                }

                Write-Verbose "Retrieving $Item"
                try {
                    Invoke-RestMethod -Uri $Item -Method Get -ErrorAction Stop
                }
                catch {
                    Write-Warning "Failed to retrieve $Item. $($_.Exception.Message)"
                }
            }
        }
    }
}
function Get-GithubRawUrl {
    <#
    .SYNOPSIS
    Resolves a GitHub or Gist URL to one or more raw content URLs.

    .DESCRIPTION
    Converts common GitHub URL forms (blob, raw, and gist) to direct raw content
    URLs that can be consumed by download or content retrieval commands. For gist
    pages, the function queries the GitHub Gist API to return raw URLs for all files.

    .PARAMETER Uri
    A GitHub, Gist, raw URL, or other absolute URI to resolve.

    .EXAMPLE
    Get-GithubRawUrl -Uri 'https://github.com/OSDeploy/OSD/blob/master/README.md'
    Returns the matching raw.githubusercontent.com URL for README.md.

    .EXAMPLE
    Get-GithubRawUrl -Uri 'https://gist.github.com/user/0123456789abcdef'
    Returns raw URLs for files in the specified gist.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-13 - Improved URL normalization and gist API handling
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Url')]
        [System.Uri[]]
        $Uri
    )

    process {
        foreach ($CurrentUri in $Uri) {
            if (-not $CurrentUri -or -not $CurrentUri.AbsoluteUri) {
                continue
            }

            $HostName = $CurrentUri.Host.ToLowerInvariant()
            $AbsolutePath = $CurrentUri.AbsolutePath.Trim('/')

            if ($HostName -eq 'raw.githubusercontent.com' -or $HostName -eq 'gist.githubusercontent.com') {
                $CurrentUri.AbsoluteUri
                continue
            }

            if ($HostName -eq 'gist.github.com') {
                try {
                    $GistId = $null
                    if ($AbsolutePath -match '(?<id>[a-fA-F0-9]{8,})') {
                        $GistId = $Matches.id
                    }

                    if ($GistId) {
                        $Headers = @{ 'User-Agent' = 'PowerShell' }
                        $Gist = Invoke-RestMethod -Uri ("https://api.github.com/gists/{0}" -f $GistId) -Headers $Headers -Method Get -ErrorAction Stop
                        $Gist.files.PSObject.Properties.Value.raw_url | Where-Object { $_ } | Select-Object -Unique
                        continue
                    }
                }
                catch {
                    Write-Warning "Unable to resolve gist API URL for $CurrentUri. $($_.Exception.Message)"
                }

                # Fallback to legacy page parsing when gist API lookup fails.
                try {
                    $GetUri = (Invoke-WebRequest -UseBasicParsing -Method Get -Uri $CurrentUri -ErrorAction Stop).Links |
                        Where-Object { $_.href -match '/raw/' } |
                        Select-Object -ExpandProperty href

                    $GetUri |
                        ForEach-Object { "https://gist.githubusercontent.com$_" -replace '\/raw\/[\w-]{40}', '/raw' } |
                        Select-Object -Unique
                }
                catch {
                    Write-Warning "Unable to parse gist URL for $CurrentUri. $($_.Exception.Message)"
                }

                continue
            }

            if ($HostName -eq 'github.com') {
                $PathParts = $AbsolutePath -split '/'
                if ($PathParts.Count -ge 5 -and ($PathParts[2] -eq 'blob' -or $PathParts[2] -eq 'raw')) {
                    $Owner = $PathParts[0]
                    $Repo = $PathParts[1]
                    $Branch = $PathParts[3]
                    $FilePath = ($PathParts[4..($PathParts.Count - 1)] -join '/')
                    "https://raw.githubusercontent.com/$Owner/$Repo/$Branch/$FilePath"
                    continue
                }

                # Fallback to page parsing if the URL is not a direct blob/raw path.
                try {
                    $GetUri = (Invoke-WebRequest -UseBasicParsing -Method Get -Uri $CurrentUri -ErrorAction Stop).Links |
                        Where-Object { $_.href -match '/raw/' } |
                        Select-Object -ExpandProperty href

                    $GetUri |
                        ForEach-Object {
                            $Normalized = $_ -replace '/raw/', '/'
                            if ($Normalized -match '^https?://') {
                                $Normalized -replace '^https?://github.com', 'https://raw.githubusercontent.com'
                            }
                            else {
                                "https://raw.githubusercontent.com$Normalized"
                            }
                        } |
                        Select-Object -Unique
                }
                catch {
                    Write-Warning "Unable to parse GitHub URL for $CurrentUri. $($_.Exception.Message)"
                }

                continue
            }

            $CurrentUri.AbsoluteUri
        }
    }
}
