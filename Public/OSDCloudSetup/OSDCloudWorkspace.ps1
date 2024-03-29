function Get-OSDCloudWorkspace {
    <#
    .SYNOPSIS
    Returns the path to the OSDCloud Workspace by reading the configuration file $env:ProgramData\OSDCloud\workspace.json
    
    .DESCRIPTION
    Returns the path to the OSDCloud Workspace by reading the configuration file $env:ProgramData\OSDCloud\workspace.json
    
    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs/Get-OSDCloudWorkspace.md
    
    .LINK
    https://www.osdcloud.com/setup/osdcloud-workspace
    #>

    [CmdletBinding()]
    param ()

    #region Block
    Block-WinPE
    #Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #endregion

    #region workspace.json
    if (Test-Path "$env:ProgramData\OSDCloud\workspace.json") {
        $WorkspaceSettings = Get-Content -Path "$env:ProgramData\OSDCloud\workspace.json" | ConvertFrom-Json
        $WorkspacePath = $WorkspaceSettings.WorkspacePath
        $WorkspacePath
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to locate $env:ProgramData\OSDCloud\workspace.json"
    }
    #endregion
}
function New-OSDCloudWorkspace {
    <#
    .SYNOPSIS
    Creates or updates an OSDCloud Workspace

    .DESCRIPTION
    Creates or updates an OSDCloud Workspace

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs/Set-OSDCloudWorkspace.md
    
    .LINK
    https://www.osdcloud.com/setup/osdcloud-workspace
    #>
    
    [CmdletBinding(DefaultParameterSetName='fromTemplate')]
    param (
        [Parameter(ParameterSetName='fromTemplate',Position=0,ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='fromIsoFile',Position=0,ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='fromIsoUrl',Position=0,ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='fromUsbDrive',Position=0,ValueFromPipelineByPropertyName)]
        [System.String]
        #Directory for the OSDCloud Workspace to create or update.  Default is $env:SystemDrive\OSDCloud
        $WorkspacePath = "$env:SystemDrive\OSDCloud",
        
        [Parameter(ParameterSetName='fromIsoFile',Mandatory)]
        [System.IO.FileInfo]
        #Path to an OSDCloud ISO
        #This file will be mounted and the contents will be copied to the OSDCloud Workspace
        $fromIsoFile,
        
        [Parameter(ParameterSetName='fromIsoUrl',Mandatory)]
        [System.String]
        #Path to an OSDCloud ISO saved on the internet
        #This file will be downloaded and mounted and the contents will be copied to the OSDCloud Workspace
        $fromIsoUrl,
        
        [Parameter(ParameterSetName='fromUsbDrive',Mandatory)]
        [System.Management.Automation.SwitchParameter]
        #Searches for an OSDCloud USB
        #The OSDCloud USB contents will be copied to the OSDCloud Workspace
        $fromUsbDrive,

        [System.Management.Automation.SwitchParameter]
        #Prevents the copying of Private Config files
        $Public
    )

    #region Block
    Block-NoCurl
    Block-PowerShellVersionLt5
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-WinPE
    #endregion

    #region Preferences
    $ErrorActionPreference = 'Stop'
    $WinpeSourcePath = $null
    #endregion

    #region Initialize Workspace from Template
    if ($PSCmdlet.ParameterSetName -eq 'fromTemplate') {
        #=================================================
        #	OSDCloudTemplate
        #=================================================
        $OSDCloudTemplate = Get-OSDCloudTemplate -ErrorAction Stop
    
        if (-NOT ($OSDCloudTemplate)) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Template at $OSDCloudTemplate"
            Break
        }
    
        if (-NOT (Test-Path $OSDCloudTemplate)) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Template at $OSDCloudTemplate"
            Break
        }
        #=================================================
        #	Remove Old Autopilot Content
        #=================================================
        if (Test-Path "$(Get-OSDCloudTemplate)\Autopilot") {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Move all your Autopilot Profiles to $(Get-OSDCloudTemplate)\Config\AutopilotJSON"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You will be unable to create or update an OSDCloud Workspace until $(Get-OSDCloudTemplate)\Autopilot is manually removed"
            Break
        }
        if (Test-Path "$WorkspacePath\Autopilot") {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Move all your Autopilot Profiles to $WorkspacePath\Config\AutopilotJSON"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You will be unable to create or update an OSDCloud Workspace until $WorkspacePath\Autopilot is manually removed"
            Break
        }
    }
    #endregion

    #region Initialize Workspace fromIsoFile
    if ($PSCmdlet.ParameterSetName -eq 'fromIsoFile') {
        $fromIsoFileGetItem = Get-Item -Path $fromIsoFile -ErrorAction Ignore
        $fromIsoFileFullName = $fromIsoFileGetItem.FullName

        if ($fromIsoFileGetItem -and $fromIsoFileGetItem.Extension -eq '.iso') {
            #Do nothing
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to get the properties of $fromIsoFile"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
            Break
        }
        #=================================================
        #   Mount fromIsoFile
        #=================================================
        $Volumes = (Get-Volume).Where({$_.DriveLetter}).DriveLetter

        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mounting OSDCloudISO at $fromIsoFileFullName"
        $MountDiskImage = Mount-DiskImage -ImagePath $fromIsoFileFullName
        Start-Sleep -Seconds 3
        $MountDiskImageDriveLetter = (Compare-Object -ReferenceObject $Volumes -DifferenceObject (Get-Volume).Where({$_.DriveLetter}).DriveLetter).InputObject

        if ($MountDiskImageDriveLetter) {
            $WinpeSourcePath = "$($MountDiskImageDriveLetter):\"
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to mount $MountDiskImage"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
            Break
        }
    }
    #endregion

    #region Initialize Workspace fromIsoUrl
    if ($PSCmdlet.ParameterSetName -eq 'fromIsoUrl') {
        $ResolveUrl = Invoke-WebRequest -Uri $fromIsoUrl -Method Head -MaximumRedirection 0 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($ResolveUrl.StatusCode -eq 302) {
            $fromIsoUrl = $ResolveUrl.Headers.Location
        }

        $fromIsoFileGetItem = Save-WebFile -SourceUrl $fromIsoUrl -DestinationDirectory (Join-Path $HOME 'Downloads')
        $fromIsoFileFullName = $fromIsoFileGetItem.FullName
    
        if ($fromIsoFileGetItem -and $fromIsoFileGetItem.Extension -eq '.iso') {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloudISO downloaded to $fromIsoFileFullName"
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to download OSDCloudISO"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
            Break
        }
        #=================================================
        #   Mount OSDCloudISO
        #=================================================
        $Volumes = (Get-Volume).Where({$_.DriveLetter}).DriveLetter

        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mounting OSDCloudISO"
        $MountDiskImage = Mount-DiskImage -ImagePath $fromIsoFileFullName
        Start-Sleep -Seconds 3
        $MountDiskImageDriveLetter = (Compare-Object -ReferenceObject $Volumes -DifferenceObject (Get-Volume).Where({$_.DriveLetter}).DriveLetter).InputObject

        if ($MountDiskImageDriveLetter) {
            $WinpeSourcePath = "$($MountDiskImageDriveLetter):\"
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to mount $MountDiskImage"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
            Break
        }
    }
    #endregion

    #region Initialize fromUsbDrive
    if ($PSCmdlet.ParameterSetName -eq 'fromUsbDrive') {
        #=================================================
        #	USB Volumes
        #=================================================
        $UsbVolumes = Get-USBVolume
        if ($UsbVolumes) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) USB volumes found"
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find any USB Volumes"
            Get-Help New-OSDCloudUSB -Examples
            Break
        }
    }
    #endregion

    #region Validate
    if (Test-Path $WorkspacePath) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Workspace already exists at $WorkspacePath"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Content will be merged and overwritten"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Press Ctrl+C to cancel in the next 5 seconds"
        Start-Sleep -Seconds 5
    }
    else {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-Item $WorkspacePath"
        try {
            $null = New-Item -Path $WorkspacePath -ItemType Directory -Force -ErrorAction Stop
        }
        catch {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to create an OSDCloud Workspace at $WorkspacePath"
            Break
        }
    }
    #endregion

    #region Logs and Transcript
    $WorkspaceLogs = "$WorkspacePath\Logs\Workspace"
    Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloud Workspace Logs at $WorkspaceLogs"

    if (Test-Path $WorkspaceLogs) {
        $null = Remove-Item -Path "$WorkspaceLogs\*" -Recurse -Force -ErrorAction Ignore | Out-Null
    }
    if (-NOT (Test-Path $WorkspaceLogs)) {
        $null = New-Item -Path $WorkspaceLogs -ItemType Directory -Force | Out-Null
    }

    $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-New-OSDCloudWorkspace.log"
    $null = Start-Transcript -Path (Join-Path $WorkspaceLogs $Transcript) -ErrorAction Ignore
    #endregion

    #region Build Workspace
    if ($PSCmdlet.ParameterSetName -eq 'fromTemplate') {
        #=================================================
        #	Copy WorkspacePath
        #=================================================
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying from OSDCloud Template at $OSDCloudTemplate"
        Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Source: $OSDCloudTemplate"
        Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Destination: $WorkspacePath"
    
        $null = robocopy "$OSDCloudTemplate" "$WorkspacePath" *.* /e /b /ndl /np /r:0 /w:0 /xj /xf workspace.json /LOG+:$WorkspaceLogs\Robocopy.log
        #=================================================
        #	Mirror Media
        #=================================================
        Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mirroring OSDCloud Template Media using Robocopy"
        Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mirroring will replace any previous WinPE with a new Template WinPE"
        Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Directories named OSDCloud are updated"
        Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Source: $OSDCloudTemplate\Media"
        Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Destination: $WorkspacePath\Media"

        $null = robocopy "$OSDCloudTemplate\Media\OSDCloud" "$WorkspacePath\Media\OSDCloud" *.* /e /b /ndl /np /r:0 /w:0 /xj /LOG+:$WorkspaceLogs\Robocopy.log
        $null = robocopy "$OSDCloudTemplate\Media" "$WorkspacePath\Media" *.* /mir /b /ndl /np /r:0 /w:0 /xj /LOG+:$WorkspaceLogs\Robocopy.log /XD OSDCloud
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'fromUsbDrive') {
        #=================================================
        #   WinPE Volume
        #=================================================
        $WinpeVolumes = $UsbVolumes | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT') -or ($_.FileSystemLabel -eq 'WinPE')}
    
        if ($WinpeVolumes) {
            foreach ($WinpeVolume in $WinpeVolumes) {
                if (Test-Path -Path "$($WinPEVolume.DriveLetter):\") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying OSDCloud WinPE volume at $($WinPEVolume.DriveLetter):\ to $WorkspacePath\Media"
                    robocopy "$($WinPEVolume.DriveLetter):\" "$WorkspacePath\Media" *.* /e /ndl /njh /njs /np /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud USB WinPE volume"
            Break
        }
    
        $OSDCloudVolumes = Get-USBVolume | Where-Object {($_.FileSystemLabel -eq 'OSDCloud') -or ($_.FileSystemLabel -eq 'OSDCloudUSB')}
    
        if ($OSDCloudVolumes) {
            foreach ($OSDCloudVolume in $OSDCloudVolumes) {
                if (! $Public) {
                    if (Test-Path "$($OSDCloudVolume.DriveLetter):\OSDCloud\Config") {
                        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $($OSDCloudVolume.DriveLetter):\OSDCloud\Config to OSDCloud Workspace $WorkspacePath\Config"
                        robocopy "$($OSDCloudVolume.DriveLetter):\OSDCloud\Config" "$WorkspacePath\Config" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    }
                }
    
                if (Test-Path "$($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks to OSDCloud Workspace $WorkspacePath\DriverPacks"
                    robocopy "$($OSDCloudVolume.DriveLetter):\OSDCloud\DriverPacks" "$WorkspacePath\DriverPacks" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                }
    
                if (Test-Path "$($OSDCloudVolume.DriveLetter):\OSDCloud\OS") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $($OSDCloudVolume.DriveLetter):\OSDCloud\OS to OSDCloud Workspace $WorkspacePath\OS"
                    robocopy "$($OSDCloudVolume.DriveLetter):\OSDCloud\OS" "$WorkspacePath\OS" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                }
    
                if (Test-Path "$($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell to OSDCloud Workspace $WorkspacePath\PowerShell"
                    robocopy "$($OSDCloudVolume.DriveLetter):\OSDCloud\PowerShell" "$WorkspacePath\PowerShell" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                }
            }
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud USB volume"
            Break
        }
    }
    else {
        #=================================================
        #	Test WinpeSourcePath
        #=================================================
        if (-NOT ($WinpeSourcePath)) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Media"
            Break
        }
    
        if (-NOT (Test-Path $WinpeSourcePath)) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Media at $WinpeSourcePath"
            Break
        }
    
        if (-NOT (Test-Path "$WinpeSourcePath\sources\boot.wim")) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud WinPE at $WinpeSourcePath\sources\boot.wim"
            Break
        }
        $WinpeDestinationPath = "$WorkspacePath\Media"
        if (-NOT (Test-Path $WinpeDestinationPath)) {
            $null = New-Item -Path $WinpeDestinationPath -ItemType Directory -Force | Out-Null
        }
        #=================================================
        #	Update WinPE Volume
        #=================================================
        if ((Test-Path -Path "$WinpeSourcePath") -and (Test-Path -Path "$WinpeDestinationPath")) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $WinpeSourcePath to $WinpeDestinationPath"
            robocopy "$WinpeSourcePath" "$WinpeDestinationPath" *.* /e /ndl /njh /njs /np /r:0 /w:0 /b /zb
        }
    }
    #endregion

    #region Remove Read-Only Attribute
    if ($WinpeDestinationPath) {
        Get-ChildItem -Path $WinpeDestinationPath -File -Recurse -Force | foreach {
            Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $false -Force -ErrorAction Ignore
        }
    }
    #endregion

    #region Dismount OSDCloudISO
    if ($MountDiskImage) {
        Start-Sleep -Seconds 3
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Dismounting $($MountDiskImage.ImagePath)"
        $null = Dismount-DiskImage -ImagePath $MountDiskImage.ImagePath
    }
    #endregion
    
    #region Set WorkspacePath
    Set-OSDCloudWorkspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    #endregion
    
    #region Complete
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Yellow "Find your current OSDCloud Workspace:   " -NoNewline
    Write-Host -ForegroundColor Gray "Get-OSDCloudWorkspace"
    Write-Host -ForegroundColor Yellow "Set a default OSDCloud Workspace:       " -NoNewline
    Write-Host -ForegroundColor Gray "Set-OSDCloudWorkspace C:\OSDCloud2"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-OSDCloudWorkspace created at $WorkspacePath"
    $null = Stop-Transcript -ErrorAction Ignore
    #endregion
}
function Set-OSDCloudWorkspace {
    <#
    .SYNOPSIS
    Changes the path to the OSDCloud Workspace

    .DESCRIPTION
    Changes the path to the OSDCloud Workspace from an OSDCloud Template

    .PARAMETER WorkspacePath
    Directory for the OSDCloud Workspace to set.  Default is $env:SystemDrive\OSDCloud

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs/Set-OSDCloudWorkspace.md
    
    .LINK
    https://www.osdcloud.com/setup/osdcloud-workspace
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [System.String]$WorkspacePath = "$env:SystemDrive\OSDCloud"
    )
    
    #region Block
    Block-StandardUser
    Block-PowerShellVersionLt5
    Block-WinPE
    #endregion

    #region Set-OSDCloudWorkspace
    $WorkspaceSettings = [PSCustomObject]@{
        WorkspacePath = $WorkspacePath
    }

    if (-not (Test-Path "$env:ProgramData\OSDCloud")) {
        $null = New-Item -Path "$env:ProgramData\OSDCloud" -ItemType Directory -Force -ErrorAction Stop
    }

    $WorkspaceSettings | ConvertTo-Json | Out-File "$env:ProgramData\OSDCloud\workspace.json" -Encoding ascii -Width 2000 -Force

    $WorkspacePath
    #endregion
}

function New-OSDCloudWorkSpaceSetupCompleteTemplate {

    $OSDCloudWS = Get-OSDCloudWorkspace
    $SetupCompletePath = "$OSDCloudWS\Config\Scripts\SetupComplete"
    $ScriptsPath = $SetupCompletePath

    if (!(Test-Path -Path $ScriptsPath)){New-Item -Path $ScriptsPath -ItemType Directory} 

    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})


    Write-Output "Creating $($RunScript.Script) Files"

    $BatFilePath = "$($RunScript.Path)\$($RunScript.batFile)"
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"
            
    #Create Batch File to Call PowerShell File
    if (Test-Path -Path $PSFilePath){
        copy-item $PSFilePath -Destination "$ScriptsPath\SetupComplete.ps1.bak"
    }        
    New-Item -Path $BatFilePath -ItemType File -Force
    $CustomActionContent = New-Object system.text.stringbuilder
    [void]$CustomActionContent.Append('%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File C:\OSDCloud\Scripts\SetupComplete\SetupComplete.ps1')
    Add-Content -Path $BatFilePath -Value $CustomActionContent.ToString()

    #Create PowerShell File to do actions

    New-Item -Path $PSFilePath -ItemType File -Force
    Add-Content -path $PSFilePath 'Write-Output "========================================================="'
    Add-Content -path $PSFilePath 'Write-Output "Calling Custom Setup Complete File: $($PSCommandPath)"'
    Add-Content -path $PSFilePath 'Write-Output ""'
    Add-Content -path $PSFilePath 'Write-Output "CONFIRMED THIS RAN FROM FILE COPIED VIA FLASH DRIVE"'
    Add-Content -path $PSFilePath 'Write-Output ""'
    Add-Content -path $PSFilePath 'Write-Output "Completed Custom Setup Complete File: $($PSCommandPath)"'
    Add-Content -path $PSFilePath 'Write-Output "========================================================="'
}