function ConvertTo-OSDCloudDriverPack {
    <#
    .SYNOPSIS
    Converts core driver pack objects to the legacy OSDCloud driver pack schema.

    .DESCRIPTION
    Projects driver pack objects read from core\driverpacks into the property schema
    returned by Get-OSDCloudDriverPacks. Compatibility values are derived without
    evaluating OSDCore licensing.

    .PARAMETER InputObject
    One or more core driver pack catalog objects to convert.

    .PARAMETER LegacyDriverPackCatalog
    Legacy driver pack records used to preserve existing GUIDs for matching records.

    .EXAMPLE
    Get-OSDCoreDriverPackCatalogDell -LocalOnly | ConvertTo-OSDCloudDriverPack
    Converts bundled Dell driver pack records to the public OSDCloud schema.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-09-30 - Added core catalog compatibility projection
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $InputObject,

        [Parameter()]
        [System.Management.Automation.PSObject[]]
        $LegacyDriverPackCatalog = @()
    )

    begin {
        $Error.Clear()
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
        $legacyGuidLookup = @{}
        foreach ($legacyDriverPack in $LegacyDriverPackCatalog) {
            if ([string]::IsNullOrWhiteSpace([string]$legacyDriverPack.Guid)) {
                continue
            }

            $legacyIdentity = '{0}|{1}|{2}' -f
                ([string]$legacyDriverPack.Manufacturer).ToUpperInvariant(),
                ([string]$legacyDriverPack.Model).ToUpperInvariant(),
                ([string]$legacyDriverPack.FileName).ToUpperInvariant()
            if (-not $legacyGuidLookup.ContainsKey($legacyIdentity)) {
                $legacyGuidLookup[$legacyIdentity] = @()
            }
            $legacyGuidLookup[$legacyIdentity] += [string]$legacyDriverPack.Guid
        }
    }

    process {
        $systemIds = @($InputObject.SystemId | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
        $identitySystemIds = @($systemIds | ForEach-Object { ([string]$_).ToUpperInvariant() } | Sort-Object -Unique)
        $identity = '{0}|{1}|{2}|{3}|{4}' -f
            ([string]$InputObject.Manufacturer).ToUpperInvariant(),
            ([string]$InputObject.Model).ToUpperInvariant(),
            ($identitySystemIds -join ','),
            ([string]$InputObject.FileName).ToUpperInvariant(),
            ([string]$InputObject.OSArchitecture).ToUpperInvariant()

        $md5 = [System.Security.Cryptography.MD5]::Create()
        try {
            $identityBytes = [System.Text.Encoding]::UTF8.GetBytes($identity)
            $hashBytes = $md5.ComputeHash($identityBytes)
        }
        finally {
            $md5.Dispose()
        }

        $hashText = [System.BitConverter]::ToString($hashBytes).Replace('-', '').ToLowerInvariant()
        $generatedGuid = '{0}-{1}-{2}-{3}-{4}' -f
            $hashText.Substring(0, 8),
            $hashText.Substring(8, 4),
            $hashText.Substring(12, 4),
            $hashText.Substring(16, 4),
            $hashText.Substring(20, 12)

        $legacyIdentity = '{0}|{1}|{2}' -f
            ([string]$InputObject.Manufacturer).ToUpperInvariant(),
            ([string]$InputObject.Model).ToUpperInvariant(),
            ([string]$InputObject.FileName).ToUpperInvariant()
        $legacyGuidAliases = @()
        if ($legacyGuidLookup.ContainsKey($legacyIdentity)) {
            $legacyGuids = @($legacyGuidLookup[$legacyIdentity] | Sort-Object -Unique)
            $guid = $legacyGuids[0]
            if ($legacyGuids.Count -gt 1) {
                $legacyGuidAliases = @($legacyGuids | Select-Object -Skip 1)
            }
        }
        else {
            $guid = $generatedGuid
        }

        $packageId = $null
        if ($InputObject.PSObject.Properties['PackageID']) {
            $packageId = $InputObject.PackageID
        }
        elseif ([string]$InputObject.UpdatePage -match '[?&]id=(\d+)') {
            $packageId = $Matches[1]
        }
        elseif ([string]$InputObject.FileName -match '^(sp\d+)') {
            $packageId = $Matches[1]
        }
        elseif ([string]$InputObject.FileName -match '-([A-Za-z0-9]+)_Win(?:10|11)') {
            $packageId = $Matches[1]
        }

        $osBuild = $null
        if ($InputObject.PSObject.Properties['OSBuild']) {
            $osBuild = $InputObject.OSBuild
        }
        elseif ([string]$InputObject.FileName -match 'Win(?:10|11)_(\d{5})') {
            $osBuild = $Matches[1]
        }

        $osReleaseId = $null
        if ($InputObject.PSObject.Properties['OSVersion']) {
            $osReleaseId = $InputObject.OSVersion
        }
        elseif ($osBuild) {
            $osReleaseId = switch ([string]$osBuild) {
                '22000' { '21H2' }
                '22621' { '22H2' }
                '22631' { '23H2' }
                '26100' { '24H2' }
                '26200' { '25H2' }
                '26300' { '26H2' }
                '28000' { '26H1' }
                default { $null }
            }
        }

        $compatibilityObject = [Ordered]@{
            CatalogVersion = $InputObject.CatalogVersion
            Status         = if ($InputObject.PSObject.Properties['Status']) { $InputObject.Status } else { $null }
            ReleaseDate    = $InputObject.ReleaseDate
            Manufacturer   = $InputObject.Manufacturer
            Model          = $InputObject.Model
            Legacy         = if ($InputObject.PSObject.Properties['Legacy']) { $InputObject.Legacy } else { $null }
            Product        = $InputObject.SystemId
            Name           = $InputObject.Name
            PackageID      = $packageId
            FileName       = $InputObject.FileName
            Url            = $InputObject.Url
            OS             = "$($InputObject.OperatingSystem) x64"
            OSReleaseId    = $osReleaseId
            OSBuild        = $osBuild
            OSArchitecture = $InputObject.OSArchitecture
            HashMD5        = $InputObject.HashMD5
            Guid           = $guid
        }
        if ($legacyGuidAliases.Count -gt 0) {
            $compatibilityObject.GuidAliases = $legacyGuidAliases
        }
        [PSCustomObject]$compatibilityObject
    }

    end {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    }
}
