function Sort-CatalogResults {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Uri,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Title", "Products", "Classification", "LastUpdated", "Size")]
        [string] $SortBy,

        [Parameter(Mandatory = $false)]
        [switch] $Descending,

        [Parameter(DontShow)]
        [string] $EventArgument,

        [Parameter(DontShow)]
        [string] $EventValidation,

        [Parameter(DontShow)]
        [string] $ViewState,

        [Parameter(DontShow)]
        [string] $ViewStateGenerator
    )

    $EventTarget = switch ($SortBy) {
        {$_ -eq "Title"} {'ctl00$catalogBody$updateMatches$ctl02$titleHeaderLink'}
        {$_ -eq "Products"} {'ctl00$catalogBody$updateMatches$ctl02$productsHeaderLink'}
        {$_ -eq "Classification"} {'ctl00$catalogBody$updateMatches$ctl02$classHeaderLink'}
        {$_ -eq "LastUpdated"} {'ctl00$catalogBody$updateMatches$ctl02$dateHeaderLink'}
        {$_ -eq "Size"} {'ctl00$catalogBody$updateMatches$ctl02$sizeHeaderLink'}
    }

    $Params = @{
        Uri = $Uri
        Method = "Post"
        EventArgument = $EventArgument
        EventTarget = $EventTarget
        EventValidation = $EventValidation
        ViewState = $ViewState
        ViewStateGenerator = $ViewStateGenerator
    }
    $Res = Invoke-CatalogRequest @Params

    # By default the LastUpdated field is sorted in descending order from the catalog website the first time you
    # issue the sort POST request. All the other fields are sorted in ascending order first as you would expect.
    # To ensure that this sort function is predictable we re-request the sorted request if the SortBy parameter is LastUpdated
    # and the Descending parameter is $false in order to return the results sorted in ascending order which is what would
    # be expected.
    if (($SortBy -eq "LastUpdated") -and -not $Descending) {
        $Params = @{
            Uri = $Uri
            Method = "Post"
            EventArgument = $Res.EventArgument
            EventTarget = $EventTarget
            EventValidation = $Res.EventValidation
            ViewState = $Res.ViewState
            ViewStateGenerator = $Res.ViewStateGenerator
        }
        $Res = Invoke-CatalogRequest @Params
    } elseif (($SortBy -ne "LastUpdated") -and $Descending) {
        $Params = @{
            Uri = $Uri
            Method = "Post"
            EventArgument = $Res.EventArgument
            EventTarget = $EventTarget
            EventValidation = $Res.EventValidation
            ViewState = $Res.ViewState
            ViewStateGenerator = $Res.ViewStateGenerator
        }
        $Res = Invoke-CatalogRequest @Params
    }

    $Res
}