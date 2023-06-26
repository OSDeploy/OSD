<#PSScriptInfo
.VERSION 23.6.6.1
.GUID 9aabfaa6-2760-46a0-ae53-ba845aa764c6
.AUTHOR Gary Blok, David Segura
.COMPANYNAME HP
.COPYRIGHT (c) 2023 HP. All rights reserved.
.TAGS HP HPIA
.LICENSEURI 
.PROJECTURI
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
#>
<#
.DESCRIPTION
Tests if a device is supported by HP Image Assistant
#>

Test-HPIASupport -Verbose


function Test-HPIASupport {
    [CmdletBinding()]
    param(
        [string]$PlatformID
    )
    if ($PlatformID) {
        $MachinePlatform = $PlatformID
    }
    else {
        $MachinePlatform = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product
    }
    Write-Verbose "PlatformID: $MachinePlatform" -Verbose

    if ($MachinePlatform) {
        $CabPath = "$env:TEMP\platformList.cab"
        $XMLPath = "$env:TEMP\platformList.xml"
        $PlatformListCabURL = "https://hpia.hpcloud.hp.com/ref/platformList.cab"
        if (!(Test-Path $CabPath)) {
            Invoke-WebRequest -Uri $PlatformListCabURL -OutFile $CabPath -UseBasicParsing
        }
        if (!(Test-Path $XMLPath)){
            $Expand = expand $CabPath $XMLPath
        }
        [xml]$XML = Get-Content $XMLPath
        $Platforms = $XML.ImagePal.Platform.SystemID

        if ($MachinePlatform -in $Platforms) {
            $true
        }
        else {
            $false
        }
    }
}