function Get-MsUpCat {
    <#
        .SYNOPSIS
        Query catalog.update.micrsosoft.com for available updates.

        .DESCRIPTION
        Given that there is currently no public API available for the catalog.update.micrsosoft.com site, this
        command makes HTTP requests to the site and parses the returned HTML for the required data.

        .PARAMETER Search
        Specify a string to search for.

        .PARAMETER SortBy
        Specify a field to sort the results by. The default sort is by LastUpdated and in descending order.

        .PARAMETER Descending
        Switch the sort order to descending.

        .PARAMETER Strict
        Force a Search paramater with multiple words to be treated as a single string.

        .PARAMETER IncludeFileNames
        Include the filenames for the files as they would be downloaded from catalog.update.micrsosoft.com.
        This option will cause an extra web request for each update included in the results. It is best to only
        use this option with a very narrow search term.

        .PARAMETER AllPages
        By default the Get-MSCatalogUpdate command returns the first page of results from catalog.update.micrsosoft.com, which is
        limited to 25 updates. If you specify this switch the command will instead return all pages of search results.
        This can result in a significant increase in the number of HTTP requests to the catalog.update.micrsosoft.com endpoint.

        .EXAMPLE
        Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903"

        .EXAMPLE
        Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903" -SortBy "Title" -Descending

        .EXAMPLE
        Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903" -Strict

        .EXAMPLE
        Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903" -IncludeFileNames

        .EXAMPLE
        Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903" -AllPages
    #>
    
    [CmdLetBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Search,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Title", "Products", "Classification", "LastUpdated", "Size")]
        [string] $SortBy,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Descending,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Strict,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $IncludeFileNames,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $AllPages
    )

    try {
        $ProgPref = $ProgressPreference
        $ProgressPreference = "SilentlyContinue"

        $Uri = "https://www.catalog.update.microsoft.com/Search.aspx?q=$Search"
        $Res = Invoke-CatalogRequest -Uri $Uri

        if ($PSBoundParameters.ContainsKey("SortBy")) {
            $SortParams = @{
                Uri = $Uri
                SortBy = $SortBy
                Descending = $Descending
                EventArgument = $Res.EventArgument
                EventValidation = $Res.EventValidation
                ViewState = $Res.ViewState
                ViewStateGenerator = $Res.ViewStateGenerator
            }
            $Res = Sort-CatalogResults @SortParams
        } else {
            # Default sort is by LastUpdated and in descending order.
            $SortParams = @{
                Uri = $Uri
                SortBy = "LastUpdated"
                Descending = $true
                EventArgument = $Res.EventArgument
                EventValidation = $Res.EventValidation
                ViewState = $Res.ViewState
                ViewStateGenerator = $Res.ViewStateGenerator
            }
            $Res = Sort-CatalogResults @SortParams
        }

        $Rows = $Res.Rows

        if ($Strict -and -not $AllPages) {
            $StrictRows = $Rows.Where({
                $_.SelectNodes("td")[1].innerText.Trim() -like "*$Search*"
            })
            # If $NextPage is $null then there are more pages to collect. It is arse backwards but trust me.
            while (($StrictRows.Count -lt 25) -and ($Res.NextPage -eq "")) {
                $NextParams = @{
                    Uri = $Uri
                    EventArgument = $Res.EventArgument
                    EventTarget = 'ctl00$catalogBody$nextPageLinkText'
                    EventValidation = $Res.EventValidation
                    ViewState = $Res.ViewState
                    ViewStateGenerator = $Res.ViewStateGenerator
                    Method = "Post"
                }
                $Res = Invoke-CatalogRequest @NextParams
                $StrictRows += $Res.Rows.Where({
                    $_.SelectNodes("td")[1].innerText.Trim() -like "*$Search*"
                })
            }
            $Rows = $StrictRows[0..24]
        } elseif ($AllPages) {
            # If $NextPage is $null then there are more pages to collect. It is arse backwards but trust me.
            while ($Res.NextPage -eq "") {
                $NextParams = @{
                    Uri = $Uri
                    EventArgument = $Res.EventArgument
                    EventTarget = 'ctl00$catalogBody$nextPageLinkText'
                    EventValidation = $Res.EventValidation
                    ViewState = $Res.ViewState
                    ViewStateGenerator = $Res.ViewStateGenerator
                    Method = "Post"
                }
                $Res = Invoke-CatalogRequest @NextParams
                $Rows += $Res.Rows
            }
            if ($Strict) {
                $Rows = $Rows.Where({
                    $_.SelectNodes("td")[1].innerText.Trim() -like "*$Search*"
                })
            }
        }
        
        if ($Rows.Count -gt 0) {
            foreach ($Row in $Rows) {
                if ($Row.Id -ne "headerRow") {
                    [MsUpCat]::new($Row, $IncludeFileNames)
                }
            }
        } else {
            Write-Warning "No updates found matching the search term."
        }
        $ProgressPreference = $ProgPref
    } catch {
        $ProgressPreference = $ProgPref
        if ($_.Exception.Message -like "We did not find*") {
            #Write-Warning $_.Exception.Message
        } else {
            throw $_
        }
    }
}
