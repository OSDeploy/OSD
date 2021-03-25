function Get-HpDriverPack {
    [CmdletBinding()]
    param (
        [string]$Product
    )
    #=======================================================================
    #   Notes
    #=======================================================================

    #=======================================================================
    #   Get the Catalog
    #=======================================================================
    $CatalogContent = New-Object System.Xml.XmlDocument
    [xml]$CatalogContent = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\Files\Hp\HPClientDriverPackCatalog.xml" -Raw
    $DriverPackManifest = $CatalogContent.NewDataSet.HPClientDriverPackCatalog.SoftPaqList.SoftPaq
    $HpModelList = $CatalogContent.NewDataSet.HPClientDriverPackCatalog.ProductOSDriverPackList.ProductOSDriverPack
    $HpModelList = $HpModelList | Where-Object {$_.OSName -match 'Windows 10'}
    
    foreach ($Item in $HpModelList) {
        $Item.SystemId = $Item.SystemId.Trim()
    }

    if ($PSBoundParameters.ContainsKey('Product')) {
        $HpModelList = $HpModelList | Where-Object {($_.SystemId -match $Product) -or ($_.SystemId -contains $Product)}
    }
    #=======================================================================
    #   Create Object 
    #=======================================================================
    $ErrorActionPreference = "Ignore"

    $HpDriverPack = foreach ($DriverPackage in $DriverPackManifest) {
        #=======================================================================
        #   Matching
        #=======================================================================
        $ProductId          = $DriverPackage.Id
        $MatchingList       = @()
        $MatchingList       = $HpModelList | Where-Object {$_.SoftPaqId -match $ProductId}

        if ($null -eq $MatchingList) {
            Continue
        }

        $SystemSku          = @()
        $SystemSku          = $MatchingList | Select-Object -Property SystemId -Unique
        $SystemSku          = ($SystemSku).SystemId
        $DriverPackVersion  = $DriverPackage.Version
        $DriverPackName     = "$($DriverPackage.Name) $DriverPackVersion"

        $ObjectProperties = [Ordered]@{
            Name            = $DriverPackage.Name
            FileName        = $DriverPackage.Url | Split-Path -Leaf
            Product         = [array]$SystemSku
            ReleaseDate     = [datetime]$DriverPackage.DateReleased
            Version         = $DriverPackVersion
            DriverPackUrl   = $DriverPackage.Url
        }
        New-Object -TypeName PSObject -Property $ObjectProperties
    }
    $HpDriverPack = $HpDriverPack | Where-Object {$_.Name -match 'Windows 10'}
    $HpDriverPack = $HpDriverPack | Sort-Object Name, ReleaseDate -Descending | Group-Object Name | ForEach-Object {$_.Group | Select-Object -First 1}
    #=======================================================================
    #   Return Driver Pack
    #=======================================================================
    $HpDriverPack | Sort-Object Name | Select-Object @{Name='Name';Expression={"$($_.Name) $($_.Version)"}}, Product, DriverPackUrl, FileName
    #=======================================================================
}