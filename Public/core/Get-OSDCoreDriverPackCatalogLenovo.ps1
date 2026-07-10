function Get-OSDCoreDriverPackCatalogLenovo {
    <#
    .SYNOPSIS
        Downloads and parses the Lenovo driver pack catalog for Windows 11.

    .DESCRIPTION
        Retrieves the latest Lenovo SCCM driver pack catalog from Lenovo's download site,
        parses the XML to create a catalog of available Windows 11 driver packs.
        Falls back to offline catalog if download fails.

    .PARAMETER LocalDriverPackCatalog
        Path to the local fallback Lenovo catalog XML file.

    .PARAMETER OemDriverPackCatalog
        URL to the online Lenovo driver pack catalog XML file.

    .PARAMETER Force
        Forces download and rebuild of the temporary online catalog even when a
        cached temp catalog file already exists.

    .PARAMETER LocalOnly
        Uses only local catalog values and skips online catalog download.

    .EXAMPLE
        Get-OSDCoreDriverPackCatalogLenovo

        Retrieves the Lenovo driver pack catalog for Windows 11.

    .EXAMPLE
        Get-OSDCoreDriverPackCatalogLenovo -Force

        Forces a fresh online download of the Lenovo catalog before parsing.

    .EXAMPLE
        Get-OSDCoreDriverPackCatalogLenovo -LocalOnly

        Processes only local catalog values without any online download checks.

    .OUTPUTS
        PSCustomObject[]
        Returns custom objects with driver pack information including Name, Model,
        SystemId, URL, ReleaseDate, and other metadata.

    .NOTES
        Catalog is downloaded from https://download.lenovo.com/cdrt/td/catalogv2.xml
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$LocalDriverPackCatalog = (Join-Path $($MyInvocation.MyCommand.Module.ModuleBase) 'core\driverpacks\lenovo.xml'),

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$OemDriverPackCatalog = 'https://download.lenovo.com/cdrt/td/catalogv2.xml',

        [Parameter(Mandatory = $false)]
        [switch]$Force,

        [Parameter(Mandatory = $false)]
        [switch]$LocalOnly
    )

    begin {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
        #=================================================
        # Catalogs
        $tempCatalogPath = "$($env:TEMP)\osdcloud-driverpack-lenovo.xml"
        #=================================================
        # Build realtime catalog from online source, if fails fallback to offline catalog
        try {
            if ($LocalOnly) {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] LocalOnly requested; skipping online catalog download"
            }
            elseif ($Force -or -not (Test-Path $tempCatalogPath)) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Downloading $OemDriverPackCatalog"
                $sourceContent = Invoke-RestMethod -Uri $OemDriverPackCatalog -UseBasicParsing -ErrorAction Stop

                if ($sourceContent) {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Loading $tempCatalogPath"
                    # Remove BOM (Byte Order Mark) from the beginning of the content
                    $catalogContent = $sourceContent.Substring(3)
                    $catalogContent | Out-File -FilePath $tempCatalogPath -Encoding utf8 -Force
                    [xml]$XmlCatalogContent = $catalogContent
                }
            } else {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Using temp catalog"
                if (Test-Path $tempCatalogPath) {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Loading $tempCatalogPath"
                    [xml]$XmlCatalogContent = Get-Content -Path $tempCatalogPath -Raw
                }
            }
        } catch {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to download DriverPack catalog: $($_.Exception.Message)"
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Falling back to local catalog"
        }

        # Load offline catalog if online catalog failed
        if ($LocalOnly) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Loading $LocalDriverPackCatalog"
            [xml]$XmlCatalogContent = Get-Content -Path $LocalDriverPackCatalog -Raw
        }
        elseif (-not $XmlCatalogContent) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Loading $LocalDriverPackCatalog"
            [xml]$XmlCatalogContent = Get-Content -Path $LocalDriverPackCatalog -Raw
        }

        # Validate catalog content
        if (-not $XmlCatalogContent) {
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.Exception]::new("Failed to load catalog content"),
                'CatalogLoadFailed',
                [System.Management.Automation.ErrorCategory]::InvalidData,
                $tempCatalogPath
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }

    process {
        #=================================================
        # Build Catalog
        #=================================================
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Building driver pack catalog"
        $CatalogVersion = Get-Date -Format yy.MM.dd
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Catalog version: $CatalogVersion"

        $ModelList = $XmlCatalogContent.ModelList.Model
        #=================================================
        # Create Object
        #=================================================
        $Results = foreach ($Model in $ModelList) {
            foreach ($Item in $Model.SCCM) {
                $DownloadUrl = $Item.'#text'
                # Release date is in this format: 2022-09-28
                $ReleaseDate = $Item.date
                # Need to convert it to this format: 22.09.28
                $ReleaseDate = Get-Date $ReleaseDate -Format "yy.MM.dd"

                $OSVersion = $Item.version
                if ($OSVersion -eq '*') {
                    $OSVersion = $null
                }

                $HashMD5 = $Item.crc

                if ($Item.os -eq 'win11') {
                    $OperatingSystem = "Windows 11"
                } else {
                    continue
                }

                $NewName = "Lenovo $($Model.name) [$ReleaseDate]"

                $ObjectProperties = [Ordered]@{
                    CatalogVersion  = $CatalogVersion
                    ReleaseDate     = $ReleaseDate
                    Name            = $NewName
                    Manufacturer    = 'Lenovo'
                    Model           = $Model.name
                    SystemId        = $Model.Types.Type.split(',').ForEach({$_.Trim()})
                    FileName        = $DownloadUrl | Split-Path -Leaf
                    Url             = $DownloadUrl
                    OperatingSystem = $OperatingSystem
                    OSArchitecture  = 'amd64'
                    OSVersion       = $OSVersion
                    HashMD5         = $HashMD5
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
        }
        #=================================================
        # Cleanup Catalog
        #=================================================
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Filtering to latest driver packs per model"
        $Results = $Results | Sort-Object Model, OSVersion -Descending | Group-Object Model | ForEach-Object {$_.Group | Select-Object -First 1}
        # $Results = $Results | Sort-Object Model, OSVersion -Descending | Group-Object HashMD5 | ForEach-Object {$_.Group | Select-Object -First 1}
        #=================================================
        # Sort Results
        #=================================================
        $Results = $Results | Sort-Object Model, OSVersion -Descending
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Found $($Results.Count) Windows 11 driver packs"
        $Results
    }

    end {
        #=================================================
        if ($VerbosePreference -eq 'Continue' -or $DebugPreference -eq 'Continue') {
            $Results | ConvertTo-Json -Depth 10 | Out-File -FilePath "$env:Temp\osdcloud-driverpack-lenovo.json" -Encoding utf8
        }
        if (Test-Path $tempCatalogPath) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Removing temporary catalog file"
            Remove-Item -Path $tempCatalogPath -Force -ErrorAction SilentlyContinue
        }
        #=================================================
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
        #=================================================
    }
}
