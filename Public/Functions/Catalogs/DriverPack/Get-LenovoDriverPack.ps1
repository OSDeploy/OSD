<#
.SYNOPSIS
Returns the Lenovo DriverPack Catalog

.DESCRIPTION
Returns the Lenovo DriverPack Catalog

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-LenovoDriverPack {
    [CmdletBinding()]
    param (
        #Limits the results to match the current system
        [System.Management.Automation.SwitchParameter]
        $Compatible,

        #Specifies a download path for matching results displayed in Out-GridView
        [System.String]
        $DownloadPath
    )
    #=================================================
    #   Import Catalog
    #=================================================
    $Results = Import-Clixml -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\LenovoDriverPackCatalog.xml" | `
    Select-Object CatalogVersion, Status, ReleaseDate, Manufacturer, Model, `
    @{Name='Product';Expression={([array]$_.Product)}}, `
    Name, PackageID, FileName, `
    @{Name='DriverPackUrl';Expression={($_.Url)}}, `
    @{Name='DriverPackOS';Expression={($null)}}, `
    OSReleaseId,OSBuild,HashMD5
    #=================================================
    #   Modify Results
    #=================================================
    foreach ($Result in $Results) {
        if ($Result.FileName -match 'w11') {
            $Result.DriverPackOS = 'Windows 11 x64'
        }
        else {
            $Result.DriverPackOS = 'Windows 10 x64'
        }
    }

    $Results = $Results | Sort-Object -Property Model
    #=================================================
    #   Filter Compatible
    #=================================================
    if ($PSBoundParameters.ContainsKey('Compatible')) {
        $MyComputerProduct = Get-MyComputerProduct
        Write-Verbose "Filtering Catalog for items compatible with Product $MyComputerProduct"
        $Results = $Results | Where-Object {$_.Product -contains $MyComputerProduct}
    }
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
        $Results | Sort-Object Name
    }
}