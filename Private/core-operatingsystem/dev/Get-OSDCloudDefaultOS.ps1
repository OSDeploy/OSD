function Get-OSDCloudDefaultOS {
    <#
    .SYNOPSIS
    Gets the default OSDCloud operating system record for the current context.

    .DESCRIPTION
    Retrieves operating system records from Get-OSDCoreOperatingSystems and
    applies architecture and language preference filters to select a single default
    record. Language preference order is:
    1) $global:OSDCLOUD_OSLANGUAGECODE
    2) $env:OSDCLOUD_OSLANGUAGECODE
    3) Get-Culture Name

    Architecture selection uses $env:PROCESSOR_ARCHITECTURE when available.
    The first matching record is returned after filters are applied.

    .EXAMPLE
    Get-OSDCloudDefaultOS

    Returns the first matching operating system based on the current architecture
    and language preference inputs.

    .EXAMPLE
    $env:OSDCLOUD_OSLANGUAGECODE = 'en-us'
    Get-OSDCloudDefaultOS

    Returns an en-us operating system record when one exists for the selected
    architecture.

    .EXAMPLE
    $record = Get-OSDCloudDefaultOS
    $record.FileName

    Returns the media filename for the selected default record.

    .INPUTS
    None
    You cannot pipe input to this function.

    .OUTPUTS
    PSCustomObject
    A single operating system catalog record.

    .LINK
    https://www.osdeploy.com/

    .NOTES
    Author: OSDeploy
    2026-08-05 - Standardized and expanded comment-based help
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param ()
    $ErrorActionPreference = 'Stop'

    <#
        Id              : Windows 11 26H2 amd64 Retail en-gb 26300.9457
        OperatingSystem : Windows 11 26H2
        OSName          : Windows 11
        OSVersion       : 26H2
        OSArchitecture  : amd64
        OSActivation    : Retail
        OSLanguageCode  : en-gb
        OSLanguage      : English (United Kingdom)
        OSBuild         : 26300
        OSBuildVersion  : 26300.9457
        Size            : 6237917797
        Sha1            :
        Sha256          : 6c5d2f9a2916b3c580bf0f7b510535abfa3f192bdf638910661e343c3c9dd226
        FileName        : 26300.9457.260913-1737.26h2_ge_release_svc_refresh_CLIENTCONSUMER_RET_x64FRE_en-gb.esd
        FilePath        : http://dl.delivery.mp.microsoft.com/filestreamingservice/files/2a0e5ba9-88b3-4255-b89c-6aab9dfdc7d0/26300.9457.260913-1737.26h2_ge_release_svc_refresh_CLIENTCONSUMER_RET_x64FRE_en-gb.esd
    #>

    $records = Get-OSDCoreOperatingSystems
    #=================================================
    # Limit the results based on $env:PROCESSOR_ARCHITECTURE
    $ProcessorArchitecture = $env:PROCESSOR_ARCHITECTURE
    if ($ProcessorArchitecture -and ($records.OSArchitecture -match $ProcessorArchitecture)) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Set OSArchitecture from PROCESSOR_ARCHITECTURE environment variable $ProcessorArchitecture"
        $records = $records | Where-Object { $_.OSArchitecture -eq $ProcessorArchitecture }
    }
    #=================================================
    # OSDCloud OSLanguageCode
    # Preference Order:
    # 1. Parameter
    # 2. $global:OSDCLOUD_OSLANGUAGECODE
    $LanguageCodeGlobal = $global:OSDCLOUD_OSLANGUAGECODE
    # 3. $env:OSDCLOUD_OSLANGUAGECODE
    $LanguageCodeEnvironment = $env:OSDCLOUD_OSLANGUAGECODE
    # 4. Get-Culture
    $LanguageCodeCulture = Get-Culture | Select-Object -ExpandProperty Name -First 1
    # 5. Default Json Configuration

    if ($LanguageCodeGlobal) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Set OSLanguageCode from global variable $LanguageCodeGlobal"
        $records = $records | Where-Object { $_.OSLanguageCode -eq $LanguageCodeGlobal }
    }
    elseif ($LanguageCodeEnvironment) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Set OSLanguageCode from environment variable $LanguageCodeEnvironment"
        $records = $records | Where-Object { $_.OSLanguageCode -eq $LanguageCodeEnvironment }
    }
    elseif ($LanguageCodeCulture) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Set OSLanguageCode from Get-Culture value $LanguageCodeCulture"
        $records = $records | Where-Object { $_.OSLanguageCode -eq $LanguageCodeCulture }
    }
    else {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] No OSLanguageCode preference set, using default records"
    }
    #=================================================
    if (-not $records) {
        Write-Warning "[$($MyInvocation.MyCommand.Name)] No operating systems found matching criteria"
        return
    }
    return $records | Select-Object -First 1
}
