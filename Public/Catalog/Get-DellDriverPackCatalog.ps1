<#
.SYNOPSIS
Returns the Dell DriverPacks downloads

.DESCRIPTION
Returns the Dell DriverPacks downloads

.PARAMETER Compatible
Filters results based on your current Product

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-DellDriverPackCatalog {
    [CmdletBinding()]
    param (
        [System.String]$DownloadPath,
        [switch]$Compatible
    )
    #=================================================
    #   Paths
    #=================================================
    $UseCatalog				= 'Cloud'
    $CloudCatalogUri		= 'https://downloads.dell.com/catalog/DriverPackCatalog.cab'
    $RawCatalogFile			= Join-Path $env:TEMP (Join-Path 'OSD' 'DriverPackCatalog.xml')
    $BuildCatalogFile		= Join-Path $env:TEMP (Join-Path 'OSD' 'DellDriverPackCatalog.xml')
    $OfflineCatalogFile		= "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\DellDriverPackCatalog.xml"

    $RawCatalogCabName  	= [string]($CloudCatalogUri | Split-Path -Leaf)
    $RawCatalogCabPath 		= Join-Path $env:TEMP (Join-Path 'OSD' $RawCatalogCabName)
    $DownloadsBaseUrl       = 'http://downloads.dell.com/'
    #=================================================
    #   Create Download Path
    #=================================================
    if (-not(Test-Path (Join-Path $env:TEMP 'OSD'))) {
        $null = New-Item -Path (Join-Path $env:TEMP 'OSD') -ItemType Directory -Force
    }
    #=================================================
    #   Test Build Catalog
    #=================================================
    if (Test-Path $BuildCatalogFile) {
        Write-Verbose "Build Catalog already created at $BuildCatalogFile"	

        $GetItemBuildCatalogFile = Get-Item $BuildCatalogFile

        #If the Build Catalog is older than 12 hours, delete it
        if (((Get-Date) - $GetItemBuildCatalogFile.LastWriteTime).TotalHours -gt 12) {
            Write-Verbose "Removing previous Build Catalog"
            $null = Remove-Item $GetItemBuildCatalogFile.FullName -Force
        }
        else {
            $UseCatalog = 'Build'
        }
    }
    #=================================================
    #   Test Cloud Catalog
    #=================================================
    if ($UseCatalog -eq 'Cloud') {
        if (Test-WebConnection -Uri $CloudCatalogUri) {
            $UseCatalog = 'Cloud'
        }
        else {
            $UseCatalog = 'Offline'
        }
    }
    #=================================================
    #   UseCatalog Cloud
    #=================================================
    if ($UseCatalog -eq 'Cloud') {
        Write-Verbose "Source: $CloudCatalogUri"
        Write-Verbose "Destination: $RawCatalogCabPath"
        (New-Object System.Net.WebClient).DownloadFile($CloudCatalogUri, $RawCatalogCabPath)

        if (Test-Path $RawCatalogCabPath) {
            Write-Verbose "Expand: $RawCatalogCabPath"
            $null = Expand "$RawCatalogCabPath" "$RawCatalogFile"

            if (Test-Path $RawCatalogFile) {
                Write-Verbose "Using Raw Catalog at $RawCatalogFile"
                $UseCatalog = 'Raw'
            }
            else {
                Write-Verbose "Could not expand $RawCatalogCabPath"
                Write-Verbose "Using Offline Catalog at $OfflineCatalogFile"
                $UseCatalog = 'Offline'
            }
        }
        else {
            Write-Verbose "Using Offline Catalog at $OfflineCatalogFile"
            $UseCatalog = 'Offline'
        }
    }
    #=================================================
    #   UseCatalog Raw
    #=================================================
    if ($UseCatalog -eq 'Raw') {
        Write-Verbose "Reading the Raw Catalog at $RawCatalogFile"
        [xml]$XmlCatalogContent = Get-Content $RawCatalogFile -ErrorAction Stop
        $CatalogVersion = (Get-Date $XmlCatalogContent.DriverPackManifest.version).ToString('yy.MM.dd')
        $Results = $XmlCatalogContent.DriverPackManifest.DriverPackage

        $Results = $Results | Select-Object @{Label="CatalogVersion";Expression={$CatalogVersion};},
        @{Label="Component";Expression={"DriverPack"};},
        @{Label="ReleaseDate";Expression = {[datetime] ($_.dateTime)};},
        @{Label="Name";Expression={($_.Name.Display.'#cdata-section'.Trim())};},
        #@{Label="Description";Expression={($_.Description.Display.'#cdata-section'.Trim())};},
        @{Label="DellVersion";Expression={$_.dellVersion};},
        @{Label="Url";Expression={-join ($DownloadsBaseUrl, $_.path)};},
        @{Label="VendorVersion";Expression={$_.vendorVersion};},
        @{Label="FileName";Expression = {(split-path -leaf $_.path)};},
        @{Label="SizeMB";Expression={'{0:f2}' -f ($_.size/1MB)};},
        @{Label="ReleaseID";Expression={$_.ReleaseID};},
        @{Label="Brand";Expression={($_.SupportedSystems.Brand.Display.'#cdata-section'.Trim() | Select-Object -Unique)};},
        @{Label="Key";Expression={($_.SupportedSystems.Brand.key | Select-Object -Unique)};},
        @{Label="Prefix";Expression={($_.SupportedSystems.Brand.prefix | Select-Object -Unique)};},
        @{Label="Model";Expression={($_.SupportedSystems.Brand.Model.name | Select-Object -Unique)};},
        @{Label="ModelID";Expression={($_.SupportedSystems.Brand.Model.Display.'#cdata-section'.Trim() | Select-Object -Unique)};},
        @{Label="SystemID";Expression={($_.SupportedSystems.Brand.Model.systemID | Select-Object -Unique)};},
        @{Label="RtsDate";Expression={($_.SupportedSystems.Brand.Model.rtsDate | Select-Object -Unique)};},
        @{Label="Generation";Expression={($_.SupportedSystems.Brand.Model.generation | Select-Object -Unique)};},
        @{Label="SupportedOS";Expression={($_.SupportedOperatingSystems.OperatingSystem.Display.'#cdata-section'.Trim() | Select-Object -Unique)};},
        @{Label="osCode";Expression={($_.SupportedOperatingSystems.OperatingSystem.osCode.Trim() | Select-Object -Unique)};},
        @{Label="osVendor";Expression={($_.SupportedOperatingSystems.OperatingSystem.osVendor.Trim() | Select-Object -Unique)};},
        @{Label="osArch";Expression={($_.SupportedOperatingSystems.OperatingSystem.osArch.Trim() | Select-Object -Unique)};},
        @{Label="osType";Expression={($_.SupportedOperatingSystems.OperatingSystem.osType.Trim() | Select-Object -Unique)};},
        @{Label="majorVersion";Expression={($_.SupportedOperatingSystems.OperatingSystem.majorVersion.Trim() | Select-Object -Unique)};},
        @{Label="minorVersion";Expression={($_.SupportedOperatingSystems.OperatingSystem.minorVersion.Trim() | Select-Object -Unique)};},
        @{Label="spMajorVersion";Expression={($_.SupportedOperatingSystems.OperatingSystem.spMajorVersion.Trim() | Select-Object -Unique)};},
        @{Label="spMinorVersion";Expression={($_.SupportedOperatingSystems.OperatingSystem.spMinorVersion.Trim() | Select-Object -Unique)};},
        @{Label="ImportantInfoUrl";Expression={($_.ImportantInfo.URL.Trim() | Select-Object -Unique)};},
        #@{Label="Format";Expression={$_.format};},
        #@{Label="Delta";Expression={$_.delta};},
        #@{Label="Type";Expression={$_.type};},
        @{Label="HashMD5";Expression={$_.HashMD5};}

        Write-Verbose "Exporting Build Catalog to $BuildCatalogFile"
        $Results = $Results | Sort-Object ReleaseDate -Descending
        $Results | Export-Clixml -Path $BuildCatalogFile
    }
    #=================================================
    #   UseCatalog Build
    #=================================================
    if ($UseCatalog -eq 'Build') {
        Write-Verbose "Importing the Build Catalog at $BuildCatalogFile"
        $Results = Import-Clixml -Path $BuildCatalogFile
    }
    #=================================================
    #   UseCatalog Offline
    #=================================================
    if ($UseCatalog -eq 'Offline') {
        Write-Verbose "Importing the Offline Catalog at $OfflineCatalogFile"
        $Results = Import-Clixml -Path $OfflineCatalogFile
    }
    #=================================================
    #   Compatible
    #=================================================
    if ($PSBoundParameters.ContainsKey('Compatible')) {
        $MyComputerProduct = Get-MyComputerProduct
        Write-Verbose "Filtering Catalog for items compatible with Product $MyComputerProduct"
        $Results = $Results | Where-Object {$_.SupportedSystemID -contains $MyComputerProduct}
    }
    #=================================================
    #   Component
    #=================================================
    if ($PSBoundParameters.ContainsKey('Component')) {
        Write-Verbose "Filtering Catalog for $Component"
        $Results = $Results | Where-Object {$_.Component -eq $Component}
    }
    #=================================================
    #   DownloadPath
    #=================================================
    if ($PSBoundParameters.ContainsKey('DownloadPath')) {
        $Results = $Results | Out-GridView -Title 'Select one or more files to Download' -PassThru -ErrorAction Stop
        foreach ($Item in $Results) {
            $OutFile = Save-WebFile -SourceUrl $Item.Url -DestinationDirectory $DownloadPath -DestinationName $Item.FileName -Verbose
            $Item | ConvertTo-Json | Out-File "$($OutFile.FullName).json" -Encoding ascii -Width 2000 -Force
        }
    }
    #=================================================
    #   Complete
    #=================================================
    $Results | Sort-Object -Property ReleaseDate -Descending
    #=================================================
}