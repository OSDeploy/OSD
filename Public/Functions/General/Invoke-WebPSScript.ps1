<#
.SYNOPSIS
Allows you to execute a PowerShell Script as a URL Link
.DESCRIPTION
Allows you to execute a PowerShell Script as a URL Link
.LINK
https://osd.osdeploy.com/module/functions/webpsscript
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

    $Uri = $Uri -replace '%20',' '
    Write-Verbose $Uri -Verbose
    
    if (-NOT (Test-WebConnection $Uri))
    {
        Return
    }
    #[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls1
    $WebClient = New-Object System.Net.WebClient
    $WebPSCommand = $WebClient.DownloadString("$Uri")
    Invoke-Expression -Command $WebPSCommand
    $WebClient.Dispose()
}