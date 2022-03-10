function Get-HpDriverPack {
    [CmdletBinding()]
    param (
        [System.String]$DownloadPath
    )
    #=================================================
    #   Get Catalog
    #=================================================
    $Results = Get-OSDCatalogHPDriverPack | Select-Object CatalogVersion, Status, @{Name='ReleaseDate';Expression={($_.DateReleased)}}, @{Name='Name';Expression={($_.Model)}}, @{Name='Product';Expression={($_.SystemId)}}, @{Name='DriverPackUrl';Expression={($_.Url)}}, FileName
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