function Get-DellDriverPack {
    [CmdletBinding()]
    param (
        [System.String]$DownloadPath,
        
        [ValidateSet('Win10','Win11')]
        [System.String]$OsCode
    )
    #=================================================
    #   Get Catalog
    #=================================================
    $Results = Get-DellDriverPackCatalog | Select-Object CatalogVersion, ReleaseDate, Name, @{Name='Product';Expression={($_.SystemID)}}, @{Name='DriverPackUrl';Expression={($_.Url)}}, FileName, SupportedOS
    $Results = $Results | Where-Object {$null -ne $_.Product}
    #=================================================
    #   OsCode
    #=================================================
    if ($OsCode -eq 'Win11') {
        $Results = $Results | Where-Object {$_.SupportedOS -contains 'Windows 11 x64'}
    }
    elseif ($OsCode -eq 'Win10') {
        $Results = $Results | Where-Object {$_.SupportedOS -contains 'Windows 10 x64'}
    }
    else {
        $Results = $Results | Where-Object {($_.SupportedOS -contains 'Windows 11 x64') -or ($_.SupportedOS -contains 'Windows 10 x64')}
    }
    #$Results = $Results | Sort-Object SupportedOS -Descending | Group-Object Name | ForEach-Object {$_.Group | Select-Object -First 1}
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