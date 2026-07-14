function Test-HPIASupport {
    <#
    .SYNOPSIS
    Tests whether the current HP platform is supported by HPIA.

    .DESCRIPTION
    Downloads the HP platform catalog, reads the platform IDs from the XML, and
    compares the local baseboard product ID to determine whether HPIA support is
    available on this device.

    .EXAMPLE
    Test-HPIASupport
    Returns True when the current device platform is listed in the HPIA platform catalog.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-13 - Initial help block created
    #>
    $CabPath = Join-Path -Path $env:TEMP -ChildPath "platformList.cab"
    $XMLPath = Join-Path -Path $env:TEMP -ChildPath "platformList.xml"
    $PlatformListCabURL = "https://hpia.hpcloud.hp.com/ref/platformList.cab"

    try {
        Invoke-WebRequest -Uri $PlatformListCabURL -OutFile $CabPath -UseBasicParsing -ErrorAction Stop
        $null = & expand.exe $CabPath $XMLPath
        [xml]$XML = Get-Content -Path $XMLPath -Raw -ErrorAction Stop
        $Platforms = $XML.ImagePal.Platform.SystemID
        $MachinePlatform = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product
        return ($MachinePlatform -in $Platforms)
    }
    catch {
        return $false
    }
    finally {
        Remove-Item -Path $CabPath -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $XMLPath -Force -ErrorAction SilentlyContinue
    }
}

function Get-HPOSSupport {
    <#
    .SYNOPSIS
    Gets supported Windows releases for an HP platform from the HPIA catalog.

    .DESCRIPTION
    Downloads and parses the HP platform catalog and returns operating system
    support data for a specified platform or the local device platform. Optional
    switches can return only the latest supported OS values.

    .PARAMETER Platform
    HP platform ID to query. If not provided, the local baseboard product ID is used.

    .PARAMETER Latest
    Returns a combined string containing the latest supported OS description and release ID.

    .PARAMETER MaxOS
    Returns the latest supported OS family as Win10 or Win11.

    .PARAMETER MaxOSVer
    Returns the latest supported OS release ID value.

    .PARAMETER MaxOSNum
    Returns the latest supported OS major version number as 10.0 or 11.0.

    .EXAMPLE
    Get-HPOSSupport
    Returns all supported OS entries for the local platform.

    .EXAMPLE
    Get-HPOSSupport -Platform 83B2 -MaxOSVer
    Returns the maximum supported release ID for platform 83B2.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-13 - Initial help block created
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position=0,mandatory=$false)]
    [string]$Platform,
    [switch]$Latest,
    [switch]$MaxOS,
    [switch]$MaxOSVer,
    [switch]$MaxOSNum
    )
    $CabPath = "$env:TEMP\platformList.cab"
    $XMLPath = "$env:TEMP\platformList.xml"
    if ($Platform){$MachinePlatform = $platform}
    else {$MachinePlatform = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product}
    $PlatformListCabURL = "https://hpia.hpcloud.hp.com/ref/platformList.cab"
    Invoke-WebRequest -Uri $PlatformListCabURL -OutFile $CabPath -UseBasicParsing
    $Expand = expand $CabPath $XMLPath
    [xml]$XML = Get-Content $XMLPath
    $XMLPlatforms = $XML.ImagePal.Platform
    $OSList = ($XMLPlatforms | Where-Object {$_.SystemID -match $MachinePlatform}).OS | Select-Object -Property OSReleaseIdDisplay, OSBuildId, OSDescription

    if ($Latest){
        [String]$MaxOSSupported = ($OSList.OSDescription | Where-Object {$_ -notmatch "LTSB"}| Select-Object -Unique| Measure-Object -Maximum).Maximum
        [String]$MaxOSVerion = (($OSList | Where-Object {$_.OSDescription -eq "$MaxOSSupported"}).OSReleaseIdDisplay | Measure-Object -Maximum).Maximum
        return "$MaxOSSupported $MaxOSVerion"
        break
    }
    if ($MaxOS){
        [String]$MaxOSSupported = ($OSList.OSDescription | Where-Object {$_ -notmatch "LTSB"}| Select-Object -Unique| Measure-Object -Maximum).Maximum
        if ($MaxOSSupported -Match "11"){[String]$MaxOSName = "Win11"}
        else {[String]$MaxOSName = "Win10"}
        return "$MaxOSName"
        break
    }
    if ($MaxOSVer){
        [String]$MaxOSSupported = ($OSList.OSDescription | Where-Object {$_ -notmatch "LTSB"}| Select-Object -Unique| Measure-Object -Maximum).Maximum
        [String]$MaxOSVersion = (($OSList | Where-Object {$_.OSDescription -eq "$MaxOSSupported"}).OSReleaseIdDisplay | Measure-Object -Maximum).Maximum
        return "$MaxOSVersion"
        break
    }
    if ($MaxOSNum){
        [String]$MaxOSSupported = ($OSList.OSDescription | Where-Object {$_ -notmatch "LTSB"}| Select-Object -Unique| Measure-Object -Maximum).Maximum
        if ($MaxOSSupported -Match "11"){[String]$MaxOSNumber = "11.0"}
        else {[String]$MaxOSNumber = "10.0"}
        return "$MaxOSNumber"
        break
    }
    return $OSList
}

function Get-HPSoftpaqListLatest {
    <#
    .SYNOPSIS
    Gets the latest HPIA SoftPaq list for an HP platform.

    .DESCRIPTION
    Resolves the latest supported OS information for a platform, downloads the
    corresponding HPIA reference CAB, and returns the SoftPaq update list from
    the extracted XML metadata.

    .PARAMETER Platform
    HP platform ID to query. If not provided, the local baseboard product ID is used.

    .PARAMETER SystemInfo
    Returns system information from the HPIA XML instead of the SoftPaq list.

    .PARAMETER MaxOSVer
    Reserved switch parameter in this function signature.

    .PARAMETER MaxOSNum
    Reserved switch parameter in this function signature.

    .EXAMPLE
    Get-HPSoftpaqListLatest
    Returns the latest SoftPaq list for the local platform.

    .EXAMPLE
    Get-HPSoftpaqListLatest -Platform 83B2 -SystemInfo
    Returns system information metadata for platform 83B2.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-13 - Initial help block created
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position=0,mandatory=$false)]
    [string]$Platform,
    [switch]$SystemInfo,
    [switch]$MaxOSVer,
    [switch]$MaxOSNum
    )
    if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64"){
        $Arch = '64'
    }

    if ($Platform){$MachinePlatform = $platform}
    else {$MachinePlatform = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product}
    $OSNum = Get-HPOSSupport -MaxOSNum -Platform $MachinePlatform
    $ReleaseID = Get-HPOSSupport -MaxOSVer -Platform $MachinePlatform
    $BaseURL = ("https://hpia.hpcloud.hp.com/ref/$($MachinePlatform)/$($MachinePlatform)_$($Arch)_$($OSNum).$($ReleaseID).cab").ToLower()
    #https://hpia.hpcloud.hp.com/ref/83b2/83b2_64_11.0.23h2.cab
    $CabPath = "$env:TEMP\HPIA.cab"
    $XMLPath = "$env:TEMP\HPIA.xml"
    Write-Verbose "Invoke-WebRequest -Uri $BaseURL -OutFile $CabPath -UseBasicParsing"
    Invoke-WebRequest -Uri $BaseURL -OutFile $CabPath -UseBasicParsing
    $Expand = expand $CabPath $XMLPath
    [xml]$XML = Get-Content $XMLPath
    $SoftpaqList = $XML.ImagePal.Solutions.UpdateInfo
    if ($SystemInfo){
        $SysInfo = $XML.ImagePal.SystemInfo.System
        return $SystemInfo
        break
    }
    return $SoftpaqList

}

function Get-HPSoftPaqItems {
    <#
    .SYNOPSIS
    Gets HPIA SoftPaq items for a specific HP platform and OS release.

    .DESCRIPTION
    Validates that the requested operating system and release are supported by
    the target platform, downloads the matching HPIA CAB metadata file, and
    returns the SoftPaq update entries from the extracted XML.

    .PARAMETER Platform
    HP platform ID to query. If not provided, the local baseboard product ID is used.

    .PARAMETER osver
    Operating system release ID value to query, such as 23H2.

    .PARAMETER os
    Operating system major version number to query. Valid values are 10.0 and 11.0.

    .EXAMPLE
    Get-HPSoftPaqItems -osver 23H2 -os 11.0
    Returns SoftPaq items for Windows 11 23H2 on the local platform.

    .EXAMPLE
    Get-HPSoftPaqItems -Platform 83B2 -osver 22H2 -os 10.0
    Returns SoftPaq items for Windows 10 22H2 on platform 83B2.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-13 - Initial help block created
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position=0,mandatory=$false)]
    [string] $Platform,
    [Parameter(Position=1,mandatory=$true)]
    [string] $osver,
    [Parameter(Position=2,mandatory=$true)]
    [ValidateSet("10.0","11.0")]
    [string] $os
    )



    if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64"){$Arch = '64'}
    $CabPath = "$env:TEMP\HPIA.cab"
    $XMLPath = "$env:TEMP\HPIA.xml"
    if ($Platform){$MachinePlatform = $platform}
    else {$MachinePlatform = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product}

    #Test Passed Parameters
    $OSList = Get-HPOSSupport -Platform $MachinePlatform
    if ($OS -eq "11.0"){
        $OK = $OSList | Where-Object {$_.OSDescription -match "Windows 11"}
        if ($null -eq $OK){
        Write-Error "Your option of OS: $OS is not valid, This platform does not support Windows 11"
        break
        }
    }
    if ($OS -eq "10.0"){
        $OK = $OSList | Where-Object {$_.OSDescription -match "Windows 10"}
        if ($null -eq $OK){
        Write-Error "Your option of OS: $OS is not valid, This platform does not support Windows 10"
        break
        }
    }
    $SupportedOSVers = $OSList.OSReleaseIdDisplay
    if ($osver -notin $SupportedOSVers){
        Write-Host -ForegroundColor red "Selected Release $OSVer is not supported by this Platform: $MachinePlatform"
        Write-Error " Use Get-HPOSSupport to find list of options"
        break
    }
    $BaseURL = ("https://hpia.hpcloud.hp.com/ref/$($MachinePlatform)/$($MachinePlatform)_$($Arch)_$($os).$($osver).cab").ToLower()
    Write-Verbose "Invoke-WebRequest -Uri $BaseURL -OutFile $CabPath -UseBasicParsing"
    Invoke-WebRequest -Uri $BaseURL -OutFile $CabPath -UseBasicParsing
    $Expand = expand $CabPath $XMLPath
    [xml]$XML = Get-Content $XMLPath
    $SoftpaqList = $XML.ImagePal.Solutions.UpdateInfo

    return $SoftpaqList

}

function Get-HPDriverPackLatest {
    <#
    .SYNOPSIS
    Gets the latest available HP driver pack for a platform.

    .DESCRIPTION
    Checks supported OS releases for the target platform, searches from newest
    to oldest release for Windows 11 and then Windows 10, and returns the first
    matching Driver Pack entry found in the HPIA SoftPaq catalog.

    .PARAMETER Platform
    HP platform ID to query. If not provided, the local baseboard product ID is used.

    .PARAMETER URL
    Returns only the full download URL for the discovered driver pack.

    .PARAMETER download
    Downloads the discovered driver pack to C:\Drivers using Save-WebFile.

    .EXAMPLE
    Get-HPDriverPackLatest
    Returns the latest driver pack metadata for the local platform.

    .EXAMPLE
    Get-HPDriverPackLatest -Platform 83B2 -URL
    Returns only the driver pack URL for platform 83B2.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-13 - Initial help block created
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position=0,mandatory=$false)]
    [string]$Platform,
    [switch]$URL,
    [switch]$download
    )
    if ($Platform){$MachinePlatform = $platform}
    else {$MachinePlatform = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product}
    $OSList = Get-HPOSSupport -Platform $MachinePlatform
    if (($OSList.OSDescription) -contains "Microsoft Windows 11"){
        $OS = "11.0"
        #Get the supported Builds for Windows 11 so we can loop through them
        $SupportedWinXXBuilds = ($OSList| Where-Object {$_.OSDescription -match "11"}).OSReleaseIdDisplay | Sort-Object -Descending
        if ($SupportedWinXXBuilds){
            write-Verbose "Checking for Win $OS Driver Pack"
            [int]$Loop_Index = 0
            do {
                Write-Verbose "Checking for Driver Pack for $OS $($SupportedWinXXBuilds[$loop_index])"
                $DriverPack = Get-HPSoftPaqItems -osver $($SupportedWinXXBuilds[$loop_index]) -os $OS -Platform $MachinePlatform | Where-Object {$_.Category -match "Driver Pack"}
                #$DriverPack = Get-SoftpaqList -Category Driverpack -OsVer $($SupportedWinXXBuilds[$loop_index]) -Os "Win11" -ErrorAction SilentlyContinue

                if (!($DriverPack)){$Loop_Index++;}
                if ($DriverPack){
                    Write-Verbose "Windows 11 $($SupportedWinXXBuilds[$loop_index]) Driver Pack Found"
                }
            }
            while ($null -eq $DriverPack -and $loop_index -lt $SupportedWinXXBuilds.Count)
        }
    }

    if (!($DriverPack)){ #If no Win11 Driver Pack found, check for Win10 Driver Pack
        if (($OSList.OSDescription) -contains "Microsoft Windows 10"){
            $OS = "10.0"
            #Get the supported Builds for Windows 10 so we can loop through them
            $SupportedWinXXBuilds = ($OSList| Where-Object {$_.OSDescription -match "10"}).OSReleaseIdDisplay | Sort-Object -Descending
            if ($SupportedWinXXBuilds){
                write-Verbose "Checking for Win $OS Driver Pack"
                [int]$Loop_Index = 0
                do {
                    Write-Verbose "Checking for Driver Pack for $OS $($SupportedWinXXBuilds[$loop_index])"
                    $DriverPack = Get-HPSoftPaqItems -osver $($SupportedWinXXBuilds[$loop_index]) -os $OS  -Platform $MachinePlatform | Where-Object {$_.Category -match "Driver Pack"}
                    #$DriverPack = Get-SoftpaqList -Category Driverpack -OsVer $($SupportedWinXXBuilds[$loop_index]) -Os "Win10" -ErrorAction SilentlyContinue
                    if (!($DriverPack)){$Loop_Index++;}
                    if ($DriverPack){
                        Write-Verbose "Windows 10 $($SupportedWinXXBuilds[$loop_index]) Driver Pack Found"
                    }
                }
                while ($null-eq $DriverPack  -and $loop_index -lt $SupportedWinXXBuilds.Count)
            }
        }
    }
    if ($DriverPack){
        Write-Verbose "Driver Pack Found: $($DriverPack.Name) for Platform: $Platform"
        if($PSBoundParameters.ContainsKey('Download')){
            Save-WebFile -SourceUrl "https://$($DriverPack.URL)" -DestinationName "$($DriverPack.id).exe" -DestinationDirectory "C:\Drivers"
        }
        else{
        if($PSBoundParameters.ContainsKey('URL')){
                return "https://$($DriverPack.URL)"
            }
            else {
                return $DriverPack
            }
        }
    }
    else {
        Write-Verbose "No Driver Pack Found for Platform: $Platform"
        return $false
    }
}

function Invoke-HPIAOfflineSync {
    <#
    .SYNOPSIS
    Creates and synchronizes an offline HPIA repository for the local HP platform.

    .DESCRIPTION
    Builds a local repository using HPCMSL commands, applies platform and OS
    filters, and downloads selected update content for offline use. Logs are
    written to C:\OSDCloud\Logs\HPIAOfflineSync.log.

    .PARAMETER Category
    Update category filter for repository content. Valid values are All, BIOS,
    Driver, Software, Firmware, and UWPPack.

    .PARAMETER OS
    Operating system filter passed to Add-RepositoryFilter, such as win11.

    .PARAMETER Release
    Operating system release filter passed to Add-RepositoryFilter, such as 23H2.

    .EXAMPLE
    Invoke-HPIAOfflineSync
    Creates an offline repository for the local platform using default Driver, win11, and 23H2 filters.

    .EXAMPLE
    Invoke-HPIAOfflineSync -Category BIOS -OS win10 -Release 22H2
    Creates an offline repository filtered to Windows 10 22H2 BIOS content.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-13 - Initial help block created
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)]
        [ValidateSet("All", "BIOS", "Driver", "Software", "Firmware", "UWPPack")]
        $Category = "Driver",
        [Parameter(Mandatory=$false)]
        $OS = "win11",
        [Parameter(Mandatory=$false)]
        $Release = "23H2"
    )

    #Create HPIA Repo & Sync for this Platform (EXE / Online)
    $LogFolder = "C:\OSDCloud\Logs"
    $HPIARepoFolder = "C:\OSDCloud\HPIA\Repo"
    $PlatformCode = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product
    New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
    New-Item -Path $HPIARepoFolder -ItemType Directory -Force | Out-Null
    $CurrentLocation = Get-Location
    Set-Location -Path $HPIARepoFolder
    Initialize-Repository | out-null
    Set-RepositoryConfiguration -Setting OfflineCacheMode -CacheValue Enable | out-null
    Add-RepositoryFilter -Os $OS -OsVer $Release -Category $Category -Platform $PlatformCode | out-null
    Write-Host "Starting HPCMSL to create HPIA Repo for $($PlatformCode) with Drivers" -ForegroundColor Green
    write-host " This process can take several minutes to download all drivers" -ForegroundColor Gray
    write-host " Writing Progress Log to $LogFolder" -ForegroundColor Gray
    write-host " Downloading to $HPIARepoFolder" -ForegroundColor Gray
    Invoke-RepositorySync -Verbose 4> "$LogFolder\HPIAOfflineSync.log"
    Set-Location $CurrentLocation
    Write-Host "Completed Driver Download for HP Device to be applied in OOBE" -ForegroundColor Green
}
