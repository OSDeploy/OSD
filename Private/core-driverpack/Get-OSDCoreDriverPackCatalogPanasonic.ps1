function Get-OSDCoreDriverPackCatalogPanasonic {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$LocalDriverPackCatalog = (Join-Path $($MyInvocation.MyCommand.Module.ModuleBase) 'core\driverpacks\panasonic.json'),

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$OemDriverPackCatalog = 'https://pna-b2b-storage-mkt.s3.amazonaws.com/computer/software/apps/Panasonic.json',

        [Parameter(Mandatory = $false)]
        [switch]$Force,

        [Parameter(Mandatory = $false)]
        [switch]$LocalOnly
    )

    begin {
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
        #=================================================
        # Catalogs
        $tempCatalogPath = "$($env:TEMP)\osdcloud-driverpack-panasonic.json"
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
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Indexing $tempCatalogPath"
                    $sourceContent | Out-File -FilePath $tempCatalogPath -Encoding utf8 -Force
                    $JsonCatalogContent = $sourceContent
                }
            } else {
                Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Using temp Panasonic driver pack catalog"
                if (Test-Path $tempCatalogPath) {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Indexing $tempCatalogPath"
                    $JsonCatalogContent = Get-Content -Path $tempCatalogPath -Raw | ConvertFrom-Json
                }
            }
        } catch {
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to download Panasonic driver pack catalog: $($_.Exception.Message)"
            Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Falling back to local catalog"
        }

        # Load offline catalog if online catalog failed
        if ($LocalOnly) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Indexing $LocalDriverPackCatalog"
            $JsonCatalogContent = Get-Content -Path $LocalDriverPackCatalog -Raw | ConvertFrom-Json
        }
        elseif (-not $JsonCatalogContent) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Indexing $LocalDriverPackCatalog"
            $JsonCatalogContent = Get-Content -Path $LocalDriverPackCatalog -Raw | ConvertFrom-Json
        }

        # Validate catalog content
        if (-not $JsonCatalogContent) {
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
        $CatalogVersion = Get-Date $JsonCatalogContent.LastDateModified -Format "yy.MM.dd"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Catalog version: $CatalogVersion"

        $ModelList = $JsonCatalogContent.Models
        #=================================================
        # Create Object
        #=================================================
        $Results = foreach ($Model in $ModelList) {

            $ModelName = $Model.Alias
            $SystemId = $Model.Product

            foreach ($Item in $Model.DriverPacks) {
                if ($Item.OSVer -eq 'Win10') { continue }

                $DownloadUrl = $Item.URL
                $ReleaseDate = $Item.ReleaseDate
                $ReleaseDate = Get-Date $ReleaseDate -Format "yy.MM.dd"

                $HashMD5 = $Item.Hash
                $NewName = "Panasonic $ModelName [$ReleaseDate]"

                $ObjectProperties = [Ordered]@{
                    CatalogVersion  = $CatalogVersion
                    ReleaseDate     = $ReleaseDate
                    Name            = $NewName
                    Manufacturer    = 'Panasonic'
                    Model           = $ModelName
                    SystemId        = $SystemId
                    FileName        = $DownloadUrl | Split-Path -Leaf
                    Url             = $DownloadUrl
                    OperatingSystem = 'Windows 11'
                    OSArchitecture  = 'amd64'
                    OSVersion       = $Item.OSRelease
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
        $Results = $Results | Sort-Object Model, OSVersion -Descending | Group-Object HashMD5 | ForEach-Object {$_.Group | Select-Object -First 1}
        #=================================================
        # Sort Results
        #=================================================
        $Results = $Results | Sort-Object Model
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Found $($Results.Count) Windows 11 driver packs"
        $Results
    }

    end {
        #=================================================
        if ($VerbosePreference -eq 'Continue' -or $DebugPreference -eq 'Continue') {
            $Results | ConvertTo-Json -Depth 10 | Out-File -FilePath "$env:Temp\osdcloud-driverpack-panasonic.json" -Encoding utf8
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
