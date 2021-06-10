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
        [switch]$Overwrite,
        [string]$Proxy = $null ,
        [ValidateSet('NTLM', 'Basic', 'Negotiate')]
        [string]$ProxyType = "Basic",
        [string]$ProxyUser = $null, 
        [string]$ProxyPassword = $null 
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
            $curlopt = ""
            if($Proxy -ne $null){
                $curlopt += " --proxy $proxy"
                if($ProxyType){
                    if ($ProxyType -eq "Basic") {
                        $curlopt += " --proxy-basic"
                    }
                    elseif ($ProxyType -eq "NTLM") {
                        $curlopt += " --proxy-ntlm"
                    }
                    elseif ($ProxyType -eq "Negotiate") {
                        $curlopt += " --proxy-negotiate"
                    }
                }
                if($ProxyUser -ne $null -and $ProxyPassword -ne $null){
                    $curlopt += " --proxy-user $proxyUser`:$proxyPassword"
                }elseif($ProxyUser -ne $null){
                    $curlopt += " --proxy-user $proxyUser"
                }
            }                
    
            if ($host.name -match 'ConsoleHost') {

                Write-Host "& curl.exe --location --output `"$DestinationFullName`" --url $SourceUrl  $curlopt"
                Invoke-Expression "& curl.exe --location --output `"$DestinationFullName`" --url $SourceUrl $curlopt"
            }
            else {
                #PowerShell ISE will display a NativeCommandError, so progress will not be displayed
                Write-Verbose "& curl.exe --location --output `"$DestinationFullName`" --url $SourceUrl  $curlopt 2>&1"
                $Quiet = Invoke-Expression "& curl.exe --location --output `"$DestinationFullName`" --url $SourceUrl  $curlopt 2>&1"
                $Quiet
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
