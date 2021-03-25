function Get-LenovoDriverPack {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #   Notes
    #=======================================================================
    #Lenovo Updates Catalog V1
    #$CatalogUrlv1 = 'https://download.lenovo.com/cdrt/td/catalogs.xml'

    #Lenovo Updates Catalog V2 for SCCM
    #https://thinkdeploy.blogspot.com/2019/07/lenovo-updates-catalog-v2-for-sccm.html


    #https://thinkdeploy.blogspot.com/2020/06/lenovo-updates-catalog-v3-for-sccm.html
    #https://download.lenovo.com/luc/v2/LenovoUpdatesCatalog2v2.cab
    #=======================================================================
    #   Get the Catalog
    #=======================================================================
    $CatalogUrl = 'https://download.lenovo.com/cdrt/td/catalogv2.xml'

    $CatalogContent = New-Object System.Xml.XmlDocument

    if (Test-WebConnection $CatalogUrl) {
        Save-WebFile -SourceUrl $CatalogUrl -DestinationDirectory $env:Temp -DestinationName catalogv2.xml -Overwrite | Out-Null
        [xml]$CatalogContent = Get-Content -Path "$env:Temp\catalogv2.xml" -Raw
    }
    else {
        Write-Verbose "Gathering local content from $($MyInvocation.MyCommand.Module.ModuleBase)\Files\Lenovo\catalogv2.xml"
        [xml]$CatalogContent = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\Files\Lenovo\catalogv2.xml" -Raw
    }

    $ModelList = $CatalogContent.ModelList.Model
    #=======================================================================
    #   Create Object 
    #=======================================================================
    $LenovoDriverPack = foreach ($Model in $ModelList) {
        foreach ($Item in $Model.SCCM) {

            $ObjectProperties = [Ordered]@{
                Name            = $Model.name
                FileName        = $Item.'#text' | Split-Path -Leaf
                Product         = $Model.Types.Type.split(',').Trim()
    
                OSVersion       = $Item.version
                DriverPackUrl   = $Item.'#text'
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
    }
    #=======================================================================
    #   Return Driver Pack
    #=======================================================================
    $LenovoDriverPack = $LenovoDriverPack | Sort-Object Name, OSVersion -Descending | Group-Object Name | ForEach-Object {$_.Group | Select-Object -First 1}
    $LenovoDriverPack | Sort-Object Name, OSVersion -Descending | Select-Object Name, Product, DriverPackUrl, FileName
    #=======================================================================
}