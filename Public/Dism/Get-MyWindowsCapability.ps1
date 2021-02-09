<#
.SYNOPSIS
Gets Windows capabilities for an image or a running operating system.  Modified version of Get-WindowsCapability

.DESCRIPTION
The Get-MyWindowsCapability function gets Windows capabilities installed in an image or running operating system

.PARAMETER Path
Specifies the full path to the root directory of the offline Windows image that you will service.

.PARAMETER State
Installation state of the Windows Capability
Get-MyWindowsCapability -State Installed
Get-MyWindowsCapability -State NotPresent

.PARAMETER Category
Category of the Windows Capability
Get-MyWindowsCapability -Category Language
Get-MyWindowsCapability -Category Rsat
Get-MyWindowsCapability -Category Other

.PARAMETER Culture
Culture of the Capability
Get-MyWindowsCapability -Culture 'de-DE'
Get-MyWindowsCapability -Culture 'de-DE','es-ES','fr-FR'

.PARAMETER Like
Searches the Capability Name for the specified string.  Wildcards are permitted
Get-MyWindowsCapability -Like "*Dns*"

.PARAMETER Match
Searches the Capability Name for a matching string.  Wildcards are not permitted
Get-MyWindowsCapability -Match 'Dhcp'
Get-MyWindowsCapability -Match 'Dhcp','Rsat'

.PARAMETER Detail
Processes a foreach Get-WindowsCapability <Name> to get further details of the Windows Capability
Get-MyWindowsCapability -Detail

.PARAMETER DisableWSUS
Allows computers configured to Add-WindowsCapability from Windows Update
Temporarily sets the Group Policy 'Download repair content and optional features directly from Windows Update instead of Windows Server Update Services (WSUS)'
Restarts the Windows Update Service
Get-MyWindowsCapability -Culture es-es -Match Basic -State NotPresent -DisableWSUS | Add-WindowsCapability

.INPUTS
None

.OUTPUTS
Microsoft.Dism.Commands.ImageObject

.LINK
https://osd.osdeploy.com/module/functions/dism/get-mywindowscapability

.LINK
https://docs.microsoft.com/en-us/powershell/module/dism/get-windowscapability?view=win10-ps

.LINK
Add-WindowsCapability

.LINK
Get-WindowsCapability

.LINK
Remove-WindowsCapability

.NOTES
21.2.8.1    Initial Release
21.2.8.2    Added IsAdmin requirement
            Added validation for Get-WindowsCapability
            Resolved issue if multiple OSD modules are installed
            Renamed Language parameter to Culture
21.2.9.1    Added DisableWSUS Parameter
            Resolved issue with Like and Match parameters not working as expected
#>
function Get-MyWindowsCapability {
    [CmdletBinding(DefaultParameterSetName = 'Online')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Offline", ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$Path,

        [ValidateSet('Installed','NotPresent')]
        [string]$State,

        [ValidateSet('Language','Rsat','Other')]
        [string]$Category,

        [string[]]$Culture,

        [string[]]$Like,
        [string[]]$Match,

        [switch]$Detail,

        [Parameter(ParameterSetName = "Online")]
        [switch]$DisableWSUS
    )
    begin {
        #===================================================================================================
        #   Require Admin Rights
        #===================================================================================================
        if ((Get-OSDGather -Property IsAdmin) -eq $false) {
            Write-Warning 'Get-MyWindowsCapability requires Admin Rights ELEVATED'
            Break
        }
        #===================================================================================================
        #   Test Get-WindowsCapability
        #===================================================================================================
        if (Get-Command -Name Get-WindowsCapability -ErrorAction SilentlyContinue) {
            Write-Verbose 'Verified command Get-WindowsCapability'
        } else {
            Write-Warning 'Get-MyWindowsCapability requires Get-WindowsCapability which is not present'
            Break
        }
        #===================================================================================================
        #   Verify BuildNumber
        #===================================================================================================
        $MinimumBuildNumber = 17763
        $CurrentBuildNumber = (Get-CimInstance -Class Win32_OperatingSystem).BuildNumber
        if ($MinimumBuildNumber -gt $CurrentBuildNumber) {
            Write-Warning "The current Windows BuildNumber is $CurrentBuildNumber"
            Write-Warning "Get-MyWindowsCapability requires Windows BuildNumber greater than $MinimumBuildNumber"
            Break
        }
        #===================================================================================================
        #   UseWUServer
        #   Original code from Martin Bengtsson
        #   https://www.imab.dk/deploy-rsat-remote-server-administration-tools-for-windows-10-v2004-using-configmgr-and-powershell/
        #   https://github.com/imabdk/Powershell/blob/master/Install-RSATv1809v1903v1909v2004v20H2.ps1
        #===================================================================================================
        $WUServer = (Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name WUServer -ErrorAction Ignore).WUServer
        $UseWUServer = (Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ErrorAction Ignore).UseWuServer
        if ($PSCmdlet.ParameterSetName -eq 'Online') {

            if (($WUServer -ne $null) -and ($UseWUServer -eq 1) -and ($DisableWSUS -eq $false)) {
                Write-Warning "This computer is configured to receive updates from WSUS Server $WUServer"
                Write-Warning "Piping to Add-WindowsCapability may not function properly"
                Write-Warning "Local Source:    Get-MyWindowsCapability | Add-WindowsCapability -Source"
                Write-Warning "Windows Update:  Get-MyWindowsCapability -DisableWSUS | Add-WindowsCapability"
            }

            if (($DisableWSUS -eq $true) -and ($UseWUServer -eq 1)) {
                Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWuServer" -Value 0
                Restart-Service wuauserv
            }
        }
        #===================================================================================================
        #   Get Module Path
        #===================================================================================================
        $GetModuleBase = Get-Module -Name OSD | Select-Object -ExpandProperty ModuleBase -First 1
        #===================================================================================================
    }
    process {
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
        #   Like
        #===================================================================================================
        foreach ($Item in $Like) {
            $GetAllItems = $GetAllItems | Where-Object {$_.Name -like "$Item"}
        }
        #===================================================================================================
        #   Match
        #===================================================================================================
        foreach ($Item in $Match) {
            $GetAllItems = $GetAllItems | Where-Object {$_.Name -match "$Item"}
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
        #   Culture
        #===================================================================================================
        $FilteredItems = @()
        if ($Culture) {
            foreach ($Item in $Culture) {
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
        if ($Detail -eq $true) {
            $Results = foreach ($Item in $FilteredItems) {
                $ItemProductName   = ($Item.Name -split ',*~')[0]
                $ItemCulture    = ($Item.Name -split ',*~')[3]
                $ItemVersion    = ($Item.Name -split ',*~')[4]

                $ItemDetails = $null
                $ItemDetails = $GetAllItemsDictionary | `
                    Where-Object {($_.ProductName -eq $ItemProductName)} | `
                    Where-Object {($_.Culture -eq $ItemCulture)} | `
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
                        Culture         = $ItemCulture
                        Version         = $ItemVersion
                        State           = $Item.State
                        Description     = $ItemDetails.Description
                        Name            = $Item.Name
                        Online          = $Item.Online
                        ProductName     = $ItemProductName
                    }
                }
                if ($PSCmdlet.ParameterSetName -eq 'Offline') {
                    [PSCustomObject] @{
                        DisplayName     = $ItemDetails.DisplayName
                        Culture         = $ItemCulture
                        Version         = $ItemVersion
                        State           = $Item.State
                        Description     = $ItemDetails.Description
                        Name            = $Item.Name
                        Path            = $Item.Path
                        ProductName     = $ItemProductName
                    }
                }
            }
        } else {
            $Results = foreach ($Item in $FilteredItems) {
                $ItemProductName   = ($Item.Name -split ',*~')[0]
                $ItemCulture   = ($Item.Name -split ',*~')[3]
                $ItemVersion    = ($Item.Name -split ',*~')[4]

                if ($PSCmdlet.ParameterSetName -eq 'Online') {
                    [PSCustomObject] @{
                        ProductName     = $ItemProductName
                        Culture         = $ItemCulture
                        Version         = $ItemVersion
                        State           = $Item.State
                        Name            = $Item.Name
                        Online          = $Item.Online
                    }
                }
                if ($PSCmdlet.ParameterSetName -eq 'Offline') {
                    [PSCustomObject] @{
                        ProductName     = $ItemProductName
                        Culture         = $ItemCulture
                        Version         = $ItemVersion
                        State           = $Item.State
                        Name            = $Item.Name
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
        Select-Object Name, ProductName, Culture, DisplayName, Description | `
        ConvertTo-Json | `
        Out-File "$env:TEMP\Get-MyWindowsCapability.json"
        #===================================================================================================
        #   Install / Return
        #===================================================================================================
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
        #===================================================================================================
    }
    end {
        if (($DisableWSUS -eq $true) -and ($UseWUServer -eq 1)) {
            Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWuServer" -Value $UseWUServer
            Restart-Service wuauserv
        }
    }
}
