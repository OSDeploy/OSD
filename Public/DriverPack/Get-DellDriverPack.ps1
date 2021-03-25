function Get-DellDriverPack {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #   Notes
    #=======================================================================
<# 	Write-Verbose "Reading the Dell Update Catalog at $CatalogPCXmlFullName"
    [xml]$XMLCatalogPcUrl = Get-Content "$CatalogPCXmlFullName" -ErrorAction Stop
    Write-Verbose "Loading the Dell Update XML Nodes"
    $DellCatalogPc = $XMLCatalogPcUrl.Manifest.SoftwareComponent

    $DellCatalogPc = $DellCatalogPc | `
    Select-Object @{Label="Component";Expression={($_.ComponentType.Display.'#cdata-section'.Trim())};},
    @{Label="ReleaseDate";Expression = {[datetime] ($_.dateTime)};},
    @{Label="Name";Expression={($_.Name.Display.'#cdata-section'.Trim())};},
    #@{Label="Description";Expression={($_.Description.Display.'#cdata-section'.Trim())};},
    @{Label="DellVersion";Expression={$_.dellVersion};},
    @{Label="Url";Expression={-join ($DellDownloadsUrl, $_.path)};},
    @{Label="VendorVersion";Expression={$_.vendorVersion};},
    @{Label="Criticality";Expression={($_.Criticality.Display.'#cdata-section'.Trim())};},
    @{Label="FileName";Expression = {(split-path -leaf $_.path)};},
    @{Label="SizeMB";Expression={'{0:f2}' -f ($_.size/1MB)};},
    @{Label="PackageID";Expression={$_.packageID};},
    @{Label="PackageType";Expression={$_.packageType};},
    @{Label="ReleaseID";Expression={$_.ReleaseID};},
    @{Label="Category";Expression={($_.Category.Display.'#cdata-section'.Trim())};},
    @{Label="SupportedDevices";Expression={($_.SupportedDevices.Device.Display.'#cdata-section'.Trim())};},
    @{Label="SupportedBrand";Expression={($_.SupportedSystems.Brand.Display.'#cdata-section'.Trim())};},
    @{Label="SupportedModel";Expression={($_.SupportedSystems.Brand.Model.Display.'#cdata-section'.Trim())};},
    @{Label="SupportedSystemID";Expression={($_.SupportedSystems.Brand.Model.systemID)};},
    @{Label="SupportedOperatingSystems";Expression={($_.SupportedOperatingSystems.OperatingSystem.Display.'#cdata-section'.Trim())};},
    @{Label="SupportedArchitecture";Expression={($_.SupportedOperatingSystems.OperatingSystem.osArch)};},
    @{Label="HashMD5";Expression={$_.HashMD5};}

    Write-Verbose "Exporting Offline Catalog to $OfflineCatalogPcFullName"
    $DellCatalogPc = $DellCatalogPc | Sort-Object ReleaseDate -Descending
    $DellCatalogPc | Export-Clixml -Path $OfflineCatalogPcFullName #>
    #=======================================================================
    #   Get the Catalog
    #=======================================================================
    $CatalogContent = New-Object System.Xml.XmlDocument
    [xml]$CatalogContent = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\Files\Dell\DriverPackCatalog.xml" -Raw
    $DriverPackManifest = $CatalogContent.DriverPackManifest.DriverPackage
    #=======================================================================
    #   Create Object 
    #=======================================================================
    $ErrorActionPreference = "Ignore"

    $DellDriverPack = foreach ($DriverPackage in $DriverPackManifest) {

        foreach ($DriverPackUrl in $DriverPackage.path) {

            $DellBrand = @($DriverPackage.SupportedSystems.Brand.Display.'#cdata-section'.Trim())[0]
            $DellModel = @($DriverPackage.SupportedSystems.Brand.Model.Display.'#cdata-section'.split(',').Trim())[0] -replace ('/',' ')
            $OSVersion = $DriverPackage.SupportedOperatingSystems.OperatingSystem.Display.'#cdata-section'.Trim() -replace ('Vista','6.0') -replace ('XP','5.2') -replace ('10','9.9')

            $ObjectProperties = [Ordered]@{
                Name = "$DellBrand $DellModel" -replace ('Internet of Things ','')
                FileName = $DriverPackUrl | Split-Path -Leaf
                Product = $DriverPackage.SupportedSystems.Brand.Model.systemID
    
                OSVersion = $OSVersion
                DriverPackUrl = 'http://downloads.dell.com/' + $DriverPackUrl
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
    }

    #$DellDriverPack = $DellDriverPack | Where-Object {$_.OSVersion -contains 'Windows 10 x64'}
    #=======================================================================
    #   Return Driver Pack
    #=======================================================================
    $DellDriverPack = $DellDriverPack | Sort-Object OSVersion -Descending | Group-Object Name | ForEach-Object {$_.Group | Select-Object -First 1}
    $DellDriverPack = $DellDriverPack | Where-Object {$_.Product -ne ''}
    $DellDriverPack | Sort-Object Name | Select-Object Name, Product, DriverPackUrl, FileName
    #=======================================================================
}