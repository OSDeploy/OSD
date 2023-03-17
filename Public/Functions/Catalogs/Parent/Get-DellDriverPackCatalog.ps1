<#
.SYNOPSIS
Builds the Dell DriverPack Catalog

.DESCRIPTION
Builds the Dell DriverPack Catalog

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-DellDriverPackCatalog {
    [CmdletBinding()]
    param (
        #Limits the results to match the current system
        [System.Management.Automation.SwitchParameter]
        $Compatible,

        #Specifies a download path for matching results displayed in Out-GridView
        [System.String]
        $DownloadPath,

        #Checks for the latest Online version
        [System.Management.Automation.SwitchParameter]
        $Online,

        #Updates the OSD Module Offline Catalog
        [System.Management.Automation.SwitchParameter]
        $UpdateModuleCatalog
    )
    #=================================================
    #   Defaults
    #=================================================
    $UseCatalog = 'Offline'
    $OfflineCatalogName = 'DellDriverPackCatalog.xml'
    $ModuleCatalogJsonFile = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\DellDriverPackCatalog.json"

    $OnlineCatalogName = 'DriverPackCatalog.xml'
    $OnlineBaseUri = 'http://downloads.dell.com/'
    $OnlineCatalogUri = 'https://downloads.dell.com/catalog/DriverPackCatalog.cab'
    #=================================================
    #   Initialize
    #=================================================
    $IsOnline = $false

    if ($UpdateModuleCatalog) {
        $Online = $true
        $TestUrl = $true
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
        Write-Warning "Building Catalog content, please wait ..."
        [xml]$XmlCatalogContent = Get-Content $RawCatalogFile -ErrorAction Stop

        #$CatalogVersion = (Get-Date $XmlCatalogContent.DriverPackManifest.version).ToString('yy.MM.dd')
        $RawCatalogVersion = $XmlCatalogContent.DriverPackManifest.version -replace '.00','.01'
        $CatalogVersion = (Get-Date $RawCatalogVersion).ToString('yy.MM.dd')

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
            elseif ($ModelID -eq '0630') {
                Continue
            }
            else {
                Continue
            }

            $Name = "Dell $($Item.SupportedSystems.Brand.Model.name | Select-Object -Unique) $osShortName $($Item.dellVersion)"
            $Name = $Name -replace '  ',' '
            $Model = ($Item.SupportedSystems.Brand.Model.name | Select-Object -Unique)
            if ($Model -match '3650 Tower') {
                $Model = 'Precision 3650 Tower'
            }

            $ModelID = ($Item.SupportedSystems.Brand.Model.Display.'#cdata-section'.Trim() | Select-Object -Unique)
            if ($Model -eq 'Precision 3650 Tower') {
                $ModelID = 'Precision 3650 Tower'
            }

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
                Url		            = -join ($OnlineBaseUri, $Item.path)
                VendorVersion		= $Item.vendorVersion
                FileName		    = (split-path -leaf $Item.path)
                SizeMB		        = '{0:f2}' -f ($Item.size/1MB)
                ReleaseID		    = $Item.ReleaseID
                Brand		        = ($Item.SupportedSystems.Brand.Display.'#cdata-section'.Trim() | Select-Object -Unique)
                Key		            = ($Item.SupportedSystems.Brand.key | Select-Object -Unique)
                Prefix		        = ($Item.SupportedSystems.Brand.prefix | Select-Object -Unique)
                Model		        = $Model
                ModelID		        = $ModelID
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
                OSVersion           = $null
                OSReleaseId         = $null
                OSBuild             = $null
                HashMD5		        = $Item.HashMD5
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
        
        foreach ($Item in $Results) {
            if ($Item.Name -match 'Win10') {
                $Item.OSVersion = 'Windows 10 x64'
            }
            if ($Item.Name -match 'Win11') {
                $Item.OSVersion = 'Windows 11 x64'
            }
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
        $Results = $Results | Sort-Object Name
    }
    #=================================================
    #   UpdateModuleCatalog
    #=================================================
    if ($UpdateModuleCatalog) {
        $Results | Export-Clixml -Path $ModuleCatalogFile
        $Results | ConvertTo-Json | Out-File -FilePath $ModuleCatalogJsonFile -Encoding ascii -Width 2000 -Force
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
    $Results | Sort-Object -Property Name
    #=================================================
}