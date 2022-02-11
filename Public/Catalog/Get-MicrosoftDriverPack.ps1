function Get-MicrosoftDriverPack {
    [CmdletBinding()]
    param (
        [System.String]$DownloadPath
    )
    #=================================================
    #   Get-MicrosoftDriverPackCatalog
    #=================================================
    $Results = Get-MicrosoftDriverPackCatalog | Select-Object CatalogVersion, ReleaseDate, Name, Product, @{Name='DriverPackUrl';Expression={($_.Url)}}, FileName
    #=================================================
    #   DownloadPath
    #=================================================
    if ($PSBoundParameters.ContainsKey('DownloadPath')) {
        $Results = $Results | Out-GridView -Title 'Select one or more files to Download' -PassThru -ErrorAction Stop
        foreach ($Item in $Results) {
            $OutFile = Save-WebFile -SourceUrl $Item.DriverPackUrl -DestinationDirectory $DownloadPath -DestinationName $Item.FileName -Verbose
            $Item | ConvertTo-Json | Out-File "$($OutFile.FullName).json" -Encoding ascii -Width 2000 -Force
        }
    }
    else {
        $Results
    }
}