<#
.SYNOPSIS
Returns the Dell DriverPacks downloads

.DESCRIPTION
Returns the Dell DriverPacks downloads

.PARAMETER Compatible
Filters results based on your current Product

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-OSDCatalogDellDriverPack {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Compatible,
        [System.String]$DownloadPath,
        [System.Management.Automation.SwitchParameter]$Force,
        [System.Management.Automation.SwitchParameter]$TestUrl
    )
    #=================================================
    #   Paths
    #=================================================
    $UseCatalog				= 'Cloud'
    $CloudCatalogUri		= 'https://downloads.dell.com/catalog/DriverPackCatalog.cab'
    $RawCatalogFile			= Join-Path $env:TEMP (Join-Path 'OSD' 'DriverPackCatalog.xml')
    $BuildCatalogFile		= Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogDellDriverPack.xml')
    $OfflineCatalogFile		= "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\OSDCatalog\OSDCatalogDellDriverPack.xml"

    $RawCatalogCabName  	= [string]($CloudCatalogUri | Split-Path -Leaf)
    $RawCatalogCabPath 		= Join-Path $env:TEMP (Join-Path 'OSD' $RawCatalogCabName)
    $DownloadsBaseUrl       = 'http://downloads.dell.com/'
    #=================================================
    #   Create Download Path
    #=================================================
    if (-not(Test-Path (Join-Path $env:TEMP 'OSD'))) {
        $null = New-Item -Path (Join-Path $env:TEMP 'OSD') -ItemType Directory -Force
    }
    #=================================================
    #   Test Build Catalog
    #=================================================
    if (Test-Path $BuildCatalogFile) {
        Write-Verbose "Build Catalog already created at $BuildCatalogFile"	

        $GetItemBuildCatalogFile = Get-Item $BuildCatalogFile

        #If the Build Catalog is older than 12 hours, delete it
        if (((Get-Date) - $GetItemBuildCatalogFile.LastWriteTime).TotalHours -gt 12) {
            Write-Verbose "Removing previous Build Catalog"
            $null = Remove-Item $GetItemBuildCatalogFile.FullName -Force
        }
        else {
            $UseCatalog = 'Build'
        }
    }
    #=================================================
    #   Test Cloud Catalog
    #=================================================
    if ($Force) {
        $UseCatalog = 'Cloud'
    }
    if ($UseCatalog -eq 'Cloud') {
        if (Test-WebConnection -Uri $CloudCatalogUri) {
            $UseCatalog = 'Cloud'
        }
        else {
            $UseCatalog = 'Offline'
        }
    }
    #=================================================
    #   UseCatalog Cloud
    #=================================================
    if ($UseCatalog -eq 'Cloud') {
        Write-Verbose "Source: $CloudCatalogUri"
        Write-Verbose "Destination: $RawCatalogCabPath"
        (New-Object System.Net.WebClient).DownloadFile($CloudCatalogUri, $RawCatalogCabPath)

        if (Test-Path $RawCatalogCabPath) {
            Write-Verbose "Expand: $RawCatalogCabPath"
            $null = Expand "$RawCatalogCabPath" "$RawCatalogFile"

            if (Test-Path $RawCatalogFile) {
                Write-Verbose "Using Raw Catalog at $RawCatalogFile"
                $UseCatalog = 'Raw'
            }
            else {
                Write-Verbose "Could not expand $RawCatalogCabPath"
                Write-Verbose "Using Offline Catalog at $OfflineCatalogFile"
                $UseCatalog = 'Offline'
            }
        }
        else {
            Write-Verbose "Using Offline Catalog at $OfflineCatalogFile"
            $UseCatalog = 'Offline'
        }
    }
    #=================================================
    #   UseCatalog Raw
    #=================================================
    if ($UseCatalog -eq 'Raw') {
        Write-Verbose "Reading the Raw Catalog at $RawCatalogFile"
        [xml]$XmlCatalogContent = Get-Content $RawCatalogFile -ErrorAction Stop
        $CatalogVersion = (Get-Date $XmlCatalogContent.DriverPackManifest.version).ToString('yy.MM.dd')
        $DellDriverPackXml = $XmlCatalogContent.DriverPackManifest.DriverPackage

        $DellDriverPackXml = $DellDriverPackXml | Where-Object {($_.SupportedOperatingSystems.OperatingSystem.osCode.Trim() | Select-Object -Unique) -notmatch 'winpe'}

        #=================================================
        #   Create DriverPack Object
        #=================================================
        $Results = foreach ($Item in $DellDriverPackXml) {

            $osCode = $Item.SupportedOperatingSystems.OperatingSystem.osCode.Trim() | Select-Object -Unique
            if ($osCode -match 'Windows11') {
                $osShortName = 'Win11'
            }
            elseif ($osCode -match 'Windows10') {
                $osShortName = 'Win10'
            }
            elseif ($osCode -match 'Windows7') {
                $osShortName = 'Win7'
                Continue
            }
            else {
                Continue
            }

            $Name = "$($Item.SupportedSystems.Brand.Model.name | Select-Object -Unique) $osShortName $($Item.dellVersion)"
            $Generation = $Item.SupportedSystems.Brand.Model.generation | Select-Object -Unique
            if ($Generation -notmatch 'X') {
                $Generation = 'XX'
            }

            $ObjectProperties = [Ordered]@{
                CatalogVersion 	    = $CatalogVersion
                Status		        = $null
                Component		    = "DriverPack"
                ReleaseDate		    = Get-Date $Item.dateTime -Format "yy.MM.dd"
                Manufacturer        = 'Dell'
                Name		        = $Name
                #Description		= ($Item.Description.Display.'#cdata-section'.Trim())
                DellVersion		    = $Item.dellVersion
                Url		            = -join ($DownloadsBaseUrl, $Item.path)
                VendorVersion		= $Item.vendorVersion
                FileName		    = (split-path -leaf $Item.path)
                SizeMB		        = '{0:f2}' -f ($Item.size/1MB)
                ReleaseID		    = $Item.ReleaseID
                Brand		        = ($Item.SupportedSystems.Brand.Display.'#cdata-section'.Trim() | Select-Object -Unique)
                Key		            = ($Item.SupportedSystems.Brand.key | Select-Object -Unique)
                Prefix		        = ($Item.SupportedSystems.Brand.prefix | Select-Object -Unique)
                Model		        = ($Item.SupportedSystems.Brand.Model.name | Select-Object -Unique)
                ModelID		        = ($Item.SupportedSystems.Brand.Model.Display.'#cdata-section'.Trim() | Select-Object -Unique)
                SystemID		    = ($Item.SupportedSystems.Brand.Model.systemID | Select-Object -Unique)
                RtsDate		        = ($Item.SupportedSystems.Brand.Model.rtsDate | Select-Object -Unique)
                Generation		    = $Generation
                SupportedOS		    = ($Item.SupportedOperatingSystems.OperatingSystem.Display.'#cdata-section'.Trim() | Select-Object -Unique)
                osCode		        = $osCode
                osVendor		    = ($Item.SupportedOperatingSystems.OperatingSystem.osVendor.Trim() | Select-Object -Unique)
                osArch		        = ($Item.SupportedOperatingSystems.OperatingSystem.osArch.Trim() | Select-Object -Unique)
                osType		        = ($Item.SupportedOperatingSystems.OperatingSystem.osType.Trim() | Select-Object -Unique)
                majorVersion		= ($Item.SupportedOperatingSystems.OperatingSystem.majorVersion.Trim() | Select-Object -Unique)
                minorVersion		= ($Item.SupportedOperatingSystems.OperatingSystem.minorVersion.Trim() | Select-Object -Unique)
                spMajorVersion		= ($Item.SupportedOperatingSystems.OperatingSystem.spMajorVersion.Trim() | Select-Object -Unique)
                spMinorVersion		= ($Item.SupportedOperatingSystems.OperatingSystem.spMinorVersion.Trim() | Select-Object -Unique)
                ImportantInfoUrl    = ($Item.ImportantInfo.URL.Trim() | Select-Object -Unique)
                #Format		        = $Item.format
                #Delta		        = $Item.delta
                #Type		        = $Item.type
                HashMD5		        = $Item.HashMD5
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }

        #Need to remove duplicates
        $Results = $Results | Sort-Object ReleaseDate -Descending | Group-Object Name | ForEach-Object {$_.Group | Select-Object -First 1}

        if ($TestUrl) {
            $Results = $Results | Sort-Object Url
            $PreviousUrl = $null
            foreach ($Item in $Results) {
                $CurrentUrl = $Item.Url
                if ($CurrentUrl -ne $PreviousUrl) {
                    Write-Verbose "Testing Download File at $CurrentUrl"
                    try {
                        $DownloadHeaders = (Invoke-WebRequest -Method Head -Uri $CurrentUrl -UseBasicParsing).Headers
                    }
                    catch {
                        Write-Warning "Failed: $CurrentUrl"
                        $Item.Status = 'Failed'
                    }
                }
                $PreviousUrl = $CurrentUrl
            }
        }

        Write-Verbose "Exporting Build Catalog to $BuildCatalogFile"
        $Results = $Results | Sort-Object Name
        $Results | Export-Clixml -Path $BuildCatalogFile
    }
    #=================================================
    #   UseCatalog Build
    #=================================================
    if ($UseCatalog -eq 'Build') {
        Write-Verbose "Importing the Build Catalog at $BuildCatalogFile"
        $Results = Import-Clixml -Path $BuildCatalogFile
    }
    #=================================================
    #   UseCatalog Offline
    #=================================================
    if ($UseCatalog -eq 'Offline') {
        Write-Verbose "Importing the Offline Catalog at $OfflineCatalogFile"
        $Results = Import-Clixml -Path $OfflineCatalogFile
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
    $Results | Sort-Object -Property Name
    #=================================================
}