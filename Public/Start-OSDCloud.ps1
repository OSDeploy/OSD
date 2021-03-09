<#
.SYNOPSIS
Launches a script in a GitHub Repo

.DESCRIPTION
Executes Invoke-UrlExpression with the following Url that is set by using Parameters
https://raw.githubusercontent.com/$GitHubUser/$Repository/main/$Script

.LINK
https://osd.osdeploy.com/module/functions/general/start-osdcloud

.NOTES
21.3.9  Initial Release
#>
function Start-OSDCloud {
    [CmdletBinding()]
    param (
        [string]$GitHubUser = 'OSDeploy',
        [string]$Repository = 'OSDCloud',
        [string]$Script = 'Start-OSDCloud.ps1'
    )

    Invoke-UrlExpression -Url "https://raw.githubusercontent.com/$GitHubUser/$Repository/main/$Script"
}