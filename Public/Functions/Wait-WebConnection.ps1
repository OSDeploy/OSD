<#
.SYNOPSIS
Waits for an internet connection to the specified Uri
.DESCRIPTION
Waits for an internet connection to the specified Uri
.LINK
https://osd.osdeploy.com/module/functions/webconnection
#>
function Wait-WebConnection
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline)]
        # Waits for a valid connection to a Uri
        [System.Uri]
        $Uri = 'powershellgallery.com'
    )
    if ((Test-WebConnection -Uri "$Uri") -eq $true)
    {
        Write-Verbose "Wait-WebConnection to $Uri"
    }
    else
    {
        Write-Verbose "Wait-WebConnection to $Uri"
        do
        {
            Write-Verbose "Waiting 10 seconds to try again ..."
            Start-Sleep -Seconds 10
        }
        until ((Test-WebConnection -Uri 'powershellgallery.com') -eq $true)
    }
    $Error.Clear()
}