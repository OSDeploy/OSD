<#
.SYNOPSIS
Converts the HP Client Catalog for Microsoft System Center Product to a PowerShell Object

.DESCRIPTION
Converts the HP Client Catalog for Microsoft System Center Product to a PowerShell Object
Requires Internet Access to download HpCatalogForSms.latest.cab

.EXAMPLE
Get-HPSystemCatalog
Don't do this, you will get an almost endless list

.EXAMPLE
$Results = Get-HPSystemCatalog
Yes do this.  Save it in a Variable

.EXAMPLE
Get-HPSystemCatalog -Component BIOS | Out-GridView
Displays all the HP BIOS updates in GridView

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
#>
function Get-HPSystemCatalog {
    [CmdletBinding()]
    param (
        #Specifies a download path for matching results displayed in Out-GridView
        [System.String]
        $DownloadPath,

        #Limits the results to match the current system
        [System.Management.Automation.SwitchParameter]
        $Compatible,

        #Limits the results to a specified component
        [ValidateSet('Software','Firmware','Driver','Accessories Firmware and Driver','BIOS')]
        [System.String]
        $Component,

        #Checks for the latest Online version
        [System.Management.Automation.SwitchParameter]
        $Online,

        #Updates the local catalog in the OSD Module
        [System.Management.Automation.SwitchParameter]
        $UpdateModuleCatalog
    )
    #=================================================
    #   Defaults
    #=================================================
    $UseCatalog = 'Offline'
    $OfflineCatalogName = 'HPSystemCatalog.xml'
    $OnlineCatalogName = 'HpCatalogForSms.xml'
    $OnlineCatalogUri = 'https://hpia.hpcloud.hp.com/downloads/sccmcatalog/HpCatalogForSms.latest.cab'
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
            $null = Expand "$RawCatalogCabPath" -F:"$($OnlineCatalogName)" "$CatalogBuildFolder"

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
        $PlatformCatalogHashTable = @{}
        Get-HPPlatformCatalog | ForEach-Object{
            $PlatformCatalogHashTable.Add($_.SystemId,$_.SupportedModel)
        }
        
        [xml]$XmlCatalogContent = Get-Content $RawCatalogFile -ErrorAction Stop
        $CatalogVersion = Get-Item $RawCatalogFile | Select-Object -ExpandProperty LastWriteTimeUtc | Get-Date -Format yy.MM.dd
        $Packages = $XmlCatalogContent.SystemsManagementCatalog.SoftwareDistributionPackage

        $Packages = $Packages | Where-Object{$_.Properties.PublicationState -ne 'Expired'}
        
        #Only Windows 10 applicable packages
        #$Packages = $Packages | Where-Object{$_.IsInstallable.And.Or.And.WindowsVersion.MajorVersion -contains '10'}
        
        $Results = Foreach($Item in $Packages){
            #SystemId
            $SystemIdMatchInfo = $Item.InstallableItem.ApplicabilityRules.IsInstallable.And.WmiQuery.wqlquery | Where-Object{$_ -like "*from Win32_BaseBoard*"} | Select-String -Pattern '%(.{4})%' -AllMatches
            $SupportedSystemId = [array]($SystemIdMatchinfo.Matches.Groups | Where-Object{$_.Name -eq 1} | Select-Object -ExpandProperty Value)
            
            #SupportedModel
            $SupportedModel = foreach($Id in $SupportedSystemId){
                $PlatformCatalogHashTable."$($Id)"
            }
            $SupportedModel = $SupportedModel | Select-Object -Unique
            
            #Title
            $TitleMatchInfo = $Item.LocalizedProperties | Where-Object{$_.Language -eq 'en'} | Select-Object -ExpandProperty Title | Select-String -Pattern "^(.*) \[(.*)\]$"
            If($TitleMatchInfo){#Remove the version in the title
                $Title = $TitleMatchInfo.Matches.Groups[1].Value
            }Else{#No version in title
                $Title = $Item.LocalizedProperties | Where-Object{$_.Language -eq 'en'} | Select-Object -ExpandProperty Title
            }
            
            #[Version] + Description
            #There's always a version in the description so far, let's hope HP stays consistent...
            $DescriptionMatchInfo = $Item.LocalizedProperties | Where-Object{$_.Language -eq 'en'} | Select-Object -ExpandProperty Description | Select-String -Pattern "^\[(.*)\] (.*)$"

            $DeviceComponent = $Item.Properties.ProductName
            
            if ($Title -match 'System BIOS') {
                $DeviceComponent = 'BIOS'
            }
            elseif ($Title -match 'HP BIOS and System Firmware') {
                $DeviceComponent = 'BIOS'
            }
            elseif ($Title -match 'HP Firmware Pack') {
                $DeviceComponent = 'BIOS'
            }

            if ($DeviceComponent -eq 'Firmware' -and $_.Description -like "*NOTE: THIS BIOS UPDATE*") {
                $DeviceComponent = 'BIOS'
            }


            $ObjectProperties = [Ordered]@{
                CatalogVersion      = $CatalogVersion
                Status              = $null
                Component           = $DeviceComponent
                CreationDate        = ($Item.Properties.CreationDate) | Get-Date -Format yy.MM.dd
                Title               = $Title
                Version             = ($DescriptionMatchInfo.Matches.Groups[1].Value).Trim('.')
                SupportedSystemId   = $SupportedSystemId
                SupportedModel      = $SupportedModel
                Description         = ($DescriptionMatchInfo.Matches.Groups[2].Value)
                SoftPaqId           = $Item.UpdateSpecificData.KBArticleID
                Program             = $Item.InstallableItem.CommandLineInstallerData.Program
                ProgramArguments    = $Item.InstallableItem.CommandLineInstallerData.Arguments
                Url                 = $Item.InstallableItem.OriginFile.OriginUri
                MoreInfoUrl         = $Item.Properties.MoreInfoUrl
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }

        Write-Verbose "Exporting Build Catalog to $TempCatalogFile"
        $Results = $Results | Sort-Object CreationDate -Descending
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
        $Results = $Results | Where-Object {$_.SupportedSystemID -contains $MyComputerProduct}
    }
    #=================================================
    #   Component
    #=================================================
    if ($PSBoundParameters.ContainsKey('Component')) {
        Write-Verbose "Filtering Catalog for $Component"
        switch ($Component) {
            'BIOS'{
                $Results = $Results | Where-Object {$_.Component -eq 'BIOS'}
            }
            'Firmware'{
                $Results = $Results | Where-Object{$_.Component -eq 'Firmware' -and $_.Description -notlike "*NOTE: THIS BIOS UPDATE*"}
            }
            default {
                $Results = $Results | Where-Object {$_.Component -eq $Component}
            }
        }
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