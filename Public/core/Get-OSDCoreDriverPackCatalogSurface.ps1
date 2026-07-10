function Get-OSDCoreDriverPackCatalogSurface {
    <#
    .SYNOPSIS
        Retrieves the Microsoft Surface driver pack catalog, enriching entries from live download pages.

    .DESCRIPTION
        Loads the bundled surface.json catalog as the offline base. For entries that include an
        UpdatePage URL, the function scrapes the corresponding Microsoft download page to find the
        newest available MSI and updates FileName, Url, and ReleaseDate accordingly.
        Results are cached in $env:TEMP so subsequent calls within the same session skip network
        requests. Falls back to base JSON values when a page cannot be reached.

    .PARAMETER LocalDriverPackCatalog
        Path to the local fallback Surface catalog JSON file.

    .PARAMETER Force
        Forces bypass of the temp cache and rebuilds the enriched catalog from the
        local Surface catalog.

    .PARAMETER LocalOnly
        Uses only local catalog values and skips connectivity probing and all live
        UpdatePage checks.

    .EXAMPLE
        Get-OSDCoreDriverPackCatalogSurface

        Returns all Surface driver pack entries, with live URLs where available.

    .EXAMPLE
        Get-OSDCoreDriverPackCatalogSurface -Verbose

        Returns all Surface driver pack entries with verbose progress output.

    .EXAMPLE
        Get-OSDCoreDriverPackCatalogSurface -Force

        Bypasses the temp cache and rebuilds the enriched catalog.

    .EXAMPLE
        Get-OSDCoreDriverPackCatalogSurface -LocalOnly

        Processes only local catalog values without any live network checks.

    .OUTPUTS
        PSCustomObject[]
        Objects with CatalogVersion, ReleaseDate, Name, Manufacturer, Model, SystemId, FileName,
        Url, OperatingSystem, OSArchitecture, and HashMD5 properties.

    .NOTES
        Base catalog: core/driverpacks/surface.json (bundled with the module)
        Temp cache:   $env:TEMP\osdcloud-driverpack-surface.json
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$LocalDriverPackCatalog = (Join-Path $($MyInvocation.MyCommand.Module.ModuleBase) 'core\driverpacks\surface.json'),

        [Parameter(Mandatory = $false)]
        [switch]$Force,

        [Parameter(Mandatory = $false)]
        [switch]$LocalOnly
    )

    begin {
        $Error.Clear()
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
        #=================================================
        # Paths
        $tempCatalogPath  = "$env:TEMP\osdcloud-driverpack-surface.json"
        #=================================================
        # Load from temp cache if available
        $useCache = $false
        if ((-not $Force) -and (Test-Path $tempCatalogPath)) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Loading $tempCatalogPath"
            $JsonCatalogContent = Get-Content -Path $tempCatalogPath -Raw -Encoding UTF8 | ConvertFrom-Json
            $useCache = $true
        }
        else {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Loading $LocalDriverPackCatalog"
            $JsonCatalogContent = Get-Content -Path $LocalDriverPackCatalog -Raw -Encoding UTF8 | ConvertFrom-Json
        }

        if (-not $JsonCatalogContent) {
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.Exception]::new("Failed to load Surface driver pack catalog"),
                'CatalogLoadFailed',
                [System.Management.Automation.ErrorCategory]::InvalidData,
                $LocalDriverPackCatalog
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }

    process {
        #=================================================
        # Return cached results immediately
        #=================================================
        if ($useCache) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Returning $($JsonCatalogContent.Count) entries from cache"
            $JsonCatalogContent
            return
        }

        #=================================================
        # Build enriched catalog from base JSON
        #=================================================
        $processStopwatch  = [System.Diagnostics.Stopwatch]::StartNew()
        $CatalogVersion    = Get-Date -Format yy.MM.dd
        $userAgent         = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36'
        $msiPattern        = 'https://download\.microsoft\.com/download/[^"''<>\s]+\.msi'
        $datePattern       = 'Date Published[^:]*:[^\d]*(\d{1,2}/\d{1,2}/\d{4})'
        $parallelThrottle  = 4
        $updatePageCache   = @{}
        $urlReachabilityCache = @{}
        $networkCalls      = 0
        $fallbackCalls     = 0
        $cacheHits         = 0
        $reachabilityChecks = 0
        $reachabilityMisses = 0
        $isOnline          = $true
        $skipLiveUpdates   = [bool]$LocalOnly

        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Building Surface driver pack catalog (CatalogVersion: $CatalogVersion)"

        # If a device OSDProduct is known, limit live UpdatePage checks to the matching entry only
        $osdProduct = if ($global:OSDCoreDevice -and $global:OSDCoreDevice.OSDProduct) { $global:OSDCoreDevice.OSDProduct } else { $null }
        $escapedOsdProduct = if ($osdProduct) { [regex]::Escape($osdProduct) } else { $null }
        if ($osdProduct) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] OSDProduct filter active: only fetching live data for SystemId matching '$osdProduct'"
        }

        # Determine online/offline state from the first catalog URL that does not require UpdatePage scraping.
        $connectivityProbeUrl = (
            $JsonCatalogContent |
                Where-Object { $_.Url -and (-not $_.UpdatePage) } |
                Select-Object -First 1
        ).Url

        if ($LocalOnly) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] LocalOnly requested; skipping connectivity probe and live updates"
        }
        elseif ($connectivityProbeUrl) {
            try {
                $probe = Invoke-WebRequest -Uri $connectivityProbeUrl -Method Head -UseBasicParsing -UserAgent $userAgent -MaximumRedirection 5 -TimeoutSec 10 -ErrorAction Stop
                $isOnline = ($probe.StatusCode -ge 200 -and $probe.StatusCode -lt 400)
            }
            catch {
                try {
                    $probe = Invoke-WebRequest -Uri $connectivityProbeUrl -Method Get -UseBasicParsing -UserAgent $userAgent -MaximumRedirection 5 -TimeoutSec 10 -ErrorAction Stop
                    $isOnline = ($probe.StatusCode -ge 200 -and $probe.StatusCode -lt 400)
                }
                catch {
                    $isOnline = $false
                }
            }
        }

        if (-not $isOnline) {
            $skipLiveUpdates = $true
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Offline detected from connectivity probe; skipping all live updates and using local catalog values"
        }

        # Probe existing target URLs first; only scrape UpdatePage when the current URL is unreachable.
        $uniqueUpdatePages = @()
        if (-not $skipLiveUpdates) {
            $targetItems = @(
                $JsonCatalogContent | Where-Object {
                    $_.UpdatePage -and ((-not $escapedOsdProduct) -or ($_.SystemId -match $escapedOsdProduct))
                }
            )
            $itemsNeedingUpdate = @(
                foreach ($item in $targetItems) {
                    $targetUrl = $item.Url
                    $isReachable = $false

                    if (-not [string]::IsNullOrWhiteSpace($targetUrl)) {
                        if ($urlReachabilityCache.ContainsKey($targetUrl)) {
                            $isReachable = [bool]$urlReachabilityCache[$targetUrl]
                        }
                        else {
                            $reachabilityChecks++
                            try {
                                $probe = Invoke-WebRequest -Uri $targetUrl -Method Head -UseBasicParsing -UserAgent $userAgent -MaximumRedirection 5 -TimeoutSec 10 -ErrorAction Stop
                                $isReachable = ($probe.StatusCode -ge 200 -and $probe.StatusCode -lt 400)
                            }
                            catch {
                                try {
                                    $probe = Invoke-WebRequest -Uri $targetUrl -Method Get -UseBasicParsing -UserAgent $userAgent -MaximumRedirection 5 -TimeoutSec 10 -ErrorAction Stop
                                    $isReachable = ($probe.StatusCode -ge 200 -and $probe.StatusCode -lt 400)
                                }
                                catch {
                                    $isReachable = $false
                                }
                            }

                            $urlReachabilityCache[$targetUrl] = $isReachable
                        }
                    }

                    if (-not $isReachable) {
                        $reachabilityMisses++
                        $item
                    }
                }
            )

            $uniqueUpdatePages = @($itemsNeedingUpdate.UpdatePage | Sort-Object -Unique)
        }

        if ($uniqueUpdatePages.Count -gt 0) {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Resolving $($uniqueUpdatePages.Count) unique UpdatePage URLs"

            if ($PSVersionTable.PSVersion.Major -ge 7) {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Using parallel UpdatePage resolution (ThrottleLimit: $parallelThrottle)"
                $resolvedPages = $uniqueUpdatePages | ForEach-Object -Parallel {
                    $updatePage = $_
                    $result = [ordered]@{
                        UpdatePage   = $updatePage
                        Error        = $null
                        FileName     = $null
                        Url          = $null
                        ReleaseDate  = $null
                        UsedFallback = $false
                    }

                    try {
                        $response = Invoke-WebRequest -Uri $updatePage -UseBasicParsing -UserAgent $using:userAgent -MaximumRedirection 5 -ErrorAction Stop
                        $html = $response.Content

                        $allMsi = @(
                            [regex]::Matches($html, $using:msiPattern) |
                                ForEach-Object { $_.Value } |
                                Select-Object -Unique
                        )

                        if ($allMsi.Count -eq 0 -and $updatePage -match '[?&]id=(\d+)') {
                            $confirmUri = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=$($Matches[1])"
                            $result.UsedFallback = $true
                            $response = Invoke-WebRequest -Uri $confirmUri -UseBasicParsing -UserAgent $using:userAgent -MaximumRedirection 5 -ErrorAction Stop
                            $html = $response.Content
                            $allMsi = @(
                                [regex]::Matches($html, $using:msiPattern) |
                                    ForEach-Object { $_.Value } |
                                    Select-Object -Unique
                            )
                        }

                        if ($allMsi.Count -gt 0) {
                            $win11Uris = @($allMsi | Where-Object { $_ -match 'Win11' })
                            $candidates = if ($win11Uris.Count -gt 0) { $win11Uris } else { $allMsi }
                            $bestUri = $candidates |
                                Sort-Object {
                                    if ($_ -match '_(\d{5})_') { [int]$Matches[1] } else { 0 }
                                } -Descending |
                                Select-Object -First 1

                            $newDate = $null
                            $now = [datetime]::UtcNow
                            foreach ($m in [regex]::Matches($html, $using:datePattern)) {
                                try {
                                    $parsed = [datetime]::ParseExact($m.Groups[1].Value, 'M/d/yyyy', $null)
                                    if ($parsed.Year -ge 2015 -and $parsed -le $now.AddMonths(3)) {
                                        $newDate = $parsed.ToString('yy.MM.dd')
                                        break
                                    }
                                }
                                catch { }
                            }

                            $result.FileName = $bestUri -replace '.+/', ''
                            $result.Url = $bestUri
                            $result.ReleaseDate = $newDate
                        }
                        else {
                            $result.Error = 'No MSI links found'
                        }
                    }
                    catch {
                        $result.Error = $_.Exception.Message
                    }

                    [PSCustomObject]$result
                } -ThrottleLimit $parallelThrottle

                foreach ($resolved in $resolvedPages) {
                    if (-not $resolved) { continue }
                    $networkCalls++
                    if ($resolved.UsedFallback) { $fallbackCalls++ }
                    $updatePageCache[$resolved.UpdatePage] = @{
                        Error       = $resolved.Error
                        FileName    = $resolved.FileName
                        Url         = $resolved.Url
                        ReleaseDate = $resolved.ReleaseDate
                    }
                }
            }
            else {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] PowerShell < 7 detected, using sequential UpdatePage resolution"
                foreach ($updatePage in $uniqueUpdatePages) {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Downloading $updatePage"
                    $networkCalls++
                    try {
                        $response = Invoke-WebRequest -Uri $updatePage -UseBasicParsing -UserAgent $userAgent -MaximumRedirection 5 -ErrorAction Stop
                        $html     = $response.Content

                        $allMsi = @(
                            [regex]::Matches($html, $msiPattern) |
                                ForEach-Object { $_.Value } |
                                Select-Object -Unique
                        )

                        if ($allMsi.Count -eq 0 -and $updatePage -match '[?&]id=(\d+)') {
                            $confirmUri = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=$($Matches[1])"
                            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Downloading $confirmUri"
                            $fallbackCalls++
                            $networkCalls++
                            $response = Invoke-WebRequest -Uri $confirmUri -UseBasicParsing -UserAgent $userAgent -MaximumRedirection 5 -ErrorAction Stop
                            $html     = $response.Content
                            $allMsi   = @(
                                [regex]::Matches($html, $msiPattern) |
                                    ForEach-Object { $_.Value } |
                                    Select-Object -Unique
                            )
                        }

                        if ($allMsi.Count -gt 0) {
                            $win11Uris = @($allMsi | Where-Object { $_ -match 'Win11' })
                            $candidates = if ($win11Uris.Count -gt 0) { $win11Uris } else { $allMsi }
                            $bestUri = $candidates |
                                Sort-Object {
                                    if ($_ -match '_(\d{5})_') { [int]$Matches[1] } else { 0 }
                                } -Descending |
                                Select-Object -First 1

                            $newDate = $null
                            $now     = [datetime]::UtcNow
                            foreach ($m in [regex]::Matches($html, $datePattern)) {
                                try {
                                    $parsed = [datetime]::ParseExact($m.Groups[1].Value, 'M/d/yyyy', $null)
                                    if ($parsed.Year -ge 2015 -and $parsed -le $now.AddMonths(3)) {
                                        $newDate = $parsed.ToString('yy.MM.dd')
                                        break
                                    }
                                }
                                catch { }
                            }

                            $updatePageCache[$updatePage] = @{
                                Error       = $null
                                FileName    = ($bestUri -replace '.+/', '')
                                Url         = $bestUri
                                ReleaseDate = $newDate
                            }
                        }
                        else {
                            $updatePageCache[$updatePage] = @{ Error = 'No MSI links found' }
                        }
                    }
                    catch {
                        $updatePageCache[$updatePage] = @{ Error = $_.Exception.Message }
                    }
                }
            }
        }

        $Results = foreach ($item in $JsonCatalogContent) {
            $releaseDate = $item.ReleaseDate
            $fileName    = $item.FileName
            $url         = $item.Url

            $isTargetDevice = (-not $escapedOsdProduct) -or ($item.SystemId -match $escapedOsdProduct)

            if ($item.UpdatePage -and $isTargetDevice) {
                $updatePage = $item.UpdatePage

                if ($updatePageCache.ContainsKey($updatePage)) {
                    $cacheHits++
                    $cached = $updatePageCache[$updatePage]
                    if (-not $cached.Error) {
                        $fileName    = $cached.FileName
                        $url         = $cached.Url
                        if ($cached.ReleaseDate) {
                            $releaseDate = $cached.ReleaseDate
                        }
                    }
                    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Cache hit for $($item.Model) -> $fileName"
                }
                else {
                    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] No pre-resolved cache entry for $($item.Model), using base values"
                }
            }

            # Rebuild the Name bracket date with current releaseDate
            $baseName    = $item.Name -replace '\s*\[.*?\]$', ''
            $displayName = "$baseName [$releaseDate]"

            $objectProperties = [Ordered]@{
                CatalogVersion  = $CatalogVersion
                ReleaseDate     = $releaseDate
                Name            = $displayName
                Manufacturer    = $item.Manufacturer
                Model           = $item.Model
                SystemId        = $item.SystemId
                FileName        = $fileName
                Url             = $url
                OperatingSystem = $item.OperatingSystem
                OSArchitecture  = $item.OSArchitecture
                HashMD5         = $item.HashMD5
                UpdatePage      = $item.UpdatePage
            }
            [PSCustomObject]$objectProperties
        }

        #=================================================
        # Save enriched results to temp cache
        #=================================================
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Saving $($Results.Count) entries to $tempCatalogPath"
        $Results | ConvertTo-Json -Depth 10 | Out-File -FilePath $tempCatalogPath -Encoding utf8 -Force

        $processStopwatch.Stop()
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Performance: ReachabilityChecks=$reachabilityChecks, ReachabilityMisses=$reachabilityMisses, UpdatePages=$($uniqueUpdatePages.Count), CacheHits=$cacheHits, NetworkCalls=$networkCalls, FallbackCalls=$fallbackCalls, ElapsedMs=$($processStopwatch.ElapsedMilliseconds)"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Found $($Results.Count) Surface driver packs"
        $Results
    }

    end {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    }
}
