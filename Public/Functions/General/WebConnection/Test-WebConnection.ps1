<#
.SYNOPSIS
Tests to see if a Uri by Invoke-WebRequest -Method Head
.DESCRIPTION
Tests to see if a Uri by Invoke-WebRequest -Method Head
.LINK
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