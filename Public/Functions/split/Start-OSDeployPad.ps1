function Start-OSDeployPad {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$RepoFolder,

        [Alias('OAuthToken')]
        [string]$OAuth
    )

    if ($OAuth) {
        $OSDPadParams = @{
            Brand           = "OSDeploy OSDPad $RepoFolder"
            RepoOwner       = 'OSDeploy'
            RepoName        = 'OSDPad'
            RepoFolder      = $RepoFolder
            OAuth           = $OAuth
        }
    }
    else {
        $OSDPadParams = @{
            Brand           = "OSDeploy OSDPad $RepoFolder"
            RepoOwner       = 'OSDeploy'
            RepoName        = 'OSDPad'
            RepoFolder      = $RepoFolder
        }
    }
    Start-OSDPad @OSDPadParams
}