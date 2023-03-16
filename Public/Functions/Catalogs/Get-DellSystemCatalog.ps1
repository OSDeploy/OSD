<#
.SYNOPSIS
Builds the Dell System Catalog

.DESCRIPTION
Builds the Dell System Catalog

.EXAMPLE
Get-DellSystemCatalog
Don't do this, you will get an almost endless list

.EXAMPLE
$Result = Get-DellSystemCatalog
Yes do this.  Save it in a Variable

.EXAMPLE
Get-DellSystemCatalog -Component BIOS | Out-GridView
Displays all the Dell BIOS Updates in GridView

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-DellSystemCatalog {
    [CmdletBinding()]
    param (
        #Specifies a download path for matching results displayed in Out-GridView
        [System.String]
        $DownloadPath,

        #Limits the results to match the current system
        [System.Management.Automation.SwitchParameter]
        $Compatible,

        #Limits the results to a specified component
        [ValidateSet('Application','BIOS','Driver','Firmware')]
        [System.String]
        $Component,

        #Checks for the latest Online version
        [System.Management.Automation.SwitchParameter]
        $Online,

        #Updates the local catalog in the OSD Module
        [System.Management.Automation.SwitchParameter]
        $UpdateModuleCatalog
    )
    #=================================================
    #   Defaults
    #=================================================
    $UseCatalog = 'Offline'
    $OfflineCatalogName = 'DellSystemCatalog.xml'
    $OnlineCatalogName = 'CatalogPC.xml'
    $OnlineBaseUri = 'http://downloads.dell.com/'
    $OnlineCatalogUri = 'http://downloads.dell.com/catalog/CatalogPC.cab'
    #=================================================
    #   Initialize
    #=================================================
    $IsOnline = $false

    if ($UpdateModuleCatalog) {
        $Online = $true
    }
    if ($Online) {
        $UseCatalog = 'Cloud'
    }
    if ($Online) {
        $IsOnline = Test-WebConnection $OnlineCatalogUri
    }

    if ($IsOnline -eq $false) {
        $Online = $false
        $UpdateModuleCatalog = $false
        $UseCatalog = 'Offline'
    }
    Write-Verbose "$UseCatalog Catalog"
    #=================================================
    #   Additional Paths
    #=================================================
    $CatalogBuildFolder = Join-Path $env:TEMP 'OSD'
    if (-not(Test-Path $CatalogBuildFolder)) {
        $null = New-Item -Path $CatalogBuildFolder -ItemType Directory -Force
    }
    $RawCatalogFile			= Join-Path $env:TEMP (Join-Path 'OSD' $OnlineCatalogName)
    $RawCatalogCabName  	= [string]($OnlineCatalogUri | Split-Path -Leaf)
    $RawCatalogCabPath 		= Join-Path $env:TEMP (Join-Path 'OSD' $RawCatalogCabName)
    $TempCatalogFile        = Join-Path $env:TEMP (Join-Path 'OSD' $OfflineCatalogName)
    $ModuleCatalogFile      = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\$OfflineCatalogName"
    #=================================================
    #   UseCatalog Cloud
    #=================================================
    if ($UseCatalog -eq 'Cloud') {
        Write-Verbose "Source: $OnlineCatalogUri"
        Write-Verbose "Destination: $RawCatalogCabPath"
        (New-Object System.Net.WebClient).DownloadFile($OnlineCatalogUri, $RawCatalogCabPath)

        if (Test-Path $RawCatalogCabPath) {
            Write-Verbose "Expand: $RawCatalogCabPath"
            $null = Expand "$RawCatalogCabPath" "$RawCatalogFile"

            if (Test-Path $RawCatalogFile) {
                Write-Verbose "Using Raw Catalog at $RawCatalogFile"
                $UseCatalog = 'Raw'
            }
            else {
                Write-Verbose "Could not expand $RawCatalogCabPath"
                Write-Verbose "Using Offline Catalog at $ModuleCatalogFile"
                $UseCatalog = 'Offline'
            }
        }
        else {
            Write-Verbose "Using Offline Catalog at $ModuleCatalogFile"
            $UseCatalog = 'Offline'
        }
    }
    #=================================================
    #   UseCatalog Raw
    #=================================================
    if ($UseCatalog -eq 'Raw') {
        Write-Verbose "Reading the Raw Catalog at $RawCatalogFile"
        [xml]$XmlCatalogContent = Get-Content $RawCatalogFile -ErrorAction Stop
        $CatalogVersion = $XmlCatalogContent.Manifest.version
        $Results = $XmlCatalogContent.Manifest.SoftwareComponent

        $Results = $Results | Select-Object @{Label="CatalogVersion";Expression={$CatalogVersion};},
        @{Label="Status";Expression={$null};},
        @{Label="Component";Expression={($_.ComponentType.Display.'#cdata-section'.Trim())};},
        @{Label="ReleaseDate";Expression = {[datetime] ($_.dateTime)};},
        @{Label="Name";Expression={($_.Name.Display.'#cdata-section'.Trim())};},
        #@{Label="Description";Expression={($_.Description.Display.'#cdata-section'.Trim())};},
        @{Label="DellVersion";Expression={$_.dellVersion};},
        @{Label="Url";Expression={-join ($OnlineBaseUri, $_.path)};},
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

        Write-Verbose "Exporting Build Catalog to $TempCatalogFile"
        $Results = $Results | Sort-Object ReleaseDate -Descending
        $Results | Export-Clixml -Path $TempCatalogFile
    }
    #=================================================
    #   UpdateModuleCatalog
    #=================================================
    if ($UpdateModuleCatalog) {
        if (Test-Path $TempCatalogFile) {
            Write-Verbose "Copying $TempCatalogFile to $ModuleCatalogFile"
            Copy-Item $TempCatalogFile $ModuleCatalogFile -Force -ErrorAction Ignore
        }
    }
    #=================================================
    #   UseCatalog Offline
    #=================================================
    if ($UseCatalog -eq 'Offline') {
        Write-Verbose "Importing the Offline Catalog at $ModuleCatalogFile"
        $Results = Import-Clixml -Path $ModuleCatalogFile
    }
    #=================================================
    #   Compatible
    #=================================================
    if ($PSBoundParameters.ContainsKey('Compatible')) {
        $MyComputerProduct = Get-MyComputerProduct
        Write-Verbose "Filtering Catalog for items compatible with Product $MyComputerProduct"
        $Results = $Results | Where-Object {$_.SupportedSystemID -contains $MyComputerProduct}
    }
    #=================================================
    #   Component
    #=================================================
    if ($PSBoundParameters.ContainsKey('Component')) {
        Write-Verbose "Filtering Catalog for $Component"
        $Results = $Results | Where-Object {$_.Component -eq $Component}
    }
    #=================================================
    #   DownloadPath
    #=================================================
    if ($PSBoundParameters.ContainsKey('DownloadPath')) {
        $Results = $Results | Out-GridView -Title 'Select one or more files to Download' -PassThru -ErrorAction Stop
        foreach ($Item in $Results) {
            $OutFile = Save-WebFile -SourceUrl $Item.Url -DestinationDirectory $DownloadPath -DestinationName $Item.FileName -Verbose
            $Item | ConvertTo-Json | Out-File "$($OutFile.FullName).json" -Encoding ascii -Width 2000 -Force
        }
    }
    #=================================================
    #   Complete
    #=================================================
    $Results
    #=================================================
}