function Test-OSDCoreOperatingSystemObjectUrl {
    <#
    .SYNOPSIS
    Tests whether an OSDCore operating system object URL is reachable.

    .DESCRIPTION
    Reads the Url property from the supplied operating system object, or from
    $global:OSDCoreOperatingSystemObject when no object is supplied, and returns
    $true when an HTTP HEAD request can reach it. Returns $false when the object
    is missing, the Url property is empty, or the URL test fails. HTTP and HTTPS
    are both tested for host-only web URLs so systems with an invalid date can still
    detect basic network reachability over HTTP. Specific absolute file URLs are
    tested exactly as supplied.

    .PARAMETER OperatingSystemObject
    Operating system object containing a Url property to test.

    .EXAMPLE
    Test-OSDCoreOperatingSystemObjectUrl
    Tests the Url property on $global:OSDCoreOperatingSystemObject.

    .EXAMPLE
    Test-OSDCoreOperatingSystemObjectUrl -OperatingSystemObject $global:OSDCoreOperatingSystemObject
    Tests the Url property on the supplied operating system object.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-19 - Initial private helper created
    2026-07-19 - Removed Test-WebConnection dependency
    2026-07-19 - Preserved supplied scheme for specific file URLs
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(ValueFromPipeline)]
        [psobject]
        $OperatingSystemObject = $global:OSDCoreOperatingSystemObject
    )

    process {
        # The caller may pass an object explicitly or rely on the global OSDCore selection.
        if ($null -eq $OperatingSystemObject) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject is not set."
            return $false
        }

        # A missing URL means there is nothing useful to test, so return the Boolean failure state.
        $OperatingSystemObjectUrl = [string]$OperatingSystemObject.Url
        if ([string]::IsNullOrWhiteSpace($OperatingSystemObjectUrl)) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject Url is not set."
            return $false
        }

        try {
            # Build the exact set of URLs to probe before making any web requests.
            $OperatingSystemObjectUri = [System.Uri]$OperatingSystemObjectUrl
            $IsSpecificAbsoluteUrl = $OperatingSystemObjectUri.IsAbsoluteUri -and -not [string]::IsNullOrWhiteSpace($OperatingSystemObjectUri.AbsolutePath) -and $OperatingSystemObjectUri.AbsolutePath -ne '/'
            if ($OperatingSystemObjectUri.IsAbsoluteUri -and ($OperatingSystemObjectUri.Scheme -notin @('http','https') -or $IsSpecificAbsoluteUrl)) {
                # Non-web absolute URIs and specific file URLs are tested as provided.
                $RequestUris = @($OperatingSystemObjectUri)
            }
            else {
                if ($OperatingSystemObjectUri.IsAbsoluteUri) {
                    # Host-only web URLs are checked over HTTPS first, then HTTP as a fallback for bad system time.
                    $UriBuilder = New-Object System.UriBuilder $OperatingSystemObjectUri
                    $UriBuilder.Scheme = 'https'
                    $UriBuilder.Port = -1
                    $HttpsUri = $UriBuilder.Uri

                    $UriBuilder.Scheme = 'http'
                    $UriBuilder.Port = -1
                    $HttpUri = $UriBuilder.Uri
                }
                else {
                    # Bare URLs are expanded to both HTTPS and HTTP targets.
                    $HttpsUri = [System.Uri]::new("https://$($OperatingSystemObjectUri.OriginalString)")
                    $HttpUri = [System.Uri]::new("http://$($OperatingSystemObjectUri.OriginalString)")
                }

                $RequestUris = @($HttpsUri, $HttpUri)
            }
        }
        catch {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject Url is not valid: $OperatingSystemObjectUrl"
            return $false
        }

        $InvokeWebRequestCommand = Get-Command Invoke-WebRequest
        $Results = foreach ($RequestUri in $RequestUris) {
            # Use HEAD to validate reachability without downloading the operating system payload.
            $Params = @{
                Method      = 'Head'
                Uri         = $RequestUri
                Headers     = @{'Cache-Control'='no-cache'}
                ErrorAction = 'Stop'
            }

            # Keep the request compatible across Windows PowerShell and newer PowerShell versions.
            if ($InvokeWebRequestCommand.Parameters.ContainsKey('UseBasicParsing')) {
                $Params['UseBasicParsing'] = $true
            }
            if ($InvokeWebRequestCommand.Parameters.ContainsKey('TimeoutSec')) {
                $Params['TimeoutSec'] = 15
            }

            try {
                Invoke-WebRequest @Params | Out-Null
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject URL OK: $RequestUri"
                [pscustomobject]@{
                    Uri     = $RequestUri
                    Success = $true
                }
            }
            catch {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDCoreOperatingSystemObject URL FAIL: $RequestUri"
                [pscustomobject]@{
                    Uri     = $RequestUri
                    Success = $false
                }
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
