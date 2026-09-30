function Initialize-ModuleCoreOperatingSystems {
    <#
    .SYNOPSIS
    Gets normalized module core operating system catalog records.

    .DESCRIPTION
    Reads operating system catalog XML files from core\operatingsystems under the module root,
    ProgramData, and OSDCloud catalog directories on mounted drive letters. For each major build,
    only catalogs with the latest valid build revision are imported. Each PublishedMedia file node
    is converted into a PowerShell object, excluded metadata properties are removed, and duplicate
    properties are normalized. Duplicate catalog rows are grouped by FilePath, FileName,
    LanguageCode, and Architecture, then the preferred row is selected by hash availability.
    The bundled module catalog wins when an external catalog has the same build revision.

    .EXAMPLE
    Initialize-ModuleCoreOperatingSystems

    Returns all normalized catalog records discovered in the module core operating systems cache.

    .EXAMPLE
    Initialize-ModuleCoreOperatingSystems | Where-Object { $_.LanguageCode -eq 'en-us' }

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
    2026-09-17 - Added external catalog discovery and latest build selection
    2026-09-30 - Preferred bundled catalogs when external revisions are equal
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param ()
    #=================================================
    # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [INFO] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    $ErrorActionPreference = 'Stop'
    $Error.Clear()
    $records = @()
    $mctRecords = @()

    $srcRoot = Join-Path $($MyInvocation.MyCommand.Module.ModuleBase) 'core\operatingsystems'
    $catalogSources = @(
        [pscustomobject]@{
            Path     = $srcRoot
            External = $false
        }
    )

    $externalCatalogPaths = @()
    if (-not [string]::IsNullOrWhiteSpace($env:ProgramData)) {
        $externalCatalogPaths += Join-Path -Path $env:ProgramData -ChildPath 'OSDeployCore\OSDCloud\catalogs\operatingsystems'
    }
    $externalCatalogPaths += 'C:\ProgramData\OSDeployCore\OSDCloud\catalogs\operatingsystems'

    $driveCatalogPaths = Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue |
    Where-Object { $_.Root -match '^[A-Z]:\\$' } |
    ForEach-Object {
        Join-Path -Path $_.Root -ChildPath 'OSDCloud\catalogs\operatingsystems'
    }
    $externalCatalogPaths += $driveCatalogPaths

    foreach ($catalogPath in ($externalCatalogPaths | Sort-Object -Unique)) {
        $catalogSources += [pscustomobject]@{
            Path     = $catalogPath
            External = $true
        }
    }

    $catalogSources = $catalogSources |
    Group-Object -Property { ([System.IO.Path]::GetFullPath($_.Path)).TrimEnd('\').ToLowerInvariant() } |
    ForEach-Object {
        $_.Group | Sort-Object -Property External | Select-Object -First 1
    } |
    Sort-Object -Property Path

    $catalogFiles = @()
    foreach ($catalogSource in $catalogSources) {
        try {
            if (-not (Test-Path -LiteralPath $catalogSource.Path -PathType Container -ErrorAction Stop)) {
                continue
            }

            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Searching $($catalogSource.Path)"
            $sourceFiles = Get-ChildItem -LiteralPath $catalogSource.Path -Filter '*.xml' -Recurse -File -ErrorAction Stop
            foreach ($file in $sourceFiles) {
                $catalogFiles += [pscustomobject]@{
                    File     = $file
                    External = $catalogSource.External
                }
            }
        }
        catch {
            if ($catalogSource.External) {
                Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to search external operating system catalogs at '$($catalogSource.Path)': $($_.Exception.Message)"
                continue
            }
            throw
        }
    }

    $catalogFiles = $catalogFiles |
    Group-Object -Property { ([System.IO.Path]::GetFullPath($_.File.FullName)).ToLowerInvariant() } |
    ForEach-Object {
        $_.Group | Sort-Object -Property External | Select-Object -First 1
    } |
    Sort-Object -Property { $_.File.FullName }

    $catalogCandidates = @()
    foreach ($catalogFile in $catalogFiles) {
        $file = $catalogFile.File
        if ($file.Name -notmatch '^(?<MajorBuild>\d{5})\.(?<Revision>0|[1-9]\d*)\.(?<Timestamp>\d{6}-\d{4})\.xml$') {
            $message = "Operating system catalog filename '$($file.FullName)' does not match '<major>.<ubr>.<yyMMdd>-<HHmm>.xml'."
            if ($catalogFile.External) {
                Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] $message Skipping external catalog."
                continue
            }
            throw $message
        }
        $majorBuild = $Matches.MajorBuild
        $revision = $Matches.Revision

        try {
            $xml = [xml](Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop)
            $fileNodes = $xml.MCT.Catalogs.Catalog.PublishedMedia.Files.File
            if (-not $fileNodes) {
                $message = "Operating system catalog '$($file.FullName)' does not contain PublishedMedia file records."
                if ($catalogFile.External) {
                    Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] $message Skipping external catalog."
                    continue
                }
                throw $message
            }

            $catalogCandidates += [pscustomobject]@{
                File         = $file
                FileNodes    = $fileNodes
                MajorBuild   = $majorBuild
                BuildVersion = [version]"$majorBuild.$revision"
                External     = $catalogFile.External
            }
        }
        catch {
            if ($catalogFile.External) {
                Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to import external operating system catalog '$($file.FullName)': $($_.Exception.Message)"
                continue
            }
            throw
        }
    }

    $selectedCatalogs = $catalogCandidates |
    Group-Object -Property MajorBuild |
    ForEach-Object {
        $latestBuildVersion = $_.Group |
        Sort-Object -Property BuildVersion -Descending |
        Select-Object -First 1 -ExpandProperty BuildVersion

        $latestCatalogs = @($_.Group | Where-Object { $_.BuildVersion -eq $latestBuildVersion })
        $bundledCatalogs = @($latestCatalogs | Where-Object { -not $_.External })
        if ($bundledCatalogs.Count -gt 0) {
            $bundledCatalogs
        }
        else {
            $latestCatalogs
        }
    } |
    Sort-Object -Property MajorBuild, BuildVersion, @{ Expression = { $_.File.FullName } }

    foreach ($catalog in $selectedCatalogs) {
        $file = $catalog.File
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Importing $($file.FullName)"
        $fileNodes = $catalog.FileNodes

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

            $properties['OSBuild'] = [string]$catalog.MajorBuild
            $properties['OSBuildVersion'] = $catalog.BuildVersion.ToString()

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
        $global:ModuleCoreOperatingSystems = $records
        # return $records
    }
    else {
        # return $mctRecords
        $global:ModuleCoreOperatingSystems = $mctRecords
    }
    $global:ModuleCoreOperatingSystems | Export-Clixml -Path (Join-Path -Path $env:TEMP -ChildPath 'ModuleCoreOperatingSystems.xml') -Force
    # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [INFO] Ready: ModuleCoreOperatingSystems"
}
