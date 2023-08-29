<#
.SYNOPSIS
Updates the local HP DriverPack Catalog in the OSD Module

.DESCRIPTION
Updates the local HP DriverPack Catalog in the OSD Module

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Update-HPDriverPackCatalog {
    [CmdletBinding()]
    param (
        #Updates the OSD Module Offline Catalog. Requires Admin rights
        [System.Management.Automation.SwitchParameter]
        $UpdateModuleCatalog,

        #Verifies that the DriverPack is reachable. This will take some time to complete
        [System.Management.Automation.SwitchParameter]
        $Verify
    )
    #=================================================
    #   Custom Defaaults
    #=================================================
    $OnlineCatalogName = 'HPClientDriverPackCatalog.xml'
    $OnlineCatalogUri = 'http://ftp.hp.com/pub/caps-softpaq/cmit/HPClientDriverPackCatalog.cab'

    $OfflineCatalogName = 'HPDriverPackCatalog.xml'

    $ModuleCatalogXml = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\HPDriverPackCatalog.xml"
    $ModuleCatalogJson = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\HPDriverPackCatalog.json"
    #=================================================
    #   Additional Defaults
    #=================================================
    $CatalogBuildFolder = Join-Path $env:TEMP 'OSD'
    if (-not(Test-Path $CatalogBuildFolder)) {
        $null = New-Item -Path $CatalogBuildFolder -ItemType Directory -Force
    }
    $RawCatalogFile			= Join-Path $env:TEMP (Join-Path 'OSD' $OnlineCatalogName)
    $RawCatalogCabName  	= [string]($OnlineCatalogUri | Split-Path -Leaf)
    $RawCatalogCabPath 		= Join-Path $env:TEMP (Join-Path 'OSD' $RawCatalogCabName)
    #=================================================
    #   Get Online Cloud
    #=================================================
    Write-Verbose -Verbose "Source: $OnlineCatalogUri"
    Write-Verbose -Verbose "Destination: $RawCatalogCabPath"
    (New-Object System.Net.WebClient).DownloadFile($OnlineCatalogUri, $RawCatalogCabPath)

    if (Test-Path $RawCatalogCabPath) {
        Write-Verbose -Verbose "Expand: $RawCatalogCabPath"
        $null = Expand "$RawCatalogCabPath" "$RawCatalogFile"

        if (Test-Path $RawCatalogFile) {
            Write-Verbose -Verbose "Using Raw Catalog at $RawCatalogFile"
        }
        else {
            Write-Verbose -Verbose "Could not expand $RawCatalogCabPath"
            Write-Warning 'Unable to complete'
            Break
        }
    }
    else {
        Write-Warning 'Unable to complete'
        Break
    }
    #=================================================
    #   Read Catalog
    #=================================================
    Write-Verbose -Verbose "Reading the Raw Catalog at $RawCatalogFile"
    Write-Warning "Building Catalog content, please wait ..."
    [xml]$XmlCatalogContent = Get-Content $RawCatalogFile -ErrorAction Stop

    $HpSoftPaqList = $XmlCatalogContent.NewDataSet.HPClientDriverPackCatalog.SoftPaqList.SoftPaq

    $HpModelList = $XmlCatalogContent.NewDataSet.HPClientDriverPackCatalog.ProductOSDriverPackList.ProductOSDriverPack
    $HpModelList = $HpModelList | Where-Object {$_.OSId -ge '4243'}
    #$HpModelList = $HpModelList | Sort-Object OSId -Descending | Group-Object ProductId, SoftPaqId | ForEach-Object {$_.Group | Select-Object -First 1}
    #$HpModelList = $HpModelList | Sort-Object OSId -Descending | Group-Object ProductId | ForEach-Object {$_.Group | Select-Object -First 1}
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
            OSVersion       = ''
            OSReleaseId     = ''
            OSBuild         = ''
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
    #=================================================
    #   Normalize Results
    #=================================================
    foreach ($Item in $Results) {
        $Item.Model = $Item.Model -replace 'HP ', ''
        if ($Item.OSName -match 'Windows 10') {
            $Item.OSVersion = 'Windows 10 x64'
        }
        if ($Item.OSName -match 'Windows 11') {
            $Item.OSVersion = 'Windows 11 x64'
        }
        if ($Item.OSId -match '4261') {
            $Item.OSVersion = 'Windows 10 x64'
        }
    }

    foreach ($Item in $Results) {
        if ($Item.OSName -match '22H2') {
            if ($Item.OSName -match 'Windows 10') {
                $Item.OSReleaseId = '22H2'
                $Item.OSBuild = '19045'
            }
            if ($Item.OSName -match 'Windows 11') {
                $Item.OSReleaseId = '22H2'
                $Item.OSBuild = '22621'
            }
        }
        elseif ($Item.OSName -match '21H2') {
            if ($Item.OSName -match 'Windows 10') {
                $Item.OSReleaseId = '21H2'
                $Item.OSBuild = '19044'
            }
            if ($Item.OSName -match 'Windows 11') {
                $Item.OSReleaseId = '21H2'
                $Item.OSBuild = '22000'
            }
        }
        elseif ($Item.OSName -match '21H1') {
            $Item.OSReleaseId = '21H1'
            $Item.OSBuild = '19043'
        }
        elseif ($Item.OSName -match '20H2') {
            $Item.OSReleaseId = '20H2'
            $Item.OSBuild = '19042'
        }
        elseif ($Item.OSName -match '2004') {
            $Item.OSReleaseId = '2004'
            $Item.OSBuild = '19041'
        }
        elseif ($Item.OSName -match '1909') {
            $Item.OSReleaseId = '1909'
            $Item.OSBuild = '18363'
        }
        elseif ($Item.OSName -match '1903') {
            $Item.OSReleaseId = '1903'
            $Item.OSBuild = '18362'
        }
        elseif ($Item.OSName -match '1809') {
            $Item.OSReleaseId = '1809'
            $Item.OSBuild = '17763'
        }
        elseif ($Item.OSName -match '1803') {
            $Item.OSReleaseId = '1803'
            $Item.OSBuild = '17134'
        }
        elseif ($Item.OSName -match '1709') {
            $Item.OSReleaseId = '1709'
            $Item.OSBuild = '16299'
        }
        elseif ($Item.OSName -match '1703') {
            $Item.OSReleaseId = '1703'
            $Item.OSBuild = '15063'
        }
        elseif ($Item.OSName -match '1607') {
            $Item.OSReleaseId = '1607'
            $Item.OSBuild = '14393'
        }
        elseif ($Item.OSName -match '1511') {
            $Item.OSReleaseId = '1511'
            $Item.OSBuild = '10586'
        }
        elseif ($Item.OSName -match '1507') {
            $Item.OSReleaseId = '1507'
            $Item.OSBuild = '10240'
        }
    }
    #=================================================
    #   Verify DriverPack is reachable
    #=================================================
    if ($Verify) {
        Write-Warning "Testing each download link, please wait..."
        $Results = $Results | Sort-Object Url
        $LastDriverPack = $null

        foreach ($CurrentDriverPack in $Results) {
            if ($CurrentDriverPack.Url -eq $LastDriverPack.Url) {
                $CurrentDriverPack.Status = $LastDriverPack.Status
                #$CurrentDriverPack.ReleaseDate = $LastDriverPack.ReleaseDate
            }
            else {
                $Global:DownloadHeaders = $null
                try {
                    $Global:DownloadHeaders = (Invoke-WebRequest -Method Head -Uri $CurrentDriverPack.Url -UseBasicParsing).Headers
                }
                catch {
                    Write-Warning "Failed: $($CurrentDriverPack.Url)"
                }

                if ($Global:DownloadHeaders) {
                    Write-Verbose -Verbose "$($CurrentDriverPack.Url)"
                    #$CurrentDriverPack.ReleaseDate = Get-Date ($Global:DownloadHeaders.'Last-Modified') -Format "yy.MM.dd"
                    #Write-Verbose -Verbose "ReleaseDate: $($CurrentDriverPack.ReleaseDate)"
                }
                else {
                    $CurrentDriverPack.Status = 'Failed'
                }
            }
            $LastDriverPack = $CurrentDriverPack
        }
    }
    #=================================================
    #   Sort Results
    #=================================================
    $Results = $Results | Sort-Object -Property Name
    #=================================================
    #   UpdateModule
    #=================================================
    if ($UpdateModuleCatalog) {
        Write-Verbose -Verbose "UpdateModule: Exporting to OSD Module Catalogs at $ModuleCatalogXml"
        $Results | Export-Clixml -Path $ModuleCatalogXml -Force
        Write-Verbose -Verbose "UpdateModule: Exporting to OSD Module Catalogs at $ModuleCatalogJson"
        $Results | ConvertTo-Json | Out-File $ModuleCatalogJson -Encoding ascii -Width 2000 -Force
        #=================================================
        #   UpdateCatalog
        #=================================================
        Get-HPPlatformCatalog -UpdateModuleCatalog
        Get-HPSystemCatalog -UpdateModuleCatalog
        
        $MasterDriverPacks = @()
        $MasterDriverPacks += Get-DellDriverPack
        $MasterDriverPacks += Get-HPDriverPack
        $MasterDriverPacks += Get-LenovoDriverPack
        $MasterDriverPacks += Get-MicrosoftDriverPack
    
        $MasterResults = $MasterDriverPacks | `
        Select-Object CatalogVersion, Status, ReleaseDate, Manufacturer, Model, `
        Product, Name, PackageID, FileName, `
        @{Name='Url';Expression={([array]$_.DriverPackUrl)}}, `
        @{Name='OS';Expression={([array]$_.DriverPackOS)}}, `
        OSReleaseId,OSBuild,HashMD5, `
        @{Name='Guid';Expression={([guid]((New-Guid).ToString()))}}
    
        $MasterResults | Export-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudDriverPacks.xml") -Force
        Import-Clixml -Path (Join-Path (Get-Module -Name OSD -ListAvailable | `
        Sort-Object Version -Descending | `
        Select-Object -First 1).ModuleBase "Catalogs\CloudDriverPacks.xml") | `
        ConvertTo-Json | `
        Out-File (Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Catalogs\CloudDriverPacks.json") -Encoding ascii -Width 2000 -Force
    }
    #=================================================
    #   Complete
    #=================================================
    Write-Verbose -Verbose 'Complete: Results have been stored $Global:HPDriverPackCatalog'
    $Global:HPDriverPackCatalog = $Results | Sort-Object -Property Name
    #=================================================
}