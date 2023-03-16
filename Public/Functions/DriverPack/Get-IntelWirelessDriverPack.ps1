<#
.SYNOPSIS
Returns a Intel Wireless Driver Object

.DESCRIPTION
Returns a Intel Wireless Driver Object
#>
function Get-IntelWirelessDriverPack {
    [CmdletBinding()]
    param (
        [ValidateSet('x64','x86')]
        [System.String]
        $CompatArch,
        
        [ValidateSet('Win7','Win10')]
        [System.String]
        $CompatOS,
        
        [System.Management.Automation.SwitchParameter]
        $Force
    )
    #=================================================
    #   Online
    #=================================================
    $IsOnline = $false
    $DriverUrl = 'https://www.intel.com/content/www/us/en/support/articles/000017246/network-and-i-o/wireless-networking.html'

    if ($Force) {
        $IsOnline = Test-WebConnection $DriverUrl
    }
    #=================================================
    #   OfflineCloudDriver
    #=================================================
    $OfflineCloudDriverPath = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\IntelWirelessDriverPack.json"
    $OfflineCloudDriver = Get-Content -Path $OfflineCloudDriverPath -Raw | ConvertFrom-Json
    #=================================================
    #   IsOnline
    #=================================================
    if ($IsOnline) {
        Write-Verbose "CloudDriver Online"
        #All Drivers are from the same URL
        $OfflineCloudDriver = $OfflineCloudDriver | Select-Object -First 1
        #=================================================
        #   ForEach
        #=================================================
        $ZipFileResults = @()
        $CloudDriver = @()
        $CloudDriver = foreach ($OfflineCloudDriverItem in $OfflineCloudDriver) {
            #Write-Verbose "$($OfflineCloudDriverItem.DriverGrouping) $($OfflineCloudDriverItem.OsArch)" -Verbose
            #Write-Verbose "     $($OfflineCloudDriverItem.DriverInfo)" -Verbose
            #=================================================
            #   WebRequest
            #=================================================
            $DriverInfoWebRequest = Invoke-WebRequest -Uri $OfflineCloudDriverItem.DriverInfo -Method Get
            $DriverInfoWebRequestContent = $DriverInfoWebRequest.Content

            $DriverInfoHTML = $DriverInfoWebRequest.ParsedHtml.childNodes | Where-Object {$_.nodename -eq 'HTML'} 
            $DriverInfoHEAD = $DriverInfoHTML.childNodes | Where-Object {$_.nodename -eq 'HEAD'}
            $DriverInfoMETA = $DriverInfoHEAD.childNodes | Where-Object {$_.nodename -like "meta*"} | Select-Object -Property Name, Content
            $OSCompatibility = $DriverInfoMETA | Where-Object {$_.name -eq 'DownloadOSes'} | Select-Object -ExpandProperty Content
            Write-Verbose "OSCompatibility: $OSCompatibility"
            #=================================================
            #   Driver Filter
            #=================================================
            $ZipFileResults = @($DriverInfoWebRequestContent -split " " -split '"' -match 'http' -match "downloadmirror" -match ".zip")

            $ZipFileResults = $ZipFileResults | Where-Object {$_ -match 'Driver'}

            if ($OfflineCloudDriverItem.OsArch -match 'x64') {
                $ZipFileResults = $ZipFileResults | Where-Object {$_ -notmatch 'win32'}
            }
            if ($OfflineCloudDriverItem.OsArch -match 'x86') {
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
                $OSDGroup = 'IntelWireless'
                $OSDType = 'Driver'

                $DriverName = $null
                $DriverVersion = $null
                $DriverReleaseId = $null
                $DriverGrouping = $null

                if ($DriverZipFile -match 'Win7') {$OsVersion = '6.0'}
                if ($DriverZipFile -match 'Win8') {$OsVersion = '6.3';Continue}
                if ($DriverZipFile -match 'Win10') {$OsVersion = '10.0'}
                if ($DriverZipFile -match 'Driver32') {$OsArch = 'x86'}
                if ($DriverZipFile -match 'Driver64') {$OsArch = 'x64'}
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
                $DriverInfo = $OfflineCloudDriverItem.DriverInfo
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
                $DriverVersion = ($DriverZipFile -split ('-'))[1]
                #=================================================
                #   DriverUrl
                #=================================================
                $DriverUrl = $DriverZipFile
                #=================================================
                #   Values
                #=================================================
                $DriverGrouping = $OfflineCloudDriverItem.DriverGrouping
                $DriverName = "$DriverGrouping $OsArch $DriverVersion $OsVersion"
                $DriverDescription = $DriverInfoMETA | Where-Object {$_.name -eq 'Description'} | Select-Object -ExpandProperty Content
                $DownloadFile = Split-Path $DriverUrl -Leaf
                $OSDPnpClass = 'Net'
                $OSDPnpClassGuid = '{4D36E972-E325-11CE-BFC1-08002BE10318}'
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
        $CloudDriver = $OfflineCloudDriver
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
    OsVersion, OsArch,`
    DriverGrouping,`
    DownloadFile, DriverUrl, DriverInfo, DriverDescription,`
    OSDGuid,`
    OSDPnpClass, OSDPnpClassGuid
    #=================================================
    #   Sort-Object
    #=================================================
    $CloudDriver = $CloudDriver | Sort-Object -Property LastUpdate -Descending
    $CloudDriver | ConvertTo-Json | Out-File "$env:TEMP\IntelWirelessDriverPack.json" -Encoding ascii -Width 2000 -Force
    #=================================================
    #   Filter
    #=================================================
    switch ($CompatArch) {
        'x64'   {$CloudDriver = $CloudDriver | Where-Object {$_.OSArch -match 'x64'}}
        'x86'   {$CloudDriver = $CloudDriver | Where-Object {$_.OSArch -match 'x86'}}
    }
    switch ($CompatOS) {
        'Win7'   {$CloudDriver = $CloudDriver | Where-Object {$_.OsVersion -match '6.0'}}
        'Win8'   {$CloudDriver = $CloudDriver | Where-Object {$_.OsVersion -match '6.3'}}
        'Win10'   {$CloudDriver = $CloudDriver | Where-Object {$_.OsVersion -match '10.0'}}
    }
    #=================================================
    #   Return
    #=================================================
    Return $CloudDriver
    #=================================================
}