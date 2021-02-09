<#
.SYNOPSIS
Gets information about packages in a Windows image.  Modified version of Get-WindowsPackage

.DESCRIPTION
The Get-MyWindowsPackage cmdlet gets information about all packages in a Windows image or about a specific package that is provided as a .cab file.

.PARAMETER Path
Specifies the full path to the root directory of the offline Windows image that you will service.

.PARAMETER PackageState
Installation state of the Windows Package
Get-MyWindowsPackage -PackageState Installed
Get-MyWindowsPackage -PackageState Superseded

.PARAMETER ReleaseType
ReleaseType of the Windows Package
Get-MyWindowsPackage -ReleaseType FeaturePack
Get-MyWindowsPackage -ReleaseType Foundation
Get-MyWindowsPackage -ReleaseType LanguagePack
Get-MyWindowsPackage -ReleaseType OnDemandPack
Get-MyWindowsPackage -ReleaseType SecurityUpdate
Get-MyWindowsPackage -ReleaseType Update

.PARAMETER Category
Category of the Windows Package
Get-MyWindowsPackage -Category FOD
Get-MyWindowsPackage -Category Language
Get-MyWindowsPackage -Category LanguagePack
Get-MyWindowsPackage -Category Update
Get-MyWindowsPackage -Category Other

.PARAMETER Culture
Culture of the Package
Get-MyWindowsPackage -Culture 'de-DE'
Get-MyWindowsPackage -Culture 'de-DE','es-ES','fr-FR'

.PARAMETER Like
Searches the PackageName for the specified string.  Wildcards are permitted
Get-MyWindowsPackage -Like "*Tools*"

.PARAMETER Match
Searches the Package Name for a matching string.  Wildcards are not permitted
Get-MyWindowsPackage -Match 'Tools'
Get-MyWindowsPackage -Match 'Tools','FoD'

.PARAMETER Detail
Processes a foreach Get-WindowsPackage <PackageName> to get further details of the Windows Package

.INPUTS
None

.OUTPUTS
Microsoft.Dism.Commands.BasicPackageObject

.OUTPUTS
Microsoft.Dism.Commands.AdvancedPackageObject

.LINK
https://osd.osdeploy.com/module/functions/dism/get-mywindowspackage

.LINK
https://docs.microsoft.com/en-us/powershell/module/dism/get-windowspackage?view=win10-ps

.LINK
Add-WindowsPackage

.LINK
Get-WindowsPackage

.LINK
Remove-WindowsPackage

.NOTES
21.2.8.1    Initial Release
21.2.8.2    Added IsAdmin requirement
            Added validation for Get-WindowsPackage
            Resolved issue if multiple OSD modules are installed
            Renamed Language parameter to Culture
21.2.9.1    Resolved issue with Like and Match parameters not working as expected
#>
function Get-MyWindowsPackage {
    [CmdletBinding(DefaultParameterSetName = 'Online')]
    Param (
        [Parameter(Mandatory = $true, ParameterSetName = "Offline", ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$Path,

        [ValidateSet('Installed','Superseded')]
        [string]$PackageState,

        [ValidateSet('FeaturePack','Foundation','LanguagePack','OnDemandPack','SecurityUpdate','Update')]
        [string]$ReleaseType,

        [ValidateSet('FOD','Language','LanguagePack','Update','Other')]
        [string]$Category,

        [string[]]$Culture,

        [string[]]$Like,
        [string[]]$Match,

        [switch]$Detail
    )
    #===================================================================================================
    #   Require Admin Rights
    #===================================================================================================
    if ((Get-OSDGather -Property IsAdmin) -eq $false) {
        Write-Warning 'This function requires Admin Rights ELEVATED'
        Break
    }
    #===================================================================================================
    #   Test Get-WindowsPackage
    #===================================================================================================
    if (Get-Command -Name Get-WindowsPackage -ErrorAction SilentlyContinue) {
        Write-Verbose 'Verified command Get-WindowsPackage'
    } else {
        Write-Warning 'This function requires Get-WindowsPackage which is not present'
        Break
    }
    #===================================================================================================
    #   Get Module Path
    #===================================================================================================
    $GetModuleBase = Get-Module -Name OSD | Select-Object -ExpandProperty ModuleBase -First 1
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
    #   Like
    #===================================================================================================
    foreach ($Item in $Like) {
        $GetAllItems = $GetAllItems | Where-Object {$_.PackageName -like "$Item"}
    }
    #===================================================================================================
    #   Match
    #===================================================================================================
    foreach ($Item in $Match) {
        $GetAllItems = $GetAllItems | Where-Object {$_.PackageName -match "$Item"}
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
    #   Culture
    #===================================================================================================
    $FilteredItems = @()
    if ($Culture) {
        foreach ($Item in $Culture) {
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
    if ($Detail -eq $true) {
        $Results = foreach ($Item in $FilteredItems) {
            $ItemProductName    = ($Item.PackageName -split ',*~')[0]
            $ItemArchitecture   = ($Item.PackageName -split ',*~')[2]
            $ItemCulture        = ($Item.PackageName -split ',*~')[3]
            $ItemVersion        = ($Item.PackageName -split ',*~')[4]

            $ItemDetails = $null
            $ItemDetails = $GetAllItemsDictionary | `
                Where-Object {($_.ProductName -notmatch 'Package_for_DotNetRollup')} | `
                Where-Object {($_.ProductName -notmatch 'Package_for_RollupFix')} | `
                Where-Object {($_.ProductName -eq $ItemProductName)} | `
                Where-Object {($_.Culture -eq $ItemCulture)} | `
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
            if ($DisplayName -eq '') {$DisplayName = $ItemProductName}
            if ($ItemProductName -match 'Package_for_DotNetRollup') {$DisplayName = 'DotNet_Cumulative_Update'}
            if ($ItemProductName -match 'Package_for_RollupFix') {$DisplayName = 'Latest_Cumulative_Update'}
            if ($ItemProductName -match 'Package_for_KB') {$DisplayName = ("$ItemProductName" -replace "Package_for_")}

            if ($PSCmdlet.ParameterSetName -eq 'Online') {
                [PSCustomObject] @{
                    DisplayName     = $DisplayName
                    Architecture    = $ItemArchitecture
                    Culture         = $ItemCulture
                    Version         = $ItemVersion
                    ReleaseType     = $Item.ReleaseType
                    PackageState    = $Item.PackageState
                    InstallTime     = $Item.InstallTime
                    CapabilityId    = $ItemDetails.CapabilityId
                    Description     = $ItemDetails.Description
                    PackageName     = $Item.PackageName
                    Online          = $Item.Online
                    ProductName     = $ItemProductName
                }
            }
            if ($PSCmdlet.ParameterSetName -eq 'Offline') {
                [PSCustomObject] @{
                    DisplayName     = $DisplayName
                    Architecture    = $ItemArchitecture
                    Culture         = $ItemCulture
                    Version         = $ItemVersion
                    ReleaseType     = $Item.ReleaseType
                    PackageState    = $Item.PackageState
                    InstallTime     = $Item.InstallTime
                    CapabilityId    = $ItemDetails.CapabilityId
                    Description     = $ItemDetails.Description
                    PackageName     = $Item.PackageName
                    Path            = $Item.Path
                    ProductName     = $ItemProductName
                }
            }
        }
    } else {
        #Build Object
        $Results = foreach ($Item in $FilteredItems) {
            $ItemProductName    = ($Item.PackageName -split ',*~')[0]
            $ItemArchitecture   = ($Item.PackageName -split ',*~')[2]
            $ItemCulture        = ($Item.PackageName -split ',*~')[3]
            $ItemVersion        = ($Item.PackageName -split ',*~')[4]

            if ($PSCmdlet.ParameterSetName -eq 'Online') {
                [PSCustomObject] @{
                    ProductName     = $ItemProductName
                    Architecture    = $ItemArchitecture
                    Culture         = $ItemCulture
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
                    ProductName     = $ItemProductName
                    Architecture    = $ItemArchitecture
                    Culture         = $ItemCulture
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
    #===================================================================================================
    #   Rebuild Dictionary
    #===================================================================================================
    $Results | `
    Sort-Object ProductName, Culture | `
    Where-Object {$_.Architecture -notmatch 'wow64'} | `
    Where-Object {$_.ProductName -notmatch 'Package_for_DotNetRollup'} | `
    Where-Object {$_.ProductName -notmatch 'Package_for_RollupFix'} | `
    Where-Object {$_.PackageState -ne 'Superseded'} | `
    Select-Object PackageName, ProductName, Architecture, Culture, DisplayName, CapabilityId, Description | `
    ConvertTo-Json | `
    Out-File "$env:TEMP\Get-MyWindowsPackage.json"
    #===================================================================================================
    #   Return
    #===================================================================================================
    Return $Results
    #===================================================================================================
}