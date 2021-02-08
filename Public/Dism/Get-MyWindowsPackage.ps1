<#
.SYNOPSIS


.DESCRIPTION


.LINK
https://osd.osdeploy.com/module/functions/dism/get-mywindowspackage

.NOTES
21.2.8  Initial Release
#>
function Get-MyWindowsPackage {
    [CmdletBinding(DefaultParameterSetName = 'Online')]
    Param (
        #[Parameter(Mandatory = $true, ParameterSetName = "Online", ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true)]
        #[switch]$Online,

        [Parameter(Mandatory = $true, ParameterSetName = "Offline", ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$Path,

        [ValidateSet('Installed','Superseded')]
        [string]$PackageState,

        [ValidateSet('FeaturePack','Foundation','LanguagePack','OnDemandPack','SecurityUpdate','Update')]
        [string]$ReleaseType,

        [ValidateSet('FOD','Language','LanguagePack','Update','Other')]
        [string]$Category,

        [string[]]$Language,

        [string[]]$Like,
        [string[]]$Match,

        [switch]$FullDetails
    )
    #===================================================================================================
    #   Get-WindowsPackage
    #===================================================================================================
    if ($PSCmdlet.ParameterSetName -eq 'Online') {
        $GetAllItems = Get-WindowsPackage -Online
    }
    if ($PSCmdlet.ParameterSetName -eq 'Offline') {
        $GetAllItems = Get-WindowsPackage -Path $Path
    }
    #===================================================================================================
    #   Get Module Path
    #===================================================================================================
    $GetModuleBase = Get-Module -Name OSD | Select-Object -ExpandProperty ModuleBase
    #===================================================================================================
    #   Like
    #===================================================================================================
    foreach ($Item in $Like) {
        $GetAllItems = $GetAllItems | Where-Object {$_.PackageName -like "$Like"}
    }
    #===================================================================================================
    #   Match
    #===================================================================================================
    foreach ($Item in $Match) {
        $GetAllItems = $GetAllItems | Where-Object {$_.PackageName -match "$Match"}
    }
    #===================================================================================================
    #   PackageState
    #===================================================================================================
    if ($PackageState) {$GetAllItems = $GetAllItems | Where-Object {$_.PackageState -eq $PackageState}}
    #===================================================================================================
    #   ReleaseType
    #===================================================================================================
    if ($ReleaseType) {$GetAllItems = $GetAllItems | Where-Object {$_.ReleaseType -eq $ReleaseType}}
    #===================================================================================================
    #   Category
    #===================================================================================================
    #Get-MyWindowsPackage -Category FOD
    if ($Category -eq 'FOD') {
        $GetAllItems = $GetAllItems | Where-Object {$_.PackageName -match 'FOD'}
    }
    #Get-MyWindowsPackage -Category Language
    if ($Category -eq 'Language') {
        $GetAllItems = $GetAllItems | Where-Object {$_.ReleaseType -ne 'LanguagePack'}
        $GetAllItems = $GetAllItems | Where-Object {($_.PackageName -split ',*~')[3] -ne ''}
    }
    #Get-MyWindowsPackage -Category LanguagePack
    if ($Category -eq 'LanguagePack') {
        $GetAllItems = $GetAllItems | Where-Object {$_.ReleaseType -eq 'LanguagePack'}
    }
    #Get-MyWindowsPackage -Category Update
    if ($Category -eq 'Update') {
        $GetAllItems = $GetAllItems | Where-Object {$_.ReleaseType -match 'Update'}
    }
    #Get-MyWindowsPackage -Category Other
    if ($Category -eq 'Other') {
        $GetAllItems = $GetAllItems | Where-Object {$_.PackageName -notmatch 'FOD'}
        $GetAllItems = $GetAllItems | Where-Object {($_.PackageName -split ',*~')[3] -eq ''}
        $GetAllItems = $GetAllItems | Where-Object {$_.ReleaseType -ne 'LanguagePack'}
        $GetAllItems = $GetAllItems | Where-Object {$_.ReleaseType -notmatch 'Update'}
    }
    #===================================================================================================
    #   Language
    #===================================================================================================
    $FilteredItems = @()
    if ($Language) {
        foreach ($Item in $Language) {
            $FilteredItems += $GetAllItems | Where-Object {$_.PackageName -match "$Item"}
        }
    } else {
        $FilteredItems = $GetAllItems
    }
    #===================================================================================================
    #   Dictionary
    #===================================================================================================
    if (Test-Path "$GetModuleBase\Dictionary\Get-MyWindowsPackage.json") {
        $GetAllItemsDictionary = Get-Content "$GetModuleBase\Dictionary\Get-MyWindowsPackage.json" | ConvertFrom-Json
    }
    #===================================================================================================
    #   Create Object
    #===================================================================================================
    if ($FullDetails -eq $true) {
        #Build Object
        $Results = foreach ($Item in $FilteredItems) {
            $ItemBaseName        = ($Item.PackageName -split ',*~')[0]
            $ItemArchitecture    = ($Item.PackageName -split ',*~')[2]
            $ItemLanguage        = ($Item.PackageName -split ',*~')[3]
            $ItemVersion         = ($Item.PackageName -split ',*~')[4]

            $ItemDetails = $null
            $ItemDetails = $GetAllItemsDictionary | `
                Where-Object {($_.BaseName -notmatch 'Package_for_DotNetRollup')} | `
                Where-Object {($_.BaseName -notmatch 'Package_for_RollupFix')} | `
                Where-Object {($_.BaseName -eq $ItemBaseName)} | `
                Where-Object {($_.Language -eq $ItemLanguage)} | `
                Select-Object -First 1

            if ($null -eq $ItemDetails) {
                Write-Verbose "$($Item.PackageName) ... gathering details" -Verbose
                if ($PSCmdlet.ParameterSetName -eq 'Online') {
                    $ItemDetails = Get-WindowsPackage -PackageName $Item.PackageName -Online
                }
                if ($PSCmdlet.ParameterSetName -eq 'Offline') {
                    $ItemDetails = Get-WindowsPackage -PackageName $Item.PackageName -Path $Path
                }
            }

            $DisplayName = $ItemDetails.DisplayName
            if ($DisplayName -eq '') {$DisplayName = $ItemBaseName}
            if ($ItemBaseName -match 'Package_for_DotNetRollup') {$DisplayName = 'DotNet_Cumulative_Update'}
            if ($ItemBaseName -match 'Package_for_RollupFix') {$DisplayName = 'Latest_Cumulative_Update'}
            if ($ItemBaseName -match 'Package_for_KB') {$DisplayName = ("$ItemBaseName" -replace "Package_for_")}

            if ($PSCmdlet.ParameterSetName -eq 'Online') {
                [PSCustomObject] @{
                    DisplayName     = $DisplayName
                    Architecture    = $ItemArchitecture
                    Language        = $ItemLanguage
                    Version         = $ItemVersion
                    ReleaseType     = $Item.ReleaseType
                    PackageState    = $Item.PackageState
                    InstallTime     = $Item.InstallTime
                    CapabilityId    = $ItemDetails.CapabilityId
                    Description     = $ItemDetails.Description
                    PackageName     = $Item.PackageName
                    Online          = $Item.Online
                    BaseName        = $ItemBaseName
                }
            }
            if ($PSCmdlet.ParameterSetName -eq 'Offline') {
                [PSCustomObject] @{
                    DisplayName     = $DisplayName
                    Architecture    = $ItemArchitecture
                    Language        = $ItemLanguage
                    Version         = $ItemVersion
                    ReleaseType     = $Item.ReleaseType
                    PackageState    = $Item.PackageState
                    InstallTime     = $Item.InstallTime
                    CapabilityId    = $ItemDetails.CapabilityId
                    Description     = $ItemDetails.Description
                    PackageName     = $Item.PackageName
                    Path            = $Item.Path
                    BaseName        = $ItemBaseName
                }
            }
        }
    } else {
        #Build Object
        $Results = foreach ($Item in $FilteredItems) {
            $ItemBaseName        = ($Item.PackageName -split ',*~')[0]
            $ItemArchitecture    = ($Item.PackageName -split ',*~')[2]
            $ItemLanguage        = ($Item.PackageName -split ',*~')[3]
            $ItemVersion         = ($Item.PackageName -split ',*~')[4]

            if ($PSCmdlet.ParameterSetName -eq 'Online') {
                [PSCustomObject] @{
                    BaseName        = $ItemBaseName
                    Architecture    = $ItemArchitecture
                    Language        = $ItemLanguage
                    Version         = $ItemVersion
                    ReleaseType     = $Item.ReleaseType
                    PackageState    = $Item.PackageState
                    InstallTime     = $Item.InstallTime
                    PackageName     = $Item.PackageName
                    Online          = $Item.Online
                }
            }
            if ($PSCmdlet.ParameterSetName -eq 'Offline') {
                [PSCustomObject] @{
                    BaseName        = $ItemBaseName
                    Architecture    = $ItemArchitecture
                    Language        = $ItemLanguage
                    Version         = $ItemVersion
                    ReleaseType     = $Item.ReleaseType
                    PackageState    = $Item.PackageState
                    InstallTime     = $Item.InstallTime
                    PackageName     = $Item.PackageName
                    Path            = $Item.Path
                }
            }
        }
    }

    #Rebuild Dictionary
    $Results | `
    Sort-Object BaseName, Language | `
    Where-Object {$_.Architecture -notmatch 'wow64'} | `
    Where-Object {$_.BaseName -notmatch 'Package_for_DotNetRollup'} | `
    Where-Object {$_.BaseName -notmatch 'Package_for_RollupFix'} | `
    Where-Object {$_.PackageState -ne 'Superseded'} | `
    Select-Object PackageName, BaseName, Architecture, Language, DisplayName, CapabilityId, Description | `
    ConvertTo-Json | `
    Out-File "$env:TEMP\Get-MyWindowsPackage.json"

    Return $Results
}