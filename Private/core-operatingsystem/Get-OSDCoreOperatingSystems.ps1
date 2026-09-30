function Get-OSDCoreOperatingSystems {
    <#
    .SYNOPSIS
    Gets parsed module-native operating system catalog entries.

    .DESCRIPTION
    Imports normalized raw catalog records from Initialize-ModuleCoreOperatingSystems and
    transforms them into operating system objects used by selection and deployment
    workflows. OSD receives its existing public property schema, while OSDCloud receives
    its native OS-prefixed property schema. The function derives build identity, Windows
    family and release, normalized architecture, and activation channel before returning
    unique sorted records.

    .EXAMPLE
    Get-OSDCoreOperatingSystems

    Returns all available parsed core operating system records.

    .EXAMPLE
    Get-OSDCoreOperatingSystems | Where-Object Version -eq 'Windows 11'

    Returns only Windows 11 operating system records.

    .EXAMPLE
    Get-OSDCoreOperatingSystems | Where-Object { $_.Architecture -eq 'arm64' }

    Returns only arm64 operating system records.

    .INPUTS
    None
    You cannot pipe input to this function.

    .OUTPUTS
    PSCustomObject[]
    Parsed operating system records with the current module's native properties.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-22 - Initial help block created
    2026-08-05 - Expanded help content and examples
    2026-09-30 - Merged OSD and OSDCloud native output projections
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param ()

    $Error.Clear()
    $ErrorActionPreference = 'Stop'
    $records = @()
    $mctRecords = @()
    $moduleName = $MyInvocation.MyCommand.Module.Name

    if ($moduleName -notin @('OSD', 'OSDCloud')) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unsupported module context '$moduleName'."
    }

    Initialize-ModuleCoreOperatingSystems
    if (-not ($global:ModuleCoreOperatingSystems)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to load Module Core Operating Systems."
    }
    $mctRecords = $global:ModuleCoreOperatingSystems

    if (-not $mctRecords) {
        return $records
    }

    foreach ($node in ($mctRecords | Sort-Object FileName, LanguageCode, Architecture)) {
        # Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Processing $($node.FileName)"

        if ([string]::IsNullOrWhiteSpace($node.OSBuild) -or [string]::IsNullOrWhiteSpace($node.OSBuildVersion)) {
            continue
        }
        #=================================================
        #   OperatingSystem / OSName / OSVersion
        $operatingSystemInfo = ConvertTo-OSDCoreOperatingSystemInfo -OSBuild $node.OSBuild
        if (-not $operatingSystemInfo) {
            continue
        }
        $OperatingSystem = $operatingSystemInfo.OperatingSystem
        $OSName = $operatingSystemInfo.OSName
        $OSVersion = $operatingSystemInfo.OSVersion
        #=================================================
        #   OSBuildVersion
        #=================================================
        $OSBuildVersion = [string]$node.OSBuildVersion
        #=================================================
        #   OSArchitecture
        #   Avoids confusion between x64 releases (amd64/arm64)
        #=================================================
        if ($node.Architecture -match 'x64') {
            $OSArchitecture = 'amd64'
        }
        elseif ($node.Architecture -match 'arm64') {
            $OSArchitecture = 'arm64'
        }
        else {
            $OSArchitecture = 'x86'
            continue
        }
        #=================================================
        #   OSActivation
        #=================================================
        if ($node.FileName -match 'clientconsumer_ret') {
            $OSActivation = 'Retail'
        }
        elseif ($node.FileName -match 'CLIENTBUSINESS_VOL') {
            $OSActivation = 'Volume'
        }
        else {
            $OSActivation = 'Unknown'
            continue
        }
        if ($moduleName -eq 'OSD') {
            $Win10 = $OSName -eq 'Windows 10'
            $Win11 = $OSName -eq 'Windows 11'
            $DisplayName = "$OSName $OSVersion $OSArchitecture $($node.LanguageCode) $OSActivation $OSBuildVersion"

            $records += [pscustomobject]@{
                Status       = $null
                ReleaseDate  = $null
                Name         = $DisplayName
                Version      = $OSName
                ReleaseID    = $OSVersion
                Architecture = $OSArchitecture
                Language     = $node.LanguageCode
                Activation   = $OSActivation
                Build        = $OSBuildVersion
                FileName     = $node.FileName
                ImageIndex   = $node.ImageIndex
                ImageName    = $node.ImageName
                Url          = $node.FilePath
                SHA1         = $node.Sha1
                SHA256       = $node.Sha256
                UpdateID     = $node.UpdateID
                Win10        = $Win10
                Win11        = $Win11
            }
        }
        else {
            $Id = "$OperatingSystem $OSArchitecture $OSActivation $($node.LanguageCode) $OSBuildVersion"

            $records += [pscustomobject]@{
                Id              = $Id
                OperatingSystem = $OperatingSystem
                OSName          = $OSName
                OSVersion       = $OSVersion
                OSArchitecture  = $OSArchitecture
                OSActivation    = $OSActivation
                OSLanguageCode  = $node.LanguageCode
                OSLanguage      = $node.Language
                OSBuild         = [string]$node.OSBuild
                OSBuildVersion  = $OSBuildVersion
                Size            = $node.Size
                Sha1            = $node.Sha1
                Sha256          = $node.Sha256
                FileName        = $node.FileName
                FilePath        = $node.FilePath
            }
        }
    }

    if ($moduleName -eq 'OSD') {
        $records = $records | Sort-Object -Property Url -Unique
        $records = $records | Sort-Object -Property Name
        $records | Export-Clixml -Path (Join-Path -Path $env:TEMP -ChildPath 'OSDCoreOperatingSystems.xml') -Force
    }
    else {
        $records = $records | Sort-Object -Property FileName -Unique
        $records = $records | Sort-Object -Property @{ Expression = { $_.OperatingSystem }; Descending = $true }, OSArchitecture, OSActivation, OSLanguageCode
        $records | Export-Clixml -Path (Join-Path -Path $env:TEMP -ChildPath 'OSDCloudCoreOperatingSystems.xml') -Force
    }
    return $records
}
