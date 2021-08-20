function Get-LenovoDriverPack {
    [CmdletBinding()]
    param (
        [string]$DownloadPath
    )
    #=================================================
    #   Get-CatalogLenovoDriverPack
    #=================================================
    $Results = Get-CatalogLenovoDriverPack | Sort-Object Product
    #=================================================
    #   Download
    #=================================================
    if ($DownloadPath) {
        $Results = $Results | Out-GridView -Title 'Select one or more DriverPacks to Download' -PassThru -ErrorAction Stop
        foreach ($Item in $Results) {
            Save-MyDriverPack -Manufacturer Lenovo -Product $Item.Product[0] -DownloadPath $DownloadPath
        }
    }
    #=================================================
    #   Results
    #=================================================
    $Results | Select-Object CatalogVersion,Product,Name,DriverPackUrl,FileName
    #=================================================
}