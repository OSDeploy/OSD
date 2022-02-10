class CloudDriverPack {
    [string] $CatalogVersion = $(Get-Module -Name OSD | Sort-Object Version | Select-Object Version -Last 1).Version
    [string] $Class = 'CloudDriverPack'
    [datetime] $ReleaseDate = (Get-Date)
    [string] $Name
    [string] $Manufacturer
    [string[]] $Model
    [string[]] $SystemFamily
    [string[]] $SystemId
    [string[]] $SystemProduct
    [string] $FileVersion
    [string] $FileName
    [string] $SizeMB
    [string] $Hash
    [string] $Download
    [string] $About
    [string] $Expand
    [ValidateSet('WindowsXP','WindowsVista','Windows7','Windows8','Windows10','Windows11')]
    [string[]] $osName = 'Windows10'
    [ValidateSet('x64','x86')]
    [string[]] $osArch = 'x64'
}

function New-CloudDriverPack {
    [CmdletBinding()]
    [OutputType([CloudDriverPack])]
    param (
        [string]$Name,
        [ValidateSet('Windows7','Windows8','Windows10','Windows11')]
        [string[]] $osName = 'Windows10',
        [ValidateSet('x64','x86')]
        [string[]] $osArch = 'x64',
        [ValidateSet('6.1','6.3','10.0')]
        [string[]] $osVersion = '10.0'
    )

    [CloudDriverPack]@{
        Name        = $Name
        osName      = $osName
        osArch      = $osArch
        osVersion   = $osVersion
    }
}

function Get-CloudDriverPackDell {
    [CmdletBinding()]
    [OutputType([CloudDriverPack])]
    param (
		[switch]$Compatible
    )
    #=================================================
    #   Paths
    #=================================================
	$CatalogState           = 'Online' #Online, Build, Local, Offline
    $DownloadsBaseUrl       = 'http://downloads.dell.com/'
	$CatalogOnlinePath      = 'https://downloads.dell.com/catalog/DriverPackCatalog.cab'
	$CatalogBuildPath       = Join-Path $env:TEMP 'CatalogPC.xml'
	$CatalogLocalPath  		= Join-Path $env:TEMP 'DellDriverPackCatalog.xml'
	$CatalogOfflinePath     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\DellDriverPackCatalog.xml"
	$CatalogLocalCabName  	= [string]($CatalogOnlinePath | Split-Path -Leaf)
    $CatalogLocalCabPath 	= Join-Path $env:TEMP $CatalogLocalCabName
    #=================================================
    #   Test CatalogState Local
    #=================================================
    if (Test-Path $CatalogLocalPath) {

		#Get-Item to determine the age
        $GetItemCatalogLocalPath = Get-Item $CatalogLocalPath

		#If the local is older than 12 hours, delete it
<#         if (((Get-Date) - $GetItemCatalogLocalPath.LastWriteTime).TotalHours -gt 12) {
            Write-Verbose "Removing previous Offline Catalog"
        }
        else {
            $CatalogState = 'Local'
        } #>
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
		$CatalogVersion = $XmlCatalogContent.DriverPackManifest.version
		$Results = $XmlCatalogContent.DriverPackManifest.DriverPackage

		Write-Verbose -Verbose "Building the System Catalog"

		$Results = $Results | Select-Object @{Label="CatalogVersion";Expression={$CatalogVersion};},
		@{Label="Component";Expression={"DriverPack"};},
		@{Label="ReleaseDate";Expression = {[datetime] ($_.dateTime)};},
		@{Label="Name";Expression={($_.Name.Display.'#cdata-section'.Trim())};},
		#@{Label="Description";Expression={($_.Description.Display.'#cdata-section'.Trim())};},
		@{Label="DellVersion";Expression={$_.dellVersion};},
		@{Label="Url";Expression={-join ($DownloadsBaseUrl, $_.path)};},
		@{Label="VendorVersion";Expression={$_.vendorVersion};},
		#@{Label="Criticality";Expression={($_.Criticality.Display.'#cdata-section'.Trim())};},
		@{Label="FileName";Expression = {(split-path -leaf $_.path)};},
		@{Label="SizeMB";Expression={'{0:f2}' -f ($_.size/1MB)};},
		#@{Label="PackageID";Expression={$_.packageID};},
		#@{Label="PackageType";Expression={$_.packageType};},
		@{Label="ReleaseID";Expression={$_.ReleaseID};},
		#@{Label="Category";Expression={($_.Category.Display.'#cdata-section'.Trim())};},
		#@{Label="SupportedDevices";Expression={($_.SupportedDevices.Device.Display.'#cdata-section'.Trim())};},
		@{Label="SupportedBrand";Expression={($_.SupportedSystems.Brand.Display.'#cdata-section'.Trim())};},
		@{Label="SupportedModel";Expression={($_.SupportedSystems.Brand.Model.Display.'#cdata-section'.Trim())};},
		@{Label="SupportedSystemID";Expression={($_.SupportedSystems.Brand.Model.systemID)};},
		@{Label="SupportedOperatingSystems";Expression={($_.SupportedOperatingSystems.OperatingSystem.Display.'#cdata-section'.Trim())};},
		@{Label="SupportedArchitecture";Expression={($_.SupportedOperatingSystems.OperatingSystem.osArch)};},
		@{Label="HashMD5";Expression={$_.HashMD5};}
	
		Write-Verbose "Exporting Offline Catalog to $CatalogLocalPath"
		$Results = $Results | Sort-Object ReleaseDate -Descending
		$Results | Export-Clixml -Path $CatalogLocalPath

        foreach ($Item in $Results) {
            $Item.SupportedModel = $Item.SupportedModel | Get-Unique -AsString
            $Item.SupportedBrand = $Item.SupportedBrand | Get-Unique -AsString

            $Item.SupportedBrand = $Item.SupportedBrand -replace 'LATITUDE','Latitude'
            $Item.SupportedBrand = $Item.SupportedBrand -replace 'PRECISION','Precision'

            $Item.SupportedModel = $Item.SupportedModel -replace 'LATITUDE','Latitude'
            $Item.SupportedModel = $Item.SupportedModel -replace 'PRECISION','Precision'
            $Item.SupportedModel = $Item.SupportedModel -replace 'TOWER','Tower'



            if ($Item.SupportedModel -notmatch $Item.SupportedBrand) {
                $Item.SupportedModel = "$($Item.SupportedBrand) $($Item.SupportedModel)"
                $Item.SupportedModel = $Item.SupportedModel -replace 'Internet of Things Dell ',''
                $Item.SupportedModel = $Item.SupportedModel -replace '9310 2in1 9310 2n1','9310 2in1'
            }
            if ($Item.SupportedOperatingSystems -match 'Windows XP') {$Item.SupportedOperatingSystems = 'WindowsXP'}
            if ($Item.SupportedOperatingSystems -match 'Vista') {$Item.SupportedOperatingSystems = 'WindowsVista'}
            if ($Item.SupportedOperatingSystems -match 'Windows 7') {$Item.SupportedOperatingSystems = 'Windows7'}
            if ($Item.SupportedOperatingSystems -match 'Windows 8') {$Item.SupportedOperatingSystems = 'Windows8'}
            if ($Item.SupportedOperatingSystems -match 'Windows 10') {$Item.SupportedOperatingSystems = 'Windows10'}
            if ($Item.SupportedOperatingSystems -match 'Windows 11') {$Item.SupportedOperatingSystems = 'Windows11'}
        }

        $DellCloudDriverPacks = foreach ($Item in $Results) {
            if ($Item.Name -match 'WinPE') {Continue}

            $ObjectProperties = @{
                ReleaseDate     = $Item.ReleaseDate
                Name            = $Item.Name
                Manufacturer    = 'Dell'
                Model           = @($Item.SupportedModel)
                SystemFamily    = $Item.SupportedBrand
                SystemId        = $Item.SupportedSystemID
                SystemProduct   = $Item.Product
                FileVersion     = $Item.DellVersion
                FileName        = $Item.FileName
                SizeMB          = $Item.SizeMB
                Hash            = $Item.HashMD5
                Download        = $Item.Url
                About           = $Item.About
                Expand          = 'expand -R <SourceFullName> -F:* <DestinationFolder>'
                osName          = $Item.SupportedOperatingSystems
                osArch          = $Item.SupportedArchitecture
            }
            New-Object -TypeName CloudDriverPack -Property $ObjectProperties
        }
	}
    $DellCloudDriverPacks
    Break
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
		$Results = $Results | Where-Object {$_.SupportedSystemID -contains $MyComputerProduct}
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
    $Results | Sort-Object -Property ReleaseDate -Descending
    #=================================================
}