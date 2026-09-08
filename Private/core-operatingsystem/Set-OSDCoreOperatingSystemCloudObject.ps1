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

    .EXAMPLE
    Set-OSDCoreOperatingSystemCloudObject -OSActivation Volume -OSArchitecture arm64 -OSLanguageCode en-us -OSReleaseID 24H2 -RefreshCatalog

    Refreshes the catalog cache and selects the latest matching Volume arm64 record.

    .INPUTS
    None
    You cannot pipe input to this function.

    .OUTPUTS
    PSCustomObject
    The selected operating system object assigned to
    $global:OSDCoreOperatingSystemCloudObject.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Initial implementation to centralize OS catalog object selection.
    2026-08-05 - Expanded help content and examples
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

    $Error.Clear()
    $ModuleName = $($MyInvocation.MyCommand.Module.Name)
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Starting operating system cloud object selection"
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Input filters: Activation='$OSActivation', Architecture='$OSArchitecture', Language='$OSLanguageCode', ReleaseID='$OSReleaseID', Version='$OSVersion', RefreshCatalog='$($RefreshCatalog.IsPresent)'"

    $normalizedArchitecture = $OSArchitecture.ToLowerInvariant()
    $normalizedLanguageCode = $OSLanguageCode.ToLowerInvariant()
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Normalized filters: Architecture='$normalizedArchitecture', Language='$normalizedLanguageCode'"

    if ($RefreshCatalog -or -not $global:OSDCoreOperatingSystems) {
        # Select the provider that exists in the current module context.
        if ($ModuleName -eq 'OSD') {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Refreshing cached operating systems from Get-OSDCoreOperatingSystems"
            $global:OSDCoreOperatingSystems = Get-OSDCoreOperatingSystems |
                Where-Object { $_.Architecture -match $normalizedArchitecture }
        }
        elseif ($ModuleName -eq 'OSDCloud') {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Refreshing cached operating systems from Get-OSDCloudCoreOperatingSystems"
            $global:OSDCoreOperatingSystems = Get-OSDCloudCoreOperatingSystems |
                Where-Object { $_.OSArchitecture -match $normalizedArchitecture }
        }
        else {
            throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to load core operating systems provider command."
        }
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Cached operating systems after architecture prefilter: $(@($global:OSDCoreOperatingSystems).Count)"
    }
    else {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Using existing cached operating systems: $(@($global:OSDCoreOperatingSystems).Count)"
    }

    if (-not $global:OSDCoreOperatingSystems) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] No operating systems are available after loading cache"
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to load Operating Systems"
    }

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Applying catalog filters to cached operating systems"
    $matchingOperatingSystems = $global:OSDCoreOperatingSystems |
        Where-Object { ($_.Activation -eq $OSActivation) -or ($_.OSActivation -eq $OSActivation) } |
        # Where-Object { ($_.Architecture -match $normalizedArchitecture) -or ($_.OSArchitecture -match $normalizedArchitecture) } |
        Where-Object { ($_.Language -eq $normalizedLanguageCode) -or ($_.OSLanguageCode -eq $normalizedLanguageCode) } |
        Where-Object { ($_.ReleaseID -eq $OSReleaseID) -or ($_.OSVersion -eq $OSReleaseID) } |
        Where-Object { ($_.Version -eq $OSVersion) -or ($_.OSName -eq $OSVersion) }
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Matching operating systems found: $(@($matchingOperatingSystems).Count)"

    $global:OSDCoreOperatingSystemCloudObject = $matchingOperatingSystems |
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
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] No matching operating system object was selected after sorting"
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to find a matching operating system object for OSReleaseID '$OSReleaseID', OSArchitecture '$normalizedArchitecture', Activation '$OSActivation', Language '$normalizedLanguageCode', and OSVersion '$OSVersion'."
    }

    # Select the provider that exists in the current module context.
    if ($ModuleName -eq 'OSD') {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Selected operating system object: Name='$($global:OSDCoreOperatingSystemCloudObject.Name)', Build='$($global:OSDCoreOperatingSystemCloudObject.Build)', FileName='$($global:OSDCoreOperatingSystemCloudObject.FileName)'"
    }
    elseif ($ModuleName -eq 'OSDCloud') {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Selected operating system object: Name='$($global:OSDCoreOperatingSystemCloudObject.Id)', Build='$($global:OSDCoreOperatingSystemCloudObject.OSBuildVersion)', FileName='$($global:OSDCoreOperatingSystemCloudObject.FileName)'"
    }
    else {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to load core operating systems provider command."
    }

    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Operating system cloud object selection completed successfully"
    return $global:OSDCoreOperatingSystemCloudObject
}
