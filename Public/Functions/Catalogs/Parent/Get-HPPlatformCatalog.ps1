<#
.SYNOPSIS
Converts the HP Platform list to a PowerShell Object. Useful to get the computer model name for System Ids

.DESCRIPTION
Converts the HP Platform list to a PowerShell Object. Useful to get the computer model name for System Ids
Requires Internet Access to download platformList.cab

.EXAMPLE
Get-HPPlatformCatalog
Don't do this, you will get a big list.

.EXAMPLE
$Results = Get-HPPlatformCatalog
Yes do this.  Save it in a Variable

.EXAMPLE
Get-HPPlatformCatalog | Out-GridView
Displays all the HP System Ids with the applicable computer model names in GridView

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-HPPlatformCatalog {
    [CmdletBinding()]
    param (
        #Checks for the latest Online version
        [System.Management.Automation.SwitchParameter]
        $Online,

        #Updates the OSD Module Offline Catalog
        [System.Management.Automation.SwitchParameter]
        $UpdateModuleCatalog
    )
    #=================================================
    #   Defaults
    #=================================================
    $UseCatalog = 'Offline'
    $OfflineCatalogName = 'Build-HPPlatformCatalog.xml'
    $OnlineCatalogName = 'platformList.xml'
    $OnlineCatalogUri = 'https://ftp.hp.com/pub/caps-softpaq/cmit/imagepal/ref/platformList.cab'
    #=================================================
    #   Initialize
    #=================================================
    $IsOnline = $false

    if ($UpdateModuleCatalog) {
        $Online = $true
    }
    if ($Online) {
        $UseCatalog = 'Cloud'
    }
    if ($Online) {
        $IsOnline = Test-WebConnection $OnlineCatalogUri
    }

    if ($IsOnline -eq $false) {
        $Online = $false
        $UpdateModuleCatalog = $false
        $UseCatalog = 'Offline'
    }
    Write-Verbose "$UseCatalog Catalog"
    #=================================================
    #   Additional Paths
    #=================================================
    $CatalogBuildFolder = Join-Path $env:TEMP 'OSD'
    if (-not(Test-Path $CatalogBuildFolder)) {
        $null = New-Item -Path $CatalogBuildFolder -ItemType Directory -Force
    }
    $RawCatalogFile			= Join-Path $env:TEMP (Join-Path 'OSD' $OnlineCatalogName)
    $RawCatalogCabName  	= [string]($OnlineCatalogUri | Split-Path -Leaf)
    $RawCatalogCabPath 		= Join-Path $env:TEMP (Join-Path 'OSD' $RawCatalogCabName)
    $TempCatalogFile        = Join-Path $env:TEMP (Join-Path 'OSD' $OfflineCatalogName)
    $ModuleCatalogFile      = "$(Get-OSDCatsPath)\osd-module\$OfflineCatalogName"
    #=================================================
    #   UseCatalog Cloud
    #=================================================
    if ($UseCatalog -eq 'Cloud') {
        Write-Verbose "Source: $OnlineCatalogUri"
        Write-Verbose "Destination: $RawCatalogCabPath"
        (New-Object System.Net.WebClient).DownloadFile($OnlineCatalogUri, $RawCatalogCabPath)

        if (Test-Path $RawCatalogCabPath) {
            Write-Verbose "Expand: $RawCatalogCabPath"
            $null = Expand "$RawCatalogCabPath" "$RawCatalogFile"

            if (Test-Path $RawCatalogFile) {
                Write-Verbose "Using Raw Catalog at $RawCatalogFile"
                $UseCatalog = 'Raw'
            }
            else {
                Write-Verbose "Could not expand $RawCatalogCabPath"
                Write-Verbose "Using Offline Catalog at $ModuleCatalogFile"
                $UseCatalog = 'Offline'
            }
        }
        else {
            Write-Verbose "Using Offline Catalog at $ModuleCatalogFile"
            $UseCatalog = 'Offline'
        }
    }
    #=================================================
    #   UseCatalog Raw
    #=================================================
    if ($UseCatalog -eq 'Raw') {
        Write-Verbose "Reading the Raw Catalog at $RawCatalogFile"
        [xml]$XmlCatalogContent = Get-Content $RawCatalogFile -ErrorAction Stop
        $CatalogVersion = $XmlCatalogContent.ImagePal.DateLastModified | Get-Date -Format yy.MM.dd
        $Platforms = $XmlCatalogContent.ImagePal.Platform
        
        $Results = foreach ($platform in $Platforms) {             
            $ObjectProperties = [Ordered]@{
                CatalogVersion  = $CatalogVersion
                Component       = 'Model'
                Status          = $null
                SystemId        = $platform.SystemId
                SupportedModel  = [array]($platform.ProductName.'#text')
                #LatestWin10SupportedBuild = $platform.OS | Sort-Object -Property OSBuildId -Descending | Select-Object -First 1 -ExpandProperty OSReleaseIdDisplay
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
        

        Write-Verbose "Exporting Build Catalog to $TempCatalogFile"
        $Results = $Results | Sort-Object -Property SystemId
        $Results | Export-Clixml -Path $TempCatalogFile
    }
    #=================================================
    #   UpdateModuleCatalog
    #=================================================
    if ($UpdateModuleCatalog) {
        if (Test-Path $TempCatalogFile) {
            Write-Verbose "Copying $TempCatalogFile to $ModuleCatalogFile"
            Copy-Item $TempCatalogFile $ModuleCatalogFile -Force -ErrorAction Ignore
        }
    }
    #=================================================
    #   UseCatalog Offline
    #=================================================
    if ($UseCatalog -eq 'Offline') {
        Write-Verbose "Importing the Offline Catalog at $ModuleCatalogFile"
        $Results = Import-Clixml -Path $ModuleCatalogFile
    }
    #=================================================
    #   Complete
    #=================================================
    $Results | Sort-Object -Property SystemId
    #=================================================
}