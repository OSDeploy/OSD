function Get-FeatureUpdate {
    <#
    .SYNOPSIS
    Returns the latest matching Windows client feature update record.

    .DESCRIPTION
    Queries OSDCloud operating system metadata and filters by language, activation,
    architecture, and either a named OS target or version/release criteria.
    Returns the newest matching feature update object.

    .PARAMETER OSName
    Friendly OS target name used to select a specific version, release, and architecture profile.
    Defaults to Windows 11 25H2 amd64.

    .PARAMETER OSVersion
    Operating system family used with OSReleaseID for legacy version/release filtering.
    Valid values are Windows 11 and Windows 10.

    .PARAMETER OSReleaseID
    Feature update release identifier used with OSVersion for legacy version/release filtering.
    Examples include 25H2, 24H2, 23H2, and 22H2.

    .PARAMETER OSArchitecture
    Processor architecture to filter on.
    Valid values are x64, amd64, and arm64.

    .PARAMETER OSActivation
    Activation channel to filter on.
    Valid values are Retail and Volume.

    .PARAMETER OSLanguage
    Language tag used to filter operating system content.
    Defaults to en-us.

    .EXAMPLE
    Get-FeatureUpdate
    Returns the latest feature update using default filters.

    .EXAMPLE
    Get-FeatureUpdate -OSName 'Windows 11 24H2 arm64' -OSLanguage 'en-us' -OSActivation Volume
    Returns the latest matching arm64 Windows 11 24H2 volume feature update.

    .OUTPUTS
    PSCustomObject
    Returns the newest feature update object that matches the supplied filters.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-16 - Updated comment-based help to match OSD standards
    #>

    [CmdletBinding()]
    param (
        # Operating system display name.
        # Default = Windows 11 25H2 amd64
        [ValidateSet(
            'Windows 11 25H2 amd64',
            'Windows 11 25H2 arm64',
            'Windows 11 25H2 x64',
            'Windows 11 24H2 amd64',
            'Windows 11 24H2 arm64',
            'Windows 11 24H2 x64',
            'Windows 11 23H2 amd64',
            'Windows 11 23H2 x64',
            'Windows 10 22H2 amd64',
            'Windows 10 22H2 x64'
            )]
        [Alias('Name')]
        [System.String]
        $OSName = 'Windows 11 25H2 amd64',

        # Activation channel.
        # Default = Volume
        [ValidateSet('Retail','Volume')]
        [Alias('License','OSLicense','Activation')]
        [System.String]
        $OSActivation = 'Volume',

        # Operating system architecture.
        # x64 and amd64 are treated interchangeably.
        # Default = x64
        [ValidateSet('amd64','arm64','x64')]
        [Alias('Arch','OSArch','Architecture')]
        [System.String]
        $OSArchitecture = $env:PROCESSOR_ARCHITECTURE,

        # Language tag.
        # Default = en-us
        [ValidateSet (
            'ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','en-us','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw')]
        [Alias('Culture','OSCulture','Language')]
        [System.String]
        $OSLanguage = 'en-us',

        # Operating system release identifier for legacy version/release filtering.
        # Default = 25H2
        [ValidateSet('25H2','24H2','23H2','22H2')]
        [Alias('Build','OSBuild','ReleaseID')]
        [System.String]
        $OSReleaseID = '25H2',

        # Operating system family for legacy version/release filtering.
        # Default = Windows 11
        [ValidateSet('Windows 11','Windows 10')]
        [Alias('Version')]
        [System.String]
        $OSVersion = 'Windows 11'
    )
    #=================================================
    # Determine selection mode from explicitly bound parameters.
    $UseLegacyCriteria = $PSBoundParameters.ContainsKey('OSVersion') -or $PSBoundParameters.ContainsKey('OSReleaseID')
    $UseOSNameCriteria = $PSBoundParameters.ContainsKey('OSName') -or (-not $UseLegacyCriteria -and -not $PSBoundParameters.ContainsKey('OSArchitecture'))

    # Resolve effective architecture.
    # If OSName is explicitly provided and includes architecture, OSName takes precedence.
    if ($PSBoundParameters.ContainsKey('OSName') -and $OSName -match '(?i)\barm64\b') {
        $NormalizedArchitecture = 'arm64'
    }
    elseif ($PSBoundParameters.ContainsKey('OSName') -and $OSName -match '(?i)\b(x64|amd64)\b') {
        $NormalizedArchitecture = 'amd64'
    }
    else {
        $NormalizedArchitecture = switch ($OSArchitecture.ToLowerInvariant()) {
            'x64'   { 'amd64' }
            'amd64' { 'amd64' }
            'arm64' { 'arm64' }
        }
    }

    $SourceArch = if ($NormalizedArchitecture -eq 'arm64') { 'arm64' } else { 'x64' }
    $Results = Get-OSDCloudOperatingSystems -OSArch $SourceArch

    $ArchitectureFilter = {
        $CurrentArch = $_.Architecture.ToLowerInvariant()
        if ($NormalizedArchitecture -eq 'amd64') {
            $CurrentArch -in @('x64', 'amd64')
        }
        else {
            $CurrentArch -eq 'arm64'
        }
    }
    #=================================================
    # OSLanguage
    $Results = $Results | Where-Object {$_.Language -match $OSLanguage}
    #=================================================
    # OSActivation
    $Results = $Results | Where-Object {$_.Activation -match $OSActivation}
    #=================================================
    # Legacy version/release filters
    if ($UseLegacyCriteria) {
        Write-Verbose -Message 'Legacy version/release criteria'
        $Results = $Results | Where-Object $ArchitectureFilter
        $Results = $Results | Where-Object {$_.Version -match $OSVersion}
        $Results = $Results | Where-Object {$_.ReleaseID -eq $OSReleaseID}
    }
    elseif ($UseOSNameCriteria) {
        $Results = $Results | Where-Object $ArchitectureFilter

        # Parse OSName into version/release/architecture and filter deterministically.
        $OSNameMatch = [regex]::Match($OSName, '^(?<Version>Windows\s+\d+)\s+(?<ReleaseID>\S+)\s+(?<Arch>amd64|x64|arm64)$', 'IgnoreCase')
        if ($OSNameMatch.Success) {
            $OSNameVersion = $OSNameMatch.Groups['Version'].Value
            $OSNameReleaseID = $OSNameMatch.Groups['ReleaseID'].Value

            $Results = $Results | Where-Object { $_.Version -match [regex]::Escape($OSNameVersion) }
            $Results = $Results | Where-Object { $_.ReleaseID -eq $OSNameReleaseID }
        }
        else {
            Write-Verbose "Unable to parse OSName '$OSName'; only architecture filter will be applied."
        }
    }
    else {
        $Results = $Results | Where-Object $ArchitectureFilter
    }
    #=================================================
    # Results
    $Results | Sort-Object CreationDate -Descending | Select-Object -First 1
    #=================================================
}
