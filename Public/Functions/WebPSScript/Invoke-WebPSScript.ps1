<#
.SYNOPSIS
Allows you to execute a PowerShell Script as a URL Link
.DESCRIPTION
Allows you to execute a PowerShell Script as a URL Link
.PARAMETER Uri
The URL of the PowerShell Script to execute.  Redirects are not allowed
.PARAMETER Headers
Additional headers to be sent in the request, for example authorization headers.
.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs
#>
function Invoke-WebPSScript
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('WebPSScript')]
        [System.Uri]
        $Uri,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Collections.IDictionary]
        $Headers
    )

    $Uri = $Uri -replace '%20',' '
    Write-Verbose $Uri -Verbose
    
    # Pass Headers through to Test-WebConnection to properly test the connection
    $Params = @{
        Uri = $Uri
    }

    if ($null -ne $Headers)
    {
        $Params.Add('Headers', $Headers)
    }

    if (-NOT (Test-WebConnection @Params))
    {
        Return
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls1

    # Disable progress bar while Invoke-WebRequest is running for a small performance gain
    $PreviousProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'

    $Params = @{
        Uri             = $Uri
        Method          = 'GET'
        ContentType     = "text/plain"
        UseBasicParsing = $true
    }

    if ($null -ne $Headers) {
        Write-Verbose -Message "Invoke-WebPSScript: Added Headers: $($Headers.Keys -join ', ')"
        $Params.Add('Headers', $Headers)
    }

    $WebPSCommand = (Invoke-WebRequest @Params).Content

    # Reset progress bar to whatever it was before
    $ProgressPreference = $PreviousProgressPreference

    Invoke-Expression -Command $WebPSCommand
}