function Step-OSDCloudWinpeDriverRecast {
    [CmdletBinding()]
    param ()
    #=================================================
    # Start the step
    $Message = "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Debug -Message $Message; Write-Verbose -Message $Message
    #=================================================
    $ExpandPath = 'C:\Windows\Temp\osdcloud\drivers-recast'
    if (-not (Test-Path "$ExpandPath")) {
        New-Item $ExpandPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    }
    
    $LogPath = "C:\Windows\Temp\osdcloud-logs"
    if (-not (Test-Path -Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
    }
    #=================================================
    # Gather In-Use Drivers
    $PnputilXml = & pnputil.exe /enum-devices /format xml
    $PnputilXmlObject = [xml]$PnputilXml
    $PnputilDevices = $PnputilXmlObject.PnpUtil.Device | `
        Where-Object { $_.DriverName -like "oem*.inf" } | `
        Sort-Object DriverName -Unique | `
        Select-Object -Property DriverName, Status, ClassGuid, ClassName, DeviceDescription, ManufacturerName, InstanceId

    if ($PnputilDevices) {
        $PnputilDevices | Export-Clixml -Path "$LogPath\drivers-recast.xml" -Force
    }
    else {
        return
    }
    #=================================================
    # Export Drivers to Disk
    Write-Verbose "[$(Get-Date -format G)] Exporting drivers to: $ExpandPath"
    foreach ($Device in $PnputilDevices) {
        # Check that the Device has a DriverName
        if ($Device.Drivername) {
            $FolderName = $Device.DriverName -replace '.inf', ''
            $destinationPath = $ExpandPath + "\$($Device.ClassName)\" + $FolderName
            # Ensure the output directory exists
            if (-not (Test-Path -Path $destinationPath)) {
                New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
            }
            
            # Export the driver using pnputil
            Write-Verbose "[$(Get-Date -format G)] Exporting $($Device.DriverName) to: $destinationPath"
            $null = & pnputil.exe /export-driver $Device.DriverName $destinationPath
        }
    }
    #=================================================
    if (Test-Path -Path $ExpandPath) {
        Add-WindowsDriver -Path "C:\" -Driver "$ExpandPath" -Recurse -ForceUnsigned -LogPath "$LogPath\drivers-recast.log" -ErrorAction SilentlyContinue | Out-Null
    }
    #=================================================
    # End the function
    $Message = "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    Write-Verbose -Message $Message; Write-Debug -Message $Message
    #=================================================
}