<#
.Synopsis
Tests to see if a Uri by Invoke-WebRequest -Method Head
.Description
Tests to see if a Uri by Invoke-WebRequest -Method Head
.Link
https://osd.osdeploy.com/module/functions/webconnection
#>
function Test-WebConnection
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline)]
        # Uri to test
        [System.Uri]
        $Uri = 'google.com'
    )
    $Params = @{
        Method = 'Head'
        Uri = $Uri
        UseBasicParsing = $true
        Headers = @{'Cache-Control'='no-cache'}
    }

    try {
        Write-Verbose "Test-WebConnection OK: $Uri"
        Invoke-WebRequest @Params | Out-Null
        $true
    }
    catch {
        Write-Verbose "Test-WebConnection FAIL: $Uri"
        $false
    }
    finally {
        $Error.Clear()
    }
}
<#
.Synopsis
Waits for an internet connection to the specified Uri
.Description
Waits for an internet connection to the specified Uri
.Link
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