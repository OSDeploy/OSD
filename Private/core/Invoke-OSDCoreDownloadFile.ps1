function Invoke-OSDCoreDownloadFile {
    <#
    .SYNOPSIS
    Downloads a file to a local path and returns file information.

    .DESCRIPTION
    Downloads content from a source URL into a destination directory using
    either curl or WebClient fallback logic, then returns a FileInfo object for
    the downloaded file.

    .PARAMETER SourceUrl
    Source URL to download.

    .PARAMETER DestinationName
    Optional destination file name. If omitted, the file name is derived from
    the source URL.

    .PARAMETER DestinationDirectory
    Destination directory for the downloaded file.

    .PARAMETER Overwrite
    Overwrites the destination file if it already exists.

    .PARAMETER WebClient
    Forces use of WebClient instead of curl.

    .EXAMPLE
    Invoke-OSDCoreDownloadFile -SourceUrl 'https://example.org/file.cab' -DestinationDirectory "$env:TEMP\OSD"
    Downloads the file and returns a FileInfo object.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-16 - Moved help block inside function and expanded required sections
    #>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param
    (
        [Parameter(Position = 0, Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('FileUri')]
        [System.String]
        $SourceUrl,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('FileName')]
        [System.String]
        $DestinationName,

        [Alias('Path')]
        [System.String]
        $DestinationDirectory = (Join-Path $env:TEMP 'OSD'),

        #Overwrite the file if it exists already
        #The default action is to skip the download
        [System.Management.Automation.SwitchParameter]
        $Overwrite,

        [System.Management.Automation.SwitchParameter]
        $WebClient
    )
    #=================================================
    #	Values
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] SourceUrl: $SourceUrl"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DestinationName: $DestinationName"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DestinationDirectory: $DestinationDirectory"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Overwrite: $Overwrite"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] WebClient: $WebClient"
    #=================================================
    #	DestinationDirectory
    #=================================================
    if (Test-Path "$DestinationDirectory") {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Directory already exists at $DestinationDirectory"
    }
    else {
        New-Item -Path "$DestinationDirectory" -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    #=================================================
    #	Test File
    #=================================================
    $DestinationNewItem = New-Item -Path (Join-Path $DestinationDirectory "$(Get-Random).txt") -ItemType File

    if (Test-Path $DestinationNewItem.FullName) {
        $DestinationDirectory = $DestinationNewItem | Select-Object -ExpandProperty Directory
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Destination Directory is writable at $DestinationDirectory"
        Remove-Item -Path $DestinationNewItem.FullName -Force | Out-Null
    }
    else {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to write to Destination Directory"
        break
    }
    #=================================================
    #	DestinationName
    #=================================================
    if ($PSBoundParameters['DestinationName']) {
    }
    else {
        $DestinationNameUri = $SourceUrl -as [System.Uri] # Convert to Uri so we can ignore any query string
        $DestinationName = $DestinationNameUri.AbsolutePath.Split('/')[-1]
    }
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DestinationName: $DestinationName"
    #=================================================
    #	WebFileFullName
    #=================================================
    $DestinationDirectoryItem = (Get-Item $DestinationDirectory -Force).FullName
    $DestinationFullName = Join-Path $DestinationDirectoryItem $DestinationName
    #=================================================
    #	OverWrite
    #=================================================
    if ((-not ($PSBoundParameters['Overwrite'])) -and (Test-Path $DestinationFullName)) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] DestinationFullName already exists"
        Get-Item $DestinationFullName -Force
    }
    else {
        #=================================================
        #	Download
        #=================================================
        $SourceUrl = [Uri]::EscapeUriString($SourceUrl.Replace('%', '~')).Replace('~', '%') # Substitute and replace '%' to avoid escaping os Azure SAS tokens
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Testing file at $SourceUrl"
        #=================================================
        #	Test for WebClient Proxy
        #=================================================
        $UseWebClient = $false
        if ($WebClient -eq $true) {
            $UseWebClient = $true
        }
        elseif (([System.Net.WebRequest]::DefaultWebProxy).Address) {
            $UseWebClient = $true
        }
        elseif (!(Test-CommandCurlExe)) {
            $UseWebClient = $true
        }

        if ($UseWebClient -eq $true) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls1
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile($SourceUrl, $DestinationFullName)
            $WebClient.Dispose()
        }
        else {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] cURL Source: $SourceUrl"
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Destination: $DestinationFullName"

            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Requesing HTTP HEAD to get Content-Length and Accept-Ranges header"
            $remote = Invoke-WebRequest -UseBasicParsing -Method Head -Uri $SourceUrl
            $remoteLength = [Int64]($remote.Headers.'Content-Length' | Select-Object -First 1)
            $remoteAcceptsRanges = ($remote.Headers.'Accept-Ranges' | Select-Object -First 1) -eq 'bytes'

            $curlCommandExpression = "& curl.exe --insecure --location --output `"$DestinationFullName`" --url `"$SourceUrl`""

            if ($host.name -match 'PowerShell ISE Host') {
                #PowerShell ISE will display a NativeCommandError, so progress will not be displayed
                $Quiet = Invoke-Expression ($curlCommandExpression + ' 2>&1')
            }
            else {
                Invoke-Expression $curlCommandExpression
            }

            #=================================================
            #	Continue interrupted download
            #=================================================
            if (Test-Path $DestinationFullName) {
                $localExists = $true
            }

            $RetryDelaySeconds = 1
            $MaxRetryCount = 10
            $RetryCount = 0
            while (
                $localExists `
                    -and ((Get-Item $DestinationFullName).Length -lt $remoteLength) `
                    -and $remoteAcceptsRanges `
                    -and ($RetryCount -lt $MaxRetryCount)
            ) {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Download is incomplete, remote server accepts ranges, will retry in $RetryDelaySeconds second(s)"
                Start-Sleep -Seconds $RetryDelaySeconds
                $RetryDelaySeconds *= 2 # retry with exponential backoff
                $RetryCount += 1
                $curlCommandExpression = "& curl.exe --insecure --location --continue-at - --output `"$DestinationFullName`" --url `"$SourceUrl`""

                if ($host.name -match 'PowerShell ISE Host') {
                    #PowerShell ISE will display a NativeCommandError, so progress will not be displayed
                    $Quiet = Invoke-Expression ($curlCommandExpression + ' 2>&1')
                }
                else {
                    Invoke-Expression $curlCommandExpression
                }
            }

            if ($localExists -and ((Get-Item $DestinationFullName).Length -lt $remoteLength)) {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Download is incomplete after $RetryCount retries."
                Write-Warning "Could not download $DestinationFullName"
                $null
            }
        }
        #=================================================
        #	Return
        #=================================================
        if (Test-Path $DestinationFullName) {
            Get-Item $DestinationFullName -Force
        }
        else {
            Write-Warning "Could not download $DestinationFullName"
            $null
        }
        #=================================================
    }
}
