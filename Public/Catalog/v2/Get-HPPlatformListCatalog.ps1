<#
.SYNOPSIS
Converts the HP Platform list to a PowerShell Object. Useful to get the computer model name for System Ids

.DESCRIPTION
Converts the HP Platform list to a PowerShell Object. Useful to get the computer model name for System Ids
Requires Internet Access to download platformList.cab


.EXAMPLE
Get-HPPlatformListCatalog
Don't do this, you will get a big list.

.EXAMPLE
$Result = Get-HPPlatformListCatalog
Yes do this.  Save it in a Variable

.EXAMPLE
Get-HPPlatformListCatalog | Out-GridView
Displays all the HP System Ids with the applicable computer model names in GridView

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-HPPlatformListCatalog {
    [CmdletBinding()]
    
    #=================================================
    #   Paths
    #=================================================
	$UseCatalog           = 'Cloud' #Cloud, Build, Local, Offline
	$CloudCatalogUri      		= 'https://ftp.hp.com/pub/caps-softpaq/cmit/imagepal/ref/platformList.cab'
	$RawCatalogFile       = Join-Path $env:TEMP 'platformList.xml'
	$BuildCatalogFile  		= Join-Path $env:TEMP 'CatalogHPPlatformList.xml'
	$OfflineCatalogFile     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Files\Catalogs\CatalogHPPlatformList.xml"
	$RawCatalogCabName  	= [string]($CloudCatalogUri | Split-Path -Leaf)
    $RawCatalogCabPath 	= Join-Path $env:TEMP $RawCatalogCabName
    #=================================================
    #   Create Paths
    #=================================================
	if (-not(Test-Path (Join-Path $env:TEMP 'OSD'))) {
		$null = New-Item -Path (Join-Path $env:TEMP 'OSD') -ItemType Directory -Force
	}
    #=================================================
    #   Test UseCatalog Local
    #=================================================
    if (Test-Path $BuildCatalogFile) {

		#Get-Item to determine the age
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
		}
	}
    #=================================================
    #   UseCatalog Cloud
	#	Need to get the Cloud Catalog to Local
    #=================================================
	if ($UseCatalog -eq 'Cloud') {
		Write-Verbose "Source: $CloudCatalogUri"
		Write-Verbose "Destination: $RawCatalogCabPath"
		(New-Object System.Net.WebClient).DownloadFile($CloudCatalogUri, $RawCatalogCabPath)

		#Make sure the file downloaded
		if (Test-Path $RawCatalogCabPath) {
			Write-Verbose "Expand: $RawCatalogCabPath"
			Expand "$RawCatalogCabPath" "$RawCatalogFile" | Out-Null

			if (Test-Path $RawCatalogFile) {
				$UseCatalog = 'Build'
			}
			else {
				Write-Verbose "Could not expand $RawCatalogCabPath"
				$UseCatalog = 'Offline'
			}
		}
		else {
			$UseCatalog = 'Offline'
		}
	}
    #=================================================
    #   UseCatalog Build
    #=================================================
	if ($UseCatalog -eq 'Build') {
		Write-Verbose "Reading the System Catalog at $RawCatalogFile"
		[xml]$XmlCatalogContent = Get-Content $RawCatalogFile -ErrorAction Stop
		$CatalogVersion = $XmlCatalogContent.ImagePal.DateLastModified | Get-Date -Format yy.MM.dd
		$Platforms = $XmlCatalogContent.ImagePal.Platform

		Write-Verbose "Building the System Catalog"
		
		$Result = foreach($platform in $Platforms){             
			$ObjectProperties = [Ordered]@{
				CatalogVersion            = $CatalogVersion
				SystemId                  = $platform.SystemId
				SupportedModel            = [array]($platform.ProductName.'#text')
				#LatestWin10SupportedBuild = $platform.OS | Sort-Object -Property OSBuildId -Descending | Select-Object -First 1 -ExpandProperty OSReleaseIdDisplay
			}
			New-Object -TypeName PSObject -Property $ObjectProperties
		}
		
	
		Write-Verbose "Exporting Offline Catalog to $BuildCatalogFile"
		$Result = $Result | Sort-Object -Property SystemId
		$Result | Export-Clixml -Path $BuildCatalogFile
	}
    #=================================================
    #   UseCatalog Local
    #=================================================
	if ($UseCatalog -eq 'Local') {
		Write-Verbose "Reading the Local System Catalog at $BuildCatalogFile"
		$Result = Import-Clixml -Path $BuildCatalogFile
	}
    #=================================================
    #   UseCatalog Offline
    #=================================================
	if ($UseCatalog -eq 'Offline') {
		Write-Verbose "Reading the Offline System Catalog at $OfflineCatalogFile"
		$Result = Import-Clixml -Path $OfflineCatalogFile
	}
    #=================================================
    #   Compatible
    #=================================================
	if ($PSBoundParameters.ContainsKey('Compatible')) {
		$MyComputerProduct = Get-MyComputerProduct
		Write-Verbose "Filtering XML for items compatible with Product $MyComputerProduct"
		$Result = $Result | Where-Object {$_.SystemID -eq $MyComputerProduct}
	}
    #=================================================
    #   Component
    #=================================================
    $Result | Sort-Object -Property SystemId
    #=================================================
}