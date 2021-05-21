<#
.SYNOPSIS
Downloads a file from the internet and returns a Get-Item Object

.DESCRIPTION
Downloads a file from the internet and returns a Get-Item Object

.LINK
https://osd.osdeploy.com/module/functions/save-webfile

.NOTES
21.3.16.2   Updated to Return Get-Item
#>
function Save-WebFile {
    [CmdletBinding()]
    param (
        #URL of the file to download
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline)]
        [string]$SourceUrl,

        #Destination File Name
        [string]$DestinationName,

        #Destination Folder
        [Alias('Path')]
        [string]$DestinationDirectory = "$env:TEMP\OSD",

        #Overwrite the file if it exists already
        #The default action is to skip the download
        [switch]$Overwrite
    )
    #=======================================================================
    #	DestinationDirectory
    #=======================================================================
    if (Test-Path "$DestinationDirectory") {
    }
    else {
        New-Item -Path "$DestinationDirectory" -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    Write-Verbose "DestinationDirectory: $DestinationDirectory"
    #=======================================================================
    #	DestinationName
    #=======================================================================
    if ($PSBoundParameters['DestinationName']) {
    }
    else {
        $DestinationName = Split-Path -Path $SourceUrl -Leaf
    }
    Write-Verbose "DestinationName: $DestinationName"
    #=======================================================================
    #	WebFileFullName
    #=======================================================================
    $DestinationDirectoryItem = (Get-Item $DestinationDirectory).FullName
    $DestinationFullName = Join-Path $DestinationDirectoryItem $DestinationName
    #=======================================================================
    #	OverWrite
    #=======================================================================
    if ((-NOT ($PSBoundParameters['Overwrite'])) -and (Test-Path $DestinationFullName)) {
        Write-Verbose "DestinationFullName already exists"
        Get-Item $DestinationFullName
    }
    else {
        #=======================================================================
        #	Download
        #=======================================================================
        if (Get-Command 'curl.exe') {
            Write-Verbose "cURL: $SourceUrl"
    
            if ($host.name -match 'ConsoleHost') {
                Invoke-Expression "& curl.exe --location --output `"$DestinationFullName`" --url `"$SourceUrl`""
            }
            else {
                #PowerShell ISE will display a NativeCommandError, so progress will not be displayed
                $Quiet = Invoke-Expression "& curl.exe --location --output `"$DestinationFullName`" --url `"$SourceUrl`" 2>&1"
            }
        }
        else {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls1
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile($SourceUrl, $DestinationFullName)
        }
        #=======================================================================
        #	Return
        #=======================================================================
        if (Test-Path $DestinationFullName) {
            Get-Item $DestinationFullName
        }
        else {
            Write-Warning "Could not download $DestinationFullName"
            $null
        }
        #=======================================================================
    }
}