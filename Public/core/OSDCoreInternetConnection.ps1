function Test-OSDCoreInternetConnection
{
    <#
    .SYNOPSIS
    Tests connectivity to a URI using an HTTP HEAD request.

    .DESCRIPTION
    Sends an HTTP HEAD request to the specified URI by using Invoke-WebRequest and returns $true when
    the request succeeds. Returns $false if the request fails.

    .PARAMETER Uri
    The URI to test for internet connectivity. Defaults to google.com.

    .EXAMPLE
    Test-OSDCoreInternetConnection
    Tests connectivity to the default URI and returns $true or $false.

    .EXAMPLE
    Test-OSDCoreInternetConnection -Uri 'https://www.microsoft.com'
    Tests connectivity to a specific URI and returns $true or $false.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-12 - Updated comment-based help to OSD canonical format.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline)]
        # Uri to test
        [System.Uri]
        $Uri = 'google.com'
    )
    $Params = @{
        Method = 'Head'
        Uri = $Uri
        UseBasicParsing = $true
        Headers = @{'Cache-Control'='no-cache'}
    }

    try {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Test-OSDCoreInternetConnection OK: $Uri"
        Invoke-WebRequest @Params | Out-Null
        $true
    }
    catch {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Test-OSDCoreInternetConnection FAIL: $Uri"
        $false
    }
    finally {
        $Error.Clear()
    }
}
