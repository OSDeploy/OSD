<#
.SYNOPSIS
Returns the Lenovo DriverPacks

.DESCRIPTION
Returns the Lenovo DriverPacks

.PARAMETER Compatible
Filters results based on your current Product

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-CatalogLenovoDriverPack {
    [CmdletBinding()]
    param (
		[switch]$Compatible
    )
    #=================================================
    #   Paths
    #=================================================
	$CatalogState           = 'Online' #Online, Build, Local, Offline
    #$DownloadsBaseUrl       = 'http://downloads.Lenovo.com/'
	$CatalogOnlinePath      = 'https://download.lenovo.com/cdrt/td/catalogv2.xml'
	$CatalogBuildPath       = Join-Path $env:TEMP (Join-Path 'OSD' 'catalogv2.xml')
	$CatalogLocalPath  		= Join-Path $env:TEMP (Join-Path 'OSD' 'CatalogLenovoDriverPack.xml')
	$CatalogOfflinePath     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\CatalogLenovoDriverPack.xml"
	#$CatalogLocalCabName  	= [string]($CatalogOnlinePath | Split-Path -Leaf)
    #$CatalogLocalCabPath 	= Join-Path $env:TEMP $CatalogLocalCabName
    #=================================================
    #   Test CatalogState Local
    #=================================================
    if (Test-Path $CatalogLocalPath) {
		Write-Verbose "Catalog already downloaded to $CatalogLocalPath"
		#Get-Item to determine the age
        $GetItemCatalogLocalPath = Get-Item $CatalogLocalPath

		#If the local is older than 12 hours, delete it
        if (((Get-Date) - $GetItemCatalogLocalPath.LastWriteTime).TotalHours -gt 12) {
            Write-Verbose "Removing previous Offline Catalog"
		}
		else {
            $CatalogState = 'Local'
        }
    }
    #=================================================
    #   Test CatalogState Online
    #=================================================
	if ($CatalogState -eq 'Online') {
		if (Test-WebConnection -Uri $CatalogOnlinePath) {
			Write-Verbose "Catalog is Online"
		}
		else {
			Write-Verbose "Catalog is Offline"
			$CatalogState = 'Offline'
		}
	}
    #=================================================
    #   CatalogState Online
	#	Need to get the Online Catalog to Local
    #=================================================
	if ($CatalogState -eq 'Online') {
		Write-Verbose "Source: $CatalogOnlinePath"
		Write-Verbose "Destination: $CatalogBuildPath"
		Write-Verbose "Downloading Online Catalog"
        Save-WebFile -SourceUrl $CatalogOnlinePath -DestinationName 'catalogv2.xml' -Overwrite | Out-Null

		#Make sure the file downloaded
		if (Test-Path $CatalogBuildPath) {
			Write-Verbose "Catalog downloaded to $CatalogBuildPath"
			$CatalogState = 'Build'
		}
		else {
			Write-Verbose "Catalog was NOT downloaded to $CatalogBuildPath"
			$CatalogState = 'Offline'
		}
	}
    #=================================================
    #   CatalogState Build
    #=================================================
	if ($CatalogState -eq 'Build') {
		Write-Verbose "Reading the System Catalog at $CatalogBuildPath"
		[xml]$XmlCatalogContent = Get-Content -Path "$env:Temp\OSD\catalogv2.xml" -Raw

		$ModelList = $XmlCatalogContent.ModelList.Model
		#=================================================
		#   Create Object 
		#=================================================
		$Results = foreach ($Model in $ModelList) {
			foreach ($Item in $Model.SCCM) {
	
				$ObjectProperties = [Ordered]@{
					CatalogVersion 	= Get-Date -Format yy.MM.dd
					Name            = $Model.name
					FileName        = $Item.'#text' | Split-Path -Leaf
					Product         = $Model.Types.Type.split(',').Trim()
		
					OSVersion       = $Item.version
					DriverPackUrl   = $Item.'#text'
				}
				New-Object -TypeName PSObject -Property $ObjectProperties
			}
		}

		$Results = $Results | Sort-Object Name, OSVersion -Descending | Group-Object Name | ForEach-Object {$_.Group | Select-Object -First 1}
		$Results | Sort-Object Name, OSVersion -Descending | Select-Object CatalogVersion,Name, Product, DriverPackUrl, FileName
	
		Write-Verbose "Exporting Offline Catalog to $CatalogLocalPath"
		$Results | Export-Clixml -Path $CatalogLocalPath
	}
    #=================================================
    #   CatalogState Local
    #=================================================
	if ($CatalogState -eq 'Local') {
		Write-Verbose "Reading the Local System Catalog at $CatalogLocalPath"
		$Results = Import-Clixml -Path $CatalogLocalPath
	}
    #=================================================
    #   CatalogState Offline
    #=================================================
	if ($CatalogState -eq 'Offline') {
		Write-Verbose "Reading the Offline System Catalog at $CatalogOfflinePath"
		$Results = Import-Clixml -Path $CatalogOfflinePath
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
	if ($PSBoundParameters.ContainsKey('Component')) {
		Write-Verbose "Filtering XML for $Component"
		$Results = $Results | Where-Object {$_.Component -eq $Component}
	}
    #=================================================
    #   Component
    #=================================================
    $Results | Sort-Object -Property Name -Descending
    #=================================================
}