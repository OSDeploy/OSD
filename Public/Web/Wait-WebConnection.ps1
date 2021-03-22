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