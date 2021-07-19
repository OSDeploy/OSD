class MsUpCatResponse {
    [HtmlAgilityPack.HtmlNodeCollection] $Rows
    [string] $EventArgument
    [string] $EventValidation
    [string] $ViewState
    [string] $ViewStateGenerator
    [string] $NextPage

    MsUpCatResponse($HtmlDoc) {
        $Table = $HtmlDoc.GetElementbyId("ctl00_catalogBody_updateMatches")
        $this.Rows = $Table.SelectNodes("tr")
        $this.EventArgument = $HtmlDoc.GetElementbyId("__EVENTARGUMENT")[0].Attributes["value"].Value
        $this.EventValidation = $HtmlDoc.GetElementbyId("__EVENTVALIDATION")[0].Attributes["value"].Value
        $this.ViewState = $HtmlDoc.GetElementbyId("__VIEWSTATE")[0].Attributes["value"].Value
        $this.ViewStateGenerator = $HtmlDoc.GetElementbyId("__VIEWSTATEGENERATOR")[0].Attributes["value"].Value
        $this.NextPage = $HtmlDoc.GetElementbyId("ctl00_catalogBody_nextPage")
    }
}