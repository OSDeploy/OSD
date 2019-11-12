<#
.SYNOPSIS
Downloads a file from the internet

.DESCRIPTION
Downloads a file from the internet.  Success returns $true

.LINK
https://osd.osdeploy.com/module/functions/save-osddownload

.NOTES
19.10.25 David Segura @SeguraOSD
#>
function Save-OSDDownload {
    [CmdletBinding()]
    Param (
        #URL of the file to download
        [Parameter(Mandatory)]
        [string]$SourceUrl,

        #Destination Folder
        [string]$DownloadFolder = "$env:TEMP\OSD",

        #Overwrite the file if it exists already
        #The default action is to skip the download
        [switch]$Overwrite,

        #Download the file using BITS-Transfer
        #Interactive Login required
        [switch]$BitsTransfer
    )
    
    $global:OSDDownload = [ordered]@{
        Name = $null
        FullName = $null
        DownloadFolder = $DownloadFolder
        SourceUrl = $SourceUrl
        BitsTransfer = $BitsTransfer
        Download = $true
        IsDownloaded = $false
    }


    $global:OSDDownload.Name = Split-Path -Path $OSDDownload.SourceUrl -Leaf
    Write-Verbose "OSDDownload Name: $($OSDDownload.Name)"

    $global:OSDDownload.FullName = Join-Path $DownloadFolder $OSDDownload.Name
    Write-Verbose "OSDDownload FullName: $($OSDDownload.FullName)"

    #======================================================================================================
    #	DownloadFolder
    #   Make sure DownloadFolder can be created
    #======================================================================================================
    if (! (Test-Path "$DownloadFolder")) {
        Write-Verbose "New-Item -Path $DownloadFolder"
        New-Item -Path "$DownloadFolder" -ItemType Directory -Force | Out-Null
        if (!(Test-Path $DownloadFolder)) {
            Return $global:OSDDownload
        }
    }

    if (!($Overwrite.IsPresent)) {
        if (Test-Path $OSDDownload.FullName) {
            $global:OSDDownload.IsDownloaded = $true
            Return $global:OSDDownload
        }
    }

    if ($BitsTransfer.IsPresent) {Start-BitsTransfer -Source $SourceUrl -Destination $OSDDownload.FullName}
    else {
        $WebClient = New-Object System.Net.WebClient
        $WebClient.OSDDownload.Name($SourceUrl,$OSDDownload.FullName)
    }

    if (Test-Path $OSDDownload.FullName) {
        $global:OSDDownload.IsDownloaded = $true
    }
    Return $global:OSDDownload
}