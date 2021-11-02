<#
.SYNOPSIS
Returns a Intel Display Driver Object

.DESCRIPTION
Returns a Intel Display Driver Object
Requires BITS for downloading the Downloads
Requires Internet access for downloading the Downloads

.LINK
https://osddrivers.osdeploy.com/functions/get-driverinteldisplay
#>
function Get-OSDDriverIntelDisplay {
    [CmdletBinding()]
    param ()
    #=================================================
    #   DriverWebPages
    #=================================================
    $DriverWebPages = @(
        'https://intel.com/content/www/us/en/download/19344/intel-graphics-windows-dch-drivers.html'
        'https://intel.com/content/www/us/en/download/19387/intel-graphics-beta-windows-dch-drivers.html'
        'https://intel.com/content/www/us/en/download/19282/radeon-rx-vega-m-graphics.html'
        'https://intel.com/content/www/us/en/download/18799/intel-graphics-driver-for-windows-15-45.html'
        'https://intel.com/content/www/us/en/download/18369/intel-graphics-driver-for-windows-15-40.html'
        'https://intel.com/content/www/us/en/download/18563/intel-graphics-driver-for-windows-7-8-1-15-40-6th-gen.html'
        'https://intel.com/content/www/us/en/download/18424/intel-graphics-driver-for-windows-7-8-1-15-36.html'
        'https://intel.com/content/www/us/en/download/18606/intel-graphics-driver-for-windows-15-33.html'
        'https://intel.com/content/www/us/en/download/18338/intel-hd-graphics-production-driver-for-windows-10-64-bit-n-series.html'
        'https://intel.com/content/www/us/en/download/18301/intel-hd-graphics-production-driver-for-windows-10-32-bit-n-series.html'
    )
    #=================================================
    #   ForEach
    #=================================================
    $ZipFileResults = @()
    $DriverResults = @()
    $DriverResults = foreach ($DriverWebPage in $DriverWebPages) {
        if ($DriverWebPage -match '19344'){$DriverResultsName = 'Intel Graphics DCH'}
        if ($DriverWebPage -match '19387'){$DriverResultsName = 'Intel Graphics DCH Beta'}
        if ($DriverWebPage -match '19282'){$DriverResultsName = 'Intel Radeon RX Vega M'}
        if ($DriverWebPage -match '18799'){$DriverResultsName = 'Intel Graphics 15.45'}
        if ($DriverWebPage -match '18563'){$DriverResultsName = 'Intel Graphics 15.40'}
        if ($DriverWebPage -match '18424'){$DriverResultsName = 'Intel Graphics 15.36'}
        if ($DriverWebPage -match '18606'){$DriverResultsName = 'Intel Graphics 15.33'}
        if ($DriverWebPage -match '18338'){$DriverResultsName = 'Intel Graphics HD N Series'}
        if ($DriverWebPage -match '18301'){$DriverResultsName = 'Intel Graphics HD N Series'}
        $DriverInfo = $DriverWebPage
        Write-Verbose "DriverInfo: $DriverInfo" -Verbose
        #=================================================
        #   Intel WebRequest
        #=================================================
        $DriverWebPageContent = Invoke-WebRequest -Uri $DriverInfo -Method Get

        $DriverHTML = $DriverWebPageContent.ParsedHtml.childNodes | Where-Object {$_.nodename -eq 'HTML'} 
        $DriverHEAD = $DriverHTML.childNodes | Where-Object {$_.nodename -eq 'HEAD'}
        $DriverMETA = $DriverHEAD.childNodes | Where-Object {$_.nodename -like "meta*"} | Select-Object -Property Name, Content
        $DriverCONTENT = $DriverWebPageContent.Content

        #$DriverType = $DriverMETA | Where-Object {$_.name -eq 'DownloadType'} | Select-Object -ExpandProperty Content
        $DriverCompatibility = $DriverMETA | Where-Object {$_.name -eq 'DownloadOSes'} | Select-Object -ExpandProperty Content
        Write-Verbose "DriverCompatibility: $DriverCompatibility" -Verbose
        #=================================================
        #   Driver Filter
        #=================================================
        $ZipFileResults = @($DriverCONTENT -split " " -split '"' -match 'http' -match ".zip")
        $ZipFileResults = $ZipFileResults | Select-Object -Unique
        #=================================================
        #   Driver Details
        #=================================================
        foreach ($DriverZipFile in $ZipFileResults) {
            Write-Verbose "$DriverZipFile" -Verbose
            #=================================================
            #   Defaults
            #=================================================
            $OSDVersion = $(Get-Module -Name OSD | Sort-Object Version | Select-Object Version -Last 1).Version
            $LastUpdate = [datetime] $(Get-Date)
            $OSDStatus = $null
            $OSDGroup = 'IntelDisplay'
            $OSDType = 'Driver'

            $DriverName = $null
            $DriverVersion = $null
            $DriverReleaseId = $null
            $DriverGrouping = $null

            $OperatingSystem = @()
            $OsVersion = @()
            $OsArch = @()
            $OsBuildMax = @()
            $OsBuildMin = @()
    
            $Make = @()
            $MakeNe = @()
            $MakeLike = @()
            $MakeNotLike = @()
            $MakeMatch = @()
            $MakeNotMatch = @('Microsoft')
    
            $Generation = $null
            $SystemFamily = $null
    
            $Model = @()
            $ModelNe = @()
            $ModelLike = @()
            $ModelNotLike = @()
            $ModelMatch = @()
            $ModelNotMatch = @('Surface')
    
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
            #   LastUpdate
            #=================================================
            #$LastUpdateRaw = $DriverMETA | Where-Object {$_.name -eq 'LastUpdate'} | Select-Object -ExpandProperty Content
            #$LastUpdate = [datetime]::ParseExact($LastUpdateRaw, "MM/dd/yyyy HH:mm:ss", $null)

            $LastUpdateRaw = $DriverMETA | Where-Object {$_.name -eq 'LastUpdate'} | Select-Object -ExpandProperty Content
            Write-Verbose "LastUpdateRaw: $LastUpdateRaw"

            $LastUpdateSplit = ($LastUpdateRaw -split (' '))[0]
            Write-Verbose "LastUpdateSplit: $LastUpdateSplit"

            $LastUpdate = [datetime]::Parse($LastUpdateSplit)
            Write-Verbose "LastUpdate: $LastUpdate"
            #=================================================
            #   DriverVersion
            #=================================================
            $DriverVersion = $DriverMETA | Where-Object {$_.name -eq 'DownloadVersion'} | Select-Object -ExpandProperty Content
            #=================================================
            #   DriverUrl
            #=================================================
            #$DriverUrl = $DriverZipFile.'data-direct-path'
            $DriverUrl = $DriverZipFile
            #=================================================
            #   OsArch
            #=================================================
            if (($DriverWebPage -match '19344') -or ($DriverUrl -match 'Win64') -or ($DriverUrl -match 'Driver64') -or ($DriverUrl -match '64_') -or ($DriverInfo -match '64-Bit')) {
                $OsArch = 'x64'
            } else {
                $OsArch = 'x86'
            }
            #=================================================
            #   OS
            #=================================================
            if ($DriverResultsName -eq 'Intel Graphics MA') {
                $OsVersion = @('6.1')
            } 
            if ($DriverResultsName -match 'Intel Graphics HD') {
                $OsVersion = @('6.1','6.3')
            }
            if ($DriverResultsName -eq 'Intel Graphics 15.33') {
                $OsVersion = @('6.1','6.3','10.0')
            }
            if ($DriverResultsName -eq 'Intel Graphics 15.36') {
                $OsVersion = @('6.1','6.3')
            }
            if ($DriverResultsName -eq 'Intel Graphics 15.40') {
                $OsVersion = @('6.1','6.3','10.0')
            }
            if ($DriverResultsName -eq 'Intel Graphics 15.45') {
                $OsVersion = @('6.1','6.3')
            }
            if ($DriverResultsName -match 'Intel Graphics DCH') {
                $OsVersion = @('10.0')
                $OsArch = 'x64'
            }
            if ($DriverResultsName -match 'Radeon') {
                $OsVersion = @('10.0')
                $OsArch = 'x64'
            }
            #=================================================
            #   Values
            #=================================================
            $DriverName = "$OSDGroup $DriverVersion $OsArch"
            $DriverGrouping = "$DriverResultsName $OsArch $OsVersion"
            $DriverDescription = $DriverMETA | Where-Object {$_.name -eq 'Description'} | Select-Object -ExpandProperty Content
            $DriverInfo = $DriverWebPage
            $DownloadFile = Split-Path $DriverUrl -Leaf
            $OSDPnpClass = 'Display'
            $OSDPnpClassGuid = '{4D36E968-E325-11CE-BFC1-08002BE10318}'
            #=================================================
            #   Create Object
            #=================================================
            $ObjectProperties = @{
                OSDVersion              = [string] $OSDVersion
                LastUpdate              = [datetime] $LastUpdate
                OSDStatus               = [string] $OSDStatus
                OSDType                 = [string] $OSDType
                OSDGroup                = [string] $OSDGroup
    
                DriverName              = [string] $DriverName
                DriverVersion           = [string] $DriverVersion
                DriverReleaseId         = [string] $DriverReleaseID
    
                OperatingSystem         = [string[]] $OperatingSystem
                OsVersion               = [string[]] $OsVersion
                OsArch                  = [string[]] $OsArch
                OsBuildMax              = [string] $OsBuildMax
                OsBuildMin              = [string] $OsBuildMin
    
                Make                    = [string[]] $Make
                MakeNe                  = [string[]] $MakeNe
                MakeLike                = [string[]] $MakeLike
                MakeNotLike             = [string[]] $MakeNotLike
                MakeMatch               = [string[]] $MakeMatch
                MakeNotMatch            = [string[]] $MakeNotMatch
    
                Generation              = [string] $Generation
                SystemFamily            = [string] $SystemFamily
    
                Model                   = [string[]] $Model
                ModelNe                 = [string[]] $ModelNe
                ModelLike               = [string[]] $ModelLike
                ModelNotLike            = [string[]] $ModelNotLike
                ModelMatch              = [string[]] $ModelMatch
                ModelNotMatch           = [string[]] $ModelNotMatch
    
                SystemSku               = [string[]] $SystemSku
                SystemSkuNe             = [string[]] $SystemSkuNe
    
                SystemFamilyMatch       = [string[]] $SystemFamilyMatch
                SystemFamilyNotMatch    = [string[]] $SystemFamilyNotMatch
    
                SystemSkuMatch          = [string[]] $SystemSkuMatch
                SystemSkuNotMatch       = [string[]] $SystemSkuNotMatch
    
                DriverGrouping          = [string] $DriverGrouping
                DriverBundle            = [string] $DriverBundle
                DriverWeight            = [int] $DriverWeight
    
                DownloadFile            = [string] $DownloadFile
                SizeMB                  = [int] $SizeMB
                DriverUrl               = [string] $DriverUrl
                DriverInfo              = [string] $DriverInfo
                DriverDescription       = [string] $DriverDescription
                Hash                    = [string] $Hash
                OSDGuid                 = [string] $OSDGuid
    
                OSDPnpClass             = [string] $OSDPnpClass
                OSDPnpClassGuid         = [string] $OSDPnpClassGuid
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
    }
    #=================================================
    #   Remove Duplicates
    #=================================================
    $DriverResults = $DriverResults | Sort-Object DriverUrl -Unique
    #=================================================
    #   Select-Object
    #=================================================
    $DriverResults = $DriverResults | Select-Object OSDVersion, LastUpdate, OSDStatus, OSDType, OSDGroup,`
    DriverName, DriverVersion,`
    OsVersion, OsArch, MakeNotMatch, ModelNotMatch,`
    DriverGrouping,`
    DownloadFile, DriverUrl, DriverInfo, DriverDescription,`
    OSDGuid,`
    OSDPnpClass, OSDPnpClassGuid
    #=================================================
    #   Sort-Object
    #=================================================
    $DriverResults = $DriverResults | Sort-Object -Property LastUpdate -Descending
    #=================================================
    #   Return
    #=================================================
    Return $DriverResults
    #=================================================
}