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
Get-CatalogHPSystem
Don't do this, you will get an almost endless list

.EXAMPLE
$Result = Get-CatalogHPSystem
Yes do this.  Save it in a Variable

.EXAMPLE
Get-CatalogHPSystem -Component BIOS | Out-GridView
Displays all the HP BIOS updates in GridView

.LINK
https://osd.osdeploy.com/module/functions

.NOTES
#>
function Get-CatalogHPSystem {
    [CmdletBinding()]
    param (
        [ValidateSet('Software','Firmware','Driver','Accessories Firmware and Driver','BIOS')]
        [string]$Component,
		[switch]$Compatible
    )
    #=================================================
    #   Paths
    #=================================================
	$CatalogState           = 'Online' #Online, Build, Local, Offline
	$CatalogOnlinePath      = 'https://hpia.hpcloud.hp.com/downloads/sccmcatalog/HpCatalogForSms.latest.cab'
	$CatalogBuildFolder     = $env:TEMP
	$CatalogBuildFileName   = 'HpCatalogForSms.xml'
	$CatalogBuildPath       = Join-Path $CatalogBuildFolder $CatalogBuildFileName
	$CatalogLocalPath  		= Join-Path $env:TEMP 'CatalogHPSystem.xml'
	$CatalogOfflinePath     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Files\Catalogs\CatalogHPSystem.xml"
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
			Expand "$CatalogLocalCabPath" -F:"$($CatalogBuildFileName)" "$CatalogBuildFolder" | Out-Null

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
		Write-Verbose "Getting the HP Platform List catalog to map System Id to model names."
		$PlatformCatalogHashTable = @{}
		Get-CatalogHPPlatformList | ForEach-Object{
			$PlatformCatalogHashTable.Add($_.SystemId,$_.SupportedModel)
		}
		
		
		Write-Verbose "Reading the System Catalog at $CatalogBuildPath"
		[xml]$XmlCatalogContent = Get-Content $CatalogBuildPath -ErrorAction Stop
		$CatalogVersion = Get-Item $CatalogBuildPath | Select-Object -ExpandProperty LastWriteTimeUtc | Get-Date -Format yy.MM.dd
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
		
	
		Write-Verbose "Exporting Offline Catalog to $CatalogLocalPath"
		$Result = $Result | Sort-Object CreationDate -Descending
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