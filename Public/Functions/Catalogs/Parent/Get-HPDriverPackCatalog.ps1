<#
.SYNOPSIS
Returns the HP DriverPacks

.DESCRIPTION
Returns the HP DriverPacks

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-HPDriverPackCatalog {
    [CmdletBinding()]
    param (
        #Limits the results to match the current system
        [System.Management.Automation.SwitchParameter]
        $Compatible,
        
        #Specifies a download path for matching results displayed in Out-GridView
        [System.String]
        $DownloadPath,

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
    $OfflineCatalogName = 'HPDriverPackCatalog.xml'

    $OnlineCatalogName = 'HPClientDriverPackCatalog.xml'
    $OnlineCatalogUri = 'http://ftp.hp.com/pub/caps-softpaq/cmit/HPClientDriverPackCatalog.cab'
    #=================================================
    #   Initialize
    #=================================================
    $IsOnline = $false

    if ($UpdateModuleCatalog) {
        $Online = $true
        $TestUrl = $true
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
    $ModuleCatalogFile      = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\$OfflineCatalogName"
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

            $UniqueName = "$($Item.SystemName) $($Item.OSName) $($($Item.SoftPaqId))"
            $UniqueName = $UniqueName.Replace('Windows 10 64-bit,', 'Win10')
            $UniqueName = $UniqueName.Replace('Windows 11 64-bit,', 'Win11')

            $template = "M/d/yyyy hh:mm:ss tt"
            $timeinfo = $HpSoftPaq.DateReleased
            $dtReleaseDate = [datetime]::ParseExact($timeinfo, $template, $null)


            $ObjectProperties = [Ordered]@{
                CatalogVersion 	= Get-Date -Format yy.MM.dd
                Status          = $null
                Component       = 'DriverPack'
                ReleaseDate     = $dtReleaseDate.ToString("yy.MM.dd")
                Manufacturer    = 'HP'
                Name            = $UniqueName
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
        Write-Verbose "Exporting Build Catalog to $TempCatalogFile"
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
    $Results | Sort-Object -Property Name
    #=================================================
}