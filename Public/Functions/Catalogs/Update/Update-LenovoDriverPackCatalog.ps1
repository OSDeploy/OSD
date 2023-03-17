<#
.SYNOPSIS
Builds the Lenovo DriverPack Catalog

.DESCRIPTION
Builds the Lenovo DriverPack Catalog

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Update-LenovoDriverPackCatalog {
    [CmdletBinding()]
    param (
        #Updates the OSD Module Offline Catalog
        [System.Management.Automation.SwitchParameter]
        $UpdateModule
    )
    #=================================================
    #   Defaults
    #=================================================
    $OnlineCatalogName = 'catalogv2.xml'
    $OnlineCatalogUri = 'https://download.lenovo.com/cdrt/td/catalogv2.xml'

    $OfflineCatalogName = 'LenovoDriverPackCatalog.xml'

    $ModuleCatalogXml      = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\LenovoDriverPackCatalog.xml"
    $ModuleCatalogJson      = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\LenovoDriverPackCatalog.json"

    $UTF8ByteOrderMark      = [System.Text.Encoding]::UTF8.GetString(@(195, 175, 194, 187, 194, 191))
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
    #=================================================
    #   Get Online Catalog
    #=================================================
    try {
        #[xml]$XmlCatalog = $RawDriverPackCatalog -replace "^$UTF8ByteOrderMark"
        $CatalogCloudRaw = Invoke-RestMethod -Uri $OnlineCatalogUri -UseBasicParsing
        Write-Verbose -Verbose "Cloud Catalog $OnlineCatalogUri"
        Write-Verbose -Verbose "Saving Cloud Catalog to $RawCatalogFile"		
        $CatalogCloudContent = $CatalogCloudRaw.Substring(3)
        $CatalogCloudContent | Out-File -FilePath $RawCatalogFile -Encoding utf8 -Force

        if (Test-Path $RawCatalogFile) {
            Write-Verbose -Verbose "Catalog saved to $RawCatalogFile"
            $UseCatalog = 'Raw'
        }
        else {
            Write-Verbose -Verbose "Catalog was NOT downloaded to $RawCatalogFile"
            Write-Warning 'Unable to complete'
            Break
        }
    }
    catch {
        Write-Warning 'Unable to complete'
        Break
    }
    #=================================================
    #   Build Catalog
    #=================================================
    Write-Verbose -Verbose "Reading the Raw Catalog at $RawCatalogFile"
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
    #=================================================
    #   Validate Results
    #=================================================
    Write-Warning "Testing each download link, please wait ..."
    $Results = $Results | Sort-Object Url
    $LastItem = $null

    foreach ($Item in $Results) {
        if ($Item.Url -eq $LastItem.Url) {
            $Item.Status = $LastItem.Status
            $Item.ReleaseDate = $LastItem.ReleaseDate
        }
        else {
            $Global:DownloadHeaders = $null
            try {
                $Global:DownloadHeaders = (Invoke-WebRequest -Method Head -Uri $Item.Url -UseBasicParsing).Headers
            }
            catch {
                Write-Warning "Failed: $($Item.Url)"
            }

            if ($Global:DownloadHeaders) {
                $Item.ReleaseDate = Get-Date ($Global:DownloadHeaders.'Last-Modified') -Format "yy.MM.dd"
                Write-Verbose -Verbose "Success: $($Item.Url)"
                Write-Verbose -Verbose "ReleaseDate: $($Item.ReleaseDate)"
            }
            else {
                $Item.Status = 'Failed'
            }
        }
        $LastItem = $Item
    }
    #=================================================
    #   Sort Results
    #=================================================
    $Results = $Results | Sort-Object Name
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
    Write-Verbose -Verbose 'Complete: Results have been stored $Global:LenovoDriverPackCatalog'
    $Global:LenovoDriverPackCatalog = $Results | Sort-Object -Property Name
    #=================================================
}