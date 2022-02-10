function Get-HpDriverPack {
    [CmdletBinding()]
    param (
        [string]$DownloadPath
    )
    #=================================================
    #   Get-CatalogHPDriverPack
    #=================================================
    $Results = Get-CatalogHPDriverPack | Sort-Object Product
    #=================================================
    #   Download
    #=================================================
    if ($DownloadPath) {
        $Results = $Results | Out-GridView -Title 'Select one or more DriverPacks to Download' -PassThru -ErrorAction Stop
        foreach ($Item in $Results) {
            Save-MyDriverPack -Manufacturer HP -Product $Item.Product[0] -DownloadPath $DownloadPath
        }
    }
    #=================================================
    #   Results
    #=================================================
    $Results | Select-Object CatalogVersion,ReleaseDate,Name,Product,DriverPackUrl,FileName
    #=================================================
}