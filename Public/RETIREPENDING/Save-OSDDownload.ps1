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
    param (
        #URL of the file to download
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline)]
        [Alias('DriverUrl')]
        [string[]]$SourceUrl,

        #Destination File
        [string]$DestinationName,

        #Destination Folder
        [string]$DownloadFolder = "$env:TEMP\OSD",

        #Overwrite the file if it exists already
        #The default action is to skip the download
        [switch]$Overwrite,

        #Download the file using BITS-Transfer
        #Interactive Login required
        [switch]$BitsTransfer
    )

    begin {

    }
    process {
        foreach ($Input in $SourceUrl) {
            #=======================================================================
            #	Create Object
            #=======================================================================
            $Global:OSDDownload = [ordered]@{
                Name = $null
                Parent = $DownloadFolder
                FullName = $null
                SourceUrl = $SourceUrl[0]
                Method = 'None'
                Download = $false
                IsDownloaded = $false
            }
            #=======================================================================
            #	Set DestinationName
            #=======================================================================
            if ($PSBoundParameters['DestinationName']) {
                $Global:OSDDownload.Name = $DestinationName
            } else {
                $Global:OSDDownload.Name = Split-Path -Path $Global:OSDDownload.SourceUrl -Leaf
            }
            #=======================================================================
            #	DownloadFolder
            #=======================================================================
            if (Test-Path "$DownloadFolder") {

            }
            else {
                New-Item -Path "$DownloadFolder" -ItemType Directory -Force -ErrorAction Stop
            }
            $Global:OSDDownload.DownloadFolder = (Get-Item $DownloadFolder).FullName
            $Global:OSDDownload.FullName = Join-Path $Global:OSDDownload.DownloadFolder $Global:OSDDownload.Name
            #=======================================================================
            #	OverWrite
            #=======================================================================
            if ($PSBoundParameters['Overwrite']) {
            }
            else {
                if (Test-Path $Global:OSDDownload.FullName) {
                    Write-Verbose "Download already exists $($Global:OSDDownload.FullName)"
                    $Global:OSDDownload.IsDownloaded = $true
                    Return $Global:OSDDownload
                }
            }
            #=======================================================================
            #	Download
            #=======================================================================
            if (Get-Command 'curl.exe') {
                Write-Verbose "cURL: $($Global:OSDDownload.SourceUrl)"
                $Global:OSDDownload.Method = 'cURL'

                if ($host.name -match 'ConsoleHost') {
                    Invoke-Expression "& curl.exe --location --output `"$($Global:OSDDownload.FullName)`" --url $($Global:OSDDownload.SourceUrl)"
                }
                else {
                    #PowerShell ISE will display a NativeCommandError, so progress will not be displayed
                    $Quiet = Invoke-Expression "& curl.exe --location --output `"$($Global:OSDDownload.FullName)`" --url $($Global:OSDDownload.SourceUrl) 2>&1"
                }
            }
            elseif ($PSBoundParameters['BitsTransfer']) {
                $Global:OSDDownload.Method = 'cURL'
                Start-BitsTransfer -Source $Global:OSDDownload.SourceUrl -Destination $Global:OSDDownload.FullName
            }
            else {
                $Global:OSDDownload.Method = 'WebClient'
                [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls1
                $WebClient = New-Object System.Net.WebClient
                $WebClient.DownloadFile($Global:OSDDownload.SourceUrl, $Global:OSDDownload.FullName)
            }
            Start-Sleep -Seconds 2
            #=======================================================================
            #	Return
            #=======================================================================
            if (Test-Path $Global:OSDDownload.FullName) {
                $Global:OSDDownload.IsDownloaded = $true
                Return $Global:OSDDownload
            }
            else {
                Write-Warning "Could not download $($Global:OSDDownload.FullName)"
                Return $null
            }
            #=======================================================================
        }
    }
    end {}
}