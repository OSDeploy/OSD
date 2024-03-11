function Invoke-CatalogRequest {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [string] $Uri,

        [Parameter(Mandatory = $false)]
        [string] $Method = "Get",

        [Parameter(Mandatory = $false)]
        [string] $EventArgument,

        [Parameter(Mandatory = $false)]
        [string] $EventTarget,

        [Parameter(Mandatory = $false)]
        [string] $EventValidation,

        [Parameter(Mandatory = $false)]
        [string] $ViewState,

        [Parameter(Mandatory = $false)]
        [string] $ViewStateGenerator
    )

    try {
        if ($Method -eq "Post") {
            $ReqBody = @{
                "__EVENTARGUMENT" = $EventArgument
                "__EVENTTARGET" = $EventTarget
                "__EVENTVALIDATION" = $EventValidation
                "__VIEWSTATE" = $ViewState
                "__VIEWSTATEGENERATOR" = $ViewStateGenerator
            }
        }

        if ($Uri -match '%26') {
            $Params = @{
                Uri = $Uri
                Method = $Method
                Body = $ReqBody
                ContentType = "application/x-www-form-urlencoded"
                UseBasicParsing = $true
                ErrorAction = "Stop"
            }
        }
        else {
            $Params = @{
                Uri = [Uri]::EscapeUriString($Uri)
                Method = $Method
                Body = $ReqBody
                ContentType = "application/x-www-form-urlencoded"
                UseBasicParsing = $true
                ErrorAction = "Stop"
            }
        }
        $Results = Invoke-WebRequest @Params
        $HtmlDoc = [HtmlAgilityPack.HtmlDocument]::new()
        $HtmlDoc.LoadHtml($Results.RawContent.ToString())
        $NoResults = $HtmlDoc.GetElementbyId("ctl00_catalogBody_noResultText")
        if ($null -eq $NoResults) {
            $ErrorText = $HtmlDoc.GetElementbyId("errorPageDisplayedError")
            if ($ErrorText) {
                throw "The catalog.update.microsoft.com site has encountered an error. Please try again later."
            }
            else {
                $HtmlDoc | Out-File -FilePath "$env:TEMP\$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Microsoft Catalog.html" -Encoding "UTF8"
                [MsUpCatResponse]::new($HtmlDoc)
            }
        } 
        else {
            throw "$($NoResults.InnerText)$($Uri.Split("q=")[-1])"
        }
    }
    catch {
        throw $_
    }
}