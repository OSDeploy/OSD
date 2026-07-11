function Get-SystemFirmwareUpdate {
    <#
    .SYNOPSIS
    Retrieves the latest system firmware update from Microsoft Update Catalog

    .DESCRIPTION
    Searches Microsoft Update Catalog directly for the latest system firmware
    update available for the current computer firmware resource GUID.

    .EXAMPLE
    Get-SystemFirmwareUpdate
    Returns the latest available firmware update

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help
    2026-07-11 - Removed Get-MSCatalogUpdate dependency and added direct catalog query
    #>
    [CmdLetBinding()]
    param()

    $SystemFirmwareResources = @(Get-SystemFirmwareResource | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)

    if (-not $SystemFirmwareResources) {
        Write-Host -ForegroundColor DarkGray "Get-SystemFirmwareUpdate: Could not find a UEFI Firmware HardwareID"
        return
    }

    if (Test-MicrosoftUpdateCatalog) {
        $CatalogResults = @()

        foreach ($SystemFirmwareResource in $SystemFirmwareResources) {
            $SearchTerms = @(
                $SystemFirmwareResource,
                $SystemFirmwareResource.Trim('{','}')
            ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

            foreach ($SearchTerm in $SearchTerms) {
                try {
                    $EncodedSearch = [uri]::EscapeDataString($SearchTerm)
                    $Uri = "https://www.catalog.update.microsoft.com/Search.aspx?q=$EncodedSearch"

                    $CurrentWarningPreference = $WarningPreference
                    $WarningPreference = 'SilentlyContinue'
                    try {
                        $Response = Invoke-CatalogRequest -Uri $Uri
                    }
                    finally {
                        $WarningPreference = $CurrentWarningPreference
                    }

                    if ($null -eq $Response -or $null -eq $Response.Rows) {
                        continue
                    }

                    foreach ($Row in $Response.Rows) {
                        if ($Row.Id -eq 'headerRow') {
                            continue
                        }

                        try {
                            $Update = [MsUpCat]::new($Row, $false)
                        }
                        catch {
                            continue
                        }

                        if ([string]::IsNullOrWhiteSpace($Update.Guid) -or [string]::IsNullOrWhiteSpace($Update.Title)) {
                            continue
                        }

                        if (
                            ($Update.Title -match '(?i)firmware') -or
                            ($Update.Classification -match '(?i)firmware') -or
                            ($Update.Classification -match '(?i)^drivers?$')
                        ) {
                            $CatalogResults += $Update
                        }
                    }
                }
                catch {
                    Write-Verbose "Get-SystemFirmwareUpdate: Failed catalog query for $SearchTerm. $_"
                }
            }
        }

        if ($CatalogResults) {
            $CatalogResults |
                Sort-Object LastUpdated -Descending |
                Select-Object LastUpdated,Title,Version,Size,Guid -First 1
            return
        }

        Write-Host -ForegroundColor DarkGray "Get-SystemFirmwareUpdate: Could not find a UEFI Firmware update for this HardwareID"
    }
    else {
        Write-Host -ForegroundColor DarkGray "Get-SystemFirmwareUpdate: Could not reach https://www.catalog.update.microsoft.com/"
    }
    #=================================================
}
function Save-SystemFirmwareUpdate {
    <#
    .SYNOPSIS
    Downloads and extracts the latest system firmware update.

    .DESCRIPTION
    Finds the latest applicable system firmware update from Microsoft Update
    Catalog, downloads the package, and extracts its contents to a destination
    directory.

    .PARAMETER DestinationDirectory
    Directory where the firmware update package will be downloaded and extracted.

    .EXAMPLE
    Save-SystemFirmwareUpdate
    Downloads and extracts the latest firmware update to the default temp path.

    .EXAMPLE
    Save-SystemFirmwareUpdate -DestinationDirectory C:\Drivers\SystemFirmware
    Downloads and extracts the latest firmware update to C:\Drivers\SystemFirmware.

    .OUTPUTS
    PSCustomObject. Returns details about the selected update, extraction path, and discovered INF files.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-11 - Improved status output and error handling
    2026-07-11 - Return structured save result and validate extraction exit code
    #>
    [CmdLetBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]$DestinationDirectory = "$env:TEMP\SystemFirmwareUpdate"
    )

    try {
        if (-not (Test-MicrosoftUpdateCatalog)) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Could not reach https://www.catalog.update.microsoft.com/"
            return
        }

        $SystemFirmwareUpdate = Get-SystemFirmwareUpdate

        if (-not $SystemFirmwareUpdate -or [string]::IsNullOrWhiteSpace($SystemFirmwareUpdate.Guid)) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Could not find a UEFI Firmware update for this HardwareID"
            return
        }

        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Selected update: $($SystemFirmwareUpdate.Title)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Version: $($SystemFirmwareUpdate.Version) | Size: $($SystemFirmwareUpdate.Size) | Last Updated: $($SystemFirmwareUpdate.LastUpdated)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] UpdateID: $($SystemFirmwareUpdate.Guid)"

        $ExtractDirectory = Join-Path -Path $DestinationDirectory -ChildPath ($SystemFirmwareUpdate.Guid.Trim('{','}'))

        if (-not (Test-Path $ExtractDirectory -PathType Container)) {
            New-Item -Path $ExtractDirectory -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }

        try {
            $SystemFirmwareUpdateFile = Save-UpdateCatalog -Guid $SystemFirmwareUpdate.Guid -DestinationDirectory $ExtractDirectory -ErrorAction Stop
        }
        catch {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to download update package: $($_.Exception.Message)"
            return
        }

        if (-not $SystemFirmwareUpdateFile -or -not (Test-Path $SystemFirmwareUpdateFile.FullName)) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Download did not produce a valid update package"
            return
        }

        try {
            & expand.exe "$($SystemFirmwareUpdateFile.FullName)" -F:* "$ExtractDirectory" | Out-Null

            if ($LASTEXITCODE -ne 0) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] expand.exe failed with exit code $LASTEXITCODE"
                return
            }
        }
        catch {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to extract update package: $($_.Exception.Message)"
            return
        }

        try {
            Remove-Item $SystemFirmwareUpdateFile.FullName -ErrorAction Stop
        }
        catch {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Failed to remove temporary package: $($_.Exception.Message)"
        }

        $InfFiles = @(Get-ChildItem -Path $ExtractDirectory -Recurse -Filter '*.inf' -ErrorAction SilentlyContinue)
        if ($InfFiles) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Saved and extracted firmware update to $ExtractDirectory (INF files: $($InfFiles.Count))"
        }
        else {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Saved and extracted firmware update to $ExtractDirectory"
        }

        [PSCustomObject]@{
            Update               = $SystemFirmwareUpdate
            DestinationDirectory = $DestinationDirectory
            ExtractDirectory     = $ExtractDirectory
            InfFiles             = $InfFiles
        }
    }
    catch {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unexpected error: $($_.Exception.Message)"
    }
    #=================================================
}
function Install-SystemFirmwareUpdate {
    <#
    .SYNOPSIS
    Downloads and installs the system firmware update

    .DESCRIPTION
    Downloads the latest system firmware update from Microsoft Update Catalog and installs it on the running system. Requires admin rights and PowerShell 5.1.

    .PARAMETER DestinationDirectory
    Directory where the firmware update will be downloaded. Default is C:\Drivers\SystemFirmwareUpdate

    .EXAMPLE
    Install-SystemFirmwareUpdate
    Downloads and installs the latest firmware update

    .EXAMPLE
    Install-SystemFirmwareUpdate -DestinationDirectory 'D:\Updates'
    Downloads firmware update to D:\Updates and installs it

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-10 - Added comment-based help
    2026-07-11 - Refactored to use Save-SystemFirmwareUpdate and improved install error handling
    #>
    [CmdLetBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $DestinationDirectory = "C:\Drivers\SystemFirmwareUpdate"
    )

    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new($CurrentIdentity)
    if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Administrative rights are required to run this function"
        return
    }

    if (-not (Test-Path 'C:\Windows' -PathType Container)) {
        Write-Host -ForegroundColor DarkGray "Install-SystemFirmwareUpdate: Could not locate C:\Windows"
        if ($env:SystemDrive -eq 'X:') {
            Write-Host -ForegroundColor DarkGray "Make sure that Bitlocker encrypted drives are unlocked and suspended first"
        }
        return
    }

    if (-not $PSCmdlet.ShouldProcess($DestinationDirectory, 'Download and install latest system firmware update')) {
        return
    }

    $SaveResult = $null
    try {
        $SaveResult = Save-SystemFirmwareUpdate -DestinationDirectory $DestinationDirectory
    }
    catch {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed while saving firmware update: $($_.Exception.Message)"
        return
    }

    if (-not $SaveResult -or [string]::IsNullOrWhiteSpace($SaveResult.ExtractDirectory)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Save-SystemFirmwareUpdate did not return an extraction path"
        return
    }

    $InstallDirectory = $SaveResult.ExtractDirectory
    if (-not (Test-Path $InstallDirectory -PathType Container)) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Could not locate extraction directory $InstallDirectory"
        return
    }

    $InfFiles = @($SaveResult.InfFiles)
    if (-not $InfFiles) {
        $InfFiles = @(Get-ChildItem -Path $InstallDirectory -Recurse -Filter '*.inf' -ErrorAction SilentlyContinue)
    }

    if (-not $InfFiles) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] No INF files found in $InstallDirectory"
        return
    }

    if ($env:SystemDrive -eq 'X:') {
        try {
            Add-WindowsDriver -Path 'C:\' -Driver $InstallDirectory -Recurse -ForceUnsigned -ErrorAction Stop | Out-Null
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Added firmware driver package in WinPE from $InstallDirectory"
        }
        catch {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to add firmware driver package in WinPE: $($_.Exception.Message)"
        }
        return
    }

    $InstalledCount = 0
    $FailedCount = 0
    $RebootRequired = $false

    foreach ($InfFile in $InfFiles) {
        try {
            & pnputil.exe /Add-Driver $InfFile.FullName /install | Out-Null
            switch ($LASTEXITCODE) {
                0 {
                    $InstalledCount++
                }
                3010 {
                    $InstalledCount++
                    $RebootRequired = $true
                }
                default {
                    $FailedCount++
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] pnputil exit code $LASTEXITCODE for $($InfFile.FullName)"
                }
            }
        }
        catch {
            $FailedCount++
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Failed to install $($InfFile.FullName): $($_.Exception.Message)"
        }
    }

    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Firmware driver install complete. Installed: $InstalledCount Failed: $FailedCount"

    if ($RebootRequired) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] A reboot is required to complete firmware update installation"
    }
    #=================================================
}
