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
https://osd.osdeploy.com

.NOTES
#>
function Get-HPPlatformCatalog {
    [CmdletBinding()]
    param (
        #Checks for the latest Online version
        [System.Management.Automation.SwitchParameter]
        $Online,

        #Updates the local catalog in the OSD Module
        [System.Management.Automation.SwitchParameter]
        $UpdateModuleCatalog
    )
    #=================================================
    #   Paths
    #=================================================
    $UseCatalog             = 'Cloud'
    $CloudCatalogUri        = 'https://ftp.hp.com/pub/caps-softpaq/cmit/imagepal/ref/platformList.cab'
    $RawCatalogFile			= Join-Path $env:TEMP (Join-Path 'OSD' 'platformList.xml')
    $TempCatalogFile		= Join-Path $env:TEMP (Join-Path 'OSD' 'HPPlatformCatalog.xml')
    $ModuleCatalogFile     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\HPPlatformCatalog.xml"

    $RawCatalogCabName  	= [string]($CloudCatalogUri | Split-Path -Leaf)
    $RawCatalogCabPath 	    = Join-Path $env:TEMP (Join-Path 'OSD' $RawCatalogCabName)
    #=================================================
    #   Create Download Path
    #=================================================
    if (-not(Test-Path (Join-Path $env:TEMP 'OSD'))) {
        $null = New-Item -Path (Join-Path $env:TEMP 'OSD') -ItemType Directory -Force
    }
    #=================================================
    #   Test Build Catalog
    #=================================================
    if (Test-Path $TempCatalogFile) {
        Write-Verbose "Build Catalog already created at $TempCatalogFile"	

        $GetItemBuildCatalogFile = Get-Item $TempCatalogFile

        #If the Build Catalog is older than 12 hours, delete it
        if (((Get-Date) - $GetItemBuildCatalogFile.LastWriteTime).TotalHours -gt 12) {
            Write-Verbose "Removing previous Build Catalog"
            $null = Remove-Item $GetItemBuildCatalogFile.FullName -Force
        }
        else {
            $UseCatalog = 'Build'
        }
    }
    #=================================================
    #   Test Cloud Catalog
    #=================================================
    if ($UseCatalog -eq 'Cloud') {
        if (Test-WebConnection -Uri $CloudCatalogUri) {
            $UseCatalog = 'Cloud'
        }
        else {
            $UseCatalog = 'Offline'
        }
    }
    #=================================================
    #   UseCatalog Cloud
    #=================================================
    if ($UseCatalog -eq 'Cloud') {
        Write-Verbose "Source: $CloudCatalogUri"
        Write-Verbose "Destination: $RawCatalogCabPath"
        (New-Object System.Net.WebClient).DownloadFile($CloudCatalogUri, $RawCatalogCabPath)

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
    #   UseCatalog Build
    #=================================================
    if ($UseCatalog -eq 'Build') {
        Write-Verbose "Importing the Build Catalog at $TempCatalogFile"
        $Results = Import-Clixml -Path $TempCatalogFile
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