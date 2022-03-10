<#
.SYNOPSIS
Converts the HP Client Catalog for Microsoft System Center Product to a PowerShell Object

.DESCRIPTION
Converts the HP Client Catalog for Microsoft System Center Product to a PowerShell Object
Requires Internet Access to download HpCatalogForSms.latest.cab

.PARAMETER Component
Filter the results based on these Components:
Software
Driver
Firmware
Accessories Firmware and Driver
BIOS

.PARAMETER Compatible
If you have a HP System, this will filter the results based on your
ComputerSystem Product (Win32_BaseBoard Product)

.EXAMPLE
Get-OSDCatalogHPSystem
Don't do this, you will get an almost endless list

.EXAMPLE
$Results = Get-OSDCatalogHPSystem
Yes do this.  Save it in a Variable

.EXAMPLE
Get-OSDCatalogHPSystem -Component BIOS | Out-GridView
Displays all the HP BIOS updates in GridView

.LINK
https://osd.osdeploy.com

.NOTES
#>
function Get-OSDCatalogHPSystem {
    [CmdletBinding()]
    param (
        [System.String]$DownloadPath,
        [System.Management.Automation.SwitchParameter]$Compatible,

        [ValidateSet('Software','Firmware','Driver','Accessories Firmware and Driver','BIOS')]
        [System.String]$Component
    )
    #=================================================
    #   Paths
    #=================================================
    $UseCatalog             = 'Cloud'
    $CloudCatalogUri        = 'https://hpia.hpcloud.hp.com/downloads/sccmcatalog/HpCatalogForSms.latest.cab'
    $RawCatalogFileName     = 'HpCatalogForSms.xml'
    $RawCatalogFile			= Join-Path $env:TEMP (Join-Path 'OSD' 'HpCatalogForSms.xml')
    $BuildCatalogFile		= Join-Path $env:TEMP (Join-Path 'OSD' 'OSDCatalogHPSystem.xml')
    $OfflineCatalogFile     = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs\OSDCatalog\OSDCatalogHPSystem.xml"

    $RawCatalogCabName  	= [string]($CloudCatalogUri | Split-Path -Leaf)
    $RawCatalogCabPath 		= Join-Path $env:TEMP (Join-Path 'OSD' $RawCatalogCabName)

    $CatalogBuildFolder     = Join-Path $env:TEMP 'OSD'
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
    if ($UseCatalog -eq 'Cloud') {
        if (Test-WebConnection -Uri $CloudCatalogUri) {
            #Catalog is Cloud and can be downloaded
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
            $null = Expand "$RawCatalogCabPath" -F:"$($RawCatalogFileName)" "$CatalogBuildFolder"

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
        $PlatformCatalogHashTable = @{}
        Get-OSDCatalogHPPlatformList | ForEach-Object{
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

            $Component = $Item.Properties.ProductName
            
            if ($Title -match 'System BIOS') {
                $Component = 'BIOS'
            }
            elseif ($Title -match 'HP BIOS and System Firmware') {
                $Component = 'BIOS'
            }
            elseif ($Title -match 'HP Firmware Pack') {
                $Component = 'BIOS'
            }

            $ObjectProperties = [Ordered]@{
                CatalogVersion      = $CatalogVersion
                Status              = $null
                Component           = $Component
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

        Write-Verbose "Exporting Build Catalog to $BuildCatalogFile"
        $Results = $Results | Sort-Object CreationDate -Descending
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
        $Results = $Results | Where-Object {$_.SupportedSystemID -contains $MyComputerProduct}
    }
    #=================================================
    #   Component
    #=================================================
    if ($PSBoundParameters.ContainsKey('Component')) {
        Write-Verbose "Filtering Catalog for $Component"
        switch ($Component) {
            'BIOS'{
                $Results = $Results | Where-Object{$_.Component -eq 'Firmware' -and $_.Description -like "*NOTE: THIS BIOS UPDATE*"}
            }
            'Firmware'{
                $Results = $Results | Where-Object{$_.Component -eq 'Firmware' -and $_.Description -notlike "*NOTE: THIS BIOS UPDATE*"}
            }
            default{
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
    $Results | Sort-Object -Property CreationDate -Descending
    #=================================================
}