<#
.SYNOPSIS
Returns the Intel Wireless Driver Object

.DESCRIPTION
Returns the Intel Wireless Driver Object

.NOTES
Modified 24.01.02 - Gary Blok
    Changed method to download the Intel Driver & Support Assistant Catalog Files and extract info from that.
    Intel DSA: https://www.intel.com/content/www/us/en/support/intel-driver-support-assistant.html
    Manual Downloads can be done from here: https://www.intel.com/content/www/us/en/download/18231/intel-proset-wireless-software-and-drivers-for-it-admins.html

Removed support for x86 (32bit)
Removed support for older OSes.  Only Supports Win10 & 11 now.

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs
#>
function Get-IntelWirelessDriverPack {
    [CmdletBinding()]
    param (
        [ValidateSet('x64')]
        [System.String]
        $CompatArch,
        
        [ValidateSet('Win10','Win11')]
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
    $OfflineCatalogName = 'IntelWirelessDriverPack.json'
    $DriverUrl = 'https://dsadata.intel.com/data/en'
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
    $TempDSADataFile = Join-Path $env:TEMP (Join-Path 'OSD' 'idsa-en.zip')
    $TempDSADataExpand = Join-Path $env:TEMP (Join-Path 'OSD' 'idsa-en-zip')
    #Create Temporary Download Directory
    if (Test-Path $TempDSADataExpand) {
        Remove-Item -Path $TempDSADataExpand -Recurse -Force
    }   
    if (-not(Test-Path $TempDSADataExpand)) {
        $null = New-Item -Path $TempDSADataExpand -ItemType Directory -Force
    }
    $ModuleCatalogFile = "$(Get-OSDCatsPath)\osd-module\$OfflineCatalogName"
    #Next two lines are specific to Gary when he is testing this function
    #$GitHubFolder = 'C:\Users\GaryBlok\OneDrive - garytown\Documents\GitHub'
    #$ModuleCatalogFile = "$GitHubFolder\OSD\Catalogs\$OfflineCatalogName" #GARY's Test Machine
    
    $ModuleCatalogContent = Get-Content -Path $ModuleCatalogFile -Raw | ConvertFrom-Json
    #=================================================
    #   IsOnline
    #=================================================
    if ($IsOnline) {
        Write-Verbose "Catalog is running Online"
        #=================================================
        #   Get DSA Zip File with Catalog JSON
        #=================================================
        Invoke-WebRequest -UseBasicParsing -Uri $DriverUrl -OutFile $TempDSADataFile
        Expand-Archive -Path $TempDSADataFile -DestinationPath $TempDSADataExpand

        $JSONPath = "$TempDSADataExpand\software-configurations.json"
        $JSONData = Get-Content -Path $JSONPath | ConvertFrom-Json
        $WiFi = $JSONData | Where-Object {$_.name -match "Wi-Fi"}
        $WiFiURL = $WiFi.Files.Url | Where-Object {$_ -match "Driver64"}
        $WiFiZipURL = $WiFiURL.replace(".exe",".zip")

        # Retrieve the Catalog number from the Download URL
        $WiFiZipURLCatalogNumber = ([int]($WiFiZipURL.Split('/') | Select-Object -Last 1 -Skip 1))

        # Generate array of multiple URLs to try
        # - Original $WiFiZipURL
        # - Original $WiFiZipURL with the catalog number increased by 1
        $WiFiZipURLs = @(
            $WiFiZipURL,
            ($WiFiZipURL -replace $WiFiZipURLCatalogNumber, ($WiFiZipURLCatalogNumber + 1)),
            ($WiFiZipURL -replace $WiFiZipURLCatalogNumber, ($WiFiZipURLCatalogNumber + 2)),
            ($WiFiZipURL -replace $WiFiZipURLCatalogNumber, ($WiFiZipURLCatalogNumber + 3))
        )

        # Test if one of the $WiFiZipURLs exists
        $WiFiZipURLExists = $false
        foreach ($WiFiZipURL in $WiFiZipURLs)
        {
            try
            {
                $WiFiZipURLWebRequest = Invoke-WebRequest -Uri $WiFiZipURL -Method Head -ErrorAction Stop
                if($WiFiZipURLWebRequest.StatusCode -eq 200)
                {
                    $WiFiZipURLExists = $true
                    break
                }
            }
            catch
            {
                # Tested URL does not exist
            }
        }

        if($WiFiZipURLExists -eq $false)
        {
            Write-Host "Please try again without using the Online switch" -ForegroundColor Yellow
            Write-Error -Message ('Unable to retrieve a valid Intel Wireless Driver Pack Download URL')
            Exit
        }

        $ModuleCatalogContent = $ModuleCatalogContent | Select-Object -First 1
        #=================================================
        #   ForEach
        #=================================================
        $ZipFileResults = @()
        $CloudDriver = @()
        $CloudDriver = foreach ($ModuleCatalogContentItem in $ModuleCatalogContent) {
            #=================================================
            #   WebRequest
            #=================================================
            <#
            $DriverInfoWebRequest = Invoke-WebRequest -Uri $ModuleCatalogContentItem.DriverInfo -Method Get -Verbose
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

            if ($ModuleCatalogContentItem.OsArch -match 'x64') {
                $ZipFileResults = $ZipFileResults | Where-Object {$_ -notmatch 'win32'}
            }
            if ($ModuleCatalogContentItem.OsArch -match 'x86') {
                $ZipFileResults = $ZipFileResults | Where-Object {$_ -notmatch 'win64'}
            }
            #>
            $ZipFileResults = $WiFiZipURL
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


                if ($DriverZipFile -match 'Win10') {$OsVersion = '10.0'}
                if ($DriverZipFile -match 'Win11') {$OsVersion = '10.0'}
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
                $DriverInfo = $ModuleCatalogContentItem.DriverInfo
                $DriverDescription = $null
                $Hash = $null
                $OSDGuid = $(New-Guid)
                #=================================================
                #   LastUpdate
                #=================================================
                #$LastUpdateMeta = $DriverInfoMETA | Where-Object {$_.name -eq 'LastUpdate'} | Select-Object -ExpandProperty Content
                #$LastUpdate = [datetime]::ParseExact($LastUpdateMeta, "MM/dd/yyyy HH:mm:ss", $null)
                <#
                $LastUpdateMeta = $DriverInfoMETA | Where-Object {$_.name -eq 'LastUpdate'} | Select-Object -ExpandProperty Content
                Write-Verbose "LastUpdateMeta: $LastUpdateMeta"

                if ($LastUpdateMeta) {
                    $LastUpdateSplit = ($LastUpdateMeta -split (' '))[0]
                    #Write-Verbose "LastUpdateSplit: $LastUpdateSplit"
    
                    $LastUpdate = [datetime]::Parse($LastUpdateSplit)
                    #Write-Verbose "LastUpdate: $LastUpdate"
                }
                #>
                $LastUpdate = [datetime]$Wifi.DisplayReleaseDate
                #=================================================
                #   DriverVersion
                #=================================================
                #$DriverVersion = ($DriverZipFile -split ('-'))[1]
                $DriverVersion = $WiFi.Version
                #=================================================
                #   DriverUrl
                #=================================================
                $DriverUrl = $DriverZipFile
                #=================================================
                #   Values
                #=================================================
                $DriverGrouping = $ModuleCatalogContentItem.DriverGrouping
                #$DriverName = "$DriverGrouping $OsArch $DriverVersion $OsVersion"
                $DriverName = $WiFi.Name
                #$DriverDescription = $DriverInfoMETA | Where-Object {$_.name -eq 'Description'} | Select-Object -ExpandProperty Content
                $DriverDescription = $WiFi.Details
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
    OsVersion, OsArch,`
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