<#
.SYNOPSIS
Returns the HP DriverPacks

.DESCRIPTION
Returns the HP DriverPacks

.PARAMETER Compatible
Filters results based on your current Product

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-CatalogHPDriverPack {
    [CmdletBinding()]
    param (
		[switch]$Compatible
    )
    #=======================================================================
    #   Paths
    #=======================================================================
	$CatalogState           = 'Online' #Online, Build, Local, Offline
    #$DownloadsBaseUrl       = 'http://downloads.HP.com/'
	$CatalogOnlinePath      = 'http://ftp.hp.com/pub/caps-softpaq/cmit/HPClientDriverPackCatalog.cab'
	$CatalogBuildPath       = Join-Path $env:TEMP 'HPClientDriverPackCatalog.xml'
	$CatalogLocalPath  		= Join-Path $env:TEMP 'CatalogHPDriverPack.xml'
	$CatalogOfflinePath     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\CatalogHPDriverPack.xml"
	$CatalogLocalCabName  	= [string]($CatalogOnlinePath | Split-Path -Leaf)
    $CatalogLocalCabPath 	= Join-Path $env:TEMP $CatalogLocalCabName
    #=======================================================================
    #   Test CatalogState Local
    #=======================================================================
    if (Test-Path $CatalogLocalPath) {

		#Get-Item to determine the age
        $GetItemCatalogLocalPath = Get-Item $CatalogLocalPath

		#If the local is older than 1 day, delete it
        if (((Get-Date) - $GetItemCatalogLocalPath.CreationTime).TotalDays -gt 1) {
            Write-Verbose "Removing previous Offline Catalog"
		}
		else {
            $CatalogState = 'Local'
			Write-Verbose "CatalogState: $CatalogState"
        }
    }
    #=======================================================================
    #   Test CatalogState Online
    #=======================================================================
	if ($CatalogState -eq 'Online') {
		if (Test-WebConnection -Uri $CatalogOnlinePath) {
			#Catalog is online and can be downloaded
		}
		else {
			$CatalogState = 'Offline'
			Write-Verbose "CatalogState: $CatalogState"
		}
	}
    #=======================================================================
    #   CatalogState Online
	#	Need to get the Online Catalog to Local
    #=======================================================================
	if ($CatalogState -eq 'Online') {
		Write-Verbose "CatalogState: $CatalogState"
		Write-Verbose "Source: $CatalogOnlinePath"
		Write-Verbose "Destination: $CatalogLocalCabPath"
		(New-Object System.Net.WebClient).DownloadFile($CatalogOnlinePath, $CatalogLocalCabPath)

		#Make sure the file downloaded
		if (Test-Path $CatalogLocalCabPath) {
			Write-Verbose "Expand: $CatalogLocalCabPath"
			Expand "$CatalogLocalCabPath" "$CatalogBuildPath" | Out-Null

			if (Test-Path $CatalogBuildPath) {
				$CatalogState = 'Build'
				Write-Verbose "CatalogState: $CatalogState"
			}
			else {
				Write-Verbose "Could not expand $CatalogLocalCabPath"
				$CatalogState = 'Offline'
				Write-Verbose "CatalogState: $CatalogState"
			}
		}
		else {
			$CatalogState = 'Offline'
			Write-Verbose "CatalogState: $CatalogState"
		}
	}
    #=======================================================================
    #   CatalogState Build
    #=======================================================================
	if ($CatalogState -eq 'Build') {
		Write-Verbose "Reading the Build Catalog at $CatalogBuildPath"


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
		#=======================================================================
		#   Create Object 
		#=======================================================================
		$ErrorActionPreference = "Ignore"
	
		$Results = foreach ($DriverPackage in $DriverPackManifest) {
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
		$Results = $Results | Sort-Object Name | Select-Object CatalogVersion, ReleaseDate, @{Name='Name';Expression={"$($_.Name) $($_.Version)"}}, Product, DriverPackUrl, FileName
	
		Write-Verbose "Exporting Offline Catalog to $CatalogLocalPath"
		$Results | Export-Clixml -Path $CatalogLocalPath
	}
    #=======================================================================
    #   CatalogState Local
    #=======================================================================
	if ($CatalogState -eq 'Local') {
		Write-Verbose "Reading the Local System Catalog at $CatalogLocalPath"
		$Results = Import-Clixml -Path $CatalogLocalPath
	}
    #=======================================================================
    #   CatalogState Offline
    #=======================================================================
	if ($CatalogState -eq 'Offline') {
		Write-Verbose "Reading the Offline System Catalog at $CatalogOfflinePath"
		$Results = Import-Clixml -Path $CatalogOfflinePath
	}
    #=======================================================================
    #   Compatible
    #=======================================================================
	if ($PSBoundParameters.ContainsKey('Compatible')) {
		$MyComputerProduct = Get-MyComputerProduct
		Write-Verbose "Filtering XML for items compatible with Product $MyComputerProduct"
		$Results = $Results | Where-Object {$_.Product -contains $MyComputerProduct}
	}
    #=======================================================================
    #   Component
    #=======================================================================
    $Results
    #=======================================================================
}