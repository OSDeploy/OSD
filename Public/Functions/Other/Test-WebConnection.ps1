<#
.SYNOPSIS
Tests to see if a Uri by Invoke-WebRequest -Method Head
.DESCRIPTION
Tests to see if a Uri by Invoke-WebRequest -Method Head
.PARAMETER Uri
Uri to test
.PARAMETER Headers
Additional headers to pass through
.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs
#>
function Test-WebConnection
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline)]
        [System.Uri]
        $Uri = 'google.com',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Collections.IDictionary]
        $Headers
    )
    $Params = @{
        Method = 'Head'
        Uri = $Uri
        UseBasicParsing = $true
        Headers = @{'Cache-Control'='no-cache'}
    }

    if ($null -ne $Headers) {
        foreach ($Header in $Headers.GetEnumerator()) {
            $Params.Headers.Add($Header.Key,$Header.Value)
        }
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