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
        #Download the file using BITS-Transfer
        #Interactive Login required
        [switch]$BitsTransfer,

        #Destination Folder
        [string]$DownloadFolder = $env:TEMP,

        #URL of the file to download
        [Parameter(Mandatory)]
        [string]$SourceUrl
    )

    if (! (Test-Path "$DownloadFolder")) {
        Write-Verbose "New-Item -Path $DownloadFolder"
        New-Item -Path "$DownloadFolder" -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    $DownloadFile = Split-Path -Path $SourceUrl -Leaf
    Write-Verbose "DownloadFile: $DownloadFile"

    $DownloadFullName = Join-Path $DownloadFolder $DownloadFile
    Write-Verbose "DownloadFullName: $DownloadFullName"

    if ($BitsTransfer.IsPresent) {
        Start-BitsTransfer -Source "$SourceUrl" -Destination "$DownloadFullName"
    } else {
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile("$SourceUrl","$DownloadFullName")
    }
    if (Test-Path "$DownloadFullName") {
        Return (Get-Item $DownloadFullName).FullName
    } else {
        Return
    }
}