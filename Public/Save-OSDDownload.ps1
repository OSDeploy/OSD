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
        [Parameter(Position = 0,Mandatory = $true, ValueFromPipelineByPropertyName)]
        [Alias('DriverUrl')]
        [string[]]$SourceUrl,

        #Destination File
        #[string]$DestinationName,

        #Destination Folder
        [string]$DownloadFolder = "$env:TEMP\OSD",

        #Overwrite the file if it exists already
        #The default action is to skip the download
        [switch]$Overwrite,

        #Download the file using BITS-Transfer
        #Interactive Login required
        [switch]$BitsTransfer
    )

    Begin {

    }
    Process {
        foreach ($Input in $SourceUrl) {
            #======================================================================================================
            #	Create Global Variable
            #======================================================================================================
            $global:OSDDownload = [ordered]@{
                Name = $null
                Parent = $DownloadFolder
                FullName = $null
                SourceUrl = $SourceUrl[0]
                BitsTransfer = $BitsTransfer
                Download = $true
                IsDownloaded = $false
            }
            #======================================================================================================
            #	Set Name
            #======================================================================================================
            #if (! $DestinationName) {
                Write-Verbose "Setting DestinationName"
                $global:OSDDownload.Name = Split-Path -Path $OSDDownload.SourceUrl -Leaf
            #}
            #======================================================================================================
            #	DownloadFolder
            #   Make sure DownloadFolder can be created
            #======================================================================================================
            if (! (Test-Path "$DownloadFolder")) {
                Write-Verbose "OSDDownload.DownloadFolder: Create $DownloadFolder"
                New-Item -Path "$DownloadFolder" -ItemType Directory -Force | Out-Null
                if (! (Test-Path $DownloadFolder)) {
                    Write-Warning "Unable to create $DownloadFolder"
                    Return
                }
            }
    
            $global:OSDDownload.DownloadFolder = (Get-Item $DownloadFolder).FullName
            $global:OSDDownload.FullName = Join-Path $global:OSDDownload.DownloadFolder $OSDDownload.Name
            Write-Verbose "OSDDownload FullName: $($OSDDownload.FullName)"
    
            if (!($Overwrite.IsPresent)) {
                if (Test-Path $global:OSDDownload.FullName) {
                    $global:OSDDownload.IsDownloaded = $true
                    Return $global:OSDDownload
                }
            }
        
            if ($BitsTransfer.IsPresent) {Start-BitsTransfer -Source $global:OSDDownload.SourceUrl -Destination $global:OSDDownload.FullName}
            else {
                $WebClient = New-Object System.Net.WebClient
                $WebClient.DownloadFile($global:OSDDownload.SourceUrl, $global:OSDDownload.FullName)
            }
        
            if (Test-Path $global:OSDDownload.FullName) {
                $global:OSDDownload.IsDownloaded = $true
            }
            #===================================================================================================
            #   Return for PassThru
            #===================================================================================================
            Return $global:OSDDownload
        }
    }
    End {}
}