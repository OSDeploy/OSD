function Get-OSDDriverIntelWireless {
    [CmdletBinding()]
    param ()
    #===================================================================================================
    #   Uri
    #===================================================================================================
    $Uri = 'https://www.intel.com/content/www/us/en/support/articles/000017246/network-and-i-o/wireless-networking.html'
    #===================================================================================================
    #   DriverWebContentRaw
    #===================================================================================================
    $DriverWebContentRaw = @()
    Write-Verbose "OSD: Get Latest Driver Versions $Uri" -Verbose
    try {
        $DriverWebContentRaw = (Invoke-WebRequest $Uri).Links
    }
    catch {
        Write-Error "OSD: Internet Explorer is used to parse the HTML data.  Make sure you can open the URL in Internet Explorer and that you dismiss any first run wizards" -ErrorAction Stop
    }
    #===================================================================================================
    #   DriverWebContent
    #===================================================================================================
    $DriverWebContent = @()
    $DriverWebContent = $DriverWebContentRaw
    #===================================================================================================
    #   Filter Results
    #===================================================================================================
    $DriverWebContent = $DriverWebContent | Select-Object -Property innerText, href
    $DriverWebContent = $DriverWebContent | Where-Object {$_.href -like "*downloadcenter.intel.com/download*"}
    $DriverWebContent = $DriverWebContent | Select-Object -First 1
    #===================================================================================================
    #   ForEach
    #===================================================================================================
    $UrlDownloads = @()
    $DriverResults = @()
    $DriverResults = foreach ($DriverLink in $DriverWebContent) {
        $DriverResultsName = $($DriverLink.innerText)
        $DriverInfo = $($DriverLink.href)
        Write-Verbose "OSD: Intel Wireless $DriverResultsName $DriverInfo" -Verbose
        #===================================================================================================
        #   Intel WebRequest
        #===================================================================================================
        $DriverInfoContent = Invoke-WebRequest -Uri $DriverInfo -Method Get

        $DriverHTML = $DriverInfoContent.ParsedHtml.childNodes | Where-Object {$_.nodename -eq 'HTML'} 
        $DriverHEAD = $DriverHTML.childNodes | Where-Object {$_.nodename -eq 'HEAD'}
        $DriverMETA = $DriverHEAD.childNodes | Where-Object {$_.nodename -like "meta*"}

<#         $DriverVersion = $DriverMETA | Where-Object {$_.name -eq 'DownloadVersion'} | Select-Object -ExpandProperty Content
        $DriverType = $DriverMETA | Where-Object {$_.name -eq 'DownloadType'} | Select-Object -ExpandProperty Content
        $DriverCompatibility = $DriverMETA | Where-Object {$_.name -eq 'DownloadOSes'} | Select-Object -ExpandProperty Content
        Write-Verbose "DriverCompatibility: $DriverCompatibility" -Verbose #>
        #===================================================================================================
        #   Driver Filter
        #===================================================================================================
        $UrlDownloads = ($DriverInfoContent).Links
        $UrlDownloads = $UrlDownloads | Where-Object {$_.innerText -notmatch 'Download'}
        $UrlDownloads = $UrlDownloads | Where-Object {$_.'data-direct-path' -like "*.zip"}
        $UrlDownloads = $UrlDownloads | Where-Object {$_.innerText -notlike "*wifi*all*"}
        $UrlDownloads = $UrlDownloads | Where-Object {$_.innerText -notlike "*proset*"}
        #===================================================================================================
        #   Driver Details
        #===================================================================================================
        foreach ($UrlDownload in $UrlDownloads) {
            #===================================================================================================
            #   Defaults
            #===================================================================================================
            $OSDVersion = $(Get-Module -Name OSD | Sort-Object Version | Select-Object Version -Last 1).Version
            $LastUpdate = [datetime] $(Get-Date)
            $OSDStatus = $null
            $OSDGroup = 'IntelWireless'
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
            $MakeNotMatch = @()
    
            $Generation = $null
            $SystemFamily = $null
    
            $Model = @()
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
            #===================================================================================================
            #   LastUpdate
            #===================================================================================================
            $LastUpdateRaw = $DriverMETA | Where-Object {$_.name -eq 'LastUpdate'} | Select-Object -ExpandProperty Content
            $LastUpdate = [datetime]::ParseExact($LastUpdateRaw, "MM/dd/yyyy HH:mm:ss", $null)
            #===================================================================================================
            #   DriverVersion
            #===================================================================================================
            $DriverVersion = $DriverMETA | Where-Object {$_.name -eq 'DownloadVersion'} | Select-Object -ExpandProperty Content
            #===================================================================================================
            #   DriverUrl
            #===================================================================================================
            $DriverUrl = $UrlDownload.'data-direct-path'
            #===================================================================================================
            #   OsArch
            #===================================================================================================
            if (($DriverUrl -match 'Win64') -or ($DriverUrl -match 'Driver64') -or ($DriverUrl -match '64_') -or ($DriverInfo -match '64-Bit')) {
                $OsArch = 'x64'
            } else {
                $OsArch = 'x86'
            }
            #===================================================================================================
            #   DriverDescription
            #===================================================================================================
            $DriverDescription = $DriverMETA | Where-Object {$_.name -eq 'Description'} | Select-Object -ExpandProperty Content
            #===================================================================================================
            #   DownloadFile
            #===================================================================================================
            $DownloadFile = Split-Path $DriverUrl -Leaf
            #===================================================================================================
            #   OS
            #===================================================================================================
            if ($DownloadFile -match 'Win10') {
                $OsNameMatch = @('Win10')
                $OsVersion = @('10.0')
            } 
            if ($DownloadFile -match 'Win8.1') {
                $OsNameMatch = @('Win8.1')
                $OsVersion = @('6.3')
            }
            if ($DownloadFile -match 'Win7') {
                $OsNameMatch = @('Win7')
                $OsVersion = @('6.1')
            }
            #===================================================================================================
            #   Values
            #===================================================================================================
            $DriverName = "$OSDGroup $DriverVersion $OsArch $OsVersion" 
            $DriverGrouping = "Intel Wireless $OsArch $OsVersion"
            $DriverInfo = $DriverLink.href

            $OSDPnpClass = 'Net'
            $OSDPnpClassGuid = '{4D36E972-E325-11CE-BFC1-08002BE10318}'
            #===================================================================================================
            #   Create Object
            #===================================================================================================
            $ObjectProperties = @{
                OSDVersion              = [string] $OSDVersion
                LastUpdate              = [datetime] $LastUpdate
                OSDStatus               = [string] $OSDStatus
                OSDType                 = [string] $OSDType
                OSDGroup                = [string] $OSDGroup
    
                DriverName              = [string] $DriverName
                DriverVersion           = [string] $DriverVersion
                DriverReleaseId         = [string] $DriverReleaseID
    
                OperatingSystem         = [array] $OperatingSystem
                OsVersion               = [string[]] $OsVersion
                OsArch                  = [array[]] $OsArch
                OsBuildMax              = [string] $OsBuildMax
                OsBuildMin              = [string] $OsBuildMin
    
                Make                    = [array[]] $Make
                MakeNe                  = [array[]] $MakeNe
                MakeLike                = [array[]] $MakeLike
                MakeNotLike             = [array[]] $MakeNotLike
                MakeMatch               = [array[]] $MakeMatch
                MakeNotMatch            = [array[]] $MakeNotMatch
    
                Generation              = [string] $Generation
                SystemFamily            = [string] $SystemFamily
    
                Model                   = [array[]] $Model
                ModelNe                 = [array[]] $ModelNe
                ModelLike               = [array[]] $ModelLike
                ModelNotLike            = [array[]] $ModelNotLike
                ModelMatch              = [array[]] $ModelMatch
                ModelNotMatch           = [array[]] $ModelNotMatch
    
                SystemSku               = [array[]] $SystemSku
                SystemSkuNe             = [array[]] $SystemSkuNe
    
                SystemFamilyMatch       = [array[]] $SystemFamilyMatch
                SystemFamilyNotMatch    = [array[]] $SystemFamilyNotMatch
    
                SystemSkuMatch          = [array[]] $SystemSkuMatch
                SystemSkuNotMatch       = [array[]] $SystemSkuNotMatch
    
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
    #===================================================================================================
    #   Select-Object
    #===================================================================================================
    $DriverResults = $DriverResults | Select-Object OSDVersion, LastUpdate, OSDStatus, OSDType, OSDGroup,`
    DriverName, DriverVersion,`
    OsVersion, OsArch,`
    DriverGrouping,`
    DownloadFile, DriverUrl, DriverInfo, DriverDescription,`
    OSDGuid,`
    OSDPnpClass, OSDPnpClassGuid
    #===================================================================================================
    #   Sort-Object
    #===================================================================================================
    $DriverResults = $DriverResults | Sort-Object -Property LastUpdate -Descending
    #===================================================================================================
    #   Return
    #===================================================================================================
    Return $DriverResults
    #===================================================================================================
}