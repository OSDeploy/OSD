<#
.SYNOPSIS
Converts the HP Platform list to a PowerShell Object. Useful to get the computer model name for System Ids

.DESCRIPTION
Converts the HP Platform list to a PowerShell Object. Useful to get the computer model name for System Ids
Requires Internet Access to download platformList.cab


.EXAMPLE
Get-CatalogHPPlatformList
Don't do this, you will get a big list.

.EXAMPLE
$Result = Get-CatalogHPPlatformList
Yes do this.  Save it in a Variable

.EXAMPLE
Get-CatalogHPPlatformList | Out-GridView
Displays all the HP System Ids with the applicable computer model names in GridView

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-CatalogHPPlatformList {
    [CmdletBinding()]
    
    #=================================================
    #   Paths
    #=================================================
	$CatalogState           = 'Online' #Online, Build, Local, Offline
	$CatalogOnlinePath      = 'https://ftp.hp.com/pub/caps-softpaq/cmit/imagepal/ref/platformList.cab'
	$CatalogBuildPath       = Join-Path $env:TEMP 'platformList.xml'
	$CatalogLocalPath  		= Join-Path $env:TEMP 'CatalogHPPlatformList.xml'
	$CatalogOfflinePath     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Files\Catalogs\CatalogHPPlatformList.xml"
	$CatalogLocalCabName  	= [string]($CatalogOnlinePath | Split-Path -Leaf)
    $CatalogLocalCabPath 	= Join-Path $env:TEMP $CatalogLocalCabName
    #=================================================
    #   Test CatalogState Local
    #=================================================
    if (Test-Path $CatalogLocalPath) {

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
			#Catalog is online and can be downloaded
		}
		else {
			$CatalogState = 'Offline'
		}
	}
    #=================================================
    #   CatalogState Online
	#	Need to get the Online Catalog to Local
    #=================================================
	if ($CatalogState -eq 'Online') {
		Write-Verbose "Source: $CatalogOnlinePath"
		Write-Verbose "Destination: $CatalogLocalCabPath"
		(New-Object System.Net.WebClient).DownloadFile($CatalogOnlinePath, $CatalogLocalCabPath)

		#Make sure the file downloaded
		if (Test-Path $CatalogLocalCabPath) {
			Write-Verbose "Expand: $CatalogLocalCabPath"
			Expand "$CatalogLocalCabPath" "$CatalogBuildPath" | Out-Null

			if (Test-Path $CatalogBuildPath) {
				$CatalogState = 'Build'
			}
			else {
				Write-Verbose "Could not expand $CatalogLocalCabPath"
				$CatalogState = 'Offline'
			}
		}
		else {
			$CatalogState = 'Offline'
		}
	}
    #=================================================
    #   CatalogState Build
    #=================================================
	if ($CatalogState -eq 'Build') {
		Write-Verbose "Reading the System Catalog at $CatalogBuildPath"
		[xml]$XmlCatalogContent = Get-Content $CatalogBuildPath -ErrorAction Stop
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
		
	
		Write-Verbose "Exporting Offline Catalog to $CatalogLocalPath"
		$Result = $Result | Sort-Object -Property SystemId
		$Result | Export-Clixml -Path $CatalogLocalPath
	}
    #=================================================
    #   CatalogState Local
    #=================================================
	if ($CatalogState -eq 'Local') {
		Write-Verbose "Reading the Local System Catalog at $CatalogLocalPath"
		$Result = Import-Clixml -Path $CatalogLocalPath
	}
    #=================================================
    #   CatalogState Offline
    #=================================================
	if ($CatalogState -eq 'Offline') {
		Write-Verbose "Reading the Offline System Catalog at $CatalogOfflinePath"
		$Result = Import-Clixml -Path $CatalogOfflinePath
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