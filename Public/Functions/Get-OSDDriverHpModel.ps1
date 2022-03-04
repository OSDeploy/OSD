<#
.SYNOPSIS
Returns a PowerShell Object of the HP Model Driver Packs

.DESCRIPTION
Returns a PowerShell Object of the HP Model Driver Packs by parsing the Catalog at https://ftp.hp.com/pub/caps-softpaq/cmit/HPClientDriverPackCatalog.cab"

.LINK
https://osd.osdeploy.com
#>
function Get-OSDDriverHpModel {
    [CmdletBinding()]
    param ()
    #=================================================
    #   Variables
    #=================================================
    $global:SetOSDDriverHpModel = [ordered]@{
        Downloads                   = "$env:TEMP\OSD"
        UrlDownloads                = ''
        UrlDownloadsList            = ''
        UrlCommunity                = ''
        UrlBios64Utility            = ''
        UrlDriverPackTable          = ''
        UrlCabCatalogPC             = ''
        UrlCabDriverPackCatalog     = 'https://ftp.hp.com/pub/caps-softpaq/cmit/HPClientDriverPackCatalog.cab'
    }

    $global:SetOSDDriverHpModel.CatalogPCCab           = $null
    $global:SetOSDDriverHpModel.DriverPackCatalogCab   = [string]($global:SetOSDDriverHpModel.UrlCabDriverPackCatalog | Split-Path -Leaf)

    $DownloadPath = $global:SetOSDDriverHpModel.Downloads
    $DriverPackCatalogCab = $global:SetOSDDriverHpModel.DriverPackCatalogCab
    $DriverPackCatalogCabFullName = Join-Path $DownloadPath $DriverPackCatalogCab
    $DriverPackCatalogXmlFullName = Join-Path $DownloadPath 'DriverPackCatalog.xml'
    $UrlDownloads = $global:SetOSDDriverHpModel.UrlDownloads
    $UrlCabDriverPackCatalog = $global:SetOSDDriverHpModel.UrlCabDriverPackCatalog
    #=================================================
    #   Create DownloadPath
    #=================================================
    if (-not (Test-Path $DownloadPath)) {
        Write-Verbose "Get-OSDDriverHpModel: Creating $DownloadPath"
        New-Item $DownloadPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    #=================================================
    #   Download DriverPackCatalog.cab
    #=================================================
    (New-Object System.Net.WebClient).DownloadFile($UrlCabDriverPackCatalog, $DriverPackCatalogCabFullName)

    Expand $DriverPackCatalogCabFullName $DriverPackCatalogXmlFullName | Out-Null

    if (Test-Path $DriverPackCatalogCabFullName) {
        Remove-Item -Path "$DriverPackCatalogCabFullName" -Force | Out-Null
    } else {
        Write-Warning "Get-OSDDriverHpModel: Unable to download $UrlCabDriverPackCatalog"
        Break
    }
    #=================================================
    #   HP Catalog
    #=================================================
    [xml]$DriverPackCatalogXmlContent = Get-Content "$DriverPackCatalogXmlFullName" -ErrorAction Stop
    $DriverPackCatalog = $DriverPackCatalogXmlContent.NewDataSet.HPClientDriverPackCatalog.SoftPaqList.SoftPaq
    $HpProductOSDriverPackList = $DriverPackCatalogXmlContent.NewDataSet.HPClientDriverPackCatalog.ProductOSDriverPackList.ProductOSDriverPack
    Write-Warning "Get-OSDDriverHpModel: Results are limited to Windows 10 x64"
    #=================================================
    #   ForEach
    #=================================================
    $ErrorActionPreference = 'SilentlyContinue'
    $global:GetOSDDriverHpModel = @()
    $global:GetOSDDriverHpModel = foreach ($item in $DriverPackCatalog) {
        #=================================================
        #   Skip
        #=================================================
        if ($item.Name -match 'IOT') {Continue}
        #=================================================
        #   Defaults
        #=================================================
        $OSDVersion = $(Get-Module -Name OSD | Sort-Object Version | Select-Object Version -Last 1).Version
        $LastUpdate = [datetime] $item.DateReleased
        $OSDStatus = $null
        $OSDType = 'ModelPack'
        $OSDGroup = 'HPModel'

        $DriverName = $item.Name
        if ($DriverName -match 'x86') {Continue}
        if ($DriverName -match 'Win7') {Continue}
        if ($DriverName -match 'Win 7') {Continue}
        if ($DriverName -match 'Windows 7') {Continue}
        if ($DriverName -match 'Win 8') {Continue}
        if ($DriverName -match 'Windows 8') {Continue}


        $DriverName = ($DriverName).Replace('/',' ')
        $DriverName = ($DriverName).Replace(' x64','')
        $DriverName = ($DriverName).Replace(' x86','')
        $DriverName = ($DriverName).Replace(' Win7','')
        $DriverName = ($DriverName).Replace(' Win10','')
        $DriverName = ($DriverName).Replace(' Win 7','')
        $DriverName = ($DriverName).Replace(' Win 10','')
        $DriverName = ($DriverName).Replace(' Windows 7','')
        $DriverName = ($DriverName).Replace(' Windows 10','')
        $DriverName = ($DriverName).Replace(' Driver Pack','')

        $DriverVersion = $item.Version.Trim()
        $DriverReleaseId = ($item.Url | Split-Path -Leaf).Replace('.exe','').ToUpper()
        $DriverGrouping = $null
        #=================================================
        #   Matching
        #=================================================
        $MatchingList = @()
        $MatchingList = $HpProductOSDriverPackList | Where-Object {$_.SoftPaqId -match $DriverReleaseId}

        $OperatingSystem = @()
        $OsVersion = $null
        $OsArch = $null
        $OsBuildMax = @()
        $OsBuildMin = @()

        $Make = 'HP'
        $MakeNe = @()
        $MakeLike = @()
        $MakeNotLike = @()
        $MakeMatch = @()
        $MakeNotMatch = @()

        $Generation = 'G0'
        $SystemFamily = $null

        $Model = ($MatchingList | Select-Object -Property SystemName -Unique)
        $Model = ($Model).SystemName
        #$Model = $null
        $ModelNe = @()
        $ModelLike = @()
        $ModelNotLike = @()
        $ModelMatch = @()
        $ModelNotMatch = @()

        $SystemSku = @()
        $SystemSku = ($MatchingList | Select-Object -Property SystemId -Unique)
        $SystemSku = ($SystemSku).SystemId
        #$SystemSku = $SystemSku | Select-Object SystemId -ExpandProperty
        $SystemSkuNe = @()

        $DriverBundle = $null
        $DriverWeight = 100

        $DownloadFile = $item.Url | Split-Path -Leaf
        $SizeMB = ($item.Size.Trim() | Select-Object -Unique) / 1024
        $DriverUrl = $item.Url
        $DriverInfo = $item.CvaFileUrl
        $DriverDescription = $item.ReleaseNotesUrl
        $Hash = $item.MD5.Trim()
        $OSDGuid = $(New-Guid)
        #=================================================
        #   Get Values
        #=================================================
        if ($item.Name -match 'x64') {$OsArch = 'x64'}
        if ($item.Name -match 'x86') {$OsArch = 'x86'}
        if ($null -eq $OsArch) {$OsArch = 'x64'}
        if ($item.Name -match 'Win7') {$OsVersion = '6.1'}
        if ($item.Name -match 'Win 7') {$OsVersion = '6.1'}
        if ($item.Name -match 'Window 7') {$OsVersion = '6.1'}
        if ($item.Name -match 'Windows 7') {$OsVersion = '6.1'}
        if ($item.Name -match 'Win8') {$OsVersion = '6.3'}
        if ($item.Name -match 'Win 8') {$OsVersion = '6.3'}
        if ($item.Name -match 'Windows 8') {$OsVersion = '6.3'}
        if ($item.Name -match 'Win10') {$OsVersion = '10.0'}
        if ($item.Name -match 'Win 10') {$OsVersion = '10.0'}
        if ($item.Name -match 'Windows 10') {$OsVersion = '10.0'}

        if ($item.Name -match 'G1') {$Generation = 'G1'}
        if ($item.Name -match 'G2') {$Generation = 'G2'}
        if ($item.Name -match 'G3') {$Generation = 'G3'}
        if ($item.Name -match 'G4') {$Generation = 'G4'}
        if ($item.Name -match 'G5') {$Generation = 'G5'}
        if ($item.Name -match 'G6') {$Generation = 'G6'}
        if ($item.Name -match 'G7') {$Generation = 'G7'}
        if ($item.Name -match 'G8') {$Generation = 'G8'}
        if ($item.Name -match 'G9') {$Generation = 'G8'}
        #=================================================
        #   SystemFamily
        #=================================================
        #=================================================
        #   Corrections
        #=================================================
        if ($SystemSku -contains '81C6') {$Generation = 'G4'}
        if ($SystemSku -contains '81C7') {$Generation = 'G4'}
        if ($SystemSku -contains '824C') {$Generation = 'G4'}
        #=================================================
        #   Customizations
        #=================================================
        if (Test-Path "$DownloadPath\$DownloadFile") {
            $OSDStatus = 'Downloaded'
        }
        #=================================================
        #   Create Object 
        #=================================================
        $ObjectProperties = @{
            OSDVersion              = [string]$OSDVersion
            LastUpdate              = $(($LastUpdate).ToString("yyyy-MM-dd"))
            OSDStatus               = $OSDStatus
            OSDType                 = $OSDType
            OSDGroup                = $OSDGroup

            DriverName              = "$DriverName $OsVersion $OsArch $DriverVersion"
            DriverVersion           = $DriverVersion
            DriverReleaseId         = $DriverReleaseID

            OperatingSystem         = $OperatingSystem
            OsCode                  = $OsCode
            OsVersion               = $OsVersion
            OsArch                  = $OsArch
            OsBuildMax              = $OsBuildMax
            OsBuildMin              = $OsBuildMin

            Make                    = $Make
            MakeNe                  = $MakeNe
            MakeLike                = $MakeLike
            MakeNotLike             = $MakeNotLike
            MakeMatch               = $MakeMatch
            MakeNotMatch            = $MakeNotMatch

            Generation              = $Generation
            SystemFamily            = $SystemFamily

            Model                   = $Model
            ModelNe                 = $ModelNe
            ModelLike               = $ModelLike
            ModelNotLike            = $ModelNotLike
            ModelMatch              = $ModelMatch
            ModelNotMatch           = $ModelNotMatch

            SystemSku               = $SystemSku -split(',')
            SystemSkuNe             = $SystemSkuNe

            DriverGrouping          = "$DriverName $OsVersion $OsArch"
            DriverBundle            = $DriverBundle
            DriverWeight            = [int] $DriverWeight

            DownloadFile            = $DownloadFile
            SizeMB                  = [int] $SizeMB
            DriverUrl               = $DriverUrl
            DriverInfo              = $DriverInfo
            DriverDescription       = $DriverDescription
            Hash                    = $Hash
            OSDGuid                 = $OSDGuid
            IsSuperseded            = [bool] $IsSuperseded
        }
        New-Object -TypeName PSObject -Property $ObjectProperties
    }
    #=================================================
    #   Supersedence
    #=================================================
    $global:GetOSDDriverHpModel = $global:GetOSDDriverHpModel | Sort-Object LastUpdate -Descending
    $CurrentOSDDriverHpModelPack = @()
    foreach ($HpModelPack in $global:GetOSDDriverHpModel) {
        if ($CurrentOSDDriverHpModelPack.DriverGrouping -match $HpModelPack.DriverGrouping) {
            $HpModelPack.IsSuperseded = $true
        } else { 
            $CurrentOSDDriverHpModelPack += $HpModelPack
        }
    }
    $global:GetOSDDriverHpModel = $global:GetOSDDriverHpModel | Where-Object {$_.IsSuperseded -eq $false}
    #=================================================
    #   Select-Object
    #=================================================
    $global:GetOSDDriverHpModel = $global:GetOSDDriverHpModel | Select-Object LastUpdate,`
    OSDType, OSDGroup, OSDStatus, `
    DriverGrouping, DriverName, Make, Generation, Model, SystemSku,`
    DriverVersion, DriverReleaseId,`
    OsVersion, OsArch,`
    DownloadFile, SizeMB, DriverUrl, DriverInfo, DriverDescription,
    Hash, OSDGuid, OSDVersion
    #=================================================
    #   Sort Object
    #=================================================
    $global:GetOSDDriverHpModel = $global:GetOSDDriverHpModel | Sort-Object LastUpdate -Descending
    #=================================================
    #   Return
    #=================================================
    Return $global:GetOSDDriverHpModel
    #=================================================
}