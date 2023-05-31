function Start-PwshHub {
    [CmdletBinding()]
    param (
        [Alias('OAuthToken')]
        [string]$OAuth
    )
    # Set Params
    $Params = @{
        RepoOwner       = 'OSDeploy'
        RepoName        = 'PwshHub'
    }

    if ($OAuth) {
        $Params.add("OAuth", $OAuth)
    }

    Start-OSDPadCategories @Params
}