<#
.SYNOPSIS
Updates the local Microsoft Surface DriverPacks in the OSD Module

.DESCRIPTION
Updates the local Microsoft Surface DriverPacks in the OSD Module

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Update-MicrosoftDriverPackCatalog {
    [CmdletBinding()]
    param (
        #Updates the OSD Module Offline Catalog. Requires Admin rights
        [System.Management.Automation.SwitchParameter]
        $UpdateModuleCatalog,

        #Verifies that the DriverPack is reachable. This will take some time to complete
        [System.Management.Automation.SwitchParameter]
        $Verify
    )
    #=================================================
    #	Reference
    #=================================================
    #   Device List
    #   https://docs.microsoft.com/en-us/surface/surface-system-sku-reference
    #
    #   Supported Operating Systems
    #   https://support.microsoft.com/en-us/surface/surface-supported-operating-systems-9559cc3c-7a38-31b6-d9fb-571435e84cd1
    #
    #   Download Links
    #   https://support.microsoft.com/en-us/surface/download-drivers-and-firmware-for-surface-09bb2e09-2a4b-cb69-0951-078a7739e120#bkmk_update-manually
    #
    #   https://docs.microsoft.com/en-us/surface/manage-surface-driver-and-firmware-updates
    #   https://www.reddit.com/r/Surface/comments/mlhqw5/all_direct_download_links_for_surface/
    #   https://dancharblog.wordpress.com/2021/04/06/all-direct-download-links-for-surface-firmware-drivers/
    #=================================================
    #   Defaults
    #=================================================
    $OfflineCatalogName = 'MicrosoftDriverPackCatalog.json'

    $OnlineCatalogName = 'MicrosoftDriverPackCatalog.json'
    $OnlineBaseUri = 'https://www.microsoft.com/en-us/download/details.aspx?id='
    $OnlineDownloadUri = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id='
    $OnlineCatalogUri = 'https://support.microsoft.com/en-us/surface/download-drivers-and-firmware-for-surface-09bb2e09-2a4b-cb69-0951-078a7739e120'

    $MicrosoftSurfaceModels = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\MicrosoftSurfaceModels.json" -Raw
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
    $ModuleCatalogXml       = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\MicrosoftDriverPackCatalog.xml"
    $ModuleCatalogJson      = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\MicrosoftDriverPackCatalog.json"
    #=================================================
    #   UseCatalog Cloud
    #=================================================
    $SurfaceModels = $MicrosoftSurfaceModels | ConvertFrom-Json
    $MasterResults = @()

    $MasterResults = foreach ($Surface in $SurfaceModels) {
        Write-Verbose -Verbose "Processing $($Surface.Name)"
        $DriverPage = $OnlineDownloadUri + $Surface.PackageID
        $Downloads = (Invoke-WebRequest -Uri $DriverPage).Links
        $Downloads = $Downloads | Where-Object {$_.href -match 'download.microsoft.com'}
        $Downloads = $Downloads | Where-Object {($_.href -match 'Win11') -or ($_.href -match 'Win10')}
        $Downloads = $Downloads | Sort-Object href | Select-Object href -Unique
        #$Downloads = $Downloads | Select-Object -Last 1
        #$Surface.Url = ($Downloads).href
        #$Surface.FileName = Split-Path $Surface.Url -Leaf
        #=================================================
        #   Create Object
        #=================================================
        foreach ($Download in $Downloads) {
            $DownloadUrl = $Download.href
            Write-Verbose -Verbose "Verify: $DownloadUrl"

            $GetUrl = Invoke-WebRequest -Method Head -Uri $DownloadUrl
            $GetHeaders = $GetUrl.Headers
            $GetLastModified = $GetHeaders['Last-Modified']
            Write-Verbose -Verbose "Last Modified: $GetLastModified"

            $ReleaseDate = (Get-Date $GetLastModified).ToString('yy.MM.dd')
            $FileName = Split-Path $DownloadUrl -Leaf

            if ($FileName -match 'Win11') {
                $OSVersion = 'Windows 11 x64'
            }
            else {
                $OSVersion = 'Windows 10 x64'
            }
            
            $ByteArray = [System.Convert]::FromBase64String($GetHeaders['Content-MD5'])
            $HexObject = $ByteArray | Format-Hex
            $HashMD5 = ($HexObject.Bytes | ForEach-Object {"{0:X}" -f $_}) -join ''

            $UniqueFileName = $FileName
            $UniqueFileName = $UniqueFileName -replace '_Win', ' Win'
            $UniqueFileName = $UniqueFileName.Split(' ')[1]
            $UniqueFileName = $UniqueFileName -replace 'Win10_', 'Win10 '
            $UniqueFileName = $UniqueFileName -replace 'Win11_', 'Win11 '
            $UniqueFileName = $UniqueFileName.Split('_')[0]

            $UniqueName = "Microsoft $($Surface.Name) $UniqueFileName"

            $ObjectProperties = [ordered] @{
                CatalogVersion          = Get-Date -Format yy.MM.dd
                Status                  = $null
                Component               = 'DriverPack'
                ReleaseDate             = $ReleaseDate
                Manufacturer            = 'Microsoft'
                Model                   = $Surface.Model
                Product                 = $Surface.Product
                Name                    = $UniqueName
                PackageID               = $Surface.PackageID
                FileName                = $FileName
                Url                     = $DownloadUrl
                DownloadCenter          = $OnlineBaseUri + $Surface.PackageID
                OSVersion               = $OSVersion
                OSReleaseId             = ''
                OSBuild                 = ''    
                HashMD5                 = $HashMD5
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
    }

    foreach ($Item in $MasterResults) {
        $Item.OSBuild = $Item.Name.Split(' ')[-1]
    }

    foreach ($Item in $MasterResults) {
        if ($Item.Name -match 'Win10 10240') {
            $Item.OSReleaseId = '1507'
            $Item.Name = $Item.Name -replace 'Win10 10240', 'Win10 1507'
        }
        if ($Item.Name -match 'Win10 10586') {
            $Item.OSReleaseId = '1511'
            $Item.Name = $Item.Name -replace 'Win10 10586', 'Win10 1511'
        }
        if ($Item.Name -match 'Win10 14393') {
            $Item.OSReleaseId = '1607'
            $Item.Name = $Item.Name -replace 'Win10 14393', 'Win10 1607'
        }
        if ($Item.Name -match 'Win10 15063') {  
            $Item.OSReleaseId = '1703'
            $Item.Name = $Item.Name -replace 'Win10 15063', 'Win10 1703'
        }
        if ($Item.Name -match 'Win10 16299') {
            $Item.OSReleaseId = '1709'
            $Item.Name = $Item.Name -replace 'Win10 16299', 'Win10 1709'
        }
        if ($Item.Name -match 'Win10 17134') {
            $Item.OSReleaseId = '1803'
            $Item.Name = $Item.Name -replace 'Win10 17134', 'Win10 1803'
        }
        if ($Item.Name -match 'Win10 17763') {
            $Item.OSReleaseId = '1809'
            $Item.Name = $Item.Name -replace 'Win10 17763', 'Win10 1809'
        }
        if ($Item.Name -match 'Win10 18362') {
            $Item.OSReleaseId = '1903'
            $Item.Name = $Item.Name -replace 'Win10 18362', 'Win10 1903'
        }
        if ($Item.Name -match 'Win10 18363') {
            $Item.OSReleaseId = '1909'
            $Item.Name = $Item.Name -replace 'Win10 18363', 'Win10 1909'
        }
        if ($Item.Name -match 'Win10 19041') {
            $Item.OSReleaseId = '2004'
            $Item.Name = $Item.Name -replace 'Win10 19041', 'Win10 2004'
        }
        if ($Item.Name -match 'Win10 19042') {
            $Item.OSReleaseId = '20H2'
            $Item.Name = $Item.Name -replace 'Win10 19042', 'Win10 20H2'
        }
        if ($Item.Name -match 'Win10 19043') {
            $Item.OSReleaseId = '21H1'
            $Item.Name = $Item.Name -replace 'Win10 19043', 'Win10 21H1'
        }
        if ($Item.Name -match 'Win10 19044') {
            $Item.OSReleaseId = '21H2'
            $Item.Name = $Item.Name -replace 'Win10 19044', 'Win10 21H2'
        }
        if ($Item.Name -match 'Win10 19045') {
            $Item.OSReleaseId = '22H2'
            $Item.Name = $Item.Name -replace 'Win10 19045', 'Win10 22H2'
        }
        if ($Item.Name -match 'Win11 22000') {
            $Item.OSReleaseId = '21H2'
            $Item.Name = $Item.Name -replace 'Win11 22000', 'Win11 21H2'
        }
        if ($Item.Name -match 'Win11 22621') {
            $Item.OSReleaseId = '22H2'
            $Item.Name = $Item.Name -replace 'Win11 22621', 'Win11 22H2'
        }
    }
    #=================================================
    #   UpdateModule
    #=================================================
    if ($UpdateModuleCatalog) {
        Write-Verbose -Verbose "UpdateModule: Exporting to OSD Module Catalogs at $ModuleCatalogXml"
        $MasterResults | Export-Clixml -Path $ModuleCatalogXml -Force
        Write-Verbose -Verbose "UpdateModule: Exporting to OSD Module Catalogs at $ModuleCatalogJson"
        $MasterResults | ConvertTo-Json | Out-File $ModuleCatalogJson -Encoding ascii -Width 2000 -Force
        #=================================================
        #   UpdateCatalog
        #=================================================
        $MasterDriverPacks = @()
        $MasterDriverPacks += Get-DellDriverPack
        $MasterDriverPacks += Get-HPDriverPack
        $MasterDriverPacks += Get-LenovoDriverPack
        $MasterDriverPacks += Get-MicrosoftDriverPack
    
        $Results = $MasterDriverPacks | `
        Select-Object CatalogVersion, Status, ReleaseDate, Manufacturer, Model, `
        Product, Name, PackageID, FileName, `
        @{Name='Url';Expression={([array]$_.DriverPackUrl)}}, `
        @{Name='OS';Expression={([array]$_.DriverPackOS)}}, `
        OSReleaseId,OSBuild,HashMD5, `
        @{Name='Guid';Expression={([guid]((New-Guid).ToString()))}}
    
        $Results | Export-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudDriverPacks.xml") -Force
        Import-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | `
        Sort-Object Version -Descending | `
        Select-Object -First 1).ModuleBase "Catalogs\CloudDriverPacks.xml") | `
        ConvertTo-Json | `
        Out-File (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudDriverPacks.json") -Encoding ascii -Width 2000 -Force
    }
    #=================================================
    #   Results
    #=================================================
    Write-Verbose -Verbose 'Complete: Results have been stored $Global:MicrosoftDriverPackCatalog'
    $Global:MicrosoftDriverPackCatalog = $MasterResults | Sort-Object -Property Name
    #=================================================
}