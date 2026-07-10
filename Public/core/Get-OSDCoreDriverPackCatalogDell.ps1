function Get-OSDCoreDriverPackCatalogDell {
    <#
    .SYNOPSIS
        Downloads and parses the Dell driver pack catalog for Windows 11.

    .DESCRIPTION
        Retrieves the latest Dell DriverPackCatalog.cab from Dell's download site,
        extracts and parses it to create a catalog of available Windows 11 driver packs.
        If online retrieval fails, the function falls back to the bundled local catalog.

    .PARAMETER LocalDriverPackCatalog
        Path to the local fallback Dell catalog XML file. This file is used when the
        online catalog cannot be downloaded or extracted.

    .PARAMETER OemDriverPackCatalog
        URL to the online Dell DriverPack catalog CAB file.

    .PARAMETER Force
        Forces download and rebuild of the temporary online catalog even when a
        cached temp catalog file already exists.

    .PARAMETER LocalOnly
        Uses only local catalog values and skips online catalog download/extraction.

    .EXAMPLE
        Get-OSDCoreDriverPackCatalogDell

        Retrieves the Dell driver pack catalog for Windows 11.

    .EXAMPLE
        Get-OSDCoreDriverPackCatalogDell -Force

        Forces a fresh online download of the Dell catalog before parsing.

    .EXAMPLE
        Get-OSDCoreDriverPackCatalogDell -LocalDriverPackCatalog 'C:\Catalogs\dell.xml'

        Uses a custom local fallback catalog path.

    .EXAMPLE
        Get-OSDCoreDriverPackCatalogDell -LocalOnly

        Processes only local catalog values without any online download checks.

    .OUTPUTS
        PSCustomObject[]
        Returns custom objects with driver pack information including Name, Model,
        SystemId, URL, ReleaseDate, and other metadata.

    .NOTES
        Catalog is downloaded from https://downloads.dell.com/catalog/DriverPackCatalog.cab
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$LocalDriverPackCatalog = (Join-Path $($MyInvocation.MyCommand.Module.ModuleBase) 'core\driverpacks\dell.xml'),

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$OemDriverPackCatalog = 'https://downloads.dell.com/catalog/DriverPackCatalog.cab',

        [Parameter(Mandatory = $false)]
        [switch]$Force,

        [Parameter(Mandatory = $false)]
        [switch]$LocalOnly
    )

    begin {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
        #=================================================
        # Catalogs
        $tempCatalogPackagePath = "$($env:TEMP)\DriverPackCatalog.cab"
        $tempCatalogPath = "$($env:TEMP)\osdcloud-driverpack-dell.xml"
        #=================================================
        # Build realtime catalog from online source, if fails fallback to offline catalog
        try {
            if ($LocalOnly) {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] LocalOnly requested; skipping online catalog download"
            }
            elseif ($Force -or -not (Test-Path $tempCatalogPath)) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Downloading $OemDriverPackCatalog"
                $null = Invoke-WebRequest -Uri $OemDriverPackCatalog -OutFile $tempCatalogPackagePath -ErrorAction Stop

                if (Test-Path $tempCatalogPackagePath) {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Extracting $tempCatalogPath"
                    # expand.exe is used for CAB extraction as Expand-Archive only supports ZIP
                    $expandResult = & expand.exe $tempCatalogPackagePath $tempCatalogPath 2>&1
                    if ($LASTEXITCODE -ne 0) {
                        Write-Warning "Failed to extract catalog: $expandResult"
                    }
                }
            } else {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Using temp catalog"
            }
        } catch {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to download DriverPack catalog: $($_.Exception.Message)"
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Falling back to local catalog"
        }

        # Load catalog content
        if ($LocalOnly) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Loading $LocalDriverPackCatalog"
            [xml]$XmlCatalogContent = Get-Content -Path $LocalDriverPackCatalog -Raw
        }
        elseif (Test-Path $tempCatalogPath) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Loading $tempCatalogPath"
            [xml]$XmlCatalogContent = Get-Content -Path $tempCatalogPath -Raw
        } else {
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
        $OnlineBaseUri = 'https://downloads.dell.com/'

        #$CatalogVersion = (Get-Date $XmlCatalogContent.DriverPackManifest.version).ToString('yy.MM.dd')
        $RawCatalogVersion = $XmlCatalogContent.DriverPackManifest.version -replace '.00','.01'
        $CatalogVersion = (Get-Date $RawCatalogVersion).ToString('yy.MM.dd')
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Catalog version: $CatalogVersion"

        $DellDriverPackXml = $XmlCatalogContent.DriverPackManifest.DriverPackage

        # Fixed handling null values
        $DellDriverPackXml = $DellDriverPackXml | Where-Object {
            $osCode = $_.SupportedOperatingSystems.OperatingSystem.osCode
            $osCode -and ($osCode.Trim() | Select-Object -Unique) -notmatch 'winpe'
        }
        #=================================================
        # Create Object
        #=================================================
        $Results = foreach ($Item in $DellDriverPackXml) {
            $osCode = $Item.SupportedOperatingSystems.OperatingSystem.osCode.Trim() | Select-Object -Unique
            if ($osCode -match 'Windows11') {
                $OperatingSystem = 'Windows 11'
            } else {
                Continue
            }

            $Name = "Dell $($Item.SupportedSystems.Brand.Model.name | Select-Object -Unique)"
            $Name = $Name -replace '  ',' '
            $Name = $Name -replace 'Dell Dell','Dell'
            $Model = ($Item.SupportedSystems.Brand.Model.name | Select-Object -Unique)

            # DriverPack Version
            $DriverPackVersion = $Item.dellVersion
            if ($DriverPackVersion -eq '*') {
                $DriverPackVersion = $null
            }

            $ReleaseDate = Get-Date $Item.dateTime -Format "yy.MM.dd"

            $ObjectProperties = [Ordered]@{
                CatalogVersion      = $CatalogVersion
                ReleaseDate         = $ReleaseDate
                Name                = "$Name $DriverPackVersion [$ReleaseDate]"
                Manufacturer        = 'Dell'
                Model               = $Model
                SystemId            = [string[]]@($Item.SupportedSystems.Brand.Model.systemID | Select-Object -Unique)
                FileName            = (Split-Path -Leaf $Item.path)
                Url                 = -join ($OnlineBaseUri, $Item.path)
                OperatingSystem     = $OperatingSystem
                OSArchitecture      = 'amd64'
                HashMD5             = $Item.HashMD5
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
        #=================================================
        # Sort Results
        #=================================================
        $Results = $Results | Sort-Object -Property Name
        if ($VerbosePreference -eq 'Continue' -or $DebugPreference -eq 'Continue') {
            $Results | ConvertTo-Json -Depth 10 | Out-File -FilePath "$env:Temp\osdcloud-driverpack-dell.json" -Encoding utf8
        }
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Found $($Results.Count) Windows 11 driver packs"
        $Results
    }

    end {
        #=================================================
        if ($VerbosePreference -eq 'Continue' -or $DebugPreference -eq 'Continue') {
            $Results | ConvertTo-Json -Depth 10 | Out-File -FilePath "$env:Temp\osdcloud-driverpack-dell.json" -Encoding utf8
        }
        if (Test-Path $tempCatalogPackagePath) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Removing temporary CAB file"
            Remove-Item -Path $tempCatalogPackagePath -Force -ErrorAction SilentlyContinue
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
