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
    
    end {}
}
function Wait-WebConnection {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $True)]
        [string]$Uri = 'powershellgallery.com'
    )


    if ((Test-WebConnection -Uri 'powershellgallery.com') -eq $true) {
        Write-Verbose "Wait-WebConnection to $Uri"
    }
    else {
        do {
            Write-Verbose "Wait-WebConnection to $Uri"
            
            Write-Verbose "Waiting 10 seconds to try again ..."
            Start-Sleep -Seconds 10
    
        } until ((Test-WebConnection -Uri 'powershellgallery.com') -eq $true)
    }
    $Error.Clear()
}