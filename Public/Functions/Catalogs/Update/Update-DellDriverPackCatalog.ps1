<#
.SYNOPSIS
Builds the Dell DriverPack Catalog

.DESCRIPTION
Builds the Dell DriverPack Catalog

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Update-DellDriverPackCatalog {
    [CmdletBinding()]
    param (
        #Updates the OSD Module Offline Catalog
        [System.Management.Automation.SwitchParameter]
        $UpdateModule
    )
    #=================================================
    #   Custom Defaaults
    #=================================================
    $OnlineCatalogName = 'DriverPackCatalog.xml'
    $OnlineBaseUri = 'http://downloads.dell.com/'
    $OnlineCatalogUri = 'https://downloads.dell.com/catalog/DriverPackCatalog.cab'

    $OfflineCatalogName = 'DellDriverPackCatalog.xml'

    $ModuleCatalogXml = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\DellDriverPackCatalog.xml"
    $ModuleCatalogJson = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\DellDriverPackCatalog.json"
    #=================================================
    #   Additional Defaults
    #=================================================
    $CatalogBuildFolder = Join-Path $env:TEMP 'OSD'
    if (-not(Test-Path $CatalogBuildFolder)) {
        $null = New-Item -Path $CatalogBuildFolder -ItemType Directory -Force
    }
    $RawCatalogFile			= Join-Path $env:TEMP (Join-Path 'OSD' $OnlineCatalogName)
    $RawCatalogCabName  	= [string]($OnlineCatalogUri | Split-Path -Leaf)
    $RawCatalogCabPath 		= Join-Path $env:TEMP (Join-Path 'OSD' $RawCatalogCabName)
    #=================================================
    #   UseCatalog Cloud
    #=================================================
    Write-Verbose -Verbose "Source: $OnlineCatalogUri"
    Write-Verbose -Verbose "Destination: $RawCatalogCabPath"
    (New-Object System.Net.WebClient).DownloadFile($OnlineCatalogUri, $RawCatalogCabPath)

    if (Test-Path $RawCatalogCabPath) {
        Write-Verbose -Verbose "Expand: $RawCatalogCabPath"
        $null = Expand "$RawCatalogCabPath" "$RawCatalogFile"

        if (Test-Path $RawCatalogFile) {
            Write-Verbose -Verbose "Using Raw Catalog at $RawCatalogFile"
        }
        else {
            Write-Verbose -Verbose "Could not expand $RawCatalogCabPath"
            Write-Warning 'Unable to complete'
            Break
        }
    }
    else {
        Write-Warning 'Unable to complete'
        Break
    }
    #=================================================
    #   UseCatalog Raw
    #=================================================
    Write-Verbose -Verbose "Reading the Raw Catalog at $RawCatalogFile"
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
    #=================================================
    #   Normalize Results
    #=================================================
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
    #=================================================
    #   Validate Results
    #=================================================
    $Results = $Results | Sort-Object Url
    $PreviousUrl = $null
    foreach ($Item in $Results) {
        $CurrentUrl = $Item.Url
        if ($CurrentUrl -ne $PreviousUrl) {
            Write-Verbose -Verbose "Testing Download File at $CurrentUrl"
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
    #=================================================
    #   Sort Results
    #=================================================
    $Results = $Results | Sort-Object -Property Name
    #=================================================
    #   UpdateModule
    #=================================================
    if ($UpdateModule) {
        Write-Verbose -Verbose "UpdateModule: Exporting to OSD Module Catalogs at $ModuleCatalogXml"
        $Results | Export-Clixml -Path $ModuleCatalogXml -Force
        Write-Verbose -Verbose "UpdateModule: Exporting to OSD Module Catalogs at $ModuleCatalogJson"
        $Results | ConvertTo-Json | Out-File $ModuleCatalogJson -Encoding ascii -Width 2000 -Force
    }
    #=================================================
    #   Complete
    #=================================================
    Write-Verbose -Verbose 'Complete: Results have been stored $Global:DellDriverPackCatalog'
    $Global:DellDriverPackCatalog = $Results | Sort-Object -Property Name
    #=================================================
}