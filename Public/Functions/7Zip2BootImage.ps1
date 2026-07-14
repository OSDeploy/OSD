function Add-7Zip2BootImage {
    <#
    .SYNOPSIS
    Adds 7-Zip command-line binaries to a mounted Windows image.

    .DESCRIPTION
    Downloads the latest 7-Zip release assets from GitHub and copies the
    extracted binaries into Windows\System32 for the target mount path.

    .PARAMETER MountPath
    Mounted Windows image path. If omitted, uses the currently mounted image.

    .PARAMETER Use7zr
    Copies 7zr.exe only instead of the full 7z x64 binaries.

    .PARAMETER TempTest
    Uses a temporary test path under %TEMP% instead of a mounted image.

    .EXAMPLE
    Add-7Zip2BootImage -MountPath 'C:\Mount'
    Downloads and copies 7-Zip binaries into C:\Mount\Windows\System32.

    .EXAMPLE
    Add-7Zip2BootImage -Use7zr
    Adds only 7zr.exe to the detected mounted image.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Updated comment-based help
    2026-07-13 - Refactored internals for readability without changing output behavior
    #>
    param(
        [Parameter(Position=0,mandatory=$false)]
        [string]$MountPath,
        [switch]$Use7zr, #Uses 7zr.exe instead of 7z.exe
        [switch]$TempTest
    )
    $Temp7ZipPath = Join-Path -Path $env:TEMP -ChildPath '7zip'
    $Temp7zrPath = Join-Path -Path $env:TEMP -ChildPath '7zr.exe'

    if ($TempTest) {
        $MountPath = $Temp7ZipPath
    }
    else {
        if (-not $MountPath) {
            $MountPath = (Get-WindowsImage -Mounted).Path
            if ($MountPath.Count -gt 1) {
                Write-Warning "Multiple Images Mounted, please specify the path"
                return
            }
            if (-not (Test-Path -Path (Join-Path -Path $MountPath -ChildPath 'Windows\System32'))) {
                Write-Host -ForegroundColor Yellow "Unable to find Windows\System32 in $MountPath"
                return
            }
        }
    }
    Write-Host -ForegroundColor DarkGray "Using Current Mount Path: $MountPath"
    #Scrape the latest version of 7zip from the github page
    $Latest = Invoke-WebRequest -Uri https://github.com/ip7z/7zip/releases/latest -UseBasicParsing
    $NextLink = ($Latest.Links | Where-Object { $_.href -match 'releases/tag' } | Select-Object -First 1).href
    if ($null -eq $NextLink) {
        Write-Warning "Could not find the latest version of 7zip"
        return
    }

    $Version = $NextLink.Split('/')[-1]
    $VersionClean = ($Version).Replace(".","")
    $FileName = "7z$VersionClean-extra.7z" #Full 7zip command line options, 3 files
    if ($Use7zr) { $FileName = "lzma$VersionClean.7z" } #Reduced 7zip command line options, 1 file
    # Example: https://github.com/ip7z/7zip/releases/download/24.07/7z2407-extra.7z
    $Download7zrURL = "https://github.com/ip7z/7zip/releases/download/$Version/7zr.exe" #Needed to extract the 7z file - isn't 64bit
    $DownloadURL = "https://github.com/ip7z/7zip/releases/download/$Version/$FileName" #This is 64bit

    $DownloadedArchivePath = Join-Path -Path $env:TEMP -ChildPath $FileName

    if ($Null -eq $NextLink -or $null -eq $Version) {
        Write-Warning "Could not find the latest version of 7zip"
        return
    }

    Write-Host -ForegroundColor DarkGray "Downloading $Download7zrURL"
    Invoke-WebRequest -Uri $Download7zrURL -OutFile $Temp7zrPath -UseBasicParsing
    Write-Host -ForegroundColor DarkGray "Downloading $DownloadURL"
    Invoke-WebRequest -Uri $DownloadURL -OutFile $DownloadedArchivePath -UseBasicParsing
    if ((Test-Path -Path $DownloadedArchivePath) -and (Test-Path -Path $Temp7zrPath)) {
        Write-Host -ForegroundColor DarkGray "Extracting $env:TEMP\$FileName to $env:temp\7zip"
        $null = & $Temp7zrPath x $DownloadedArchivePath -o"$Temp7ZipPath" -y
        if (-not $TempTest) {
            if ($Use7zr) {
                Copy-Item -Path (Join-Path -Path $Temp7ZipPath -ChildPath 'bin\x64\7zr.exe') -Destination (Join-Path -Path $MountPath -ChildPath 'Windows\System32') -Recurse -Force -Verbose
            }
            else {
                Copy-Item -Path (Join-Path -Path $Temp7ZipPath -ChildPath 'x64\*') -Destination (Join-Path -Path $MountPath -ChildPath 'Windows\System32') -Recurse -Force -Verbose
            }
        }
    }
    else {
        Write-Warning "Could not find $env:TEMP\$FileName"
    }
}
