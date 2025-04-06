<#
.SYNOPSIS
Returns the Intel Graphics Driver Object

.DESCRIPTION
Returns the Intel Graphics Driver Object

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs
#>
function Get-IntelGraphicsDriverPack {
    [CmdletBinding()]
    param (
        [ValidateSet('x64','x86')]
        [System.String]
        $CompatArch,
        
        [ValidateSet('Win7','Win10')]
        [System.String]
        $CompatOS,
        
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
    $OfflineCatalogName = 'IntelGraphicsDriverPack.json'
    $DriverUrl = 'https://www.intel.com/content/www/us/en/download/19344/intel-graphics-windows-dch-drivers.html'
    #=================================================
    #   Initialize
    #=================================================
    $IsOnline = $false

    if ($UpdateModuleCatalog) {
        $Online = $true
    }
    if ($Online) {
        $IsOnline = Test-WebConnection $DriverUrl
    }

    #Create Temporary Download Directory
    if (-not(Test-Path (Join-Path $env:TEMP 'OSD'))) {
        $null = New-Item -Path (Join-Path $env:TEMP 'OSD') -ItemType Directory -Force
    }

    $TempCatalogFile = Join-Path $env:TEMP (Join-Path 'OSD' $OfflineCatalogName)
    $ModuleCatalogFile = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\$OfflineCatalogName"
    $ModuleCatalogContent = Get-Content -Path $ModuleCatalogFile -Raw | ConvertFrom-Json
    #=================================================
    #   Filter
    #=================================================
    switch ($CompatArch) {
        'x64'   {$ModuleCatalogContent = $ModuleCatalogContent | Where-Object {$_.OSArch -match 'x64'}}
        'x86'   {$ModuleCatalogContent = $ModuleCatalogContent | Where-Object {$_.OSArch -match 'x86'}}
    }
    switch ($CompatOS) {
        'Win7'   {$ModuleCatalogContent = $ModuleCatalogContent | Where-Object {$_.OsVersion -match '6.0'}}
        'Win8'   {$ModuleCatalogContent = $ModuleCatalogContent | Where-Object {$_.OsVersion -match '6.3'}}
        'Win10'   {$ModuleCatalogContent = $ModuleCatalogContent | Where-Object {$_.OsVersion -match '10.0'}}
    }
    #=================================================
    #   IsOnline
    #=================================================
    if ($IsOnline) {
        Write-Verbose "Catalog is running Online"
        #=================================================
        #   ForEach
        #=================================================
        $ZipFileResults = @()
        $CloudDriver = @()
        $CloudDriver = foreach ($ModuleCatalogContentItem in $ModuleCatalogContent) {
            Write-Verbose "DriverGrouping: $($ModuleCatalogContentItem.DriverGrouping)"
            Write-Verbose "OsArch: $($ModuleCatalogContentItem.OsArch)"
            Write-Verbose "DriverInfo: $($ModuleCatalogContentItem.DriverInfo)"
            #=================================================
            #   WebRequest
            #=================================================
            $DriverInfoWebRequest = Invoke-WebRequest -Uri $ModuleCatalogContentItem.DriverInfo -Method Get -Verbose
            $DriverInfoWebRequestContent = $DriverInfoWebRequest.Content
            $DriverInfoHTML = $DriverInfoWebRequest.ParsedHtml.childNodes | Where-Object {$_.nodename -eq 'HTML'} 
            $DriverInfoHEAD = $DriverInfoHTML.childNodes | Where-Object {$_.nodename -eq 'HEAD'}
            $DriverInfoMETA = $DriverInfoHEAD.childNodes | Where-Object {$_.nodename -like "meta*"} | Select-Object -Property Name, Content
            #=================================================
            #   Driver Filter
            #=================================================
            $ZipFileResults = @($DriverInfoWebRequestContent -split " " -split '"' -match 'http' -match "downloadmirror" -match ".zip")

            if ($ModuleCatalogContentItem.OsArch -match 'x64') {
                $ZipFileResults = $ZipFileResults | Where-Object {$_ -notmatch 'win32'}
            }
            if ($ModuleCatalogContentItem.OsArch -match 'x86') {
                $ZipFileResults = $ZipFileResults | Where-Object {$_ -notmatch 'win64'}
            }
            $ZipFileResults = $ZipFileResults | Select-Object -Unique
            #=================================================
            #   Driver Details
            #=================================================
            foreach ($DriverZipFile in $ZipFileResults) {
                Write-Verbose "Latest DriverPack: $DriverZipFile"
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
                $OsVersion = $ModuleCatalogContentItem.OsVersion
                $OsArch = $ModuleCatalogContentItem.OsArch
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
                $DriverInfo = $ModuleCatalogContentItem.DriverInfo
                $DriverDescription = $null
                $Hash = $null
                $OSDGuid = $(New-Guid)
                #=================================================
                #   LastUpdate
                #=================================================
                #$LastUpdateMeta = $DriverInfoMETA | Where-Object {$_.name -eq 'LastUpdate'} | Select-Object -ExpandProperty Content
                #$LastUpdate = [datetime]::ParseExact($LastUpdateMeta, "MM/dd/yyyy HH:mm:ss", $null)

                $LastUpdateMeta = $DriverInfoMETA | Where-Object {$_.name -eq 'LastUpdate'} | Select-Object -ExpandProperty Content
                Write-Verbose "LastUpdateMeta: $LastUpdateMeta"

                if ($LastUpdateMeta) {
                    $LastUpdateSplit = ($LastUpdateMeta -split (' '))[0]
                    #Write-Verbose "LastUpdateSplit: $LastUpdateSplit"
    
                    $LastUpdate = [datetime]::Parse($LastUpdateSplit)
                    #Write-Verbose "LastUpdate: $LastUpdate"
                }
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
                $DriverGrouping = $ModuleCatalogContentItem.DriverGrouping
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
        Write-Verbose "Catalog is running Offline"
        $CloudDriver = $ModuleCatalogContent
    }
    #=================================================
    #   Remove Duplicates
    #=================================================
    $CloudDriver = $CloudDriver | Sort-Object DriverUrl -Unique
    #=================================================
    #   Select-Object
    #=================================================
    $CloudDriver = $CloudDriver | Select-Object OSDVersion, LastUpdate, OSDStatus, OSDType, OSDGroup,`
    DriverName, DriverVersion,`
    OsVersion, OsArch, MakeNotMatch, ModelNotMatch,`
    DriverGrouping,`
    DownloadFile, DriverUrl, DriverInfo, DriverDescription,`
    OSDGuid,`
    OSDPnpClass, OSDPnpClassGuid
    #=================================================
    #   Sort-Object
    #=================================================
    $CloudDriver = $CloudDriver | Sort-Object -Property LastUpdate -Descending
    $CloudDriver | ConvertTo-Json | Out-File $TempCatalogFile -Encoding ascii -Width 2000 -Force
    #=================================================
    #   UpdateModuleCatalog
    #=================================================
    if ($UpdateModuleCatalog) {
        if (Test-Path $TempCatalogFile) {
            Copy-Item $TempCatalogFile $ModuleCatalogFile -Force -ErrorAction Ignore
        }
    }
    #=================================================
    #   Return
    #=================================================
    Return $CloudDriver
    #=================================================
}