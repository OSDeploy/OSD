function Get-OSDCloudDefaultOS {
    <#
    .SYNOPSIS
    Gets the default OSDCloud operating system record for the current context.

    .DESCRIPTION
    Retrieves operating system records from Get-OSDCloudCoreOperatingSystems and
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
        Id              : Windows 11 25H2 amd64 Retail en-gb 26200.7462
        OperatingSystem : Windows 11 25H2
        OSName          : Windows 11
        OSVersion       : 25H2
        OSArchitecture  : amd64
        OSActivation    : Retail
        OSLanguageCode  : en-gb
        OSLanguage      : English (United Kingdom)
        OSBuild         : 26200
        OSBuildVersion  : 26200.7462
        Size            : 5626355066
        Sha1            :
        Sha256          : 566a518dc46ba5ea401381810751a8abcfe7d012b2f81c9709b787358c606926
        FileName        : 26200.7462.251207-0044.25h2_ge_release_svc_refresh_CLIENTCONSUMER_RET_x64FRE_en-gb.esd
        FilePath        : http://dl.delivery.mp.microsoft.com/filestreamingservice/files/79a3f5e0-d04d-4689-a5d4-3ea35f8b189a/26200.7462.251207-0044.25h2_ge_release_svc_refresh_CLIENTCONSUMER_RET_x64FRE_en-gb.esd
    #>

    $records = Get-OSDCloudCoreOperatingSystems
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
