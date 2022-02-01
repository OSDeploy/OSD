function Get-DellDriverPack {
    [CmdletBinding()]
    param (
        [string]$DownloadPath
    )
    #=================================================
    #   Get-CatalogDellDriverPack
    #=================================================
    $Results = Get-CatalogDellDriverPack
    $Results = $Results | Where-Object {$_.SupportedSystemId -ne $null}
    $Results = $Results | Where-Object {($_.SupportedOperatingSystems -contains 'Windows 11 x64') -or ($_.SupportedOperatingSystems -contains 'Windows 10 x64')}
    $Results = $Results | Sort-Object OSVersion -Descending | Group-Object Name | ForEach-Object {$_.Group | Select-Object -First 1}
    #=================================================
    #   Download
    #=================================================
    if ($DownloadPath) {
        $Results = $Results | Out-GridView -Title 'Select one or more DriverPacks to Download' -PassThru -ErrorAction Stop
        foreach ($Item in $Results) {
            $OsCode = 'Win10'
            if ($Item.SupportedOperatingSystems -match 'Windows 11') {$OsCode = 'Win11'}
            $Product = $Item.SupportedSystemId | Select-Object -First 1
            Write-Output $Product
            Write-Verbose "Saving $Product" -Verbose
            Save-MyDriverPack -Manufacturer Dell -OsCode $OsCode -Product $Product -DownloadPath $DownloadPath
        }
    }
    #=================================================
    #   Results
    #=================================================
    $Results | Sort-Object ReleaseDate -Descending | Select-Object CatalogVersion,ReleaseDate,Name,`
    @{Name='Product';Expression={($_.SupportedSystemId)}},`
    @{Name='SupportedOperatingSystems';Expression={($_.SupportedOperatingSystems)}},`
    @{Name='DriverPackUrl';Expression={($_.Url)}},FileName
    #=================================================
}