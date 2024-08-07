<#
.SYNOPSIS
    This function adds 7-Zip to a boot image.
.DESCRIPTION
    The function downloads the latest version of 7-Zip from the GitHub page and extracts it to the specified boot image path or the mounted Windows image path.
.PARAMETER MountPath
    The path to the boot image or the mounted Windows image. If not specified, the function will attempt to get the mounted Windows image path.
.PARAMETER Use7zr
    Specifies whether to use 7zr.exe instead of 7z.exe in your boot media. Default is false.
.PARAMETER TempTest
    Specifies whether to use a temporary test path for extracting the 7z file. Default is false.
.EXAMPLE
    Add-7Zip2BootImage -MountPath "C:\BootImage" -Use7zr
    This example adds 7-Zip (7zr.exe) to the boot image located at "C:\BootImage"
.EXAMPLE
    Add-7Zip2BootImage
    This example adds 7-Zip (7z.exe + 2 dll files) to the boot image at the mounted WIM path it finds.
#>

function Add-7Zip2BootImage{
    param(
        [Parameter(Position=0,mandatory=$false)]    
        [string]$MountPath,
        [switch]$Use7zr, #Uses 7zr.exe instead of 7z.exe
        [switch]$TempTest
    )
    if ($TempTest){
        $MountPath = "$env:temp\7zip"
    }
    else {
        if (!($MountPath)){
            $MountPath = (Get-WindowsImage -Mounted).path
            if ($MountPath.count -gt 1){
                Write-Warning "Multiple Images Mounted, please specify the path"
                return
            }  
            if (!(Test-Path -Path $MountPath\Windows\System32)){
                Write-Host -ForegroundColor Yellow "Unable to find Windows\System32 in $MountPath"
                return
            }
        }
    }
    Write-Host -ForegroundColor DarkGray "Using Current Mount Path: $MountPath"
    #Scrape the latest version of 7zip from the github page
    $Latest = Invoke-WebRequest -Uri https://github.com/ip7z/7zip/releases/latest -UseBasicParsing
    $NextLink = ($Latest.Links | Where-Object {$_.href -match "releases/tag"}).href
    $Version = $NextLink.Split("/")[-1]
    $VersionClean = ($Version).Replace(".","")
    $FileName = "7z$VersionClean-extra.7z" #Full 7zip command line options, 3 files
    if ($Use7zr){$FileName = "lzma$VersionClean.7z"} #Reduced 7zip command line options, 1 file
    # Example: https://github.com/ip7z/7zip/releases/download/24.07/7z2407-extra.7z
    $Download7zrURL = "https://github.com/ip7z/7zip/releases/download/$Version/7zr.exe" #Needed to extract the 7z file - isn't 64bit
    $DownloadURL ="https://github.com/ip7z/7zip/releases/download/$Version/$fileName" #This is 64bit

    if ($Null -eq $NextLink -or $null -eq $Version){
        Write-Warning "Could not find the latest version of 7zip"
        return
    } 

    Write-Host -ForegroundColor DarkGray "Downloading $Download7zrURL"
    Invoke-WebRequest -Uri $Download7zrURL -OutFile "$env:TEMP\7zr.exe" -UseBasicParsing
    Write-Host -ForegroundColor DarkGray "Downloading $DownloadURL"
    Invoke-WebRequest -Uri $DownloadURL -OutFile "$env:TEMP\$FileName" -UseBasicParsing
    if ((Test-Path -Path $env:TEMP\$FileName) -and (Test-Path -Path $env:TEMP\7zr.exe)){
        Write-Host -ForegroundColor DarkGray "Extracting $env:TEMP\$FileName to $env:temp\7zip"
        $null = & "$env:temp\7zr.exe" x "$env:TEMP\$FileName" -o"$env:temp\7zip" -y
        if (!($TempTest)){   
            if ($Use7zr){
                Copy-Item -Path "$env:temp\7zip\bin\x64\7zr.exe" -Destination "$MountPath\Windows\System32" -Recurse -Force -Verbose
            }
            else{
                Copy-Item -Path "$env:temp\7zip\x64\*" -Destination "$MountPath\Windows\System32" -Recurse -Force -Verbose
            }
        }
    }
    else {
        Write-Warning "Could not find $env:TEMP\$FileName"
    }
}