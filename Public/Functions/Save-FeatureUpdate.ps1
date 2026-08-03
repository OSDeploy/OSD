function Save-FeatureUpdate {
    <#
    .SYNOPSIS
    Downloads the latest matching Windows client feature update package.

    .DESCRIPTION
    Queries OSDCloud operating system metadata using language, activation,
    architecture, and either OSName or legacy version/release criteria,
    then downloads the newest matching feature update to the specified path.

    .PARAMETER DownloadPath
    Destination directory used to store the downloaded feature update file.
    Defaults to C:\OSDCloud\OS.

    .PARAMETER OSName
    Friendly OS target name used to select a specific version, release, and architecture profile.
    Defaults to Windows 11 25H2 amd64.

    .PARAMETER OSActivation
    Activation channel to filter on.
    Valid values are Retail and Volume.

    .PARAMETER OSArchitecture
    Processor architecture to filter on.
    Valid values are x64, amd64, and arm64.

    .PARAMETER OSLanguage
    Language tag used to filter operating system content.
    Defaults to en-us.

    .PARAMETER OSReleaseID
    Feature update release identifier used with OSVersion for legacy version/release filtering.
    Examples include 25H2, 24H2, 23H2, and 22H2.

    .PARAMETER OSVersion
    Operating system family used with OSReleaseID for legacy version/release filtering.
    Valid values are Windows 11 and Windows 10.

    .EXAMPLE
    Save-FeatureUpdate
    Downloads the latest matching feature update using default filters.

    .EXAMPLE
    Save-FeatureUpdate -DownloadPath 'D:\OSDCloud\OS' -OSName 'Windows 11 24H2 arm64' -OSLanguage 'en-us' -OSActivation Volume
    Downloads the latest matching Windows 11 24H2 arm64 volume feature update to D:\OSDCloud\OS.

    .OUTPUTS
    System.IO.FileInfo
    Returns the downloaded file, or the existing local file when it is already present.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-16 - Updated comment-based help to match OSD standards
    #>

    [CmdletBinding()]
    param (
        # Path used to save the downloaded feature update.
        # Default = C:\OSDCloud\OS
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias ('DownloadFolder','Path')]
        [System.String]
        $DownloadPath = 'C:\OSDCloud\OS',

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
    #   Results
    #=================================================
    $GetFeatureUpdate = $Results | Sort-Object CreationDate -Descending | Select-Object -First 1
    #=================================================
    #   SaveWebFile
    #=================================================
    if ($GetFeatureUpdate) {
        if (Test-Path "$DownloadPath\$($GetFeatureUpdate.FileName)") {
            Get-Item "$DownloadPath\$($GetFeatureUpdate.FileName)"
        }
        elseif (Test-WebConnection -Uri "$($GetFeatureUpdate.Url)") {
            $SaveWebFile = Save-WebFile -SourceUrl $GetFeatureUpdate.Url -DestinationDirectory "$DownloadPath" -DestinationName $GetFeatureUpdate.FileName

            if (Test-Path $SaveWebFile.FullName) {
                Get-Item $SaveWebFile.FullName
            }
            else {
                Write-Warning "Could not download the Feature Update"
            }
        }
        else {
            Write-Warning "Could not verify an Internet connection for the Feature Update"
        }
    }
    else {
        Write-Warning "Unable to determine a suitable Feature Update"
    }
}
