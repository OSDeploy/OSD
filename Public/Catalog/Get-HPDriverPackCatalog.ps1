<#
.SYNOPSIS
Returns the HP DriverPacks

.DESCRIPTION
Returns the HP DriverPacks

.PARAMETER Compatible
Filters results based on your current Product

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-HPDriverPackCatalog {
    [CmdletBinding()]
    param (
        [System.String]$DownloadPath,
        [switch]$Compatible
    )
    #=================================================
    #   Paths
    #=================================================
    $UseCatalog             = 'Cloud'
    $CloudCatalogUri        = 'http://ftp.hp.com/pub/caps-softpaq/cmit/HPClientDriverPackCatalog.cab'
    $RawCatalogFile			= Join-Path $env:TEMP (Join-Path 'OSD' 'HPClientDriverPackCatalog.xml')
    $BuildCatalogFile		= Join-Path $env:TEMP (Join-Path 'OSD' 'HPDriverPackCatalog.xml')
    $OfflineCatalogFile     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\HPDriverPackCatalog.xml"
    
    $RawCatalogCabName  	= [string]($CloudCatalogUri | Split-Path -Leaf)
    $RawCatalogCabPath 	    = Join-Path $env:TEMP (Join-Path 'OSD' $RawCatalogCabName)
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
        Write-Warning "Building Catalog content, please wait ..."
        [xml]$XmlCatalogContent = Get-Content $RawCatalogFile -ErrorAction Stop
        $DriverPackManifest = $XmlCatalogContent.NewDataSet.HPClientDriverPackCatalog.SoftPaqList.SoftPaq
        $HpModelList = $XmlCatalogContent.NewDataSet.HPClientDriverPackCatalog.ProductOSDriverPackList.ProductOSDriverPack

        $HpModelList = $HpModelList | Where-Object {$_.OSName -notmatch 'Windows 7'}
        $HpModelList = $HpModelList | Where-Object {$_.OSName -notmatch 'Windows 8'}
        $HpModelList = $HpModelList | Where-Object {$_.OSName -notmatch 'Windows 10 IoT'}

        foreach ($Item in $HpModelList) {
            $Item.SystemId = $Item.SystemId.Trim()
        }

        if ($PSBoundParameters.ContainsKey('Product')) {
            $HpModelList = $HpModelList | Where-Object {($_.SystemId -match $Product) -or ($_.SystemId -contains $Product)}
        }
        #=================================================
        #   Create Object 
        #=================================================
        $ErrorActionPreference = "Ignore"

        $Results = foreach ($DriverPackage in $DriverPackManifest) {
            #=================================================
            #   Matching
            #=================================================
            $ProductId          = $DriverPackage.Id
            $MatchingList       = @()
            $MatchingList       = $HpModelList | Where-Object {$_.SoftPaqId -match $ProductId}

            if ($null -eq $MatchingList) {
                Continue
            }

            $SystemSku          = @()
            $SystemSku          = $MatchingList | Select-Object -Property SystemId -Unique
            $SystemSku          = ($SystemSku).SystemId

            $SystemModel        = @()
            $SystemModel        = $MatchingList | Select-Object -Property SystemName -Unique
            $SystemModel        = ($SystemModel).SystemName

            $DriverPackVersion  = $DriverPackage.Version
            $DriverPackName     = "$($DriverPackage.Name) $DriverPackVersion"

            $ObjectProperties = [Ordered]@{
                CatalogVersion 	= Get-Date -Format yy.MM.dd
                ReleaseDate     = [datetime]$DriverPackage.DateReleased
                Name            = $DriverPackage.Name
                Model           = $SystemModel
                FileName        = $DriverPackage.Url | Split-Path -Leaf
                Product         = [array]$SystemSku
                Version         = $DriverPackVersion
                DriverPackUrl   = $DriverPackage.Url
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
        #$Results = $Results | Where-Object {$_.Name -notmatch 'Win 7'}
        #$Results = $Results | Where-Object {$_.Name -notmatch 'Windows 7'}
        #$Results = $Results | Where-Object {$_.Name -notmatch 'Windows 8'}
        #$Results = $Results | Where-Object {$_.Name -match 'Windows 10'}
        $Results = $Results | Sort-Object Name, ReleaseDate -Descending | Group-Object Name | ForEach-Object {$_.Group | Select-Object -First 1}
        #$Results = $Results | Sort-Object Name | Select-Object CatalogVersion, ReleaseDate, @{Name='Name';Expression={"$($_.Name) $($_.Version)"}}, Product, DriverPackUrl, FileName

        $Results = $Results | Sort-Object Name | Select-Object CatalogVersion, ReleaseDate, @{Name='Name';Expression={"$($_.Name) $($_.Version)"}}, @{
            Name='Product';Expression={
                $p = $_.Product
                $pBaseType = $p.gettype().BaseType.Name
                if ($pBaseType -eq "Array") {
                    # its array
                    $p | ForEach-Object {
                        if ($_ -match ",") {
                            ($_ -split ",").trim()
                        }
                        else {
                            $_
                        }
                    }
                }
                elseif ($p -match ",") {
                    # its string that contains more items
                    ($p -split ",").trim()
                }
                else {
                    # its one item
                    $p
                }
            }
        }, DriverPackUrl, FileName

        Write-Verbose "Exporting Build Catalog to $BuildCatalogFile"
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
        $Results = $Results | Where-Object {$_.Product -contains $MyComputerProduct}
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
            $OutFile = Save-WebFile -SourceUrl $Item.DriverPackUrl -DestinationDirectory $DownloadPath -DestinationName $Item.FileName -Verbose
            $Item | ConvertTo-Json | Out-File "$($OutFile.FullName).json" -Encoding ascii -Width 2000 -Force
        }
    }
    #=================================================
    #   Complete
    #=================================================
    $Results
    #=================================================
}