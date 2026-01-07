function Invoke-CatalogRequest {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Uri,

        [Parameter(Mandatory = $false)]
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
            UseBasicParsing = $true
            ErrorAction     = "Stop"
            Headers         = $Headers
        }

        $Results = Invoke-WebRequest @Params
        $HtmlDoc = [HtmlAgilityPack.HtmlDocument]::new()
        $HtmlDoc.LoadHtml($Results.RawContent.ToString())
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
        }
    }
    catch {
        Write-Warning "$_"
    }
    finally {
        #Set-TempSecurityProtocol -ResetToDefault
    }
}