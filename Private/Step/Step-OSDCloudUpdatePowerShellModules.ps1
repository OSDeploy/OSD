function Step-OSDCloudUpdatePowerShellModules {
    <#
    .SYNOPSIS
    Updates locally staged PowerShell modules from PowerShell Gallery.

    .DESCRIPTION
    Verifies connectivity to PowerShell Gallery, ensures the local PowerShell folders exist,
    and updates modules under C:\Program Files\WindowsPowerShell\Modules when newer gallery
    versions are available.

    .EXAMPLE
    Step-OSDCloudUpdatePowerShellModules
    Checks gallery connectivity and updates any out-of-date modules in the local modules path.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Added comment-based help and improved module update logic with summary metrics
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    # Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Host -ForegroundColor DarkCyan "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Skip. Not running in WinPE (X:)"
        return
    }
    #=================================================
    # Is it reachable online?
    try {
        $WebRequest = Invoke-WebRequest -Uri 'https://www.powershellgallery.com' -UseBasicParsing -Method Head -ErrorAction Stop
        if ($WebRequest.StatusCode -eq 200) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] PowerShell Gallery returned a 200 status code. OK."
        }
    }
    catch {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] PowerShell Gallery is not reachable."
        return
    }
    #=================================================
    #region Main
    $PowerShellSavePath = 'C:\Program Files\WindowsPowerShell'
    $ConfigurationPath = Join-Path -Path $PowerShellSavePath -ChildPath 'Configuration'
    $ModulesPath = Join-Path -Path $PowerShellSavePath -ChildPath 'Modules'
    $ScriptsPath = Join-Path -Path $PowerShellSavePath -ChildPath 'Scripts'

    foreach ($Path in @($ConfigurationPath, $ModulesPath, $ScriptsPath)) {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -ItemType Directory -Force | Out-Null
        }
    }

    $ExistingModules = Get-ChildItem -Path $ModulesPath -Directory -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Name |
        Sort-Object -Unique

    $UpdatedCount = 0
    $UpToDateCount = 0
    $SkippedCount = 0
    $FailedCount = 0

    foreach ($Name in $ExistingModules) {
        $FindModule = Find-Module -Name $Name -ErrorAction SilentlyContinue
        if ($null -eq $FindModule) {
            $SkippedCount++
            continue
        }

        $ModulePath = Join-Path -Path $ModulesPath -ChildPath $Name
        $CurrentVersion = Get-ChildItem -Path $ModulePath -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^\d+(\.\d+){1,3}$' } |
            ForEach-Object { [version]$_.Name } |
            Sort-Object -Descending |
            Select-Object -First 1

        if (($null -ne $CurrentVersion) -and ($CurrentVersion -ge $FindModule.Version)) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] $Name is current ($CurrentVersion)."
            $UpToDateCount++
            continue
        }

        try {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Updating $Name to $($FindModule.Version)"
            Save-Module -Name $Name -Path $ModulesPath -Force -ErrorAction Stop
            $UpdatedCount++
        }
        catch {
            Write-Warning "[$(Get-Date -format s)] Save-Module failed: $Name"
            $FailedCount++
        }
    }

    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Module update summary: Updated=$UpdatedCount UpToDate=$UpToDateCount Skipped=$SkippedCount Failed=$FailedCount"
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
