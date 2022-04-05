<#
.SYNOPSIS
Returns the HP DriverPacks

.DESCRIPTION
Returns the HP DriverPacks

.PARAMETER Compatible
Filters results based on your current Product

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-OSDCatalogHPDriverPack {
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Compatible,
        [System.String]$DownloadPath,
        [System.Management.Automation.SwitchParameter]$Force
    )
    #=================================================
    #   Paths
    #=================================================
    $UseCatalog             = 'Cloud'
    $CloudCatalogUri        = 'http://ftp.hp.com/pub/caps-softpaq/cmit/HPClientDriverPackCatalog.cab'
    $RawCatalogFile			= Join-Path $env:TEMP (Join-Path 'OSD' 'HPClientDriverPackCatalog.xml')
    $BuildCatalogFile		= Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogHPDriverPack.xml')
    $OfflineCatalogFile     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\OSDCatalog\OSDCatalogHPDriverPack.xml"
    
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
                Write-Verbose "Using Offline Catalog at $OfflineCatalogFile"
                $UseCatalog = 'Offline'
            }
        }
        else {
            Write-Verbose "Using Offline Catalog at $OfflineCatalogFile"
            $UseCatalog = 'Offline'
        }
    }
    #=================================================
    #   UseCatalog Raw
    #=================================================
    if ($UseCatalog -eq 'Raw') {
        Write-Verbose "Reading the Raw Catalog at $RawCatalogFile"
        Write-Warning "Building Catalog content, please wait ..."
        [xml]$XmlCatalogContent = Get-Content $RawCatalogFile -ErrorAction Stop

        $HpSoftPaqList = $XmlCatalogContent.NewDataSet.HPClientDriverPackCatalog.SoftPaqList.SoftPaq

        $HpModelList = $XmlCatalogContent.NewDataSet.HPClientDriverPackCatalog.ProductOSDriverPackList.ProductOSDriverPack
        $HpModelList = $HpModelList | Where-Object {$_.OSId -ge '4243'}
        $HpModelList = $HpModelList | Sort-Object OSId -Descending | Group-Object ProductId, SoftPaqId | ForEach-Object {$_.Group | Select-Object -First 1}
        $HpModelList = $HpModelList | Sort-Object OSId -Descending | Group-Object ProductId | ForEach-Object {$_.Group | Select-Object -First 1}

        #=================================================
        #   Create DriverPack Object
        #=================================================
        $Results = foreach ($Item in $HpModelList) {
            $HpSoftPaq = $null
            $HpSoftPaq = $HpSoftPaqList | Where-Object {$_.Id -eq $Item.SoftPaqId}

            if ($null -eq $HpSoftPaq) {
                Continue
            }

            $Name = $($HpSoftPaq.Name)
            $Name = ($Name).Replace(' x64','')
            $Name = ($Name).Replace('Win 10','Win10')
            $Name = ($Name).Replace('Win 11','Win11')
            $Name = ($Name).Replace('Windows 10','Win10')
            $Name = ($Name).Replace('Windows 11','Win11')
            $Name = ($Name).Replace(' Driver Pack','')
            $Name = ($Name).Replace('/',' ')
            $Name = ($Name).Replace('-',' ')
            $Name = "$Name $($Item.SoftPaqId)"
            #$Name = ($Name).Replace(' A 1','')


            $ObjectProperties = [Ordered]@{
                CatalogVersion 	= Get-Date -Format yy.MM.dd
                Status          = $null
                Component       = 'DriverPack'
                ReleaseDate     = (Get-Date $HpSoftPaq.DateReleased -Format "yy.MM.dd")
                Manufacturer    = 'HP'
                Name            = $Name
                Model           = $Item.SystemName
                SystemId        = [array]$Item.SystemId.split(',').Trim()
                SoftPaqId       = $Item.SoftPaqId
                OSId            = $Item.OSId
                OSName          = $Item.OSName
                Architecture    = $Item.Architecture
                ProductType     = $Item.ProductType
                SoftPaqName     = $HpSoftPaq.Name
                Version         = $HpSoftPaq.Version
                Category        = $HpSoftPaq.Category
                Url             = $HpSoftPaq.Url
                FileName        = $HpSoftPaq.Url | Split-Path -Leaf
                Size            = $HpSoftPaq.Size
                MD5             = $HpSoftPaq.MD5
                SHA256          = $HpSoftPaq.SHA256
                CvaFileUrl      = $HpSoftPaq.CvaFileUrl
                ReleaseNotesUrl = $HpSoftPaq.ReleaseNotesUrl
                CvaTitle        = $HpSoftPaq.CvaTitle
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }

        foreach ($Item in $Results) {
            $Item.Model = $Item.Model -replace 'HP ', ''
        }

        $Results = $Results | Sort-Object Model
        Write-Verbose "Exporting Build Catalog to $BuildCatalogFile"
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
    #   Complete
    #=================================================
    $Results
    #=================================================
}