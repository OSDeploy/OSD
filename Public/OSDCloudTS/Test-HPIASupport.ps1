function Test-HPIASupport {
    $CabPath = "$env:TEMP\platformList.cab"
    $XMLPath = "$env:TEMP\platformList.xml"
    $PlatformListCabURL = "https://hpia.hpcloud.hp.com/ref/platformList.cab"
    Invoke-WebRequest -Uri $PlatformListCabURL -OutFile $CabPath -UseBasicParsing
    $Expand = expand $CabPath $XMLPath
    [xml]$XML = Get-Content $XMLPath
    $Platforms = $XML.ImagePal.Platform.SystemID
    $MachinePlatform = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product
    if ($MachinePlatform -in $Platforms){$HPIASupport = $true}
    else {$HPIASupport = $false}
    return $HPIASupport
}

function Get-HPOSSupport {
    [CmdletBinding()]
    param(
    [switch]$Latest,
    [switch]$MaxOS,
    [switch]$MaxOSVer
    )
    $CabPath = "$env:TEMP\platformList.cab"
    $XMLPath = "$env:TEMP\platformList.xml"
    $PlatformListCabURL = "https://hpia.hpcloud.hp.com/ref/platformList.cab"
    Invoke-WebRequest -Uri $PlatformListCabURL -OutFile $CabPath -UseBasicParsing
    $Expand = expand $CabPath $XMLPath
    [xml]$XML = Get-Content $XMLPath
    $MachinePlatform = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product
    $XMLPlatforms = $XML.ImagePal.Platform
    $OSList = ($XMLPlatforms | Where-Object {$_.SystemID -match $MachinePlatform}).OS | Select-Object -Property OSVersion, OSReleaseIdDisplay, OSBuildId, OSDescription
    
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
        [String]$MaxOSVerion = (($OSList | Where-Object {$_.OSDescription -eq "$MaxOSSupported"}).OSReleaseIdDisplay | Measure-Object -Maximum).Maximum
        return "$MaxOSVerion"
        break
    }
    return $OSList
    
}
function Invoke-HPIAOfflineSync {
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
