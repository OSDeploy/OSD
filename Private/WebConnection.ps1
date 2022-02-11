function Test-WebConnectionMsUpCat {
    [CmdletBinding()]
    param ()

    if (Test-WebConnection -Uri 'https://www.catalog.update.microsoft.com/Home.aspx') {
        Return $true
    } else {
        Return $false
    }
}