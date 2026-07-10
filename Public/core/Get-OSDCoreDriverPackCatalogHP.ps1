function Get-OSDCoreDriverPackCatalogHP {
    <#
    .SYNOPSIS
        Downloads and parses the HP driver pack catalog for Windows 11.

    .DESCRIPTION
        Retrieves the latest HP Client Driver Pack Catalog from HP's cloud repository,
        extracts and parses it to create a catalog of available Windows 11 driver packs.
        Falls back to offline catalog if download fails.

    .PARAMETER LocalDriverPackCatalog
        Path to the local fallback HP catalog XML file.

    .PARAMETER OemDriverPackCatalog
        URL to the online HP driver pack catalog CAB file.

    .PARAMETER Force
        Forces download and rebuild of the temporary online catalog even when a
        cached temp catalog file already exists.

    .PARAMETER LocalOnly
        Uses only local catalog values and skips online catalog download/extraction.

    .EXAMPLE
        Get-OSDCoreDriverPackCatalogHP

        Retrieves the HP driver pack catalog for Windows 11.

    .EXAMPLE
        Get-OSDCoreDriverPackCatalogHP -Force

        Forces a refresh of the HP driver pack catalog by downloading the latest version
        from HP's server, bypassing any cached copies.

    .EXAMPLE
        Get-OSDCoreDriverPackCatalogHP -LocalOnly

        Processes only local catalog values without any online download checks.

    .OUTPUTS
        PSCustomObject[]
        Returns custom objects with driver pack information including Name, Model,
        SystemId, URL, ReleaseDate, and other metadata.

    .NOTES
        Catalog is downloaded from https://hpia.hpcloud.hp.com/downloads/driverpackcatalog/HPClientDriverPackCatalog.cab
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$LocalDriverPackCatalog = (Join-Path $($MyInvocation.MyCommand.Module.ModuleBase) 'core\driverpacks\hp.xml'),

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$OemDriverPackCatalog = 'https://hpia.hpcloud.hp.com/downloads/driverpackcatalog/HPClientDriverPackCatalog.cab',

        [Parameter(Mandatory = $false)]
        [switch]$Force,

        [Parameter(Mandatory = $false)]
        [switch]$LocalOnly
    )

    begin {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
        #=================================================
        # Catalogs
        $tempCatalogPackagePath = "$($env:TEMP)\HPClientDriverPackCatalog.cab"
        $tempCatalogPath = "$($env:TEMP)\osdcloud-driverpack-hp.xml"
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
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Validating $tempCatalogPackagePath"
                    # Use list mode for CAB validation to avoid destination warnings.
                    $cabTest = try { & expand.exe -D $tempCatalogPackagePath 2>&1 } catch { $null }
                    if ($LASTEXITCODE -ne 0) {
                        Write-Warning "CAB file validation failed: $cabTest"
                        Remove-Item -Path $tempCatalogPackagePath -Force -ErrorAction SilentlyContinue
                    }
                }

                if (Test-Path $tempCatalogPackagePath) {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Extracting $tempCatalogPath"
                    # expand.exe is used for CAB extraction as Expand-Archive only supports ZIP
                    $expandResult = & expand.exe $tempCatalogPackagePath $tempCatalogPath 2>&1
                    if ($LASTEXITCODE -ne 0) {
                        Write-Warning "Failed to extract catalog: $expandResult"
                        Remove-Item -Path $tempCatalogPackagePath -Force -ErrorAction SilentlyContinue
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

        # Extract catalog version from DateReleased attribute of root element
        $HpCatalogRoot = $XmlCatalogContent.NewDataSet.HPClientDriverPackCatalog
        if ($HpCatalogRoot -and $HpCatalogRoot.DateReleased) {
            # DateReleased is in format: 2026-06-11
            $dtDateReleased = [datetime]::ParseExact($HpCatalogRoot.DateReleased, 'yyyy-MM-dd', $null)
            $CatalogVersion = $dtDateReleased.ToString('yy.MM.dd')
        } else {
            # Fallback to current date if DateReleased is not available
            $CatalogVersion = Get-Date -Format yy.MM.dd
        }
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Catalog version: $CatalogVersion"

        $HpSoftPaqList = $XmlCatalogContent.NewDataSet.HPClientDriverPackCatalog.SoftPaqList.SoftPaq
        $HpModelList = $XmlCatalogContent.NewDataSet.HPClientDriverPackCatalog.ProductOSDriverPackList.ProductOSDriverPack
        $HpModelList = $HpModelList | Where-Object {$_.OSId -ge '4317'}
        #=================================================
        # Create Object
        #=================================================
        $Results = foreach ($Item in $HpModelList) {
            $HpSoftPaq = $null
            $HpSoftPaq = $HpSoftPaqList | Where-Object {$_.Id -eq $Item.SoftPaqId}

            if ($null -eq $HpSoftPaq) {
                Continue
            }
            $OperatingSystem = 'Windows 11'

            $OSVersion = $Item.OSName
            $OSVersion = $OSVersion.Substring($OSVersion.Length - 4)

            $template = "M/d/yyyy hh:mm:ss tt"
            $timeinfo = $HpSoftPaq.DateReleased
            $dtReleaseDate = [datetime]::ParseExact($timeinfo, $template, $null)
            $ReleaseDate = $dtReleaseDate.ToString("yy.MM.dd")

            # Handle null SystemId
            $SystemIds = if ($Item.SystemId) {
                $Item.SystemId.split(',').ForEach({$_.Trim()})
            } else {
                @()
            }

            $ObjectProperties = [Ordered]@{
                CatalogVersion  = $CatalogVersion
                ReleaseDate     = $ReleaseDate
                Name            = "$($Item.SystemName) $($Item.SoftPaqId) [$ReleaseDate]"
                Manufacturer    = 'HP'
                Model           = $Item.SystemName
                SystemId        = [string[]]$SystemIds
                FileName        = $HpSoftPaq.Url | Split-Path -Leaf
                Url             = $HpSoftPaq.Url
                OperatingSystem = 'Windows 11'
                OSArchitecture  = 'amd64'
                OSVersion       = $OSVersion
                HashMD5         = $HpSoftPaq.MD5
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
        #=================================================
        # Cleanup Catalog
        #=================================================
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Filtering to latest driver packs per model"
        $Results = $Results | Sort-Object Model, OSVersion -Descending | Group-Object Model | ForEach-Object {$_.Group | Select-Object -First 1}
        #=================================================
        # Sort Results
        #=================================================
        $Results = $Results | Sort-Object -Property Name
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Found $($Results.Count) Windows 11 driver packs"
        $Results
    }

    end {
        #=================================================
        if ($VerbosePreference -eq 'Continue' -or $DebugPreference -eq 'Continue') {
            $Results | ConvertTo-Json -Depth 10 | Out-File -FilePath "$env:Temp\osdcloud-driverpack-hp.json" -Encoding utf8
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
