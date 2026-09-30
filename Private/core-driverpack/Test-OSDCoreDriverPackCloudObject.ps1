function Test-OSDCoreDriverPackCloudObject {
    <#
    .SYNOPSIS
    Tests whether an OSDCore driver pack object URL is reachable.

    .DESCRIPTION
    Reads the Url property from the supplied driver pack object, or from
    $global:OSDCoreDriverPackCloudObject when no object is supplied, and returns
    $true when a live TCP connection and HTTP HEAD request can reach it. Returns $false when the object
    is missing, the Url property is empty, or the URL test fails. HTTP and HTTPS
    are both tested for host-only web URLs so systems with an invalid date can still
    detect basic network reachability over HTTP. Specific absolute file URLs are
    tested exactly as supplied.

    .PARAMETER DriverPackCloudObject
    Driver pack object containing a Url property to test.

    .EXAMPLE
    Test-OSDCoreDriverPackCloudObject
    Tests the Url property on $global:OSDCoreDriverPackCloudObject.

    .EXAMPLE
    Test-OSDCoreDriverPackCloudObject -DriverPackCloudObject $global:OSDCoreDriverPackCloudObject
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
        $DriverPackCloudObject = $global:OSDCoreDriverPackCloudObject
    )

    process {
        # The caller may pass an object explicitly or rely on the global OSDCore driver pack selection.
        if ($null -eq $DriverPackCloudObject) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreDriverPackCloudObject is not set."
            return $false
        }

        # A missing URL means there is nothing useful to test, so return the Boolean failure state.
        $DriverPackCloudObjectUrl = [string]$DriverPackCloudObject.Url
        if ([string]::IsNullOrWhiteSpace($DriverPackCloudObjectUrl)) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreDriverPackCloudObject Url is not set."
            return $false
        }

        try {
            # Build the exact set of URLs to probe before making any web requests.
            $DriverPackCloudObjectUri = [System.Uri]$DriverPackCloudObjectUrl
            $IsSpecificAbsoluteUrl = $DriverPackCloudObjectUri.IsAbsoluteUri -and -not [string]::IsNullOrWhiteSpace($DriverPackCloudObjectUri.AbsolutePath) -and $DriverPackCloudObjectUri.AbsolutePath -ne '/'
            if ($DriverPackCloudObjectUri.IsAbsoluteUri -and ($DriverPackCloudObjectUri.Scheme -notin @('http','https') -or $IsSpecificAbsoluteUrl)) {
                # Non-web absolute URIs and specific file URLs are tested as provided.
                $RequestUris = @($DriverPackCloudObjectUri)
            }
            else {
                if ($DriverPackCloudObjectUri.IsAbsoluteUri) {
                    # Host-only web URLs are checked over HTTPS first, then HTTP as a fallback for bad system time.
                    $UriBuilder = New-Object System.UriBuilder $DriverPackCloudObjectUri
                    $UriBuilder.Scheme = 'https'
                    $UriBuilder.Port = -1
                    $HttpsUri = $UriBuilder.Uri

                    $UriBuilder.Scheme = 'http'
                    $UriBuilder.Port = -1
                    $HttpUri = $UriBuilder.Uri
                }
                else {
                    # Bare URLs are expanded to both HTTPS and HTTP targets.
                    $HttpsUri = [System.Uri]::new("https://$($DriverPackCloudObjectUri.OriginalString)")
                    $HttpUri = [System.Uri]::new("http://$($DriverPackCloudObjectUri.OriginalString)")
                }

                $RequestUris = @($HttpsUri, $HttpUri)
            }
        }
        catch {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreDriverPackCloudObject Url is not valid: $DriverPackCloudObjectUrl"
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
                    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreDriverPackCloudObject TCP FAIL: $RequestUri"
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
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreDriverPackCloudObject URL OK: $RequestUri"
                [pscustomobject]@{
                    Uri     = $RequestUri
                    Success = $true
                }
            }
            catch {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreDriverPackCloudObject URL FAIL: $RequestUri"
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
