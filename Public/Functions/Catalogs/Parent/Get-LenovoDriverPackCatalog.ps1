<#
.SYNOPSIS
Builds the Lenovo DriverPack Catalog

.DESCRIPTION
Builds the Lenovo DriverPack Catalog

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-LenovoDriverPackCatalog {
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
    $OfflineCatalogName = 'LenovoDriverPackCatalog.xml'

    $OnlineCatalogName = 'catalogv2.xml'
    $OnlineCatalogUri = 'https://download.lenovo.com/cdrt/td/catalogv2.xml'

    $UTF8ByteOrderMark      = [System.Text.Encoding]::UTF8.GetString(@(195, 175, 194, 187, 194, 191))
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
        try {
            #[xml]$XmlCatalog = $RawDriverPackCatalog -replace "^$UTF8ByteOrderMark"
            $CatalogCloudRaw = Invoke-RestMethod -Uri $OnlineCatalogUri -UseBasicParsing
            Write-Verbose "Cloud Catalog $OnlineCatalogUri"
            Write-Verbose "Saving Cloud Catalog to $RawCatalogFile"		
            $CatalogCloudContent = $CatalogCloudRaw.Substring(3)
            $CatalogCloudContent | Out-File -FilePath $RawCatalogFile -Encoding utf8 -Force

            if (Test-Path $RawCatalogFile) {
                Write-Verbose "Catalog saved to $RawCatalogFile"
                $UseCatalog = 'Raw'
            }
            else {
                Write-Verbose "Catalog was NOT downloaded to $RawCatalogFile"
                Write-Verbose "Using Offline Catalog at $ModuleCatalogFile"
                $UseCatalog = 'Offline'
            }
        }
        catch {
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
        [xml]$XmlCatalogContent = Get-Content -Path $RawCatalogFile -Raw

        $ModelList = $XmlCatalogContent.ModelList.Model
        #=================================================
        #   Create Object 
        #=================================================
        $Results = foreach ($Model in $ModelList) {
            foreach ($Item in $Model.SCCM) {
                $DownloadUrl = $Item.'#text'
                $ReleaseDate = $null
                
                $OSReleaseId = $Item.version
                if ($OSReleaseId -eq '*') {
                    $OSReleaseId = $null
                }

                $OSBuild = $null
                if ($OSReleaseId -eq '22H2') {
                    if ($Item.os -eq 'win10') {
                        $OSBuild = '19045'
                    }
                    if ($Item.os -eq 'win11') {
                        $OSBuild = '22621'
                    }
                }
                elseif ($OSReleaseId -eq '21H2') {
                    if ($Item.os -eq 'win10') {
                        $OSBuild = '19044'
                    }
                    if ($Item.os -eq 'win11') {
                        $OSBuild = '22000'
                    }
                }
                elseif ($OSReleaseId -eq '21H1') {
                    $OSBuild = '19043'
                }
                elseif ($OSReleaseId -eq '20H2') {
                    $OSBuild = '19042'
                }
                elseif ($OSReleaseId -eq '2004') {
                    $OSBuild = '19041'
                }
                elseif ($OSReleaseId -eq '1909') {
                    $OSBuild = '18363'
                }
                elseif ($OSReleaseId -eq '1903') {
                    $OSBuild = '18362'
                }
                elseif ($OSReleaseId -eq '1809') {
                    $OSBuild = '17763'
                }
                elseif ($OSReleaseId -eq '1803') {
                    $OSBuild = '17134'
                }
                elseif ($OSReleaseId -eq '1709') {
                    $OSBuild = '16299'
                }
                elseif ($OSReleaseId -eq '1703') {
                    $OSBuild = '15063'
                }
                elseif ($OSReleaseId -eq '1607') {
                    $OSBuild = '14393'
                }
                elseif ($OSReleaseId -eq '1511') {
                    $OSBuild = '10586'
                }
                elseif ($OSReleaseId -eq '1507') {
                    $OSBuild = '10240'
                }
                $HashMD5 = $Item.crc

                if ($Item.os -eq 'win10') {
                    if ($Item.version -eq '*') {
                        $NewName = "Lenovo $($Model.name) Win10"
                    }
                    else {
                        $NewName = "Lenovo $($Model.name) Win10 $($Item.version)"
                    }
                    $ObjectProperties = [Ordered]@{
                        CatalogVersion 	= Get-Date -Format yy.MM.dd
                        Status          = $null
                        Component       = 'DriverPack'
                        ReleaseDate     = $ReleaseDate
                        Manufacturer    = 'Lenovo'
                        Model           = $Model.name
                        Product			= [array]$Model.Types.Type.split(',').Trim()
                        Name			= $NewName
                        PackageID       = $null
                        FileName        = $DownloadUrl | Split-Path -Leaf
                        Url             = $DownloadUrl
                        OSVersion       = 'Windows 10 x64'
                        OSReleaseId     = $OSReleaseId
                        OSBuild         = $OSBuild
                        HashMD5         = $HashMD5
                    }
                    New-Object -TypeName PSObject -Property $ObjectProperties
                }

                if ($Item.os -eq 'win11') {
                    if ($Item.version -eq '*') {
                        $NewName = "Lenovo $($Model.name) Win11"
                    }
                    else {
                        $NewName = "Lenovo $($Model.name) Win11 $($Item.version)"
                    }
                    $ObjectProperties = [Ordered]@{
                        CatalogVersion 	= Get-Date -Format yy.MM.dd
                        Status          = $null
                        Component       = 'DriverPack'
                        ReleaseDate     = $ReleaseDate
                        Manufacturer    = 'Lenovo'
                        Model           = $Model.name
                        Product			= [array]$Model.Types.Type.split(',').Trim()
                        Name			= $NewName
                        PackageID       = $null
                        FileName        = $DownloadUrl | Split-Path -Leaf
                        Url             = $DownloadUrl
                        OSVersion       = 'Windows 11 x64'
                        OSReleaseId     = $OSReleaseId
                        OSBuild         = $OSBuild
                        HashMD5         = $HashMD5
                    }
                    New-Object -TypeName PSObject -Property $ObjectProperties
                }
            }
        }
        $Results = $Results | Sort-Object Name, OSVersion -Descending | Group-Object Name | ForEach-Object {$_.Group | Select-Object -First 1}
        $Results = $Results | Sort-Object Name, OSVersion -Descending

        #Need to test each of the downloads to see if they are valid
        if ($TestUrl) {
            $Results = $Results | Sort-Object Url
            $LastItem = $null

            foreach ($Item in $Results) {
                if ($Item.Url -eq $LastItem.Url) {
                    $Item.Status = $LastItem.Status
                    $Item.ReleaseDate = $LastItem.ReleaseDate
                }
                else {
                    $DownloadHeaders = $null
                    try {
                        $DownloadHeaders = (Invoke-WebRequest -Method Head -Uri $Item.Url -UseBasicParsing).Headers
                    }
                    catch {
                        Write-Warning "Failed: $($Item.Url)"
                        Write-Warning ""
                    }

                    if ($DownloadHeaders) {
                        $Item.ReleaseDate = Get-Date ($DownloadHeaders['Last-Modified'])[0] -Format "yy.MM.dd"
                        Write-Verbose "Success: $($Item.Url)"
                        Write-Verbose "Release Date: $($Item.ReleaseDate)"
                        Write-Verbose ""
                    }
                    else {
                        $Item.Status = 'Failed'
                    }
                }
                $LastItem = $Item
            }
        }

        Write-Verbose "Exporting Build Catalog to $TempCatalogFile"
        $Results = $Results | Sort-Object Name
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
        $Results = $Results | Where-Object {$_.Product -contains $MyComputerProduct}
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
    #   Component
    #=================================================
    $Results | Sort-Object -Property Name
    #=================================================
}