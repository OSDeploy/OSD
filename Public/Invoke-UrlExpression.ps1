<#
.SYNOPSIS
Allows you to execute a PowerShell Script as a URL Link

.DESCRIPTION
Allows you to execute a PowerShell Script as a URL Link

.PARAMETER Url
The URL of the PowerShell Script to execute.  Redirects are not allowed

.LINK
https://osd.osdeploy.com/module/functions/general/invoke-urlexpression

.NOTES
21.3.8  Initial Release
#>
function Invoke-UrlExpression {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Url
    )
    $UrlExpression = $null
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $WebClient = New-Object System.Net.WebClient
    $UrlExpression = $WebClient.DownloadString("$Url")
    Invoke-Expression -Command $UrlExpression
}