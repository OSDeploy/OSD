<#
.SYNOPSIS
Returns the Lenovo DriverPacks downloads

.DESCRIPTION
Returns the Lenovo DriverPacks downloads

.PARAMETER Compatible
Filters results based on your current Product

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-OSDCatalogLenovoDriverPack {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Compatible,
        [System.String]$DownloadPath,
        [System.Management.Automation.SwitchParameter]$Force,
        [System.Management.Automation.SwitchParameter]$TestUrl
    )
    #=================================================
    #   Paths
    #=================================================
    $UseCatalog           	= 'Cloud'
    $CloudCatalogUri		= 'https://download.lenovo.com/cdrt/td/catalogv2.xml'
    $RawCatalogFile			= Join-Path $env:TEMP (Join-Path 'OSD' 'catalogv2.xml')
    $BuildCatalogFile       = Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogLenovoDriverPack.xml')
    $OfflineCatalogFile		= "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\OSDCatalog\OSDCatalogLenovoDriverPack.xml"
    #=================================================
    #   Create Paths
    #=================================================
    if (-not(Test-Path (Join-Path $env:TEMP 'OSD'))) {
        $null = New-Item -Path (Join-Path $env:TEMP 'OSD') -ItemType Directory -Force
    }
    #=================================================
    #   Test Build Catalog
    #=================================================
    if (Test-Path $BuildCatalogFile) {
        Write-Verbose "Build Catalog already created at $BuildCatalogFile"	

        $GetItemBuildCatalogFile = Get-Item $BuildCatalogFile

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
    if ($Force) {
        $UseCatalog = 'Cloud'
    }
    if ($UseCatalog -eq 'Cloud') {
        try {
            $CatalogCloudRaw = Invoke-RestMethod -Uri $CloudCatalogUri -UseBasicParsing
            Write-Verbose "Cloud Catalog $CloudCatalogUri"
            Write-Verbose "Saving Cloud Catalog to $RawCatalogFile"		
            $CatalogCloudContent = $CatalogCloudRaw.Substring(3)
            $CatalogCloudContent | Out-File -FilePath $RawCatalogFile -Encoding utf8 -Force

            if (Test-Path $RawCatalogFile) {
                Write-Verbose "Catalog saved to $RawCatalogFile"
                $UseCatalog = 'Raw'
            }
            else {
                Write-Verbose "Catalog was NOT downloaded to $RawCatalogFile"
                Write-Verbose "Using Offline Catalog at $OfflineCatalogFile"
                $UseCatalog = 'Offline'
            }
        }
        catch {
            Write-Verbose "Using Offline Catalog at $OfflineCatalogFile"
            $UseCatalog = 'Offline'
        }
    }
    #=================================================
    #   UseCatalog Raw
    #=================================================
    if ($UseCatalog -eq 'Raw') {
        Write-Verbose "Reading the Raw Catalog at $RawCatalogFile"	
        [xml]$XmlCatalogContent = Get-Content -Path $RawCatalogFile -Raw

        $ModelList = $XmlCatalogContent.ModelList.Model
        #=================================================
        #   Create Object 
        #=================================================
        $Results = foreach ($Model in $ModelList) {
            foreach ($Item in $Model.SCCM) {
                $DownloadUrl = $Item.'#text'

                $ReleaseDate = $null

                $ObjectProperties = [Ordered]@{
                    CatalogVersion 	= Get-Date -Format yy.MM.dd
                    Status          = $null
                    Component       = 'DriverPack'
                    ReleaseDate     = $ReleaseDate
                    Manufacturer    = 'Lenovo'
                    Model           = $Model.name
                    Product			= [array]$Model.Types.Type.split(',').Trim()
                    Name			= $Model.name
                    PackageID       = $null
                    FileName        = $DownloadUrl | Split-Path -Leaf
                    Url             = $DownloadUrl
                    OSVersion       = $Item.version
                    HashMD5         = $null
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
        }
        $Results = $Results | Sort-Object Name, OSVersion -Descending | Group-Object Name | ForEach-Object {$_.Group | Select-Object -First 1}
        $Results = $Results | Sort-Object Name, OSVersion -Descending

        foreach ($Result in $Results) {
            if ($Result.FileName -match 'w11') {
                $Result.Name = $Result.Name + ' Win11'
            }
            else {
                $Result.Name = $Result.Name + ' Win10'
            }
        }

        if ($TestUrl) {
            $Results = $Results | Sort-Object Url
            $PreviousUrl = $null
            foreach ($Item in $Results) {
                $CurrentUrl = $Item.Url
                if ($CurrentUrl -ne $PreviousUrl) {
                    Write-Verbose "Testing Download File at $CurrentUrl"
                    try {
                        $DownloadHeaders = (Invoke-WebRequest -Method Head -Uri $CurrentUrl -UseBasicParsing).Headers
                        $Item.ReleaseDate = Get-Date ($DownloadHeaders['Last-Modified']) -Format "yy.MM.dd"
                    }
                    catch {
                        Write-Warning "Failed: $CurrentUrl"
                        $Item.Status = 'Failed'
                    }
                }
                else {
                    $Item.ReleaseDate = Get-Date ($DownloadHeaders['Last-Modified']) -Format "yy.MM.dd"
                }
                $PreviousUrl = $CurrentUrl
            }
        }

        Write-Verbose "Exporting Build Catalog to $BuildCatalogFile"
        $Results = $Results | Sort-Object Name
        $Results | Export-Clixml -Path $BuildCatalogFile
    }
    #=================================================
    #   UseCatalog Build
    #=================================================
    if ($UseCatalog -eq 'Build') {
        Write-Verbose "Importing the Build Catalog at $BuildCatalogFile"
        $Results = Import-Clixml -Path $BuildCatalogFile
    }
    #=================================================
    #   UseCatalog Offline
    #=================================================
    if ($UseCatalog -eq 'Offline') {
        Write-Verbose "Importing the Offline Catalog at $OfflineCatalogFile"
        $Results = Import-Clixml -Path $OfflineCatalogFile
    }
    #=================================================
    #   Compatible
    #=================================================
    if ($PSBoundParameters.ContainsKey('Compatible')) {
        $MyComputerProduct = Get-MyComputerProduct
        Write-Verbose "Filtering Catalog for items compatible with Product $MyComputerProduct"
        $Results = $Results | Where-Object {$_.Product -contains $MyComputerProduct}
    }
    #=================================================
    #   Component
    #=================================================
    if ($PSBoundParameters.ContainsKey('Component')) {
        Write-Verbose "Filtering Catalog for $Component"
        $Results = $Results | Where-Object {$_.Component -eq $Component}
    }
    #=================================================
    #   DownloadPath
    #=================================================
    if ($PSBoundParameters.ContainsKey('DownloadPath')) {
        $Results = $Results | Out-GridView -Title 'Select one or more files to Download' -PassThru -ErrorAction Stop
        foreach ($Item in $Results) {
            $OutFile = Save-WebFile -SourceUrl $Item.Url -DestinationDirectory $DownloadPath -DestinationName $Item.FileName -Verbose
            $Item | ConvertTo-Json | Out-File "$($OutFile.FullName).json" -Encoding ascii -Width 2000 -Force
        }
    }
    #=================================================
    #   Component
    #=================================================
    $Results | Sort-Object -Property Name
    #=================================================
}