<#
.SYNOPSIS
Executes a PowerShell script from a URL.

.DESCRIPTION
Downloads and executes a PowerShell script from a URL.

.PARAMETER Uri
The URL of the PowerShell script to execute. Redirects are not allowed.

.EXAMPLE
Invoke-WebPSScript -Uri 'https://example.com/script.ps1'

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Improved help and readability without changing behavior
#>
function Invoke-WebPSScript
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('WebPSScript')]
        [System.Uri]
        # The URL of the PowerShell Script to execute.  Redirects are not allowed
        $Uri
    )

    $Uri = $Uri -replace '%20', ' '
    Write-Verbose $Uri -Verbose

    if (-not (Test-WebConnection $Uri))
    {
        return
    }

    #[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls1
    $webClient = New-Object System.Net.WebClient
    $webPSCommand = $webClient.DownloadString("$Uri")
    Invoke-Expression -Command $webPSCommand
    $webClient.Dispose()
}
