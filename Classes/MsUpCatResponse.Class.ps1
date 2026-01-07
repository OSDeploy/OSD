class MsUpCatResponse {
    [HtmlAgilityPack.HtmlNode[]] $Rows
    [string] $EventArgument
    [string] $EventValidation
    [string] $ViewState
    [string] $ViewStateGenerator
    [string] $NextPage

    MsUpCatResponse($HtmlDoc) {
        $Table = $HtmlDoc.GetElementbyId("ctl00_catalogBody_updateMatches")
        $this.Rows = $Table.SelectNodes("tr") | Where-Object { $_.Id -ne "headerRow" }
        $this.EventArgument = $HtmlDoc.GetElementbyId("__EVENTARGUMENT").Attributes["value"].Value
        $this.EventValidation = $HtmlDoc.GetElementbyId("__EVENTVALIDATION").Attributes["value"].Value
        $this.ViewState = $HtmlDoc.GetElementbyId("__VIEWSTATE").Attributes["value"].Value
        $this.ViewStateGenerator = $HtmlDoc.GetElementbyId("__VIEWSTATEGENERATOR").Attributes["value"].Value
        $NextPageNode = $HtmlDoc.GetElementbyId("ctl00_catalogBody_nextPageLink")
        $this.NextPage = if ($null -ne $NextPageNode) { $NextPageNode.InnerText.Trim() } else { $null }
    }
}