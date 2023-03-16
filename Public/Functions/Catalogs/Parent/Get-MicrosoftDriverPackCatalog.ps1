<#
.SYNOPSIS
Builds the Microsoft Surface DriverPacks

.DESCRIPTION
Builds the Microsoft Surface DriverPacks

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-MicrosoftDriverPackCatalog {
    [CmdletBinding()]
    param (
        #Specifies a download path for matching results displayed in Out-GridView
        [System.String]
        $DownloadPath,

        #Limits the results to match the current system
        [System.Management.Automation.SwitchParameter]
        $Compatible,

        #Checks for the latest Online version
        [System.Management.Automation.SwitchParameter]
        $Online,

        #Updates the OSD Module Offline Catalog
        [System.Management.Automation.SwitchParameter]
        $UpdateModuleCatalog
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
    $UseCatalog = 'Offline'
    $OfflineCatalogName = 'MicrosoftDriverPackCatalog.json'

    $OnlineCatalogName = 'MicrosoftDriverPackCatalog.json'
    $OnlineBaseUri = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id='
    $OnlineCatalogUri = 'https://support.microsoft.com/en-us/surface/download-drivers-and-firmware-for-surface-09bb2e09-2a4b-cb69-0951-078a7739e120'

    $MicrosoftSurfaceModels = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\MicrosoftSurfaceModels.json" -Raw
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
        $Results = $MicrosoftSurfaceModels | ConvertFrom-Json
        $MasterResults = @()
    
        $MasterResults = foreach ($Item in $Results) {
            Write-Verbose "Processing $($Item.Name)"
            $DriverPage = $OnlineBaseUri + $Item.PackageID
            $Downloads = (Invoke-WebRequest -Uri $DriverPage).Links
            $Downloads = $Downloads | Where-Object {$_.href -match 'download.microsoft.com'}
            $Downloads = $Downloads | Where-Object {($_.href -match 'Win11') -or ($_.href -match 'Win10')}
            $Downloads = $Downloads | Sort-Object href | Select-Object href -Unique
            #$Downloads = $Downloads | Select-Object -Last 1
            #$Item.Url = ($Downloads).href
            #$Item.FileName = Split-Path $Item.Url -Leaf
            #=================================================
            #   Create Object
            #=================================================
            foreach ($Download in $Downloads) {
                $DownloadUrl = $Download.href
                Write-Verbose "Testing Download File at $DownloadUrl"

                $GetUrl = Invoke-WebRequest -Method Head -Uri $DownloadUrl
                $GetHeaders = $GetUrl.Headers
                $GetLastModified = $GetHeaders['Last-Modified']
                Write-Verbose "Last Modified: $GetLastModified"

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

                $UniqueName = "Microsoft $($Item.Name) $UniqueFileName"

                $ObjectProperties = [ordered] @{
                    CatalogVersion          = Get-Date -Format yy.MM.dd
                    Status                  = $null
                    Component               = 'DriverPack'
                    ReleaseDate             = $ReleaseDate
                    Manufacturer            = 'Microsoft'
                    Model                   = $Item.Model
                    Product                 = $Item.Product
                    Name                    = $UniqueName
                    PackageID               = $Item.PackageID
                    FileName                = $FileName
                    Url                     = $DownloadUrl
                    OSVersion               = $OSVersion
                    HashMD5                 = $HashMD5
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
        }
        $MasterResults | ConvertTo-Json | Out-File $TempCatalogFile -Encoding ascii -Width 2000 -Force

        if (Test-Path $TempCatalogFile) {
            $UseCatalog = 'Build'
        }
        else {
            Write-Verbose "Could not locate $TempCatalogFile"
            $UseCatalog = 'Offline'
        }
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
        $MasterResults = Get-Content -Path $ModuleCatalogFile | ConvertFrom-Json
    }
    #=================================================
    #   Compatible
    #=================================================
    if ($PSBoundParameters.ContainsKey('Compatible')) {
        $MyComputerProduct = Get-MyComputerProduct
        Write-Verbose "Filtering Catalog for items compatible with Product $MyComputerProduct"
        $MasterResults = $MasterResults | Where-Object {$_.Product -contains $MyComputerProduct}
    }
    #=================================================
    #   DownloadPath
    #=================================================
    if ($PSBoundParameters.ContainsKey('DownloadPath')) {
        $MasterResults = $MasterResults | Out-GridView -Title 'Select one or more files to Download' -PassThru -ErrorAction Stop
        foreach ($Item in $MasterResults) {
            $OutFile = Save-WebFile -SourceUrl $Item.Url -DestinationDirectory $DownloadPath -DestinationName $Item.FileName -Verbose
            $Item | ConvertTo-Json | Out-File "$($OutFile.FullName).json" -Encoding ascii -Width 2000 -Force
        }
    }
    #=================================================
    #   Results
    #=================================================
    $MasterResults | Sort-Object -Property Name
    #=================================================
}