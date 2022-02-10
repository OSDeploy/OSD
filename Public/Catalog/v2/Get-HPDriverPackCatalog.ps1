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
		[switch]$Compatible
    )
    #=================================================
    #   Paths
    #=================================================
	$UseCatalog           = 'Cloud'
	$CloudCatalogUri      		= 'http://ftp.hp.com/pub/caps-softpaq/cmit/HPClientDriverPackCatalog.cab'
	$RawCatalogFile			= Join-Path $env:TEMP (Join-Path 'OSD' 'HPClientDriverPackCatalog.xml')
	$BuildCatalogFile		= Join-Path $env:TEMP (Join-Path 'OSD' 'HPDriverPackCatalog.xml')
	$OfflineCatalogFile     	= "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\HP\HPDriverPackCatalog.xml"
	$RawCatalogCabName  	= [string]($CloudCatalogUri | Split-Path -Leaf)
    $RawCatalogCabPath 	= Join-Path $env:TEMP (Join-Path 'OSD' $RawCatalogCabName)
    #=================================================
    #   Create Paths
    #=================================================
	if (-not(Test-Path (Join-Path $env:TEMP 'OSD'))) {
		$null = New-Item -Path (Join-Path $env:TEMP 'OSD') -ItemType Directory -Force
	}
    #=================================================
    #   Test Local UseCatalog
    #=================================================
    if (Test-Path $BuildCatalogFile) {
		Write-Verbose "Catalog already downloaded to $BuildCatalogFile"	

        $GetItemBuildCatalogFile = Get-Item $BuildCatalogFile

		#If the local is older than 12 hours, delete it
        if (((Get-Date) - $GetItemBuildCatalogFile.LastWriteTime).TotalHours -gt 12) {
            Write-Verbose "Removing previous Offline Catalog"
		}
		else {
            $UseCatalog = 'Local'
        }
    }
    #=================================================
    #   Test UseCatalog Cloud
    #=================================================
	if ($UseCatalog -eq 'Cloud') {
		if (Test-WebConnection -Uri $CloudCatalogUri) {
			#Catalog is Cloud and can be downloaded
		}
		else {
			$UseCatalog = 'Offline'
			Write-Verbose "UseCatalog: $UseCatalog"
		}
	}
    #=================================================
    #   UseCatalog Cloud
	#	Need to get the Cloud Catalog to Local
    #=================================================
	if ($UseCatalog -eq 'Cloud') {
		Write-Verbose "UseCatalog: $UseCatalog"
		Write-Verbose "Source: $CloudCatalogUri"
		Write-Verbose "Destination: $RawCatalogCabPath"
		(New-Object System.Net.WebClient).DownloadFile($CloudCatalogUri, $RawCatalogCabPath)

		#Make sure the file downloaded
		if (Test-Path $RawCatalogCabPath) {
			Write-Verbose "Expand: $RawCatalogCabPath"
			Expand "$RawCatalogCabPath" "$RawCatalogFile" | Out-Null

			if (Test-Path $RawCatalogFile) {
				$UseCatalog = 'Build'
				Write-Verbose "UseCatalog: $UseCatalog"
			}
			else {
				Write-Verbose "Could not expand $RawCatalogCabPath"
				$UseCatalog = 'Offline'
				Write-Verbose "UseCatalog: $UseCatalog"
			}
		}
		else {
			$UseCatalog = 'Offline'
			Write-Verbose "UseCatalog: $UseCatalog"
		}
	}
    #=================================================
    #   UseCatalog Build
    #=================================================
	if ($UseCatalog -eq 'Build') {
		Write-Verbose "Reading the Build Catalog at $RawCatalogFile"


		[xml]$XmlCatalogContent = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\Files\Hp\HPClientDriverPackCatalog.xml" -Raw
		$DriverPackManifest = $XmlCatalogContent.NewDataSet.HPClientDriverPackCatalog.SoftPaqList.SoftPaq
		$HpModelList = $XmlCatalogContent.NewDataSet.HPClientDriverPackCatalog.ProductOSDriverPackList.ProductOSDriverPack
		$HpModelList = $HpModelList | Where-Object {$_.OSName -match 'Windows 10'}
    
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
			$DriverPackVersion  = $DriverPackage.Version
			$DriverPackName     = "$($DriverPackage.Name) $DriverPackVersion"
	
			$ObjectProperties = [Ordered]@{
				CatalogVersion 	= Get-Date -Format yy.MM.dd
				Name            = $DriverPackage.Name
				FileName        = $DriverPackage.Url | Split-Path -Leaf
				Product         = [array]$SystemSku
				ReleaseDate     = [datetime]$DriverPackage.DateReleased
				Version         = $DriverPackVersion
				DriverPackUrl   = $DriverPackage.Url
			}
			New-Object -TypeName PSObject -Property $ObjectProperties
		}
		$Results = $Results | Where-Object {$_.Name -match 'Windows 10'}
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
		Write-Verbose "Exporting Offline Catalog to $BuildCatalogFile"
		$Results | Export-Clixml -Path $BuildCatalogFile
	}
    #=================================================
    #   UseCatalog Local
    #=================================================
	if ($UseCatalog -eq 'Local') {
		Write-Verbose "Reading the Local System Catalog at $BuildCatalogFile"
		$Results = Import-Clixml -Path $BuildCatalogFile
	}
    #=================================================
    #   UseCatalog Offline
    #=================================================
	if ($UseCatalog -eq 'Offline') {
		Write-Verbose "Reading the Offline System Catalog at $OfflineCatalogFile"
		$Results = Import-Clixml -Path $OfflineCatalogFile
	}
    #=================================================
    #   Compatible
    #=================================================
	if ($PSBoundParameters.ContainsKey('Compatible')) {
		$MyComputerProduct = Get-MyComputerProduct
		Write-Verbose "Filtering XML for items compatible with Product $MyComputerProduct"
		$Results = $Results | Where-Object {$_.Product -contains $MyComputerProduct}
	}
    #=================================================
    #   Component
    #=================================================
    $Results
    #=================================================
}