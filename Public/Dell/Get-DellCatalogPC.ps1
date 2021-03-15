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
Get-DellCatalogPC
Don't do this, you will get an almost endless list

.EXAMPLE
$DellCatalogPC = Get-DellCatalogPC
Yes do this.  Save it in a Variable

.EXAMPLE
Get-DellCatalogPC -Component BIOS | Out-GridView
Displays all the Dell BIOS Updates in GridView

.LINK
https://osd.osdeploy.com/module/functions/dell/get-dellcatalogpc

.LINK
http://downloads.dell.com/catalog/CatalogPC.cab

.NOTES
21.3.4     Initial Release
#>
function Get-DellCatalogPC {
    [CmdletBinding()]
    param (
        [ValidateSet('Application','BIOS','Driver','Firmware')]
        [string]$Component,
		[switch]$Compatible
    )
    $VerbosePreference = "Continue"
    #===================================================================================================
    #   Compatibility
    #===================================================================================================
    $SystemSKU = $((Get-WmiObject -Class Win32_ComputerSystem).SystemSKUNumber).Trim()
	$BIOSVersion = $((Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion).Trim()
    #===================================================================================================
    #   Variables
    #===================================================================================================
    $DellDownloadsUrl 			= "http://downloads.dell.com/"
	$CatalogPcUrl	        	= "http://downloads.dell.com/catalog/CatalogPC.cab"

    $DownloadPath               = $env:TEMP
	$OfflineCatalogPcFullName  	= Join-Path $env:TEMP "Get-DellCatalogPC.xml"
	$CatalogPcCabName 			= [string]($CatalogPcUrl | Split-Path -Leaf)
    $CatalogPcCabFullName       = Join-Path $DownloadPath $CatalogPcCabName
	$CatalogPcXmlName       	= "CatalogPC.xml"
    $CatalogPCXmlFullName   	= Join-Path $DownloadPath $CatalogPcXmlName
    #===================================================================================================
    #   Offline Catalog
    #===================================================================================================
    if (Test-Path $OfflineCatalogPcFullName) {
        $ExistingFile = Get-Item $OfflineCatalogPcFullName

        if (((Get-Date) - $ExistingFile.CreationTime).TotalDays -gt 1) {
            Write-Verbose "Removing previous Offline Catalog"
            Remove-Item -Path $OfflineCatalogPcFullName -Force -ErrorAction SilentlyContinue
        }
    }

	if (Test-Path $OfflineCatalogPcFullName) {
		Write-Verbose "Importing Offline Catalog at $OfflineCatalogPcFullName"
		$DellCatalogPc = Import-Clixml -Path $OfflineCatalogPcFullName
	} else {
		if (Test-Path $CatalogPcCabFullName) {
			$ExistingFile = Get-Item $CatalogPcCabFullName
	
			if (((Get-Date) - $ExistingFile.CreationTime).TotalDays -gt 1) {
				Write-Verbose "Removing previously downloaded $CatalogPcCabName"
				Remove-Item -Path $CatalogPcCabFullName -Force -ErrorAction SilentlyContinue
			}
		}
	
		if (-NOT (Test-Path $CatalogPcCabFullName)) {
			Write-Verbose "Downloading the Dell Update Catalog from $CatalogPcUrl"
			Write-Verbose "Saving to $CatalogPcCabFullName"
			(New-Object System.Net.WebClient).DownloadFile($CatalogPcUrl, "$CatalogPcCabFullName")
		}
	
		if (-NOT (Test-Path $CatalogPcCabFullName)) {
			Write-Warning "Could not download the Dell CatalogPC.cab"
			Break
		}
	
		Write-Verbose "Expanding the Dell Update Catalog"
		Expand "$CatalogPcCabFullName" "$CatalogPCXmlFullName" | Out-Null
	
		if (-NOT (Test-Path $CatalogPCXmlFullName)) {
			Write-Warning "Could not expand the Dell CatalogPC.xml"
			Break
		}
	
		Write-Verbose "Reading the Dell Update Catalog at $CatalogPCXmlFullName"
		[xml]$XMLCatalogPcUrl = Get-Content "$CatalogPCXmlFullName" -ErrorAction Stop
		Write-Verbose "Loading the Dell Update XML Nodes"
		$DellCatalogPc = $XMLCatalogPcUrl.Manifest.SoftwareComponent
	
		$DellCatalogPc = $DellCatalogPc | `
		Select-Object @{Label="Component";Expression={($_.ComponentType.Display.'#cdata-section'.Trim())};},
		@{Label="ReleaseDate";Expression = {[datetime] ($_.dateTime)};},
		@{Label="Name";Expression={($_.Name.Display.'#cdata-section'.Trim())};},
		#@{Label="Description";Expression={($_.Description.Display.'#cdata-section'.Trim())};},
		@{Label="DellVersion";Expression={$_.dellVersion};},
		@{Label="Url";Expression={-join ($DellDownloadsUrl, $_.path)};},
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
	
		Write-Verbose "Exporting Offline Catalog to $OfflineCatalogPcFullName"
		$DellCatalogPc = $DellCatalogPc | Sort-Object ReleaseDate -Descending
		$DellCatalogPc | Export-Clixml -Path $OfflineCatalogPcFullName
	}
    #===================================================================================================
    #   Filter Compatible
    #===================================================================================================
	if ($Compatible) {
		Write-Verbose "Filtering XML for items compatible with SystemSKU $SystemSKU"
		$DellCatalogPc = $DellCatalogPc | Where-Object {$_.SupportedSystemID -contains $SystemSKU}
	}
    #===================================================================================================
    #   Filter Component
    #===================================================================================================
	if ($Component) {
		Write-Verbose "Filtering XML for $Component"
		$DellCatalogPc = $DellCatalogPc | Where-Object {$_.Component -eq $Component}
	}
    Return $DellCatalogPc | Sort-Object -Property ReleaseDate -Descending
}