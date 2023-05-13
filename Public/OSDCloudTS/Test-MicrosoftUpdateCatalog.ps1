function Test-MicrosoftUpdateCatalog {
    [CmdletBinding()]
    param ()

    $StatusCode = (Invoke-WebRequest -uri 'https://www.catalog.update.microsoft.com' -Method Head -UseBasicParsing -ErrorAction Ignore).StatusCode

    if ($StatusCode -eq 200) {
        Return $true
    } else {
        Return $false
    }
}
