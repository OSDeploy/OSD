<#
.SYNOPSIS
Returns the Microsoft Surface DriverPacks

.DESCRIPTION
Returns the Microsoft Surface DriverPacks

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-MicrosoftDriverPack {
    [CmdletBinding()]
    param (
        #Specifies a download path for matching results displayed in Out-GridView
        [System.String]
        $DownloadPath
    )
    #=================================================
    #   Get-MicrosoftDriverPackCatalog
    #=================================================
    $Results = Get-MicrosoftDriverPackCatalog | `
    Select-Object CatalogVersion, Status, ReleaseDate, Manufacturer, Model, Product, Name, PackageID, FileName, `
    @{Name='DriverPackUrl';Expression={($_.Url)}}, `
    @{Name='DriverPackOS';Expression={($_.OSVersion)}}, `
    HashMD5

    $Results = $Results | Sort-Object -Property Model
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