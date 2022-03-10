<#
.SYNOPSIS
Returns a PowerShell Object of the Dell Model Driver Packs

.DESCRIPTION
Returns a PowerShell Object of the Dell Model Driver Packs by parsing the Catalog at http://downloads.dell.com/catalog/DriverPackCatalog.cab"

.LINK
https://osd.osdeploy.com
#>
function Get-CatalogDellOSDDrivers {
    [CmdletBinding()]
    param ()
    #=================================================
    #   DriverPackCatalog
    #=================================================
    $DriverPackCatalog = Get-OSDCatalogDellDriverPack
    #=================================================
    #   ForEach
    #=================================================
    $ErrorActionPreference = 'SilentlyContinue'
    $global:GetOSDDriverDellModel = @()
    $global:GetOSDDriverDellModel = foreach ($item in $DriverPackCatalog) {
        #=================================================
        #   Defaults
        #=================================================
        $OSDVersion = $(Get-Module -Name OSD | Sort-Object Version | Select-Object Version -Last 1).Version
        $LastUpdate = [datetime] $(Get-Date)
        $OSDStatus = $null
        $OSDType = 'ModelPack'
        $OSDGroup = 'DellModel'

        $DriverName = $null
        $DriverVersion = $null
        $DriverReleaseId = $null
        $DriverGrouping = $null

        $OperatingSystem = @()
        $OsVersion = @()
        $OsArch = @()
        $OsBuildMax = @()
        $OsBuildMin = @()

        $Make = 'Dell'
        $MakeNe = @()
        $MakeLike = @()
        $MakeNotLike = @()
        $MakeMatch = @()
        $MakeNotMatch = @()

        $Generation = 'XX'
        $SystemFamily = $null

        $Model = $null
        $ModelNe = @()
        $ModelLike = @()
        $ModelNotLike = @()
        $ModelMatch = @()
        $ModelNotMatch = @()

        $SystemSku = @()
        $SystemSkuNe = @()

        $DriverBundle = $null
        $DriverWeight = 100

        $DownloadFile = $null
        $SizeMB = $null
        $DriverUrl = $null
        $DriverInfo = $null
        $DriverDescription = $null
        $Hash = $null
        $OSDGuid = $(New-Guid)
        #=================================================
        #   Get Values
        #=================================================
        $LastUpdate         = [datetime] $item.ReleaseDate
        $DriverVersion      = $item.DellVersion
        $DriverReleaseId    = $item.ReleaseID
        $OperatingSystem    = $item.SupportedOS
        $OsCode             = $item.osCode
        $OsArch             = $item.osArch
        $Generation         = $item.Generation
        $Model              = $item.Model
        $SystemSku          = $item.SystemID
        $DownloadFile       = $item.FileName
        $SizeMB             = $item.SizeMB
        $DriverUrl          = $item.Url
        $DriverInfo         = $item.ImportantInfoUrl
        $Hash               = $item.HashMD5

        $OsMajor            = $item.majorVersion
        $OsMinor            = $item.minorVersion
        $ModelBrand         = $item.Brand
        $ModelBrandKey      = $item.Key
        $ModelId            = $item.Model
        $ModelRtsDate       = [datetime] $item.rtsDate
        $ModelPrefix        = $item.Prefix

        if ($null -eq $Model) {Continue}
        #=================================================
        #   DriverFamily
        #=================================================
        if ($ModelPrefix -eq 'IOT') {
            $SystemFamily = 'IOT'
            $IsDesktop = $true
        }
        if ($ModelPrefix -eq 'LAT') {
            $SystemFamily = 'Latitude'
            $IsLaptop = $true
        }
        if ($ModelPrefix -eq 'OP') {
            $SystemFamily = 'Optiplex'
            $IsDesktop = $true
        }
        if ($ModelPrefix -eq 'PRE') {
            $SystemFamily = 'Precision'
        }
        if ($ModelPrefix -eq 'TABLET') {
            $SystemFamily = 'Tablet'
            $IsLaptop = $true
        }
        if ($ModelPrefix -eq 'XPSNOTEBOOK') {
            $SystemFamily = 'XPS'
            $IsLaptop = $true
        }
        #=================================================
        #   Corrections
        #=================================================
        if ($Model -eq 'Latitude E6420' -and $SystemSku -eq '04E4') {$Model = 'Latitude E6420 XFR'}
        if ($Model -eq 'Precision M4600') {$Generation = 'X3'}
        if ($Model -eq 'Precision M3800') {$Model = 'Dell Precision M3800'}
        #=================================================
        #   Customizations
        #=================================================
        if ($OsCode -eq 'XP') {Continue}
        if ($OsCode -eq 'Vista') {Continue}
        #if ($OsCode -eq 'Windows8') {Continue}
        #if ($OsCode -eq 'Windows8.1') {Continue}
        if ($OsCode -match 'WinPE') {Continue}
        $OsVersion = "$($OsMajor).$($OsMinor)"
        if ($OsCode -eq 'Windows7') {$OsVersion = 'Win7'}
        if ($OsCode -eq 'Windows10') {$OsVersion = 'Win10'}
        if ($OsCode -eq 'Windows11') {$OsVersion = 'Win11'}
        $DriverName = "$OSDGroup $($Item.Name)"
        $DriverGrouping = "$Model $OsVersion"

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

            DriverName              = $DriverName
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

            SystemSku               = $SystemSku
            SystemSkuNe             = $SystemSkuNe

            DriverGrouping          = $DriverGrouping
            DriverBundle            = $DriverBundle
            DriverWeight            = [int] $DriverWeight

            DownloadFile            = $DownloadFile
            SizeMB                  = [int] $SizeMB
            DriverUrl               = $DriverUrl
            DriverInfo              = $DriverInfo
            DriverDescription       = $DriverDescription
            Hash                    = $Hash
            OSDGuid                 = $OSDGuid
        }
        New-Object -TypeName PSObject -Property $ObjectProperties
    }
    #=================================================
    #   Select-Object
    #=================================================
    $global:GetOSDDriverDellModel = $global:GetOSDDriverDellModel | Select-Object LastUpdate,`
    OSDType, OSDGroup, OSDStatus, `
    DriverName, DriverGrouping, Make, Generation, Model, SystemSku,`
    DriverVersion, DriverReleaseId,`
    OsCode, OsVersion, OsArch,
    DownloadFile, SizeMB, DriverUrl, DriverInfo,`
    Hash, OSDGuid, OSDVersion
    #=================================================
    #   Sort Object
    #=================================================
    $global:GetOSDDriverDellModel = $global:GetOSDDriverDellModel | Sort-Object DriverName
    #=================================================
    #   Return
    #=================================================
    Return $global:GetOSDDriverDellModel
    #=================================================
}