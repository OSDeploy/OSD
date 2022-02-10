<#
.SYNOPSIS
Converts the Dell Catalog PC to a PowerShell Object

.DESCRIPTION
Converts the Dell Catalog PC to a PowerShell Object
Requires Internet Access to download Dell CatalogPC.cab

.PARAMETER Component
Filter the results based on these Components:
Application
BIOS
Driver
Firmware

.PARAMETER Compatible
If you have a Dell System, this will filter the results based on your
ComputerSystem SystemSKUNumber

.EXAMPLE
Get-CatalogDellSystem
Don't do this, you will get an almost endless list

.EXAMPLE
$Result = Get-CatalogDellSystem
Yes do this.  Save it in a Variable

.EXAMPLE
Get-CatalogDellSystem -Component BIOS | Out-GridView
Displays all the Dell BIOS Updates in GridView

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-CatalogDellSystem {
    [CmdletBinding()]
    param (
        [ValidateSet('Application','BIOS','Driver','Firmware')]
        [System.String]$Component,
		[switch]$Compatible
    )
    #=================================================
    #   Paths
    #=================================================
	$CatalogState           = 'Online'
    $DownloadsBaseUrl       = 'http://downloads.dell.com/'
	$CatalogUri      		= 'http://downloads.dell.com/catalog/CatalogPC.cab'
	$CatalogFileRaw			= Join-Path $env:TEMP (Join-Path 'OSD' 'CatalogPC.xml')
	$CatalogFileBuild		= Join-Path $env:TEMP (Join-Path 'OSD' 'CatalogDellSystem.xml')
	$CatalogFileLocal     	= "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\Dell\CatalogPC.xml"
	$CatalogLocalCabName  	= [string]($CatalogUri | Split-Path -Leaf)
    $CatalogLocalCabPath 	= Join-Path $env:TEMP (Join-Path 'OSD' $CatalogLocalCabName)
    #=================================================
    #   Create Paths
    #=================================================
	if (-not(Test-Path (Join-Path $env:TEMP 'OSD'))) {
		$null = New-Item -Path (Join-Path $env:TEMP 'OSD') -ItemType Directory -Force
	}
    #=================================================
    #   Test Local CatalogState
    #=================================================
    if (Test-Path $CatalogFileBuild) {
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
		if (Test-WebConnection -Uri $CatalogUri) {
			#Catalog is online and can be downloaded
		}
		else {
			$CatalogFileRaw = $CatalogFileLocal
			$CatalogState = 'Build'
		}
	}
    #=================================================
    #   CatalogState Online
	#	Need to get the Online Catalog to Local
    #=================================================
	if ($CatalogState -eq 'Online') {
		Write-Verbose "Source: $CatalogUri"
		Write-Verbose "Destination: $CatalogLocalCabPath"
		(New-Object System.Net.WebClient).DownloadFile($CatalogUri, $CatalogLocalCabPath)

		if (Test-Path $CatalogLocalCabPath) {
			Write-Verbose "Expand: $CatalogLocalCabPath"
			Expand "$CatalogLocalCabPath" "$CatalogFileRaw" | Out-Null

			if (Test-Path $CatalogFileRaw) {
				Write-Verbose "Catalog saved to $CatalogFileRaw"
				$CatalogState = 'Build'
			}
			else {
				Write-Verbose "Could not expand $CatalogLocalCabPath"
				Write-Verbose "Using Offline Catalog at $CatalogFileLocal"
				$CatalogFileRaw = $CatalogFileLocal
				$CatalogState = 'Build'
			}
		}
		else {
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
		[xml]$XmlCatalogContent = Get-Content $CatalogFileRaw -ErrorAction Stop
		$CatalogVersion = $XmlCatalogContent.Manifest.version
		$Result = $XmlCatalogContent.Manifest.SoftwareComponent

		Write-Verbose "Building the System Catalog"

		$Result = $Result | Select-Object @{Label="CatalogVersion";Expression={$CatalogVersion};},
		@{Label="Component";Expression={($_.ComponentType.Display.'#cdata-section'.Trim())};},
		@{Label="ReleaseDate";Expression = {[datetime] ($_.dateTime)};},
		@{Label="Name";Expression={($_.Name.Display.'#cdata-section'.Trim())};},
		#@{Label="Description";Expression={($_.Description.Display.'#cdata-section'.Trim())};},
		@{Label="DellVersion";Expression={$_.dellVersion};},
		@{Label="Url";Expression={-join ($DownloadsBaseUrl, $_.path)};},
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
	
		Write-Verbose "Exporting Offline Catalog to $CatalogFileBuild"
		$Result = $Result | Sort-Object ReleaseDate -Descending
		$Result | Export-Clixml -Path $CatalogFileBuild
	}
    #=================================================
    #   CatalogState Local
    #=================================================
	if ($CatalogState -eq 'Local') {
		Write-Verbose "Reading the Local System Catalog at $CatalogFileBuild"
		$Result = Import-Clixml -Path $CatalogFileBuild
	}
    #=================================================
    #   CatalogState Offline
    #=================================================
	if ($CatalogState -eq 'Offline') {
		Write-Verbose "Reading the Offline System Catalog at $CatalogFileLocal"
		$Result = Import-Clixml -Path $CatalogFileLocal
	}
    #=================================================
    #   Compatible
    #=================================================
	if ($PSBoundParameters.ContainsKey('Compatible')) {
		$MyComputerProduct = Get-MyComputerProduct
		Write-Verbose "Filtering XML for items compatible with Product $MyComputerProduct"
		$Result = $Result | Where-Object {$_.SupportedSystemID -contains $MyComputerProduct}
	}
    #=================================================
    #   Component
    #=================================================
	if ($PSBoundParameters.ContainsKey('Component')) {
		Write-Verbose "Filtering XML for $Component"
		$Result = $Result | Where-Object {$_.Component -eq $Component}
	}
    #=================================================
    #   Component
    #=================================================
    $Result | Sort-Object -Property ReleaseDate -Descending
    #=================================================
}