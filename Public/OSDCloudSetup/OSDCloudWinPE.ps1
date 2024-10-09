function Edit-OSDCloudWinPE {
    <#
    .SYNOPSIS
    Edits WinPE in an OSDCloud Workspace for customization

    .DESCRIPTION
    Edits WinPE in an OSDCloud Workspace for customization

    .EXAMPLE
    Edit-OSDCloudWinPE -StartOSDCloudGUI

    .EXAMPLE
    Edit-OSDCloudWinPE -StartOSDCloud '-OSBuild 22H2 -OSEdition Pro -OSLanguage en-us -OSActivation Retail'

    .EXAMPLE
    Edit-OSDCloudWinPE –StartURL 'https://sandbox.osdcloud.com'

    .LINK
    https://www.osdcloud.com/setup/osdcloud-winpe
    #>
    
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [ValidateSet('*','Dell','HP','IntelNet','LenovoDock','Surface','Nutanix','USB','VMware','WiFi')]
        [System.String[]]
        #WinPE Driver: Download and install in WinPE drivers from Dell,HP,IntelNet,LenovoDock,Nutanix,Surface,USB,VMware,WiFi
        $CloudDriver,

        [System.Management.Automation.SwitchParameter]
        #WinPE Startup: Modifies Startnet.cmd to execute Start-OSDCloudGUI
        $StartOSDCloudGUI,

        [Alias('HardwareID')]
        [System.String[]]
        #WinPE Driver: HardwareID of the Driver to add to WinPE
        $DriverHWID,

        [System.String[]]
        #WinPE Driver: Path to additional Drivers you want to add to WinPE
        $DriverPath,

        [System.String[]]
        #PowerShell: Copies named PowerShell Modules from the running OS to WinPE
        #This is useful for adding Modules that are customized or not on PowerShell Gallery
        $PSModuleCopy,

        [Alias('Modules')]
        [System.String[]]
        #PowerShell: Installs named PowerShell Modules from PowerShell Gallery to WinPE
        $PSModuleInstall,

        [System.String]
        #WinPE Startup: Modifies Startnet.cmd to execute the specified string
        $Startnet,

        [System.String]
        #WinPE Startup: Modifies Startnet.cmd to execute Start-OSDCloud with the specified string parameters
        $StartOSDCloud,

        [System.String]
        #WinPE Startup: Modifies Startnet.cmd to execute Start-OSDPad with the specified string
        $StartOSDPad,

        [System.String]
        #WinPE Startup: Modifies Startnet.cmd to execute the specified string before OSDCloud
        $StartPSCommand,

        [Alias('WebPSScript','StartWebScript','StartCloudScript')]
        [System.String]
        #WinPE Startup: Modifies Startnet.cmd to execute the specified string before OSDCloud
        $StartURL,

        [System.Management.Automation.SwitchParameter]
        #After WinPE has been updated, the contents of the OSDCloud Workspace will be updated on any OSDCloud USB Drives
        $UpdateUSB,

        [ValidateScript({
            if (!($_ | Test-Path)) {
                throw 'Wallpaper JPG file does not exist'
            }
            if (!($_ | Test-Path -PathType Leaf)) {
                throw 'Wallpaper JPG must be a file'
            }
            if ($_ -notmatch "(\.jpg)") {
                throw 'Wallpaper must be a JPG file'
            }
            return $true
        })]
        [System.IO.FileInfo]
        #Sets the specified Wallpaper JPG file as the WinPE Background
        $Wallpaper,

        [System.Management.Automation.SwitchParameter]
        #Uses the default OSDCloud Wallpaper
        $UseDefaultWallpaper,

        [System.String]
        #Sets the custom Brand for OSDCloudGUI
        $Brand = 'OSDCloud',

        [System.String]
        #Directory for the OSDCloudWorkspace which contains Media directory
        #This is optional as the OSDCloudWorkspace is returned by Get-OSDCloudWorkspace automatically
        $WorkspacePath,

        [Switch]
        #Will leverage WirelessConnect.EXE instead of the Commandline Tools to connect to WiFi
        $WirelessConnect,

        [ValidateScript( {
            if (Test-Path -Path $_) {
                $true
            } else {
                throw "$_ doesn't exists"
            }
            if ($_ -notmatch "\.xml$") {
                throw "$_ isn't xml file"
            }
            if (!(([xml](Get-Content $_ -Raw)).WLANProfile.Name) -or (([xml](Get-Content $_ -Raw)).WLANProfile.MSM.security.sharedKey.protected) -ne "false") {
                throw "$_ isn't valid Wi-Fi XML profile (is the password correctly in plaintext?). Use command like this, to create it: netsh wlan export profile name=`"MyWifiSSID`" key=clear folder=C:\Wifi"
            }
        })]
        [System.IO.FileInfo]
        #Imports and uses a WiFi Profile to connect to WiFi
        $WifiProfile,

        [System.Management.Automation.SwitchParameter]
        #Adds 7Zip to Boot Image
        $Add7Zip,

        [System.Management.Automation.SwitchParameter]
        # Add PowerShell 7 to WinPE
        $pwsh
    )
    #=================================================
    #	Start the Clock
    #=================================================
    $WinpeStartTime = Get-Date
    #=================================================
    #	Block
    #=================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=================================================
    #	Get-OSDCloudTemplate
    #=================================================
    if (-NOT (Get-OSDCloudTemplate)) {
        Write-Warning "Setting up a new OSDCloudTemplate"
        New-OSDCloudTemplate -Verbose
    }

    $OSDCloudTemplate = Get-OSDCloudTemplate
    if (-NOT ($OSDCloudTemplate)) {
        Write-Warning "Something bad happened.  I have to go"
        Break
    }
    #=================================================
    #	Set WorkspacePath
    #=================================================
    if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Setting Workspace Path"
        Set-OSDCloudWorkspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    }
    $WorkspacePath = Get-OSDCloudWorkspace
    #=================================================
    #	Setup Workspace
    #=================================================
    if (-NOT ($WorkspacePath)) {
        Write-Warning "You need to provide a path to your Workspace with one of the following examples"
        Write-Warning "Set-OSDCloudWorkspace -WorkspacePath C:\OSDCloud"
        Write-Warning "Edit-OSDCloudWinPE -WorkspacePath C:\OSDCloud"
        Break
    }

    if (-NOT (Test-Path $WorkspacePath)) {
        New-OSDCloudWorkspace -WorkspacePath $WorkspacePath -Verbose -ErrorAction Stop
    }

    if (-NOT (Test-Path "$WorkspacePath\Media")) {
        New-OSDCloudWorkspace -WorkspacePath $WorkspacePath -Verbose -ErrorAction Stop
    }

    if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "Nothing is going well for you today my friend"
        Break
    }
    #=================================================
    #	Remove Old Autopilot Content
    #=================================================
    if (Test-Path "$(Get-OSDCloudTemplate)\Autopilot") {
        Write-Warning "Move all your Autopilot Profiles to $(Get-OSDCloudTemplate)\Config\AutopilotJSON"
        Write-Warning "You will be unable to create or update an OSDCloud Workspace until $(Get-OSDCloudTemplate)\Autopilot is manually removed"
        Break
    }
    if (Test-Path "$WorkspacePath\Autopilot") {
        Write-Warning "Move all your Autopilot Profiles to $WorkspacePath\Config\AutopilotJSON"
        Write-Warning "You will be unable to create or update an OSDCloud Workspace until $WorkspacePath\Autopilot is manually removed"
        Break
    }
    #=================================================
    #   Mount-MyWindowsImage
    #=================================================
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mounting $WorkspacePath\Media\Sources\boot.wim"
    $MountMyWindowsImage = Mount-MyWindowsImage -ImagePath "$WorkspacePath\Media\Sources\boot.wim"
    $MountPath = $MountMyWindowsImage.Path
    #=================================================
    #   Robocopy Config
    #=================================================
    if (Test-Path "$WorkspacePath\Config") {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $WorkspacePath\Config to X:\OSDCloud\Config"
        robocopy "$WorkspacePath\Config" "$MountPath\OSDCloud\Config" *.* /mir /ndl /njh /njs /b /np
    }
    #=================================================
    #   Robocopy ODT Config
    #=================================================
    if (Test-Path "$WorkspacePath\ODT") {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $WorkspacePath\ODT to X:\OSDCloud\ODT"
        robocopy "$WorkspacePath\ODT" "$MountPath\OSDCloud\ODT" *.xml /mir /ndl /njh /njs /b /np
        robocopy "$WorkspacePath\ODT" "$MountPath\OSDCloud\ODT" setup.exe /mir /ndl /njh /njs /b /np
    }

    #region PowerShell 7
    if ($PSBoundParameters.ContainsKey('pwsh')) {
        if (Test-Path "$MountPath\Program Files\PowerShell\7") {
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) WinPE is PowerShell 7 Ready"
            $PwshReady = $true
        }
        else {
            Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Adding PowerShell 7 to WinPE"
            $PwshReleases = Invoke-WebRequest -Uri https://github.com/PowerShell/PowerShell/releases/latest -UseBasicParsing
            $PwshVersion = (($PwshReleases.Links | Where-Object { $_.href -match 'releases/tag' }).href).Split('/v')[-1]
            $PwshFileName = "PowerShell-$PwshVersion-win-x64.zip"
            $PwshUri = "https://github.com/PowerShell/PowerShell/releases/download/v$PwshVersion/$PwshFileName"

            Write-Host -ForegroundColor DarkGray "Downloading $PwshUri"
            # Invoke-WebRequest -Uri $PwshUri -OutFile "$env:TEMP\$PwshFileName" -UseBasicParsing
            $PwshDownload = Save-WebFile -SourceUrl $PwshUri

            if (Test-Path -Path $PwshDownload) {
                Expand-Archive -Path $PwshDownload -DestinationPath "$MountPath\Program Files\PowerShell\7" -Force
            }
            else {
                Write-Warning "Could not find $PwshDownload"
            }

            # Add PowerShell 7 PATH to WinPE ... Thanks Johan Arwidmark
            Invoke-Exe reg load HKLM\Mount "$MountPath\Windows\System32\Config\SYSTEM"
            Start-Sleep -Seconds 3
            $RegistryKey = 'HKLM:\Mount\ControlSet001\Control\Session Manager\Environment'
            $CurrentPath = (Get-Item -path $RegistryKey ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
            $NewPath = $CurrentPath + ';%ProgramFiles%\PowerShell\7\'
            $Result = New-ItemProperty -Path $RegistryKey -Name 'Path' -PropertyType ExpandString -Value $NewPath -Force 

            $CurrentPSModulePath = (Get-Item -path $RegistryKey ).GetValue('PSModulePath', '', 'DoNotExpandEnvironmentNames')
            $NewPSModulePath = $CurrentPSModulePath + ';%ProgramFiles%\PowerShell\;%ProgramFiles%\PowerShell\7\;%SystemRoot%\system32\config\systemprofile\Documents\PowerShell\Modules\'
            $Result = New-ItemProperty -Path $RegistryKey -Name 'PSModulePath' -PropertyType ExpandString -Value $NewPSModulePath -Force

            Get-Variable Result | Remove-Variable
            Get-Variable RegistryKey | Remove-Variable
            [gc]::collect()
            Start-Sleep -Seconds 3
            Invoke-Exe reg unload HKLM\Mount | Out-Null
            $PwshReady = $true
        }
    }
    #endregion
    
    #region DriverHWID
    if ($DriverHWID) {
        $AddWindowsDriverPath = Join-Path $env:TEMP (Get-Random)
        foreach ($Item in $DriverHWID) {
            Save-MsUpCatDriver -HardwareID $Item -DestinationDirectory $AddWindowsDriverPath
        }
        try {
            Add-WindowsDriver -Path "$MountPath" -Driver $AddWindowsDriverPath -Recurse -ForceUnsigned -Verbose
        }
        catch {
            Write-Warning "Unable to find a driver for $Item"
        }
    }
    #endregion

    #region CloudDriver
    if ($CloudDriver) {
        foreach ($Driver in $CloudDriver) {
            Write-Verbose "Downloading $Driver Driver Pack"
            $AddWindowsDriverPath = Save-WinPECloudDriver -CloudDriver $Driver -Path (Join-Path $env:TEMP (Get-Random))
            Write-Verbose "Adding $AddWindowsDriverPath to WinPE Drivers mounted at $MountPath"
            Add-WindowsDriver -Path "$MountPath" -Driver "$AddWindowsDriverPath" -Recurse -ForceUnsigned -Verbose
        }
        $null = Save-WindowsImage -Path $MountPath
    }
    #endregion

    #region DriverPath
    foreach ($AddWindowsDriverPath in $DriverPath) {
        Write-Verbose "Adding $AddWindowsDriverPath to WinPE Drivers mounted at $MountPath"
        Add-WindowsDriver -Path "$MountPath" -Driver "$AddWindowsDriverPath" -Recurse -ForceUnsigned -Verbose
    }
    #endregion

    #region WifiProfile
    if ($WifiProfile) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Adding WiFi Profile $WifiProfile"
        Copy-Item -Path $WifiProfile -Destination "$env:TEMP\WiFiProfile.xml" -Force | Out-Null
        robocopy "$env:TEMP" "$MountPath\OSDCloud\Config\Scripts" WiFiProfile.xml /ndl /njh /njs /b /np /r:0 /w:0
    }
    #endregion

    #region Default Startnet.cmd
    $OSDVersion = (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
    if ($WirelessConnect){
        $InitializeOSDCloudStartnetCommand = "Initialize-OSDCloudStartnet -WirelessConnect"
    }
    elseif ($WifiProfile) {
        $InitializeOSDCloudStartnetCommand = "Initialize-OSDCloudStartnet -WifiProfile"
    }
    else {
        $InitializeOSDCloudStartnetCommand = "Initialize-OSDCloudStartnet"
    }
    
$StartnetCMD = @"
@ECHO OFF
wpeinit
cd\
title OSD $OSDVersion
PowerShell -Nol -C $InitializeOSDCloudStartnetCommand
PowerShell -Nol -C Initialize-OSDCloudStartnetUpdate
"@
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Startnet.cmd: Reset to defaults"
    $StartnetCMD
    $StartnetCMD | Out-File -FilePath "$MountPath\Windows\System32\Startnet.cmd" -Encoding ascii -Width 2000 -Force
    #endregion

    #region StartPSCommand
    if ($StartPSCommand) {
        Write-Warning "The StartPSCommand parameter is adding your Cloud PowerShell script to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloudWinPE or it will revert back to defaults"

        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Startnet.cmd: start /wait PowerShell -NoL -C `"$StartPSCommand`""
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start /wait PowerShell -NoL -C `"$StartPSCommand`"" -Force
    }
    #endregion
    
    #region Startup Parameter: StartURL
    if ($StartURL) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Startnet.cmd: Launch URL on WinPE Startup"

        Write-Host '@ECHO OFF'
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO OFF' -Force

        Write-Host '@ECHO OFF'
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO Invoke-WebPSScript' -Force

        Write-Host '@ECHO ON'
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO ON' -Force

        Write-Host "start /wait PowerShell -NoL -C Invoke-WebPSScript '$StartURL'"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start /wait PowerShell -NoL -C Invoke-WebPSScript '$StartURL'" -Force
    }
    #endregion

    #region Startup Parameter: StartOSDCloud
    if ($StartOSDCloud) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Startnet.cmd: Launch Start-OSDCloud on WinPE Startup"

        Write-Host '@ECHO OFF'
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO OFF' -Force
        
        Write-Host 'ECHO Start-OSDCloud'        
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO Start-OSDCloud' -Force
        
        Write-Host "start /wait PowerShell -NoL -C Start-OSDCloud $StartOSDCloud"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start /wait PowerShell -NoL -C Start-OSDCloud $StartOSDCloud"
        
        Write-Host '@ECHO ON'
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO ON' -Force
    }
    #endregion

    #region Startup Parameter: StartOSDCloudGUI
    if ($StartOSDCloudGUI) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Startnet.cmd: Launch Start-OSDCloudGUI on WinPE Startup"

        Write-Host '@ECHO OFF'
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO OFF' -Force

        Write-Host 'ECHO Start-OSDCloudGUI'
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO Start-OSDCloudGUI' -Force

        Write-Host "start /wait PowerShell -NoL -W Mi -C Start-OSDCloudGUI -Brand '$Brand'"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start /wait PowerShell -NoL -W Mi -C Start-OSDCloudGUI -Brand '$Brand'"

        Write-Host '@ECHO ON'
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO ON' -Force
    }
    #endregion

    #region Startup Parameter: StartOSDPad
    if ($StartOSDPad) {
        Write-Warning "The StartOSDPad parameter is adding OSDPad to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloudWinPE or it will revert back to defaults"
        
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Startnet.cmd: start /wait PowerShell -NoL -C OSDPad $StartOSDPad"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO OFF' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO OSDPad' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO ON' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start /wait PowerShell -NoL -C OSDPad $StartOSDPad"
    }
    #endregion

    #region Startup Parameter: Startnet
    if ($Startnet) {
        Write-Warning "The Startnet string is added to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloudWinPE or it will revert back to defaults"

        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value $Startnet -Force
    }
    #endregion

    #region No Startup Parameter
    if ($StartOSDCloud -or $StartOSDCloudGUI -or $StartURL -or $StartOSDPad -or $Startnet) {
        #Do Nothing
    }
    else {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Startnet.cmd: Start PowerShell in new Window"
        Write-Host '@ECHO OFF'
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO OFF' -Force
        Write-Host 'start PowerShell -NoL'
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'start PowerShell -NoL' -Force
    }
    #endregion

    #region Wallpaper
    if ($UseDefaultWallpaper) {
        $Wallpaper = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Resources\Images\OSDCloud.jpg"
    }
    if ($Wallpaper) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Adding Wallpaper $Wallpaper"
        Copy-Item -Path $Wallpaper -Destination "$env:TEMP\winpe.jpg" -Force | Out-Null
        Copy-Item -Path $Wallpaper -Destination "$env:TEMP\winre.jpg" -Force | Out-Null
        robocopy "$env:TEMP" "$MountPath\Windows\System32" winpe.jpg /ndl /njh /njs /b /np /r:0 /w:0
        robocopy "$env:TEMP" "$MountPath\Windows\System32" winre.jpg /ndl /njh /njs /b /np /r:0 /w:0
    }
    #endregion

    #region Add7Zip
    if ($PSBoundParameters.ContainsKey('Add7Zip')) {
        Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Adding 7zip (7za.exe) to WinPE"
        Add-7Zip2BootImage
    }   
    #endregion

    #region OSD PowerShell Module
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Saving OSD Module to X:\Program Files\WindowsPowerShell\Modules"
    Save-Module -Name OSD -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
    #endregion

    #region Azure PowerShell Modules
    if ($AddAzure.IsPresent) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Saving Azure Modules to X:\Program Files\WindowsPowerShell\Modules"
        Save-Module -Name Az.Accounts -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
        Save-Module -Name Az.Storage -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Saving AzCopy to X:\Windows"
        $AzCopy = Save-WebFile -SourceUrl (Invoke-WebRequest -UseBasicParsing 'https://aka.ms/downloadazcopy-v10-windows' -MaximumRedirection 0 -ErrorAction SilentlyContinue).headers.location
        if ($AzCopy) {
            Expand-Archive -Path $AzCopy.FullName -DestinationPath $env:windir\Temp\AzCopy -Force
            Get-ChildItem -Path $env:windir\Temp\AzCopy -Recurse -Include azcopy.exe | foreach {Copy-Item $_.FullName -Destination "$MountPath\Windows\azcopy.exe" -Force -ErrorAction SilentlyContinue}
        }
    }
    #endregion

    #region AWS PowerShell Modules
    if ($AddAws.IsPresent) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Saving AWS Modules to X:\Program Files\WindowsPowerShell\Modules"
        Save-Module -Name AWS.Tools.Common "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
        Save-Module -Name AWS.Tools.S3 -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
    }
    #endregion

    #region PSModuleInstall
    foreach ($Module in $PSModuleInstall) {
        if ($Module -eq 'DellBiosProvider') {
            if (Test-Path "$env:SystemRoot\System32\msvcp140.dll") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $env:SystemRoot\System32\msvcp140.dll to WinPE"
                Copy-Item -Path "$env:SystemRoot\System32\msvcp140.dll" -Destination "$MountPath\Windows\System32\msvcp140.dll" -Force | Out-Null
            }
            if (Test-Path "$env:SystemRoot\System32\vcruntime140.dll") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $env:SystemRoot\System32\vcruntime140.dll to WinPE"
                Copy-Item -Path "$env:SystemRoot\System32\vcruntime140.dll" -Destination "$MountPath\Windows\System32\vcruntime140.dll" -Force | Out-Null
            }
            if (Test-Path "$env:SystemRoot\System32\vcruntime140_1.dll") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $env:SystemRoot\System32\vcruntime140_1.dll to WinPE"
                Copy-Item -Path "$env:SystemRoot\System32\vcruntime140_1.dll" -Destination "$MountPath\Windows\System32\vcruntime140_1.dll" -Force | Out-Null
            }
        }
        
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Saving $Module to $MountPath\Program Files\WindowsPowerShell\Modules"
        if ($Module -eq 'HPCMSL'){
            Save-Module -Name $Module -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force -AcceptLicense
        }
        else {
            Save-Module -Name $Module -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
        } 
    }
    #endregion

    #region PSModuleCopy
    foreach ($Module in $PSModuleCopy) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copy-PSModuleToWindowsImage -Name $Module -Path $MountPath"
        Copy-PSModuleToWindowsImage -Name $Module -Path $MountPath
    }
    #endregion

    #region Dismount-MyWindowsImage
    $MountMyWindowsImage | Dismount-MyWindowsImage -Save
    #endregion

    #region Create OSDCloud ISOs
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Create OSDCloud Workspace ISOs"
    New-OSDCloudISO
    #endregion

    #region UpdateUSB
    if ($UpdateUSB) {
        $WinpeVolumes = (Get-USBVolume | Where-Object {$_.FileSystemLabel -eq 'WinPE'}).DriveLetter
    
        if ($WinpeVolumes) {
            foreach ($WinpeVolume in $WinpeVolumes) {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $WorkspacePath\Media to $($WinpeVolume):\"
                robocopy "$WorkspacePath\Media" "$($WinpeVolume):\" *.* /e /ndl /np /njh /njs /b /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
            }
        }
    }
    #endregion

    #region Complete
    $WinpeEndTime = Get-Date
    $WinpeTimeSpan = New-TimeSpan -Start $WinpeStartTime -End $WinpeEndTime
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($WinpeTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #endregion
}