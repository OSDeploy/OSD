function Get-DellDriverPack {
    [CmdletBinding()]
    param (
        [System.String]$DownloadPath
    )
    #=================================================
    #   Get Catalog
    #=================================================
    $Results = Get-DellDriverPackMasterCatalog | Select-Object CatalogVersion, Status, ReleaseDate, Name, @{Name='Product';Expression={($_.SystemID)}}, @{Name='DriverPackUrl';Expression={($_.Url)}}, FileName, @{Name='DriverPackOS';Expression={($_.SupportedOS)}}
    $Results = $Results | Where-Object {$null -ne $_.Product}
    #=================================================
    #   DownloadPath
    #=================================================
    if ($PSBoundParameters.ContainsKey('DownloadPath')) {

        if (Test-Path $DownloadPath) {
            $DownloadedFiles = Get-ChildItem -Path $DownloadPath *.* -Recurse -File | Select-Object -ExpandProperty Name
            foreach ($Item in $Results) {
                if ($Item.FileName -in $DownloadedFiles) {
                    $Item.Status = 'Downloaded'
                }
            }
        }

        $Results = $Results | Sort-Object -Property @{Expression='Status';Descending=$true}, Name | Out-GridView -Title 'Select one or more Driver Packs to Download' -PassThru -ErrorAction Stop
        foreach ($Item in $Results) {
            $OutFile = Save-WebFile -SourceUrl $Item.DriverPackUrl -DestinationDirectory $DownloadPath -DestinationName $Item.FileName -Verbose
            $Item | ConvertTo-Json | Out-File "$($OutFile.FullName).json" -Encoding ascii -Width 2000 -Force
        }
    }
    else {
        $Results
    }
}