function Get-ModuleCoreOperatingSystems {
    <#
    .SYNOPSIS
    Gets normalized module core operating system catalog records.

    .DESCRIPTION
    Reads operating system catalog XML files from core\operatingsystems under the module root,
    converts each PublishedMedia file node into a PowerShell object, removes excluded metadata
    properties, and normalizes duplicate properties. Duplicate catalog rows are grouped by
    FilePath, FileName, LanguageCode, and Architecture, then the preferred row is selected
    by hash availability.

    .EXAMPLE
    Get-ModuleCoreOperatingSystems

    Returns all normalized catalog records discovered in the module core operating systems cache.

    .EXAMPLE
    Get-ModuleCoreOperatingSystems | Where-Object { $_.LanguageCode -eq 'en-us' }

    Returns only catalog records for en-us language media.

    .INPUTS
    None
    You cannot pipe input to this function.

    .OUTPUTS
    PSCustomObject[]
    Normalized raw catalog records imported from module XML metadata.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-22 - Initial help block created
    2026-08-05 - Expanded help content and examples
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param ()

    $ErrorActionPreference = 'Stop'
    $records = @()
    $mctRecords = @()

    $srcRoot = Join-Path $($MyInvocation.MyCommand.Module.ModuleBase) 'core\operatingsystems'

    foreach ($file in (Get-ChildItem -Path $srcRoot -Filter '*.xml' -Recurse -File | Sort-Object FullName)) {
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

    return $mctRecords
}
