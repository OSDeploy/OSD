<#
.SYNOPSIS
Tests to see if a Uri by Invoke-WebRequest -Method Head

.DESCRIPTION
Tests to see if a Uri by Invoke-WebRequest -Method Head

.PARAMETER Uri
Uri to test

.LINK
https://osd.osdeploy.com/module/functions/webconnection

.NOTES
21.3.12 Renamed from Invoke-UrlExpression

#>
function Test-WebConnection {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $True)]
        [string]$Uri = 'google.com'
    )
    
    begin {}
    
    process {
        $Params = @{
            Method = 'Head'
            Uri = $Uri
            UseBasicParsing = $True
        }

        try {
            Write-Verbose "Test-WebConnection OK: $Uri"
            Invoke-WebRequest @Params | Out-Null
            Return $true
        }
        catch {
            Write-Warning "Test-WebConnection FAIL: $Uri"
            Return $false
        }
        finally {
            $Error.Clear()
        }
    }
    
    end {}
}