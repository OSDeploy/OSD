<#
.SYNOPSIS
Returns a Intel Radeon Display Driver Object

.DESCRIPTION
Returns a Intel Radeon Display Driver Object

.LINK
https://osddrivers.osdeploy.com
#>
function Get-OSDCatalogIntelRadeonDisplayDriver {
    [CmdletBinding()]
    param (
        [ValidateSet('x64','x86')]
        [string]$CompatArch,
        [ValidateSet('Win10')]
        [string]$CompatOS
    )
    #=================================================
    #   Uri
    #=================================================
    $Uri = 'https://www.intel.com/content/www/us/en/download/19282/radeon-rx-vega-m-graphics.html'
    #=================================================
    #   Import Base Catalog
    #=================================================
    $OSDCatalog = Get-Content -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\OSDCatalog\OSDCatalogIntelRadeonDisplayDriver.json" -Raw | ConvertFrom-Json
    #=================================================
    #   Filter
    #=================================================
    switch ($CompatArch) {
        'x64'   {$OSDCatalog = $OSDCatalog | Where-Object {$_.OSArch -match 'x64'}}
        'x86'   {$OSDCatalog = $OSDCatalog | Where-Object {$_.OSArch -match 'x86'}}
    }
    switch ($CompatOS) {
        'Win7'   {$OSDCatalog = $OSDCatalog | Where-Object {$_.OsVersion -match '6.0'}}
        'Win8'   {$OSDCatalog = $OSDCatalog | Where-Object {$_.OsVersion -match '6.3'}}
        'Win10'   {$OSDCatalog = $OSDCatalog | Where-Object {$_.OsVersion -match '10.0'}}
    }
    #=================================================
    #   Online
    #=================================================
    if (Test-WebConnection $Uri) {
        Write-Verbose "Catalog is Online"
        #=================================================
        #   ForEach
        #=================================================
        $ZipFileResults = @()
        $DriverResults = @()
        $DriverResults = foreach ($OSDCatalogItem in $OSDCatalog) {
            Write-Verbose "$($OSDCatalogItem.DriverGrouping) $($OSDCatalogItem.OsArch)"
            Write-Verbose "     $($OSDCatalogItem.DriverInfo)"
            #=================================================
            #   WebRequest
            #=================================================
            $DriverInfoWebRequest = Invoke-WebRequest -Uri $OSDCatalogItem.DriverInfo -Method Get
            $DriverInfoWebRequestContent = $DriverInfoWebRequest.Content

            $DriverInfoHTML = $DriverInfoWebRequest.ParsedHtml.childNodes | Where-Object {$_.nodename -eq 'HTML'} 
            $DriverInfoHEAD = $DriverInfoHTML.childNodes | Where-Object {$_.nodename -eq 'HEAD'}
            $DriverInfoMETA = $DriverInfoHEAD.childNodes | Where-Object {$_.nodename -like "meta*"} | Select-Object -Property Name, Content
            #=================================================
            #   Driver Filter
            #=================================================
            $ZipFileResults = @($DriverInfoWebRequestContent -split " " -split '"' -match 'http' -match "downloadmirror" -match ".zip")

            if ($OSDCatalogItem.OsArch -match 'x64') {
                $ZipFileResults = $ZipFileResults | Where-Object {$_ -notmatch 'win32'}
            }
            if ($OSDCatalogItem.OsArch -match 'x86') {
                $ZipFileResults = $ZipFileResults | Where-Object {$_ -notmatch 'win64'}
            }
            $ZipFileResults = $ZipFileResults | Select-Object -Unique
            #=================================================
            #   Driver Details
            #=================================================
            foreach ($DriverZipFile in $ZipFileResults) {
                Write-Verbose "     $DriverZipFile"
                #=================================================
                #   Defaults
                #=================================================
                $OSDVersion = $(Get-Module -Name OSD | Sort-Object Version | Select-Object Version -Last 1).Version
                $LastUpdate = [datetime] $(Get-Date)
                $OSDStatus = $null
                $OSDGroup = 'IntelRadeonDisplay'
                $OSDType = 'Driver'

                $DriverName = $null
                $DriverVersion = $null
                $DriverReleaseId = $null
                $DriverGrouping = $null

                $OperatingSystem = @()
                $OsVersion = $OSDCatalogItem.OsVersion
                $OsArch = $OSDCatalogItem.OsArch
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
                $DriverInfo = $OSDCatalogItem.DriverInfo
                $DriverDescription = $null
                $Hash = $null
                $OSDGuid = $(New-Guid)
                #=================================================
                #   LastUpdate
                #=================================================
                #$LastUpdateRaw = $DriverInfoMETA | Where-Object {$_.name -eq 'LastUpdate'} | Select-Object -ExpandProperty Content
                #$LastUpdate = [datetime]::ParseExact($LastUpdateRaw, "MM/dd/yyyy HH:mm:ss", $null)

                $LastUpdateRaw = $DriverInfoMETA | Where-Object {$_.name -eq 'LastUpdate'} | Select-Object -ExpandProperty Content
                Write-Verbose "LastUpdateRaw: $LastUpdateRaw"

                $LastUpdateSplit = ($LastUpdateRaw -split (' '))[0]
                Write-Verbose "LastUpdateSplit: $LastUpdateSplit"

                $LastUpdate = [datetime]::Parse($LastUpdateSplit)
                Write-Verbose "LastUpdate: $LastUpdate"
                #=================================================
                #   DriverVersion
                #=================================================
                $DriverVersion = $DriverInfoMETA | Where-Object {$_.name -eq 'DownloadVersion'} | Select-Object -ExpandProperty Content
                #=================================================
                #   DriverUrl
                #=================================================
                $DriverUrl = $DriverZipFile
                #=================================================
                #   Values
                #=================================================
                $DriverGrouping = $OSDCatalogItem.DriverGrouping
                $DriverName = "$DriverGrouping $OsArch $DriverVersion $OsVersion"
                $DriverDescription = $DriverInfoMETA | Where-Object {$_.name -eq 'Description'} | Select-Object -ExpandProperty Content
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
    }
    #=================================================
    #   Offline
    #=================================================
    else {
        Write-Verbose "Catalog is Offline"
        $DriverResults = $OSDCatalog
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
    $DriverResults | ConvertTo-Json | Out-File "$env:TEMP\OSDCatalogIntelRadeonDisplayDriver.json"
    #=================================================
    #   Return
    #=================================================
    Return $DriverResults
    #=================================================
}