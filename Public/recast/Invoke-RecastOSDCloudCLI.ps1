function Invoke-RecastOSDCloudCLI {
    <#
    .SYNOPSIS
    Executes the Recast OSDCloud command-line deployment workflow.

    .DESCRIPTION
    Initializes the OSDCloud runtime state from device and deployment context,
    applies supported global customization hashtables, confirms selected operating
    system and driver pack cache availability, prepares the deployment disk, and
    runs the command-line operating system deployment workflow.

    This function does not accept direct parameters. It relies on module and global
    state populated by Start-RecastOSDCloudCLI before invocation.

    .PARAMETER None
    This function does not define input parameters.

    .EXAMPLE
    Invoke-RecastOSDCloudCLI
    Runs the Recast OSDCloud CLI deployment workflow using existing global deployment state.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-20 - Updated comment-based help for Recast OSDCloud CLI behavior.
    #>
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    $global:RecastOSDCloud.TimeStart = [datetime](Get-Date)
    #=================================================
    # Set OSDCloud LogsPath
    $LogsPath = $global:RecastOSDCloud.LogsPath
    if (-not (Test-Path -LiteralPath $LogsPath -PathType Container)) {
        $null = New-Item -Path $LogsPath -ItemType Directory -Force -ErrorAction SilentlyContinue
    }
    $TranscriptFullName = Join-Path $LogsPath "transcript-$((Get-Date).ToString('yyyy-MM-dd-HHmmss')).log"
    if (-not (Start-Transcript -Path $TranscriptFullName -ErrorAction SilentlyContinue)) {
        Write-Warning "[$(Get-Date -format s)] Failed to start transcript at $TranscriptFullName"
    }
    #=================================================
    #region Initialize-OSDCoreDevice
    if (-not ($global:OSDCoreDevice)) {
        Initialize-OSDCoreDevice
    }
    #=================================================
    # Make sure there is an Operating System ESD available for deployment, either online or offline.
    if ((-not $global:RecastOSDCloud.OperatingSystemCloudObjectTest) -and (-not $global:RecastOSDCloud.OperatingSystemCacheObject)) {
        throw "[$(Get-Date -format s)] WindowsImage ESD is not reachable online or offline. Please verify the source and try again."
    }
    #=================================================
    # v2 Make sure there is a deployment disk available.
    Step-OSDCloudConfirmDeploymentDiskObject
    #=================================================
    # v1.5 Push deployment analytics to the Recast OSDCloud telemetry service.
    # Step-OSDCloudTelemetryPSGallery
    # Step-OSDCloudTelemetryPH
    #=================================================
    # v2 Disk
    Step-OSDCloudRemoveUSBDrives
    Step-OSDCloudClearDeploymentDisk
    Step-OSDCloudPartitionDeploymentDisk
    Step-OSDCloudRestoreUSBDrives
    Step-OSDCloudEnableHighPerformance
    #=================================================
    # v2 Copy the OperatingSystemCloudObject from the Cache to the Staging folder, or download it from the online source if not cached.
    if ($global:RecastOSDCloud.OperatingSystemCacheObject) {
        Step-OSDCloudSaveOperatingSystemCacheObject
    }
    elseif ($global:RecastOSDCloud.OperatingSystemCloudObjectTest) {
        Step-OSDCloudSaveOperatingSystemCloudObject
    }
    #=================================================
    # v2 Expand the Operating System after verifying the proper ImageIndex
    Step-OSDCloudGetWindowsImageIndex
    Step-OSDCloudExpandWindowsImage
    Step-OSDCloudRestartLogs
    Step-OSDCloudConfirmWindowsEdition
    Step-OSDCloudBcdBoot
    Step-OSDCloudUpdateSetupDisplayedEula
    Step-OSDCloudUpdatePowerShellModules
    Step-OSDCloudContentFolders
    #=================================================
    # v2 WinPE OEM Drivers
    Step-OSDCloudWinPEOemDriversExport
    Step-OSDCloudWinPEOemDriversAddWinOS
    Step-OSDCloudWinPEOemDriversAddWinRE
    #=================================================
    # v2 Copy the DriverPackCloudObject from the Cache to the Staging folder, or download it from the online source if not cached.
    if ($global:RecastOSDCloud.DriverPackCacheObject) {
        Step-OSDCloudSaveDriverPackCacheObject
    }
    elseif ($global:RecastOSDCloud.DriverPackCloudObjectTest) {
        Step-OSDCloudSaveDriverPackCloudObject
    }
    #=================================================
    # Step-OSDCloudDriverPackAdd
    # step-Save-WindowsDriver-Firmware
    # step-Add-WindowsDriver-Firmware
    Step-OSDCloudExportOSInformation
    Step-OSDCloudFinish
}
