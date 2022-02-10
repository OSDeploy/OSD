<#
.SYNOPSIS
Converts the HP Client Catalog for Microsoft System Center Product to a PowerShell Object

.DESCRIPTION
Converts the HP Client Catalog for Microsoft System Center Product to a PowerShell Object
Requires Internet Access to download HpCatalogForSms.latest.cab

.PARAMETER Component
Filter the results based on these Components:
Software
Driver
Firmware
Accessories Firmware and Driver
BIOS

.PARAMETER Compatible
If you have a HP System, this will filter the results based on your
ComputerSystem Product (Win32_BaseBoard Product)

.EXAMPLE
Get-HPSystemCatalog
Don't do this, you will get an almost endless list

.EXAMPLE
$Result = Get-HPSystemCatalog
Yes do this.  Save it in a Variable

.EXAMPLE
Get-HPSystemCatalog -Component BIOS | Out-GridView
Displays all the HP BIOS updates in GridView

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-HPSystemCatalog {
    [CmdletBinding()]
    param (
        [ValidateSet('Software','Firmware','Driver','Accessories Firmware and Driver','BIOS')]
        [string]$Component,
		[switch]$Compatible
    )
    #=================================================
    #   Paths
    #=================================================
	$UseCatalog           = 'Cloud' #Cloud, Build, Local, Offline
	$CloudCatalogUri      = 'https://hpia.hpcloud.hp.com/downloads/sccmcatalog/HpCatalogForSms.latest.cab'
	$CatalogBuildFolder     = $env:TEMP
	$BuildCatalogFileName   = 'HpCatalogForSms.xml'
	$RawCatalogFile       = Join-Path $CatalogBuildFolder $BuildCatalogFileName
	$BuildCatalogFile  		= Join-Path $env:TEMP 'CatalogHPSystem.xml'
	$OfflineCatalogFile     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Files\Catalogs\CatalogHPSystem.xml"
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
			Expand "$RawCatalogCabPath" -F:"$($BuildCatalogFileName)" "$CatalogBuildFolder" | Out-Null

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
		Write-Verbose "Getting the HP Platform List catalog to map System Id to model names."
		$PlatformCatalogHashTable = @{}
		Get-HPPlatformListCatalog | ForEach-Object{
			$PlatformCatalogHashTable.Add($_.SystemId,$_.SupportedModel)
		}
		
		
		Write-Verbose "Reading the System Catalog at $RawCatalogFile"
		[xml]$XmlCatalogContent = Get-Content $RawCatalogFile -ErrorAction Stop
		$CatalogVersion = Get-Item $RawCatalogFile | Select-Object -ExpandProperty LastWriteTimeUtc | Get-Date -Format yy.MM.dd
		$Packages = $XmlCatalogContent.SystemsManagementCatalog.SoftwareDistributionPackage

		Write-Verbose "Building the System Catalog"
		$Packages = $Packages | Where-Object{$_.Properties.PublicationState -ne 'Expired'}
		
		#Only Windows 10 applicable packages
		$Packages = $Packages | Where-Object{$_.IsInstallable.And.Or.And.WindowsVersion.MajorVersion -contains '10'}
		
		$Result = Foreach($Item in $Packages){
			#SystemId
			$SystemIdMatchInfo = $Item.InstallableItem.ApplicabilityRules.IsInstallable.And.WmiQuery.wqlquery | Where-Object{$_ -like "*from Win32_BaseBoard*"} | Select-String -Pattern '%(.{4})%' -AllMatches
			$SupportedSystemId = [array]($SystemIdMatchinfo.Matches.Groups | Where-Object{$_.Name -eq 1} | Select-Object -ExpandProperty Value)
			
			#SupportedModel
			$SupportedModel = foreach($Id in $SupportedSystemId){
				$PlatformCatalogHashTable."$($Id)"
			}
        	$SupportedModel = $SupportedModel | Select-Object -Unique
			
			#Title
			$TitleMatchInfo = $Item.LocalizedProperties | Where-Object{$_.Language -eq 'en'} | Select-Object -ExpandProperty Title | Select-String -Pattern "^(.*) \[(.*)\]$"
        	If($TitleMatchInfo){#Remove the version in the title
            	$Title = $TitleMatchInfo.Matches.Groups[1].Value
        	}Else{#No version in title
            	$Title = $Item.LocalizedProperties | Where-Object{$_.Language -eq 'en'} | Select-Object -ExpandProperty Title
        	}
			
			#[Version] + Description
			#There's always a version in the description so far, let's hope HP stays consistent...
        	$DescriptionMatchInfo = $Item.LocalizedProperties | Where-Object{$_.Language -eq 'en'} | Select-Object -ExpandProperty Description | Select-String -Pattern "^\[(.*)\] (.*)$"
			
			$ObjectProperties = [Ordered]@{
				CatalogVersion 	     = $CatalogVersion
				Component            = $Item.Properties.ProductName
				CreationDate         = ($Item.Properties.CreationDate) | Get-Date -Format yy.MM.dd
				Title                = $Title
				Version              = ($DescriptionMatchInfo.Matches.Groups[1].Value).Trim('.')
				SupportedSystemId    = $SupportedSystemId
				SupportedModel       = $SupportedModel
				Description          = ($DescriptionMatchInfo.Matches.Groups[2].Value)
				SoftPaqId            = $Item.UpdateSpecificData.KBArticleID
				Program              = $Item.InstallableItem.CommandLineInstallerData.Program
				ProgramArguments     = $Item.InstallableItem.CommandLineInstallerData.Arguments
				ProgramDownloadUrl   = $Item.InstallableItem.OriginFile.OriginUri
				MoreInfoUrl          = $Item.Properties.MoreInfoUrl
			}
			New-Object -TypeName PSObject -Property $ObjectProperties
		}
		
	
		Write-Verbose "Exporting Offline Catalog to $BuildCatalogFile"
		$Result = $Result | Sort-Object CreationDate -Descending
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
		$Result = $Result | Where-Object {$_.SupportedSystemID -contains $MyComputerProduct}
	}
    #=================================================
    #   Component
    #=================================================
	if ($PSBoundParameters.ContainsKey('Component')) {
		Write-Verbose "Filtering XML for $Component"
		switch($Component){
			'BIOS'{
				$Result = $Result | Where-Object{$_.Component -eq 'Firmware' -and $_.Description -like "*NOTE: THIS BIOS UPDATE*"}
			}
			'Firmware'{
				$Result = $Result | Where-Object{$_.Component -eq 'Firmware' -and $_.Description -notlike "*NOTE: THIS BIOS UPDATE*"}
			}
			default{
				$Result = $Result | Where-Object {$_.Component -eq $Component}
			}
		}
	}
    #=================================================
    #   Component
    #=================================================
    $Result | Sort-Object -Property CreationDate -Descending
    #=================================================
}