<#=================================================================================
    Get-CoreOperatingSystems
    ================================================================================
    - Returns XML content entries from core\operatingsystems as objects
    ================================================================================
    .SYNOPSIS
        Gets Microsoft catalog operating system entries from XML files.

    .DESCRIPTION
        Enumerates all XML files under the module path core\operatingsystems,
        parses each File node, and returns the node properties as
        PowerShell objects.

    .EXAMPLE
        PS C:\> Get-CoreOperatingSystems
        Returns all operating system entries from the XML catalogs.

    .NOTES
        Author: OSDeploy
        Version: 1.0
=================================================================================#>
function Get-CoreOperatingSystems {
    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param ()

    $ErrorActionPreference = 'Stop'
    $records = @()

    $srcRoot = Join-Path (Get-OSDModulePath) 'core\operatingsystems'

    foreach ($file in (Get-ChildItem -Path $srcRoot -Filter '*.xml' -Recurse -File | Sort-Object FullName)) {
        Write-Verbose "[$(Get-Date -Format s)] [$($MyInvocation.MyCommand.Name)] Importing $($file.FullName)"

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

            $records += [pscustomobject]$properties
        }
    }

    $records = $records |
        Group-Object -Property FilePath, FileName, LanguageCode, Architecture |
        ForEach-Object {
            $_.Group |
                Sort-Object -Property @{ Expression = { [string]::IsNullOrWhiteSpace($_.Sha256) }; Ascending = $true }, @{ Expression = { [string]::IsNullOrWhiteSpace($_.Sha1) }; Ascending = $true } |
                Select-Object -First 1
        } |
        Sort-Object -Property FilePath, FileName, LanguageCode, Architecture

    return $records
}
