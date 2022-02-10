<#
.SYNOPSIS
Returns the Lenovo DriverPacks downloads

.DESCRIPTION
Returns the Lenovo DriverPacks downloads

.PARAMETER Compatible
Filters results based on your current Product

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-LenovoDriverPackCatalog {
    [CmdletBinding()]
    param (
		[switch]$Compatible,
        [System.String]$DownloadPath
    )
    #=================================================
    #   Paths
    #=================================================
	$CatalogState           = 'Online'
	$CatalogUri      		= 'https://download.lenovo.com/cdrt/td/catalogv2.xml'
	$CatalogFileRaw			= Join-Path $env:TEMP (Join-Path 'OSD' 'catalogv2.xml')
	$CatalogFileBuild		= Join-Path $env:TEMP (Join-Path 'OSD' 'CatalogLenovoDriverPack.xml')
	$CatalogFileLocal		= "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\Lenovo\catalogv2.xml"
	if (-not(Test-Path (Join-Path $env:TEMP 'OSD'))) {
		$null = New-Item -Path (Join-Path $env:TEMP 'OSD') -ItemType Directory -Force
	}
    #=================================================
    #   Test Local CatalogState
    #=================================================
    if (Test-Path $CatalogFileBuild)	 {
		Write-Verbose "Catalog already downloaded to $CatalogFileBuild"	

        $GetItemCatalogFileBuild = Get-Item $CatalogFileBuild

		#If the local is older than 12 hours, delete it
        if (((Get-Date) - $GetItemCatalogFileBuild.	LastWriteTime).TotalHours -gt 12) {
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
		try {
			$CatalogOnlineRaw = Invoke-RestMethod -Uri $CatalogUri -UseBasicParsing
			Write-Verbose "Catalog is Online at $CatalogUri"
			Write-Verbose "Saving Online Catalog to $CatalogFileRaw"		
			$CatalogOnlineContent = $CatalogOnlineRaw.Substring(3)
			$CatalogOnlineContent | Out-File -FilePath $CatalogFileRaw -Encoding utf8 -Force

			if (Test-Path $CatalogFileRaw) {
				Write-Verbose "Catalog saved to $CatalogFileRaw"
				$CatalogState = 'Build'
			}
			else {
				Write-Verbose "Catalog was NOT downloaded to $CatalogFileRaw"
				Write-Verbose "Using Offline Catalog at $CatalogFileLocal"
				$CatalogFileRaw = $CatalogFileLocal
				$CatalogState = 'Build'
			}
		}
		catch {
			Write-Verbose "Using Offline Catalog at $CatalogFileLocal"
			$CatalogFileRaw = $CatalogFileLocal
			$CatalogState = 'Build'
		}
	}
    #=================================================
    #   CatalogState Build
    #=================================================
	if ($CatalogState -eq 'Build') {
		Write-Verbose "Reading the System Catalog at $CatalogFileRaw"		
		[xml]$XmlCatalogContent = Get-Content -Path $CatalogFileRaw -Raw

		$ModelList = $XmlCatalogContent.ModelList.Model
		#=================================================
		#   Create Object 
		#=================================================
		$Results = foreach ($Model in $ModelList) {
			foreach ($Item in $Model.SCCM) {
	
				$ObjectProperties = [Ordered]@{
					CatalogVersion 	= Get-Date -Format yy.MM.dd
					Name			= $Model.name
					Product			= [array]$Model.Types.Type.split(',').Trim()
					FileName        = $Item.'#text' | Split-Path -Leaf
		
					OSVersion       = $Item.version
					DriverPackUrl   = $Item.'#text'
				}
				New-Object -TypeName PSObject -Property $ObjectProperties
			}
		}
		$Results = $Results | Sort-Object Name, OSVersion -Descending | Group-Object Name | ForEach-Object {$_.Group | Select-Object -First 1}
		$Results = $Results | Sort-Object Name, OSVersion -Descending | Select-Object CatalogVersion, Name, Product, DriverPackUrl, FileName
	
		Write-Verbose "Exporting Offline Catalog to $CatalogFileBuild"	
		$Results | Export-Clixml -Path $CatalogFileBuild
		}
    #=================================================
    #   CatalogState Local
    #=================================================
	if ($CatalogState -eq 'Local') {
		Write-Verbose "Reading the Local System Catalog at $CatalogFileBuild"	
		$Results = Import-Clixml -Path $CatalogFileBuild
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
    #   Component
    #=================================================
    $Results | Sort-Object -Property Name
    #=================================================
}