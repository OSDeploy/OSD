function Test-OSDCoreDriverPackObjectUrl {
    <#
    .SYNOPSIS
    Tests whether an OSDCore driver pack object URL is reachable.

    .DESCRIPTION
    Reads the Url property from the supplied driver pack object, or from
    $global:OSDCoreDriverPackObject when no object is supplied, and returns
    $true when a live TCP connection and HTTP HEAD request can reach it. Returns $false when the object
    is missing, the Url property is empty, or the URL test fails. HTTP and HTTPS
    are both tested for host-only web URLs so systems with an invalid date can still
    detect basic network reachability over HTTP. Specific absolute file URLs are
    tested exactly as supplied.

    .PARAMETER DriverPackObject
    Driver pack object containing a Url property to test.

    .EXAMPLE
    Test-OSDCoreDriverPackObjectUrl
    Tests the Url property on $global:OSDCoreDriverPackObject.

    .EXAMPLE
    Test-OSDCoreDriverPackObjectUrl -DriverPackObject $global:OSDCoreDriverPackObject
    Tests the Url property on the supplied driver pack object.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-19 - Initial private helper created
    2026-07-20 - Added live TCP validation before HTTP HEAD to avoid cached success responses
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(ValueFromPipeline)]
        [psobject]
        $DriverPackObject = $global:OSDCoreDriverPackObject
    )

    process {
        # The caller may pass an object explicitly or rely on the global OSDCore driver pack selection.
        if ($null -eq $DriverPackObject) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreDriverPackObject is not set."
            return $false
        }

        # A missing URL means there is nothing useful to test, so return the Boolean failure state.
        $DriverPackObjectUrl = [string]$DriverPackObject.Url
        if ([string]::IsNullOrWhiteSpace($DriverPackObjectUrl)) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreDriverPackObject Url is not set."
            return $false
        }

        try {
            # Build the exact set of URLs to probe before making any web requests.
            $DriverPackObjectUri = [System.Uri]$DriverPackObjectUrl
            $IsSpecificAbsoluteUrl = $DriverPackObjectUri.IsAbsoluteUri -and -not [string]::IsNullOrWhiteSpace($DriverPackObjectUri.AbsolutePath) -and $DriverPackObjectUri.AbsolutePath -ne '/'
            if ($DriverPackObjectUri.IsAbsoluteUri -and ($DriverPackObjectUri.Scheme -notin @('http','https') -or $IsSpecificAbsoluteUrl)) {
                # Non-web absolute URIs and specific file URLs are tested as provided.
                $RequestUris = @($DriverPackObjectUri)
            }
            else {
                if ($DriverPackObjectUri.IsAbsoluteUri) {
                    # Host-only web URLs are checked over HTTPS first, then HTTP as a fallback for bad system time.
                    $UriBuilder = New-Object System.UriBuilder $DriverPackObjectUri
                    $UriBuilder.Scheme = 'https'
                    $UriBuilder.Port = -1
                    $HttpsUri = $UriBuilder.Uri

                    $UriBuilder.Scheme = 'http'
                    $UriBuilder.Port = -1
                    $HttpUri = $UriBuilder.Uri
                }
                else {
                    # Bare URLs are expanded to both HTTPS and HTTP targets.
                    $HttpsUri = [System.Uri]::new("https://$($DriverPackObjectUri.OriginalString)")
                    $HttpUri = [System.Uri]::new("http://$($DriverPackObjectUri.OriginalString)")
                }

                $RequestUris = @($HttpsUri, $HttpUri)
            }
        }
        catch {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreDriverPackObject Url is not valid: $DriverPackObjectUrl"
            return $false
        }

        $InvokeWebRequestCommand = Get-Command Invoke-WebRequest
        $Results = foreach ($RequestUri in $RequestUris) {
            if ($RequestUri.Scheme -in @('http','https')) {
                $RequestPort = $RequestUri.Port
                if ($RequestUri.IsDefaultPort) {
                    if ($RequestUri.Scheme -eq 'https') {
                        $RequestPort = 443
                    }
                    else {
                        $RequestPort = 80
                    }
                }

                $TcpClient = New-Object System.Net.Sockets.TcpClient
                try {
                    $ConnectTask = $TcpClient.ConnectAsync($RequestUri.DnsSafeHost, $RequestPort)
                    if (-not $ConnectTask.Wait(15000) -or -not $TcpClient.Connected) {
                        throw "TCP connection failed."
                    }
                }
                catch {
                    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreDriverPackObject TCP FAIL: $RequestUri"
                    [pscustomobject]@{
                        Uri     = $RequestUri
                        Success = $false
                    }
                    continue
                }
                finally {
                    $TcpClient.Close()
                }
            }

            # Use HEAD to validate reachability without downloading the driver pack payload.
            $Params = @{
                Method      = 'Head'
                Uri         = $RequestUri
                Headers     = @{'Cache-Control'='no-cache, no-store'; 'Pragma'='no-cache'}
                ErrorAction = 'Stop'
            }

            # Keep the request compatible across Windows PowerShell and newer PowerShell versions.
            if ($InvokeWebRequestCommand.Parameters.ContainsKey('UseBasicParsing')) {
                $Params['UseBasicParsing'] = $true
            }
            if ($InvokeWebRequestCommand.Parameters.ContainsKey('TimeoutSec')) {
                $Params['TimeoutSec'] = 15
            }
            if ($InvokeWebRequestCommand.Parameters.ContainsKey('DisableKeepAlive')) {
                $Params['DisableKeepAlive'] = $true
            }

            $PreviousCachePolicy = [System.Net.WebRequest]::DefaultCachePolicy
            try {
                [System.Net.WebRequest]::DefaultCachePolicy = New-Object System.Net.Cache.RequestCachePolicy ([System.Net.Cache.RequestCacheLevel]::NoCacheNoStore)
                Invoke-WebRequest @Params | Out-Null
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreDriverPackObject URL OK: $RequestUri"
                [pscustomobject]@{
                    Uri     = $RequestUri
                    Success = $true
                }
            }
            catch {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreDriverPackObject URL FAIL: $RequestUri"
                [pscustomobject]@{
                    Uri     = $RequestUri
                    Success = $false
                }
            }
            finally {
                [System.Net.WebRequest]::DefaultCachePolicy = $PreviousCachePolicy
            }
        }

        # If only HTTP succeeds, the network may be reachable but HTTPS can fail because the clock is wrong.
        $HttpsResult = $Results | Where-Object {$_.Uri.Scheme -eq 'https'} | Select-Object -First 1
        $HttpResult = $Results | Where-Object {$_.Uri.Scheme -eq 'http'} | Select-Object -First 1

        if ($HttpsResult -and $HttpResult -and -not $HttpsResult.Success -and $HttpResult.Success) {
            Write-Warning "HTTPS connection failed for $($HttpsResult.Uri), but HTTP connection succeeded for $($HttpResult.Uri). Check the system date and time."
        }

        # Return true when any attempted URL succeeds.
        [bool]($Results | Where-Object {$_.Success} | Select-Object -First 1)
    }
}
