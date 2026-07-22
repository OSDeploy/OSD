function Step-OSDCloudWinPEOemDriversExport {
    <#
    .SYNOPSIS
    Exports connected OEM WinPE drivers to the OSDCloud staging folder.

    .DESCRIPTION
    Runs in WinPE only. Enumerates connected devices with pnputil, filters to OEM
    drivers, and exports supported device classes to a structured folder layout for
    later OSDCloud driver injection steps.

    .EXAMPLE
    Step-OSDCloudWinPEOemDriversExport
    Exports matching OEM drivers from the current WinPE session to the staging path.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Added comment-based help and improved pnputil validation and export logging
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Skip. Not running in WinPE (X:)"
        return
    }
    #=================================================
    # Output Path
    $OutputPath = 'C:\Windows\Temp\osdcloud-drivers-winpe'
    if (-not (Test-Path -Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }
    $LogPath = 'C:\Windows\Temp\osdcloud-logs'
    if (-not (Test-Path -Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
    }
    #=================================================
    # Build the list of devices using pnputil.exe, as the /format xml switch is not supported in older versions of WinPE.
    $output = & pnputil.exe /enum-devices /connected
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] pnputil /enum-devices failed with exit code $LASTEXITCODE"
        Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
        return
    }

    $devices = @()
    $currentDevice = @{}
    foreach ($line in $output) {
        $line = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($line)) {
            # Blank line means end of current device
            if ($currentDevice.Count -gt 0) {
                $devices += [PSCustomObject]$currentDevice
                $currentDevice = @{}
            }
        }
        elseif ($line -like "*:*") {
            # Parse key-value pair
            $key, $value = $line -split ':\s*', 2
            $key = $key.Trim() -replace '\s+', '' # Remove spaces from key
            $value = $value.Trim()
            $currentDevice[$key] = $value
        }
    }
    # Add last device if exists
    if ($currentDevice.Count -gt 0) {
        $devices += [PSCustomObject]$currentDevice
    }
    $PnputilDevices = $devices | Where-Object { $_.DriverName -match 'oem' } | Sort-Object DriverName -Unique | Sort-Object ClassName

    # Classes to Export
    $ExportClass = @(
        '1394',
        'DiskDrive',
        'HDC',
        'HIDClass',
        'Keyboard',
        'Mouse',
        'MTD',
        'Multifunction',
        'Net',
        'NvmeDisk',
        'SCSIAdapter',
        'Securitydevices',
        'System',
        'Volume',
        'USB',
        'USBDevice'
    )
    #=================================================
    # Export OEM Drivers
    $ExportedCount = 0
    $SkippedClassCount = 0
    $FailedCount = 0

    if ($PnputilDevices) {
        foreach ($OemDriver in $PnputilDevices) {
            #=================================================
            # Normalize Manufacturer Name
            $ManufacturerName = $OemDriver.ManufacturerName -as [string]
            if ([string]::IsNullOrWhiteSpace($ManufacturerName)) {
                $ManufacturerName = 'Unknown'
            }
            $ManufacturerName = $ManufacturerName.Trim()
            if ($ManufacturerName -match 'Dell' -or $OemDriver.Description -match 'Dell') {
                $ManufacturerName = 'Dell'
            }
            if ($ManufacturerName -match 'HP' -or $OemDriver.Description -match 'HP') {
                $ManufacturerName = 'HP'
            }
            if ($ManufacturerName -match 'Intel' -or $OemDriver.Description -match 'Intel' -or $OemDriver.InstanceID -match 'VEN_8086') {
                $ManufacturerName = 'Intel'
            }
            if ($ManufacturerName -match 'Logitech' -or $OemDriver.Description -match 'Logitech' -or $OemDriver.InstanceID -match 'VID_046D') {
                $ManufacturerName = 'Logitech'
            }
            if ($ManufacturerName -match 'Qualcomm|Snapdragon' -or $OemDriver.Description -match 'Qualcomm|Snapdragon' -or $OemDriver.InstanceID -match 'QCOM') {
                $ManufacturerName = 'Qualcomm'
            }
            if ($ManufacturerName -match 'Realtek' -or $OemDriver.Description -match 'Realtek' -or $OemDriver.InstanceID -match 'VEN_10EC') {
                $ManufacturerName = 'Realtek'
            }
            #=================================================
            # Normalize Foldername
            $FolderName = $OemDriver.DeviceDescription -replace '[\\/:*?"<>|#]', ''
            $FolderName = $FolderName -replace [regex]::Escape($ManufacturerName), ''
            $FolderName = $FolderName -replace '\(standard system devices\)', ''
            $FolderName = [regex]::Replace($FolderName, '\s*\(.*?\)\s*', ' ')
            $FolderName = [regex]::Replace($FolderName, '\s+', ' ')
            $FolderName = $FolderName.Trim()
            if ([string]::IsNullOrWhiteSpace($FolderName)) {
                $FolderName = $OemDriver.DriverName
            }
            #=================================================
            # Export WinPE Drivers
            if ($ExportClass -notcontains $OemDriver.ClassName) {
                Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($OemDriver.ClassName)] $ManufacturerName $($OemDriver.DeviceDescription)"
                $SkippedClassCount++
                continue
            }
            Write-Host -ForegroundColor DarkGreen "[$(Get-Date -format s)] [$($OemDriver.ClassName)] $ManufacturerName $($OemDriver.DeviceDescription)"
            $ExportPath = Join-Path -Path (Join-Path -Path $OutputPath -ChildPath $OemDriver.ClassName) -ChildPath "$ManufacturerName $FolderName"
            if (-not (Test-Path -Path $ExportPath)) {
                New-Item -ItemType Directory -Path $ExportPath -Force | Out-Null
            }

            $null = & pnputil.exe /export-driver $OemDriver.DriverName $ExportPath
            if ($LASTEXITCODE -eq 0) {
                $ExportedCount++
            }
            else {
                Write-Warning "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Failed to export $($OemDriver.DriverName) to $ExportPath (exit code $LASTEXITCODE)"
                $FailedCount++
            }
            #=================================================
        }
        $PnputilDevices | Out-File -FilePath (Join-Path -Path $OutputPath -ChildPath 'pnputil.txt') -Encoding utf8
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Export summary: Exported=$ExportedCount SkippedClass=$SkippedClassCount Failed=$FailedCount"
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] No connected OEM drivers found for export."
    }
    #=================================================
    # If $OutputPath does not contain any files, remove it to avoid confusion.
    if (-not (Get-ChildItem -Path $OutputPath -Recurse -File -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $OutputPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
