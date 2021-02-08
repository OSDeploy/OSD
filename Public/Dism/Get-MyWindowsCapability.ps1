<#
.SYNOPSIS


.DESCRIPTION


.LINK
https://osd.osdeploy.com/module/functions/dism/get-mywindowscapability

.NOTES
21.2.8  Initial Release
#>
function Get-MyWindowsCapability {
    [CmdletBinding(DefaultParameterSetName = 'Online')]
    Param (
        #[Parameter(Mandatory = $false, ParameterSetName = "Online", ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true)]
        #[switch]$Online,

        [Parameter(Mandatory = $true, ParameterSetName = "Offline", ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$Path,

        [ValidateSet('Installed','NotPresent')]
        [string]$State,

        [ValidateSet('Language','Rsat','Other')]
        [string]$Category,

        [string[]]$Language,

        [string[]]$Like,
        [string[]]$Match,

        [switch]$Detailed

        #[Parameter(Mandatory = $false, ParameterSetName = "Online", ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true)]
        #[switch]$Install
    )
    #===================================================================================================
    #   Get-WindowsCapability
    #===================================================================================================
    if ($PSCmdlet.ParameterSetName -eq 'Online') {
        $GetAllItems = Get-WindowsCapability -Online
    }
    if ($PSCmdlet.ParameterSetName -eq 'Offline') {
        $GetAllItems = Get-WindowsCapability -Path $Path
    }
    #===================================================================================================
    #   Get Module Path
    #===================================================================================================
    $GetModuleBase = Get-Module -Name OSD | Select-Object -ExpandProperty ModuleBase
    #===================================================================================================
    #   Like
    #===================================================================================================
    foreach ($Item in $Like) {
        $GetAllItems = $GetAllItems | Where-Object {$_.Name -like "$Like"}
    }
    #===================================================================================================
    #   Match
    #===================================================================================================
    foreach ($Item in $Match) {
        $GetAllItems = $GetAllItems | Where-Object {$_.Name -match "$Match"}
    }
    #===================================================================================================
    #   State
    #===================================================================================================
    if ($State) {$GetAllItems = $GetAllItems | Where-Object {$_.State -eq $State}}
    #===================================================================================================
    #   Category
    #===================================================================================================
    if ($Category -eq 'Other') {
        $GetAllItems = $GetAllItems | Where-Object {$_.Name -notmatch 'Language'}
        $GetAllItems = $GetAllItems | Where-Object {$_.Name -notmatch 'Rsat'}
    }
    if ($Category -eq 'Language') {
        $GetAllItems = $GetAllItems | Where-Object {$_.Name -match 'Language'}
    }
    if ($Category -eq 'Rsat') {
        $GetAllItems = $GetAllItems | Where-Object {$_.Name -match 'Rsat'}
    }
    #===================================================================================================
    #   Language
    #===================================================================================================
    $FilteredItems = @()
    if ($Language) {
        foreach ($Item in $Language) {
            $FilteredItems += $GetAllItems | Where-Object {$_.Name -match $Item}
        }
    } else {
        $FilteredItems = $GetAllItems
    }
    #===================================================================================================
    #   Dictionary
    #===================================================================================================
    if (Test-Path "$GetModuleBase\Dictionary\Get-MyWindowsCapability.json") {
        $GetAllItemsDictionary = Get-Content "$GetModuleBase\Dictionary\Get-MyWindowsCapability.json" | ConvertFrom-Json
    }
    #===================================================================================================
    #   Create Object
    #===================================================================================================
    if ($Detailed -eq $true) {
        $Results = foreach ($Item in $FilteredItems) {
            $ItemBaseName        = ($Item.Name -split ',*~')[0]
            $ItemLanguage        = ($Item.Name -split ',*~')[3]
            $ItemVersion         = ($Item.Name -split ',*~')[4]

            $ItemDetails = $null
            $ItemDetails = $GetAllItemsDictionary | `
                Where-Object {($_.BaseName -eq $ItemBaseName)} | `
                Where-Object {($_.Language -eq $ItemLanguage)} | `
                Select-Object -First 1

            if ($null -eq $ItemDetails) {
                Write-Verbose "$($Item.Name) ... gathering details" -Verbose
                if ($PSCmdlet.ParameterSetName -eq 'Online') {
                    $ItemDetails = Get-WindowsCapability -Name $Item.Name -Online
                }
                if ($PSCmdlet.ParameterSetName -eq 'Offline') {
                    $ItemDetails = Get-WindowsCapability -Name $Item.Name -Path $Path
                }
            }

            if ($PSCmdlet.ParameterSetName -eq 'Online') {
                [PSCustomObject] @{
                    DisplayName     = $ItemDetails.DisplayName
                    Language        = $ItemLanguage
                    Version         = $ItemVersion
                    State           = $Item.State
                    Description     = $ItemDetails.Description
                    Name            = $Item.Name
                    Online          = $Item.Online
                    BaseName        = $ItemBaseName
                }
            }
            if ($PSCmdlet.ParameterSetName -eq 'Offline') {
                [PSCustomObject] @{
                    DisplayName     = $ItemDetails.DisplayName
                    Language        = $ItemLanguage
                    Version         = $ItemVersion
                    State           = $Item.State
                    Description     = $ItemDetails.Description
                    Name            = $Item.Name
                    Path            = $Item.Path
                    BaseName        = $ItemBaseName
                }
            }
        }
    } else {
        $Results = foreach ($Item in $FilteredItems) {
            $ItemBaseName        = ($Item.Name -split ',*~')[0]
            $ItemLanguage        = ($Item.Name -split ',*~')[3]
            $ItemVersion         = ($Item.Name -split ',*~')[4]

            if ($PSCmdlet.ParameterSetName -eq 'Online') {
                [PSCustomObject] @{
                    BaseName        = $ItemBaseName
                    Language        = $ItemLanguage
                    Version         = $ItemVersion
                    State           = $Item.State
                    Name            = $Item.Name
                    Online          = $Item.Online
                }
            }
            if ($PSCmdlet.ParameterSetName -eq 'Offline') {
                [PSCustomObject] @{
                    BaseName        = $ItemBaseName
                    Language        = $ItemLanguage
                    Version         = $ItemVersion
                    State           = $Item.State
                    Name            = $Item.Name
                    Path            = $Item.Path
                }
            }
        }
    }

    #Rebuild Dictionary
    $Results | `
    Sort-Object BaseName, Language | `
    Select-Object Name, BaseName, Language, DisplayName, Description | `
    ConvertTo-Json | `
    Out-File "$env:TEMP\Get-MyWindowsCapability.json"


    if ($Install -eq $true) {
        foreach ($Item in $Results) {
            if ($_.State -eq 'Installed') {
                Write-Verbose "$_.Name is already installed" -Verbose
            } else {
                $Item | Add-WindowsCapability -Online
            }
        }
    } else {
        Return $Results
    }
}
