<#
.SYNOPSIS
Allows you to execute a PowerShell Script as a URL Link

.DESCRIPTION
Allows you to execute a PowerShell Script as a URL Link

.PARAMETER WebPSScript
The URL of the PowerShell Script to execute.  Redirects are not allowed

.LINK
https://osd.osdeploy.com/module/functions/webpsscript

.NOTES
21.3.12 Renamed from Invoke-UrlExpression
21.3.8  Initial Release
#>
function Invoke-WebPSScript {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $True)]
        [string]$WebPSScript
    )

    if (-NOT (Test-WebConnection $WebPSScript)) {
        Return
    }

    #[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls1
    
    $WebClient = New-Object System.Net.WebClient
    $WebPSCommand = $WebClient.DownloadString("$WebPSScript")
    Invoke-Expression -Command $WebPSCommand
    $WebClient.Dispose()
}