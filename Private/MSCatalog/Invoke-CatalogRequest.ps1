function Invoke-CatalogRequest {
    <#
    .SYNOPSIS
    Sends a request to the Microsoft Update Catalog and parses the HTML response.

    .DESCRIPTION
    Performs an HTTP request to catalog.microsoft.com, loads the returned HTML into
    HtmlAgilityPack, and returns a MsUpCatResponse object when results are found.
    If the catalog returns a known error page or no results, the function emits a
    warning or throws an error as appropriate.

    .PARAMETER Uri
    The request URI for the catalog query.

    .PARAMETER Method
    The HTTP method used for the request. Defaults to Get.

    .EXAMPLE
    Invoke-CatalogRequest -Uri 'https://www.catalog.update.microsoft.com/Search.aspx?q=KB5030211'
    Queries the Microsoft Update Catalog and returns a parsed MsUpCatResponse object.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help and improved request handling.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Uri,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Get', 'Post', 'Put', 'Delete', 'Head', 'Patch', 'Options')]
        [string] $Method = "Get"
    )

    try {
        #Set-TempSecurityProtocol

        $Headers = @{
            "Cache-Control" = "no-cache"
            "Pragma"        = "no-cache"
        }

        $Params = @{
            Uri             = $Uri
            Method          = $Method
            ErrorAction     = "Stop"
            Headers         = $Headers
        }

        # UseBasicParsing is only valid in Windows PowerShell 5.1.
        if ($PSVersionTable.PSVersion.Major -lt 6) {
            $Params.UseBasicParsing = $true
        }

        $Results = Invoke-WebRequest @Params
        $HtmlDoc = [HtmlAgilityPack.HtmlDocument]::new()
        $HtmlDoc.LoadHtml($Results.Content)
        $NoResults = $HtmlDoc.GetElementbyId("ctl00_catalogBody_noResultText")
        $ErrorText = $HtmlDoc.GetElementbyId("errorPageDisplayedError")

        if ($null -eq $NoResults -and $null -eq $ErrorText) {
            return [MsUpCatResponse]::new($HtmlDoc)
        }
        elseif ($ErrorText) {
            if ($ErrorText.InnerText -match '8DDD0010') {
                throw "The catalog.microsoft.com site has encountered an error with code 8DDD0010. Please try again later."
            }
            else {
                throw "The catalog.microsoft.com site has encountered an error: $($ErrorText.InnerText)"
            }
        }
        else {
            Write-Warning "We did not find any results for $Uri"
            return $null
        }
    }
    catch {
        Write-Warning "$_"
    }
    finally {
        #Set-TempSecurityProtocol -ResetToDefault
    }
}
