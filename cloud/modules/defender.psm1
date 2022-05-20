<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module is designed for OOBE
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/defender.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/defender.psm1')
#>
#=================================================
#region Functions
function osdcloud-UpdateDefender {
    [CmdletBinding()]
    param ()
    if (Test-Path "$env:ProgramFiles\Windows Defender\MpCmdRun.exe") {
        Write-Host -ForegroundColor Cyan 'Updating Windows Defender'
        & "$env:ProgramFiles\Windows Defender\MpCmdRun.exe" -signatureupdate
    }
}
New-Alias -Name 'UpdateDefender' -Value 'osdcloud-UpdateDefender' -Description 'OSDCloud' -Force

function osdcloud-UpdateDefenderStack {
[CmdletBinding()]
param ()
# Source Addresses - Defender for Windows 10, 8.1 ################################
$sourceAVx64 = "http://go.microsoft.com/fwlink/?LinkID=121721&arch=x64"
$sourcePlatformx64 = "https://go.microsoft.com/fwlink/?LinkID=870379&clcid=0x409&arch=x64"
Write-Output "UPDATE Defender Package Script version $ScriptVer..."
$Intermediate = "$env:TEMP\DefenderScratchSpace"

if(!(Test-Path -Path "$Intermediate")) {
    $Null = New-Item -Path "$env:TEMP" -Name "DefenderScratchSpace" -ItemType Directory
    }

if(!(Test-Path -Path "$Intermediate\x64")) {
    $Null = New-Item -Path "$Intermediate" -Name "x64" -ItemType Directory
    }
Remove-Item -Path "$Intermediate\x64\*" -Force -EA SilentlyContinue
$wc = New-Object System.Net.WebClient

# x64 AV #########################################################################

$Dest = "$Intermediate\x64\" + 'mpam-fe.exe'
Write-Output "Starting MPAM-FE Download"
$wc.DownloadFile($sourceAVx64, $Dest)
if(Test-Path -Path $Dest) {
    $x = Get-Item -Path $Dest
    [version]$Version1a = $x.VersionInfo.ProductVersion #Downloaded
    [version]$Version1b = (Get-MpComputerStatus).AntivirusSignatureVersion #Currently Installed
    if ($Version1a -gt $Version1b){
        Write-Output "Starting MPAM-FE Install of $Version1b to $Version1a"
        $MPAMInstall = Start-Process -FilePath $Dest -Wait -PassThru
        }
    else{Write-Output "No Update Needed, Installed:$Version1b vs Downloaded: $Version1a"}
    Write-Output "Finished MPAM-FE Install"
    }
else{Write-Output "Failed MPAM-FE Download"}

# x64 Update Platform ########################################################################
Write-Output "Starting Update Platform Download"
$Dest = "$Intermediate\x64\" + 'UpdatePlatform.exe'
$wc.DownloadFile($sourcePlatformx64, $Dest)

if(Test-Path -Path $Dest) {
    $x = Get-Item -Path $Dest
    [version]$Version2a = $x.VersionInfo.ProductVersion #Downloaded
    [version]$Version2b = (Get-MpComputerStatus).AMServiceVersion #Installed

    if ($Version2a -gt $Version2b){
        Write-Output "Starting Update Platform Install of $Version2b to $Version2a"
        $UPInstall = Start-Process -FilePath $Dest -Wait -PassThru
        }
    else {Write-Output "No Update Needed, Installed:$Version2b vs Downloaded: $Version2a"}
    Write-Output "Finished Update Platform Install"
    }
else {Write-Output "Failed Update Platform Download"}
}
New-Alias -Name 'UpdateDefenderStack' -Value 'osdcloud-UpdateDefenderStack' -Description 'OSDCloud' -Force
#endregion
#=================================================