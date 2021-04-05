function Get-MicrosoftDriverPack {
    [CmdletBinding()]
    param (
        [string]$DownloadPath
    )
    #=======================================================================
    #   Get-CatalogMicrosoftDriverPack
    #=======================================================================
    $Results = Get-CatalogMicrosoftDriverPack | Sort-Object Product
    #=======================================================================
    #   Download
    #=======================================================================
    if ($DownloadPath) {
        $Results = $Results | Out-GridView -Title 'Select one or more DriverPacks to Download' -PassThru -ErrorAction Stop
        foreach ($Item in $Results) {
            Save-MyDriverPack -Manufacturer Microsoft -Product $Item.Product -DownloadPath $DownloadPath
        }
    }
    #=======================================================================
    #   Results
    #=======================================================================
    $Results | Select-Object CatalogVersion,Product,Name,Model,DriverPackUrl,FileName,PackageId
    #=======================================================================
}