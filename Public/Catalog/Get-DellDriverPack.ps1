function Get-DellDriverPack {
    [CmdletBinding()]
    param (
        [System.String]$DownloadPath,
        
        [ValidateSet('Windows 11 x64','Windows 10 x64')]
        [System.String]$DriverPackOS
    )
    #=================================================
    #   Get Catalog
    #=================================================
    $Results = Get-DellDriverPackMasterCatalog | Select-Object CatalogVersion, ReleaseDate, Name, @{Name='Product';Expression={($_.SystemID)}}, @{Name='DriverPackUrl';Expression={($_.Url)}}, FileName, @{Name='DriverPackOS';Expression={($_.SupportedOS)}}
    $Results = $Results | Where-Object {$null -ne $_.Product}
    #=================================================
    #   DriverPackOS
    #=================================================
    if ($DriverPackOS -eq 'Win11') {
        $Results = $Results | Where-Object {$_.DriverPackOS -contains 'Windows 11 x64'}
    }
    elseif ($DriverPackOS -eq 'Win10') {
        $Results = $Results | Where-Object {$_.DriverPackOS -contains 'Windows 10 x64'}
    }
    else {
        $Results = $Results | Where-Object {($_.DriverPackOS -contains 'Windows 11 x64') -or ($_.DriverPackOS -contains 'Windows 10 x64')}
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