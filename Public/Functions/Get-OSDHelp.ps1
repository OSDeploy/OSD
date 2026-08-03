function Get-OSDHelp {
<#
.SYNOPSIS
Gets OSDHelp information.

.DESCRIPTION
Returns OSDHelp data for the current system or OSD session context.

.PARAMETER RepoFolder
Specifies the RepoFolder to use when running Get-OSDHelp.

.PARAMETER OAuth
Specifies the OAuth to use when running Get-OSDHelp.

.EXAMPLE
Get-OSDHelp -RepoFolder <value>
Demonstrates a common way to run Get-OSDHelp.

.LINK
https://github.com/OSDeploy/OSD/tree/master/docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$RepoFolder,

        [Alias('OAuthToken')]
        [string]$OAuth
    )

    $RepoOwner = 'OSDeploy'
    $RepoName = 'OSDHelp'

    if ($OAuth) {
        $OSDPadParams = @{
            Brand           = "OSDHelp $RepoFolder"
            RepoOwner       = $RepoOwner
            RepoName        = $RepoName
            RepoFolder      = $RepoFolder
            OAuth           = $OAuth
        }
    }
    else {
        $OSDPadParams = @{
            Brand           = "OSDHelp $RepoFolder"
            RepoOwner       = $RepoOwner
            RepoName        = $RepoName
            RepoFolder      = $RepoFolder
        }
    }
    Get-OSDPad @OSDPadParams
}
