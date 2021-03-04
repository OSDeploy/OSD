function Get-DellCatalogPC {
    [CmdletBinding()]
    param (
        [ValidateSet('Application','BIOS','Driver','Firmware')]
        [string]$Component,
		[switch]$Compatible
    )
    #===================================================================================================
    #   Compatibility
    #===================================================================================================
    $SystemSKU = $((Get-WmiObject -Class Win32_ComputerSystem).SystemSKUNumber).Trim()
	$BIOSVersion = $((Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion).Trim()

    $VerbosePreference = "Continue"

    $DownloadPath               = "$env:TEMP\OSD"
	$DellCatalogPCUrl	        = "http://downloads.dell.com/catalog/CatalogPC.cab"
	$DellCatalogPCFileName      = [string]($DellCatalogPCUrl | Split-Path -Leaf)
	$DellCatalogPCXmlName       = "CatalogPC.xml"
    $DownloadFileFullName       = Join-Path $DownloadPath $DellCatalogPCFileName
    $DellCatalogPCXmlFullName   = Join-Path $DownloadPath $DellCatalogPCXmlName
    $DellDownloadsURLBase 		= "http://downloads.dell.com/"

	$OfflineCatalog				= "$env:TEMP\Get-DellCatalogPC.xml"

	if (-NOT (Test-Path $DownloadPath)) {
		New-Item -Path $DownloadPath -ItemType Directory -Force | Out-Null
	}

    if (Test-Path $OfflineCatalog) {
        $ExistingFile = Get-Item $OfflineCatalog

        if (((Get-Date) - $ExistingFile.CreationTime).TotalDays -gt 1) {
            Write-Verbose "Removing previous Offline Catalog"
            Remove-Item -Path $OfflineCatalog -Force -ErrorAction SilentlyContinue
        }
    }

	if (Test-Path $OfflineCatalog) {
		Write-Verbose "Importing Offline Catalog at $OfflineCatalog"
		$DellUpdateList = Import-Clixml -Path $OfflineCatalog
	} else {
		if (Test-Path $DownloadFileFullName) {
			$ExistingFile = Get-Item $DownloadFileFullName
	
			if (((Get-Date) - $ExistingFile.CreationTime).TotalDays -gt 1) {
				Write-Verbose "Removing previously downloaded $DellCatalogPCFileName"
				Remove-Item -Path $DownloadFileFullName -Force -ErrorAction SilentlyContinue
			}
		}
	
		if (-NOT (Test-Path $DownloadFileFullName)) {
			Write-Verbose "Downloading the Dell Update Catalog from $DellCatalogPCUrl"
			Write-Verbose "Saving to $DownloadFileFullName"
			(New-Object System.Net.WebClient).DownloadFile($DellCatalogPCUrl, "$DownloadFileFullName")
		}
	
		if (-NOT (Test-Path $DownloadFileFullName)) {
			Write-Warning "Could not download the Dell CatalogPC.cab"
			Break
		}
	
		Write-Verbose "Expanding the Dell Update Catalog"
		Expand "$DownloadFileFullName" "$DellCatalogPCXmlFullName" | Out-Null
	
		if (-NOT (Test-Path $DellCatalogPCXmlFullName)) {
			Write-Warning "Could not expand the Dell $DellCatalogPCXmlName"
			Break
		}
	
		Write-Verbose "Reading the Dell Update Catalog at $DellCatalogPCXmlFullName"
		[xml]$XMLDellCatalogPCUrl = Get-Content "$DellCatalogPCXmlFullName" -ErrorAction Stop
		Write-Verbose "Loading the Dell Update XML Nodes"
		$DellUpdateList = $XMLDellCatalogPCUrl.Manifest.SoftwareComponent
	
		$DellUpdateList = $DellUpdateList | `
		Select-Object @{Label="Component";Expression={($_.ComponentType.Display.'#cdata-section'.Trim())};},
		@{Label="ReleaseDate";Expression = {[datetime] ($_.dateTime)};},
		@{Label="Name";Expression={($_.Name.Display.'#cdata-section'.Trim())};},
		#@{Label="Description";Expression={($_.Description.Display.'#cdata-section'.Trim())};},
		@{Label="DellVersion";Expression={$_.dellVersion};},
		@{Label="Url";Expression={-join ($DellDownloadsURLBase, $_.path)};},
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
	
		Write-Verbose "Exporting Offline Catalog to $OfflineCatalog"
		$DellUpdateList = $DellUpdateList | Sort-Object ReleaseDate -Descending
		$DellUpdateList | Export-Clixml -Path $OfflineCatalog
	}
    #===================================================================================================
    #   Compatible
    #===================================================================================================
	if ($Compatible) {
		Write-Verbose "Filtering XML for items compatible with SystemSKU $SystemSKU"
		$DellUpdateList = $DellUpdateList | Where-Object {$_.SupportedSystemID -contains $SystemSKU}
	}
    #===================================================================================================
    #   Component
    #===================================================================================================
	if ($Component) {
		Write-Verbose "Filtering XML for $Component"
		$DellUpdateList = $DellUpdateList | Where-Object {$_.Component -eq $Component}
	}
    Return $DellUpdateList | Sort-Object -Property ReleaseDate -Descending
}