function Get-DriverCatalogLenovoXml {
    [CmdletBinding()]
    param ()

    $CatalogUrl = 'https://download.lenovo.com/cdrt/td/catalog.xml'
    

    if (Test-WebConnection $CatalogUrl) {
        $XmlContent = Invoke-WebRequest $CatalogUrl -UseBasicParsing
    }
    $XmlContent.Content
}