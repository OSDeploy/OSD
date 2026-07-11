function Get-EnablementPackage {
    <#
    .SYNOPSIS
    Returns the latest matching Windows enablement package metadata.

    .DESCRIPTION
    Retrieves enablement package metadata from the WSUSXML catalog and filters the result by build and architecture.

    .PARAMETER OSBuild
    Target Windows release build used to filter the enablement package.

    .PARAMETER OSArch
    Target operating system architecture used to filter the enablement package.

    .EXAMPLE
    Get-EnablementPackage -OSBuild 22H2 -OSArch x64
    Returns the newest x64 enablement package metadata for 22H2.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    #>
    [CmdletBinding()]
    param (
        [ValidateSet('22H2','21H2','21H1','20H2','1909')]
        [Alias('Build')]
        [string]$OSBuild = '22H2',

        [ValidateSet('x64','x86')]
        [string]$OSArch = 'x64'
    )
    #=================================================
    #   Import Local EnablementPackage
    #=================================================
    $Result = Get-WSUSXML -Catalog Enablement -Silent
    #=================================================
    #   Filter Compatible
    #=================================================
    $Result = $Result | `
    Where-Object {$_.UpdateArch -eq $OSArch} | `
    Where-Object {$_.UpdateBuild -eq $OSBuild}
    #=================================================
    #   Pick and Sort
    #=================================================
    $Result = $Result | Sort-Object CreationDate -Descending | Select-Object -First 1
    #=================================================
    #   Return
    #=================================================
    Return $Result
    #=================================================
}
function Save-EnablementPackage {
    <#
    .SYNOPSIS
    Downloads a matching Windows enablement package.

    .DESCRIPTION
    Resolves an enablement package for the requested build and architecture, verifies connectivity, and downloads the package to the specified directory.

    .PARAMETER DownloadPath
    Destination directory where the enablement package file is saved.

    .PARAMETER OSBuild
    Target Windows release build used to select the enablement package.

    .PARAMETER OSArch
    Target operating system architecture used to select the enablement package.

    .EXAMPLE
    Save-EnablementPackage -DownloadPath C:\Temp -OSBuild 22H2 -OSArch x64
    Downloads the latest matching x64 enablement package for 22H2 to C:\Temp.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Added comment-based help
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Alias ('DownloadFolder','Path')]
        [string]$DownloadPath = "$env:TEMP",

        [ValidateSet('22H2','21H2','21H1','20H2','1909')]
        [Alias('Build')]
        [string]$OSBuild = '21H1',

        [ValidateSet('x64','x86')]
        [string]$OSArch = 'x64'
    )
    #=================================================
    #   Get-EnablementPackage
    #=================================================
    $Result = Get-EnablementPackage -OSBuild $OSBuild -OSArch $OSArch
    #=================================================
    #   SaveWebFile
    #=================================================
    if ($Result) {
        if (Test-Path "$DownloadPath\$($Result.FileName)") {
            Get-Item "$DownloadPath\$($Result.FileName)"
        }
        elseif (Test-WebConnection -Uri "$($Result.FileUri)") {
            $SaveWebFile = Save-WebFile -SourceUrl $Result.FileUri -DestinationDirectory "$DownloadPath" -DestinationName $Result.FileName

            if (Test-Path $SaveWebFile.FullName) {
                Get-Item $SaveWebFile.FullName
            }
            else {
                Write-Warning "Could not download the Enablement Package"
            }
        }
        else {
            Write-Warning "Could not verify an Internet connection for the Enablement Package"
        }
    }
    else {
        Write-Warning "Unable to determine a suitable Enablement Package"
    }
}
