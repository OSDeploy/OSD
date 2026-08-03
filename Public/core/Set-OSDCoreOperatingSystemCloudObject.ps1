function Set-OSDCoreOperatingSystemCloudObject {
    <#
    .SYNOPSIS
    Selects and sets the global OSD core operating system object.

    .DESCRIPTION
    Filters the preloaded operating system catalog using activation, architecture,
    language, release ID, and version criteria, then sets
    $global:OSDCoreOperatingSystemCloudObject to the best match. If multiple matches
    are found, the highest build is selected.

    .PARAMETER OSActivation
    Operating system activation channel used for catalog selection.

    .PARAMETER OSArchitecture
    Operating system architecture used for catalog selection.

    .PARAMETER OSLanguageCode
    Operating system language code used for catalog selection.

    .PARAMETER OSReleaseID
    Operating system release identifier used for catalog selection.

    .PARAMETER OSVersion
    Operating system family/version label used for catalog selection.

    .PARAMETER RefreshCatalog
    Reloads $global:OSDCoreOperatingSystems from Get-OSDCoreOperatingSystems
    before filtering.

    .EXAMPLE
    Set-OSDCoreOperatingSystemCloudObject -OSArchitecture amd64 -OSReleaseID 25H2 -OSLanguageCode en-us
    Selects the latest Windows 11 Retail amd64 en-us 25H2 catalog entry and sets
    $global:OSDCoreOperatingSystemCloudObject.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Initial implementation to centralize OS catalog object selection.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Retail','Volume')]
        [string]$OSActivation = 'Retail',

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('amd64','arm64')]
        [string]$OSArchitecture = $env:PROCESSOR_ARCHITECTURE,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$OSLanguageCode = 'en-us',

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$OSReleaseID = '25H2',

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$OSVersion = 'Windows 11',

        [Parameter(Mandatory = $false)]
        [switch]$RefreshCatalog
    )

    $normalizedArchitecture = $OSArchitecture.ToLowerInvariant()
    $normalizedLanguageCode = $OSLanguageCode.ToLowerInvariant()

    if ($RefreshCatalog -or -not $global:OSDCoreOperatingSystems) {
        $global:OSDCoreOperatingSystems = Get-OSDCoreOperatingSystems | Where-Object { $_.Architecture -match $OSArchitecture }
    }

    if (-not $global:OSDCoreOperatingSystems) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to load Operating Systems"
    }

    $matches = $global:OSDCoreOperatingSystems |
        Where-Object { $_.Activation -eq $OSActivation } |
        Where-Object { $_.Architecture -match $normalizedArchitecture } |
        Where-Object { $_.Language.ToLowerInvariant() -eq $normalizedLanguageCode } |
        Where-Object { $_.ReleaseID -eq $OSReleaseID } |
        Where-Object { $_.Version -eq $OSVersion }

    $global:OSDCoreOperatingSystemCloudObject = $matches |
        Sort-Object -Property @{ Expression = {
                try {
                    [version]($_.Build -replace '[^0-9\.]', '')
                }
                catch {
                    [version]'0.0'
                }
            }; Descending = $true } |
        Select-Object -First 1

    if (-not $global:OSDCoreOperatingSystemCloudObject) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to find a matching operating system object for OSReleaseID '$OSReleaseID', OSArchitecture '$normalizedArchitecture', Activation '$OSActivation', Language '$normalizedLanguageCode', and OSVersion '$OSVersion'."
    }

    return $global:OSDCoreOperatingSystemCloudObject
}
