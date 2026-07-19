<#=================================================================================
    Get-OSDCoreOperatingSystems
    ================================================================================
        - Retrieves all operating system records from Microsoft catalogs
        - Directly imports XML records from core\operatingsystems and extracts
            OS build, version, architecture, language, and activation info
    - Returns sorted array of operating system objects
    ================================================================================
    .SYNOPSIS
        Retrieves all operating system records from the OSDCloud catalog

    .DESCRIPTION
        Enumerates all XML files under core\operatingsystems, parses each
        PublishedMedia Files File node, normalizes and deduplicates metadata,
        then parses file names and catalog properties to extract OS build
        numbers, versions, architecture, language codes, activation, and
        download information.

    .PARAMETER None
        This function does not accept parameters.

    .EXAMPLE
        PS C:\> Get-OSDCoreOperatingSystems
        Returns all available operating system records

    .EXAMPLE
        PS C:\> Get-OSDCoreOperatingSystems | Where-Object { $_.OSName -eq 'Windows 11' }
        Returns only Windows 11 operating systems

    .EXAMPLE
        PS C:\> Get-OSDCoreOperatingSystems | Group-Object OperatingSystem
        Groups operating systems by major version

    .NOTES
        Author: OSDeploy
        Version: 1.0
        GitHub: https://github.com/OSDeploy

    .LINK
        https://www.osdeploy.com/
=================================================================================#>
function Get-OSDCoreOperatingSystems {
    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param ()
    $ErrorActionPreference = 'Stop'
    $records = @()
    $mctRecords = @()

    $srcRoot = Join-Path $($MyInvocation.MyCommand.Module.ModuleBase) 'core\operatingsystems'

    foreach ($file in (Get-ChildItem -Path $srcRoot -Filter '*.xml' -File | Sort-Object FullName)) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Importing $($file.FullName)"

        $xml = [xml](Get-Content -Path $file.FullName -Raw)
        $fileNodes = $xml.MCT.Catalogs.Catalog.PublishedMedia.Files.File

        if (-not $fileNodes) {
            continue
        }

        foreach ($node in ($fileNodes | Sort-Object FileName, LanguageCode, Edition)) {
            $properties = [ordered]@{
                Sha1   = $null
                Sha256 = $null
            }

            $excludedProperties = @('Edition', 'Key', 'Architecture_Loc', 'ArchitectureLoc', 'Edition_Loc', 'EditionLoc', 'IsRetailOnly')

            foreach ($child in $node.ChildNodes) {
                if ($child.NodeType -ne [System.Xml.XmlNodeType]::Element) {
                    continue
                }

                $name = $child.LocalName
                $value = $child.InnerText

                if ($name -match '^Sha1$') {
                    $name = 'Sha1'
                }
                elseif ($name -match '^Sha256$') {
                    $name = 'Sha256'
                }

                if ($excludedProperties -contains $name) {
                    continue
                }

                if ($properties.Contains($name)) {
                    if ($name -in @('Sha1', 'Sha256') -or [string]::IsNullOrWhiteSpace($properties[$name])) {
                        $properties[$name] = $value
                    }
                    else {
                        $suffix = 2
                        while ($properties.Contains("$name$suffix")) {
                            $suffix++
                        }
                        $properties["$name$suffix"] = $value
                    }
                }
                else {
                    $properties[$name] = $value
                }
            }

            $mctRecords += [pscustomobject]$properties
        }
    }

    $mctRecords = $mctRecords |
        Group-Object -Property FilePath, FileName, LanguageCode, Architecture |
        ForEach-Object {
            $_.Group |
                Sort-Object -Property @{ Expression = { [string]::IsNullOrWhiteSpace($_.Sha256) }; Ascending = $true }, @{ Expression = { [string]::IsNullOrWhiteSpace($_.Sha1) }; Ascending = $true } |
                Select-Object -First 1
        } |
        Sort-Object -Property FilePath, FileName, LanguageCode, Architecture

    if (-not $mctRecords) {
        return $records
    }

    foreach ($node in ($mctRecords | Sort-Object FileName, LanguageCode, Architecture)) {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Processing $($node.FileName)"

        if ([string]::IsNullOrWhiteSpace($node.FileName) -or $node.FileName.Length -lt 5) {
            continue
        }
            #=================================================
            #   OSBuild
            #   Get the OSBuild from the FileName
            $OSBuild = $node.FileName.Substring(0, 5)
            #=================================================
            #   OperatingSystem / OSName / OSVersion
            #   19045 = Windows 10 22H2
            #   22000 = Windows 11 21H2
            #   22621 = Windows 11 22H2
            #   22631 = Windows 11 23H2
            #   26100 = Windows 11 24H2
            #   26200 = Windows 11 25H2
            #   28000 = Windows 11 26H1
            switch ($OSBuild) {
                '19045' { $OSName = 'Windows 10'; $OSVersion = '22H2' }
                '22000' { $OSName = 'Windows 11'; $OSVersion = '21H2' }
                '22621' { $OSName = 'Windows 11'; $OSVersion = '22H2' }
                '22631' { $OSName = 'Windows 11'; $OSVersion = '23H2' }
                '26100' { $OSName = 'Windows 11'; $OSVersion = '24H2' }
                '26200' { $OSName = 'Windows 11'; $OSVersion = '25H2' }
                '28000' { $OSName = 'Windows 11'; $OSVersion = '26H1' }
                default { continue }
            }
            #=================================================
            #   OSBuildVersion
            #   Combination of <OSBuild>.<Sub>
            #   Extract from FileName
            #=================================================
            $fileNameParts = $node.FileName -split '\.'
            if ($fileNameParts.Count -lt 2) {
                continue
            }
            $OSBuildVersion = "$($fileNameParts[0]).$($fileNameParts[1])"
            #=================================================
            #   OSArchitecture
            #   Avoids confusion between x64 releases (amd64/arm64)
            #=================================================
            if ($node.Architecture -match 'x64') {
                $OSArchitecture = 'amd64'
            } elseif ($node.Architecture -match 'arm64') {
                $OSArchitecture = 'arm64'
            } else {
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
            #=================================================
            #   Win10 / Win11
            #=================================================
            if ($OSName -eq 'Windows 10') {
                $Win10 = $true
                $Win11 = $false
            }
            elseif ($OSName -eq 'Windows 11') {
                $Win10 = $false
                $Win11 = $true
            }
            else {
                $Win10 = $false
                $Win11 = $false
            }
            #=================================================
            #   OSD Module Properties
            #=================================================
            # DisplayName should be in the format "Win11-25H2-amd64"
            $DisplayName = "$OSName $OSVersion $OSArchitecture $($node.LanguageCode) $OSActivation $OSBuildVersion"
            #=================================================
            #   ObjectProperties
            #=================================================
            <#
            Status       :
            ReleaseDate  : 2023-12-04
            Name         : Windows 10 22H2 x64 ar-sa Retail 19045.3803
            Version      : Windows 10
            ReleaseID    : 22H2
            Architecture : x64
            Language     : ar-sa
            Activation   : Retail
            Build        : 19045.3803
            FileName     : 19045.3803.231204-0204.22h2_release_svc_refresh_CLIENTCONSUMER_RET_x64FRE_ar-sa.esd
            ImageIndex   :
            ImageName    :
            Url          : http://dl.delivery.mp.microsoft.com/filestreamingservice/files/39d366c6-bb66-4938-9a78-0670eda8304d/19045.3803.231204-0204.22h2_release_svc_refresh_CLIENTCONSUMER_RET_x64FRE_ar-sa.esd
            SHA1         : 2119ef0efd432f98cdccdf525cd17fcceacef111
            UpdateID     :
            Win10        : True
            Win11        : False
            #>

        $records += [pscustomobject]@{
            Status          = $null
            ReleaseDate     = $null
            Name            = $DisplayName
            Version         = $OSName
            ReleaseID       = $OSVersion
            Architecture    = $OSArchitecture
            Language        = $node.LanguageCode
            Activation      = $OSActivation
            Build           = $OSBuildVersion
            FileName        = $node.FileName
            ImageIndex      = $node.ImageIndex
            ImageName       = $node.ImageName
            Url             = $node.FilePath
            SHA1            = $node.Sha1
            SHA256          = $node.Sha256
            UpdateID        = $node.UpdateID
            Win10           = $Win10
            Win11           = $Win11
        }
    }

    $records = $records | Sort-Object -Property Url -Unique
    $records = $records | Sort-Object -Property Name
    return $records
}
