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
        $WirelessConnect
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
        robocopy "$WorkspacePath\Config" "$MountPath\OSDCloud\Config" *.* /mir /ndl /njh /njs /b /np
    }
    #=================================================
    #   Robocopy ODT Config
    #=================================================
    if (Test-Path "$WorkspacePath\ODT") {
        robocopy "$WorkspacePath\ODT" "$MountPath\OSDCloud\ODT" *.xml /mir /ndl /njh /njs /b /np
        robocopy "$WorkspacePath\ODT" "$MountPath\OSDCloud\ODT" setup.exe /mir /ndl /njh /njs /b /np
    }
    #=================================================
    #   DriverHWID
    #=================================================
    if ($DriverHWID) {
        $AddWindowsDriverPath = Join-Path $env:TEMP (Get-Random)
        foreach ($Item in $DriverHWID) {
            Save-MsUpCatDriver -HardwareID $Item -DestinationDirectory $AddWindowsDriverPath
        }
        try {
            Add-WindowsDriver -Path "$MountPath" -Driver $AddWindowsDriverPath -Recurse -ForceUnsigned -Verbose | Out-Null
        }
        catch {
            Write-Warning "Unable to find a driver for $Item"
        }
    }
    #=================================================
    #   CloudDriver
    #=================================================
    if ($CloudDriver) {
        foreach ($Driver in $CloudDriver) {
            $AddWindowsDriverPath = Save-WinPECloudDriver -CloudDriver $Driver -Path (Join-Path $env:TEMP (Get-Random))
            Add-WindowsDriver -Path "$MountPath" -Driver "$AddWindowsDriverPath" -Recurse -ForceUnsigned -Verbose | Out-Null
        }
        $null = Save-WindowsImage -Path $MountPath
    }
    #=================================================
    #   DriverPath
    #=================================================
    foreach ($AddWindowsDriverPath in $DriverPath) {
        Add-WindowsDriver -Path "$MountPath" -Driver "$AddWindowsDriverPath" -Recurse -ForceUnsigned -Verbose
    }
    #=================================================
    #   Drop initial Startnet.cmd
    #=================================================
    $OSDVersion = (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
    if ($WirelessConnect){
        $InitializeOSDCloudStartnetCommand = "Initialize-OSDCloudStartnet -WirelessConnect"
    }
    else {
        $InitializeOSDCloudStartnetCommand = "Initialize-OSDCloudStartnet"
    }
    
    
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Startnet.cmd: wpeinit"
$StartnetCMD = @"
@ECHO OFF
wpeinit
cd\
title OSD $OSDVersion
PowerShell -Nol -C $InitializeOSDCloudStartnetCommand 
"@
    $StartnetCMD | Out-File -FilePath "$MountPath\Windows\System32\Startnet.cmd" -Encoding ascii -Width 2000 -Force
    #=================================================
    #   StartPSCommand Wait
    #=================================================
    if ($StartPSCommand) {
        Write-Warning "The StartPSCommand parameter is adding your Cloud PowerShell script to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloudWinPE or it will revert back to defaults"

        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Startnet.cmd: start /wait PowerShell -NoL -C `"$StartPSCommand`""
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start /wait PowerShell -NoL -C `"$StartPSCommand`"" -Force
    }
    #=================================================
    #   StartURL /wait
    #=================================================
    if ($StartURL) {
        Write-Warning "The StartURL parameter is adding your Cloud PowerShell script to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloudWinPE or it will revert back to defaults"

        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Startnet.cmd: start /wait PowerShell -NoL -C Invoke-WebPSScript '$StartURL'"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO OFF' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO Invoke-WebPSScript' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO ON' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start /wait PowerShell -NoL -C Invoke-WebPSScript '$StartURL'" -Force
    }
    #=================================================
    #   StartOSDCloud /wait
    #=================================================
    if ($StartOSDCloud) {
        Write-Warning "The StartOSDCloud parameter is adding Start-OSDCloud to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloudWinPE or it will revert back to defaults"
        
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Startnet.cmd: start /wait PowerShell -NoL -C Start-OSDCloud $StartOSDCloud"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO OFF' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO Start-OSDCloud' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start /wait PowerShell -NoL -C Start-OSDCloud $StartOSDCloud"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO ON' -Force
    }
    #=================================================
    #   StartOSDCloudGUI /wait
    #=================================================
    if ($StartOSDCloudGUI) {
        Write-Warning "The StartOSDCloudGUI parameter is adding Start-OSDCloudGUI to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloudWinPE or it will revert back to defaults"
        
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Startnet.cmd: start /wait PowerShell -NoL -W Mi -C Start-OSDCloudGUI -Brand '$Brand'"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO OFF' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO Start-OSDCloudGUI' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start /wait PowerShell -NoL -W Mi -C Start-OSDCloudGUI -Brand '$Brand'"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO ON' -Force
    }
    #=================================================
    #   StartOSDPad /wait
    #=================================================
    if ($StartOSDPad) {
        Write-Warning "The StartOSDPad parameter is adding OSDPad to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloudWinPE or it will revert back to defaults"
        
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Startnet.cmd: start /wait PowerShell -NoL -C OSDPad $StartOSDPad"
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO OFF' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO OSDPad' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO ON' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value "start /wait PowerShell -NoL -C OSDPad $StartOSDPad"
    }

    if ($Startnet) {
        Write-Warning "The Startnet string is added to Startnet.cmd"
        Write-Warning "This must be set every time you run Edit-OSDCloudWinPE or it will revert back to defaults"

        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value $Startnet -Force
    }
    if ($StartOSDCloud -or $StartOSDCloudGUI -or $StartURL -or $StartOSDPad -or $Startnet){
        #Do Nothing
    }
    else {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Startnet.cmd: start PowerShell -NoL"

        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value '@ECHO OFF' -Force
        #Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'ECHO Start PowerShell' -Force
        Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'start PowerShell -NoL' -Force
    }
    #=================================================
    #   Wallpaper
    #=================================================
    if ($UseDefaultWallpaper) {
        $Wallpaper = Join-Path (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "Resources\Images\OSDCloud.jpg"
    }
    if ($Wallpaper) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Wallpaper: $Wallpaper"
        Copy-Item -Path $Wallpaper -Destination "$env:TEMP\winpe.jpg" -Force | Out-Null
        Copy-Item -Path $Wallpaper -Destination "$env:TEMP\winre.jpg" -Force | Out-Null
        robocopy "$env:TEMP" "$MountPath\Windows\System32" winpe.jpg /ndl /njh /njs /b /np /r:0 /w:0
        robocopy "$env:TEMP" "$MountPath\Windows\System32" winre.jpg /ndl /njh /njs /b /np /r:0 /w:0
    }
    #=================================================
    #   Update OSD Module
    #=================================================
    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Saving OSD Module to $MountPath\Program Files\WindowsPowerShell\Modules"
    Save-Module -Name OSD -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
    if ($AddAzure.IsPresent) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Saving Azure Modules to $MountPath\Program Files\WindowsPowerShell\Modules"
        Save-Module -Name Az.Accounts -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
        Save-Module -Name Az.Storage -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Saving AzCopy to $MountPath\Windows"
        $AzCopy = Save-WebFile -SourceUrl (Invoke-WebRequest -UseBasicParsing 'https://aka.ms/downloadazcopy-v10-windows' -MaximumRedirection 0 -ErrorAction SilentlyContinue).headers.location
        if ($AzCopy) {
            Expand-Archive -Path $AzCopy.FullName -DestinationPath $env:windir\Temp\AzCopy -Force
            Get-ChildItem -Path $env:windir\Temp\AzCopy -Recurse -Include azcopy.exe | foreach {Copy-Item $_.FullName -Destination "$MountPath\Windows\azcopy.exe" -Force -ErrorAction SilentlyContinue}
        }
    }
    if ($AddAws.IsPresent) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Saving AWS Modules to $MountPath\Program Files\WindowsPowerShell\Modules"
        Save-Module -Name AWS.Tools.Common "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
        Save-Module -Name AWS.Tools.S3 -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
    }
    #=================================================
    #   PSModuleInstall
    #=================================================
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
        else {Save-Module -Name $Module -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force} 
    }
    #=================================================
    #   PSModuleCopy
    #=================================================
    foreach ($Module in $PSModuleCopy) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copy-PSModuleToWindowsImage -Name $Module -Path $MountPath"
        Copy-PSModuleToWindowsImage -Name $Module -Path $MountPath
    }
    #=================================================
    #   Save WIM
    #=================================================
    $MountMyWindowsImage | Dismount-MyWindowsImage -Save
    #=================================================
    #	UpdateUSB
    #=================================================
    if ($UpdateUSB) {
        $WinpeVolumes = (Get-USBVolume | Where-Object {$_.FileSystemLabel -eq 'WinPE'}).DriveLetter
    
        if ($WinpeVolumes) {
            foreach ($WinpeVolume in $WinpeVolumes) {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $WorkspacePath\Media to $($WinpeVolume):\"
                robocopy "$WorkspacePath\Media" "$($WinpeVolume):\" *.* /e /ndl /np /njh /njs /b /r:0 /w:0 /zb /xd "$RECYCLE.BIN" "System Volume Information"
            }
        }
    }
    #=================================================
    #	Complete
    #=================================================
    $WinpeEndTime = Get-Date
    $WinpeTimeSpan = New-TimeSpan -Start $WinpeStartTime -End $WinpeEndTime
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($WinpeTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #=================================================
}
function Get-OSDCloudTemplate {
    <#
    .SYNOPSIS
    Returns the path to the OSDCloud Template.  This is typically $env:ProgramData\OSDCloud\Templates\Default

    .DESCRIPTION
    Returns the path to the OSDCloud Template.  This is typically $env:ProgramData\OSDCloud\Templates\Default

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    
    [CmdletBinding()]
    param ()
    #=================================================
    #	Block
    #=================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=================================================
    #   template.json
    #=================================================
    if (Test-Path "$env:ProgramData\OSDCloud\template.json") {
        $TemplateSettings = Get-Content -Path "$env:ProgramData\OSDCloud\template.json" | ConvertFrom-Json
        $OSDCloudTemplate = $TemplateSettings.TemplatePath

        if (! (Test-Path "$OSDCloudTemplate\Media\sources\boot.wim")) {
            $OSDCloudTemplate = "$env:ProgramData\OSDCloud"
            $null = Remove-Item -Path "$env:ProgramData\OSDCloud\template.json" -Force
        }
    }
    else {
        $OSDCloudTemplate = "$env:ProgramData\OSDCloud"
    }
    #=================================================
    #   Template is not complete
    #=================================================
    if (! (Test-Path "$OSDCloudTemplate\Media\sources\boot.wim")) {
        Return $null
    }
    #=================================================
    #   Return Template Path
    #=================================================
    if (Test-Path "$env:ProgramData\OSDCloud\template.json") {
        $TemplateSettings = Get-Content -Path "$env:ProgramData\OSDCloud\template.json" | ConvertFrom-Json
        $OSDCloudTemplate = $TemplateSettings.TemplatePath
        
    }
    Return $OSDCloudTemplate
}
function Get-OSDCloudTemplateNames {
    <#
    .SYNOPSIS
    Returns valid OSDCloud Template Names

    .DESCRIPTION
    Returns valid OSDCloud Template Names

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    
    [CmdletBinding()]
    param ()
    #=================================================
    #	Block
    #=================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=================================================
    #   template.json
    #=================================================
    $Results = @()
    [System.Array]$Results = 'default'
    [System.Array]$Results += Get-ChildItem -Path "$env:ProgramData\OSDCloud\Templates" | Where-Object {$_.PsIsContainer -eq $true} | Select-Object -ExpandProperty Name
    [System.Array]$Results
}
function Get-OSDCloudWorkspace {
    <#
    .SYNOPSIS
    Returns the path to the OSDCloud Workspace by reading the path stored in $env:ProgramData\OSDCloud\workspace.json
    
    .DESCRIPTION
    Returns the path to the OSDCloud Workspace by reading the path stored in $env:ProgramData\OSDCloud\workspace.json
    
    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param ()

    if (Test-Path "$env:ProgramData\OSDCloud\workspace.json") {
        $WorkspaceSettings = Get-Content -Path "$env:ProgramData\OSDCloud\workspace.json" | ConvertFrom-Json
        $WorkspacePath = $WorkspaceSettings.WorkspacePath
        $WorkspacePath
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to locate $env:ProgramData\OSDCloud\workspace.json"
    }
}
function New-OSDCloudISO {
    <#
    .SYNOPSIS
    Creates an .iso file in the OSDCloud Workspace.  ADK is required

    .DESCRIPTION
    Creates an .iso file in the OSDCloud Workspace.  ADK is required

    .EXAMPLE
    New-OSDCloudISO

    .EXAMPLE
    New-OSDCloudISO -WorkspacePath C:\OSDCloud

    .LINK
    https://www.osdcloud.com/setup/osdcloud-iso
    #>

    [CmdletBinding()]
    param (
        #Path to the OSDCloud Workspace containing the Media directory
        #This parameter is not necessary if Get-OSDCloudWorkspace can get a return
        [Parameter(Position=0,ValueFromPipelineByPropertyName)]
        [System.String]$WorkspacePath
    )
    #=================================================
    #	Block
    #=================================================
    Block-NoCurl
    Block-PowerShellVersionLt5
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-WinPE
    #=================================================
    #	Initialize
    #=================================================
    $isoFileName = 'OSDCloud.iso'
    $isoLabel = 'OSDCloud'
    $ErrorActionPreference = 'Stop'
    #=================================================
    #	WorkspacePath
    #=================================================
    if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
        Set-OSDCloudWorkspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    }
    $WorkspacePath = Get-OSDCloudWorkspace -ErrorAction Stop

    if (-NOT ($WorkspacePath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Workspace at $WorkspacePath"
        Break
    }

    if (-NOT (Test-Path $WorkspacePath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Workspace at $WorkspacePath"
        Break
    }

    if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud WinPE at $WorkspacePath\Media\sources\boot.wim"
        Break
    }
    #=================================================
    #   Create ISO
    #=================================================
    $NewADKiso = New-AdkISO -MediaPath "$WorkspacePath\Media" -isoFileName $isoFileName -isoLabel $isoLabel
    #=================================================
    #   Complete
    #=================================================
    #Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-OSDCloudISO is complete"
    #=================================================
}
function New-OSDCloudTemplate {
    <#
    .SYNOPSIS
    Creates an OSDCloud Template in $env:ProgramData\OSDCloud

    .DESCRIPTION
    Creates an OSDCloud Template in $env:ProgramData\OSDCloud

    .EXAMPLE
    New-OSDCloudTemplate

    .EXAMPLE
    New-OSDCloudTemplate -WinRE

    .LINK
    https://www.osdcloud.com/setup/osdcloud-template
    #>

    [CmdletBinding()]
    param (
        [System.String]
        #Name of the OSDCloud Template. This determines the OSDCloud Template Path
        $Name = 'default',

        [ValidateSet (
            '*','ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw'
        )]
        [System.String[]]
        #Adds additional language ADK Packages
        $Language,

        [System.String]
        #Sets all International settings in WinPE to the specified setting
        $SetAllIntl,

        [System.String]
        #Sets the default InputLocale in WinPE to the specified Input Locale
        $SetInputLocale,

        [System.Management.Automation.SwitchParameter]
        #Uses Windows 10 WinRE.wim instead of the ADK Boot.wim
        $WinRE
    )
#=================================================
#   WinREDriver
#=================================================
$WinREDriver = @'
[Version]
Signature   = "$WINDOWS NT$"
Class       = System
ClassGuid   = {4D36E97d-E325-11CE-BFC1-08002BE10318}
Provider    = OSDeploy
DriverVer   = 07/20/2021,2021.07.20.0

[DefaultInstall] 
AddReg      = AddReg 

[AddReg]
;rootkey,[subkey],[value],[flags],[data]
;0x00000    REG_SZ
;0x00001    REG_BINARY
;0x10000    REG_MULTI_SZ
;0x20000    REG_EXPAND_SZ
;0x10001    REG_DWORD
;0x20001    REG_NONE
HKLM,"Software\Microsoft\Windows NT\CurrentVersion\WinPE",CustomBackground,0x10000,"X:\Windows\System32\winpe.jpg"
'@
#=================================================
#   WinPE Console Registry Settings
#=================================================
$RegistryConsole = @'
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\Default\Console]
"ColorTable00"=dword:000c0c0c
"ColorTable01"=dword:00da3700
"ColorTable02"=dword:000ea113
"ColorTable03"=dword:00dd963a
"ColorTable04"=dword:001f0fc5
"ColorTable05"=dword:00981788
"ColorTable06"=dword:00009cc1
"ColorTable07"=dword:00cccccc
"ColorTable08"=dword:00767676
"ColorTable09"=dword:00ff783b
"ColorTable10"=dword:000cc616
"ColorTable11"=dword:00d6d661
"ColorTable12"=dword:005648e7
"ColorTable13"=dword:009e00b4
"ColorTable14"=dword:00a5f1f9
"ColorTable15"=dword:00f2f2f2
"CtrlKeyShortcutsDisabled"=dword:00000000
"CursorColor"=dword:ffffffff
"CursorSize"=dword:00000019
"DefaultBackground"=dword:ffffffff
"DefaultForeground"=dword:ffffffff
"EnableColorSelection"=dword:00000000
"ExtendedEditKey"=dword:00000001
"ExtendedEditKeyCustom"=dword:00000000
"FaceName"="Consolas"
"FilterOnPaste"=dword:00000001
"FontFamily"=dword:00000036
"FontSize"=dword:00140000
"FontWeight"=dword:00000000
"ForceV2"=dword:00000000
"FullScreen"=dword:00000000
"HistoryBufferSize"=dword:00000032
"HistoryNoDup"=dword:00000000
"InsertMode"=dword:00000001
"LineSelection"=dword:00000001
"LineWrap"=dword:00000001
"LoadConIme"=dword:00000001
"NumberOfHistoryBuffers"=dword:00000004
"PopupColors"=dword:000000f5
"QuickEdit"=dword:00000001
"ScreenBufferSize"=dword:23290078
"ScreenColors"=dword:00000007
"ScrollScale"=dword:00000001
"TerminalScrolling"=dword:00000000
"TrimLeadingZeros"=dword:00000000
"WindowAlpha"=dword:000000ff
"WindowSize"=dword:001e0078
"WordDelimiters"=dword:00000000

[HKEY_LOCAL_MACHINE\Default\Console\%SystemRoot%_System32_cmd.exe]
"FaceName"="Consolas"
"FilterOnPaste"=dword:00000000
"FontSize"=dword:00100000
"FontWeight"=dword:00000190
"LineSelection"=dword:00000000
"LineWrap"=dword:00000000
"WindowAlpha"=dword:00000000
"WindowPosition"=dword:00000000
"WindowSize"=dword:00110054

[HKEY_LOCAL_MACHINE\Default\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe]
"ColorTable05"=dword:00562401
"ColorTable06"=dword:00f0edee
"FaceName"="Consolas"
"FilterOnPaste"=dword:00000000
"FontFamily"=dword:00000036
"FontSize"=dword:00140000
"FontWeight"=dword:00000190
"LineSelection"=dword:00000000
"LineWrap"=dword:00000000
"PopupColors"=dword:000000f3
"QuickEdit"=dword:00000001
"ScreenBufferSize"=dword:03e8012c
"ScreenColors"=dword:00000056
"WindowAlpha"=dword:00000000
"WindowSize"=dword:0020006c

[HKEY_LOCAL_MACHINE\Default\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe]
"ColorTable05"=dword:00562401
"ColorTable06"=dword:00f0edee
"FaceName"="Consolas"
"FilterOnPaste"=dword:00000000
"FontFamily"=dword:00000036
"FontSize"=dword:00140000
"FontWeight"=dword:00000190
"LineSelection"=dword:00000000
"LineWrap"=dword:00000000
"PopupColors"=dword:000000f3
"QuickEdit"=dword:00000001
"ScreenBufferSize"=dword:03e8012c
"ScreenColors"=dword:00000056
"WindowAlpha"=dword:00000000
"WindowSize"=dword:0020006c
'@
    #=================================================
    #	Start the Clock
    #=================================================
    $TemplateStartTime = Get-Date
    #=================================================
    #   Header
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name)"
    #=================================================
    #	Block
    #=================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-NoCurl
    #=================================================
    #   Get Adk Paths
    #=================================================
    $AdkPaths = Get-AdkPaths

    if ($null -eq $AdkPaths) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not get ADK going, sorry"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    #=================================================
    #   Test WinRE
    #=================================================
    if ($PSBoundParameters.ContainsKey('WinRE')) {
        if ((Get-WinREPartition).OperationalStatus -ne 'Online') {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You can't use WinRE because of some issue.  Sorry!"
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Break
        }
        if ((Get-RegCurrentVersion).CurrentBuild -gt 20000) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Windows 11 WinRE may not support booting some Virtual Machines"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) It is recommended that you remove the -WinRE parameter if you need Virtual Machine support"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Press Ctrl+C to cancel in the next 10 seconds"
            Start-Sleep -Seconds 10
            Write-Host -ForegroundColor DarkGray "========================================================================="
        }
    }
    #=================================================
    #   Test WimSourcePath
    #=================================================
    $WimSourcePath = $AdkPaths.WimSourcePath
    if (-NOT (Test-Path $WimSourcePath)) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not find the ADK WimSourcePath: $WimSourcePath"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    #=================================================
    #   Template
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    if ($Name -eq 'default') {
        $OSDCloudTemplate = "$env:ProgramData\OSDCloud"
    }
    else {
        $OSDCloudTemplate = "$env:ProgramData\OSDCloud\Templates\$Name"
    }

    if (-NOT (Test-Path $OSDCloudTemplate)) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloud Template: $OSDCloudTemplate"
        $null = New-Item -Path $OSDCloudTemplate -ItemType Directory -Force
    }
    #=================================================
    #   Logs
    #=================================================
    $TemplateLogs = "$OSDCloudTemplate\Logs\Template"
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloud Template Logs at $TemplateLogs"

    if (Test-Path $TemplateLogs) {
        $null = Remove-Item -Path "$TemplateLogs\*" -Recurse -Force -ErrorAction Ignore | Out-Null
    }
    if (-NOT (Test-Path $TemplateLogs)) {
        $null = New-Item -Path $TemplateLogs -ItemType Directory -Force | Out-Null
    }

    $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-New-OSDCloudTemplate.log"
    Start-Transcript -Path (Join-Path $TemplateLogs $Transcript) -ErrorAction Ignore
    #=================================================
    #   Mirror ADK Media
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mirroring ADK Media using Robocopy"
    Write-Host -ForegroundColor Yellow 'Mirroring will remove any previous WinPE and will force a full rebuild'
    
    $PathWinPEMedia = $AdkPaths.PathWinPEMedia
    Write-Host -ForegroundColor DarkGray "Source: $PathWinPEMedia"

    $DestinationMedia = Join-Path $OSDCloudTemplate 'Media'
    Write-Host -ForegroundColor DarkGray "Destination: $DestinationMedia"

    $null = robocopy "$PathWinPEMedia" "$DestinationMedia" *.* /mir /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
    #=================================================
    #   Copy Boot.wim
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    $DestinationSources = Join-Path $DestinationMedia 'sources'
    if (-NOT (Test-Path "$DestinationSources")) {
        New-Item -Path "$DestinationSources" -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    if ($PSBoundParameters.ContainsKey('WinRE')) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying WinRE.wim"
        Write-Host -ForegroundColor Yellow "OSD Function: Copy-WinREWIM"

        $BootWim = Join-Path $DestinationSources 'winre.wim'
        Write-Host -ForegroundColor DarkGray "Destination: $BootWim"

        Copy-WinREWIM -DestinationDirectory $DestinationSources -DestinationFileName 'winre.wim' -ErrorAction Stop | Out-Null
    }
    else {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying ADK WinPE.wim"
        $BootWim = Join-Path $DestinationSources 'boot.wim'
        Write-Host -ForegroundColor DarkGray "Source: $WimSourcePath"
        Write-Host -ForegroundColor DarkGray "Destination: $BootWim"

        Copy-Item -Path $WimSourcePath -Destination $BootWim -Force -ErrorAction Stop | Out-Null
    }
    #=================================================
    #   Test BootWim
    #=================================================
    if (!(Test-Path $BootWim)) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Warning "I'm not sure what happened, but I can't find $BootWim"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    attrib -s -h -r $DestinationSources
    attrib -s -h -r $BootWim
    #=================================================
    #   Download wgl4_boot.ttf
    #   This is used to resolve issues with WinPE Resolutions in 2004/20H2
    #=================================================
    if ((Get-RegCurrentVersion).CurrentBuild -lt 20000) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Replacing Boot Media font wgl4_boot.ttf"
        Write-Host -ForegroundColor Yellow "Replacing this file resolves an issue where WinPE does not boot to the proper display resolution"
    
        $SourceUrl = 'https://github.com/OSDeploy/OSDCloud/raw/main/Media/boot/fonts/wgl4_boot.ttf'
        if (Test-WebConnection -Uri $SourceUrl) {
            Write-Host -ForegroundColor DarkGray "Source: $SourceUrl"
            Write-Host -ForegroundColor DarkGray "Destination: $DestinationMedia\boot\fonts\wgl4_boot.ttf"
            Save-WebFile -SourceUrl $SourceUrl -DestinationDirectory "$DestinationMedia\boot\fonts" -Overwrite | Out-Null
        }
    
        $SourceUrl = 'https://github.com/OSDeploy/OSDCloud/raw/main/Media/efi/microsoft/boot/fonts/wgl4_boot.ttf'
        if (Test-WebConnection -Uri $SourceUrl) {
            Write-Host -ForegroundColor DarkGray "Source: $SourceUrl"
            Write-Host -ForegroundColor DarkGray "Destination: $DestinationMedia\efi\microsoft\boot\fonts\wgl4_boot.ttf"
            Save-WebFile -SourceUrl $SourceUrl -DestinationDirectory "$DestinationMedia\efi\microsoft\boot\fonts" -Overwrite | Out-Null
        }
    }
    #=================================================
    #   Mount-MyWindowsImage
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Mount Boot.wim"
    Write-Host -ForegroundColor Yellow "OSD Function: Mount-MyWindowsImage"
    $MountMyWindowsImage = Mount-MyWindowsImage $BootWim
    $MountPath = $MountMyWindowsImage.Path
    Write-Host -ForegroundColor DarkGray "MountPath: $MountPath"
    #=================================================
    #   WinRE
    #=================================================
    if ($PSBoundParameters.ContainsKey('WinRE')) {
        #=================================================
        #	Wallpaper
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) WinRE Wallpaper"
        Write-Host -ForegroundColor Yellow "WinRE does not use the standard winpe.jpg and uses an all black winre.jpg"
        Write-Host -ForegroundColor Yellow "This step adds the default WinPE Wallpaper and modifies the Registry to point to winpe.jpg"

        $Wallpaper = '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAIBAQIBAQICAgICAgICAwUDAwMDAwYEBAMFBwYHBwcGBwcICQsJCAgKCAcHCg0KCgsMDAwMBwkODw0MDgsMDAz/2wBDAQICAgMDAwYDAwYMCAcIDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAz/wAARCAAgACADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD5vooor+sD+KwooooAKKKKACiiigD/2Q=='
        [byte[]]$Bytes = [convert]::FromBase64String($Wallpaper)
        [System.IO.File]::WriteAllBytes("$env:TEMP\winpe.jpg",$Bytes)
        #[System.IO.File]::WriteAllBytes("$env:TEMP\winre.jpg",$Bytes)

        Write-Host -ForegroundColor DarkGray "Injecting $MountPath\Windows\System32\winpe.jpg"
        $null = robocopy "$env:TEMP" "$MountPath\Windows\System32" winpe.jpg /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log

        #Write-Host -ForegroundColor DarkGray "Injecting $MountPath\Windows\System32\winre.jpg"
        #$null = robocopy "$env:TEMP" "$MountPath\Windows\System32" winre.jpg /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
        #=================================================
        #   Build Driver
        #=================================================
        $InfFile = "$env:Temp\Set-WinREWallpaper.inf"
        New-Item -Path $InfFile -Force
        Set-Content -Path $InfFile -Value $WinREDriver -Encoding Unicode -Force
        #=================================================
        #   Add Driver
        #=================================================
        Add-WindowsDriver -Path $MountPath -Driver $InfFile -ForceUnsigned
        #=================================================
        #	Wireless
        #=================================================
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) WinRE Wireless"
        Write-Host -ForegroundColor Yellow "These files need to be added to support Wireless"

        $SourceFile = "$env:SystemRoot\System32\dmcmnutils.dll"
        if (Test-Path $SourceFile) {
            Write-Host -ForegroundColor DarkGray $SourceFile
            $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" dmcmnutils.dll /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
        }
        else {
            Write-Warning "Could not find $SourceFile"
        }

        $SourceFile = "$env:SystemRoot\System32\mdmpostprocessevaluator.dll"
        if (Test-Path $SourceFile) {
            Write-Host -ForegroundColor DarkGray $SourceFile
            $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" mdmpostprocessevaluator.dll /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
        }
        else {
            Write-Warning "Could not find $SourceFile"
        }

        $SourceFile = "$env:SystemRoot\System32\mdmregistration.dll"
        if (Test-Path $SourceFile) {
            Write-Host -ForegroundColor DarkGray $SourceFile
            $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" mdmregistration.dll /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
        }
        else {
            Write-Warning "Could not find $SourceFile"
        }

        Write-Host -ForegroundColor DarkGray "Downloading https://github.com/okieselbach/Helpers/raw/master/WirelessConnect/WirelessConnect/bin/Release/WirelessConnect.exe"
        Save-WebFile -SourceUrl 'https://github.com/okieselbach/Helpers/raw/master/WirelessConnect/WirelessConnect/bin/Release/WirelessConnect.exe' -DestinationDirectory "$MountPath\Windows" | Out-Null
    }
    #=================================================
    #   ADK Packages
    #=================================================
    $ErrorActionPreference = 'Ignore'
    $WinPEOCs = $AdkPaths.WinPEOCs

    $OCPackages = @(
        'WMI'
        'HTA'
        'NetFx'
        'Scripting'
        'PowerShell'
        'SecureStartup'
        'DismCmdlets'
        'Dot3Svc'
        'EnhancedStorage'
        'FMAPI'
        'GamingPeripherals'
        'PPPoE'
        'PlatformId'
        'PmemCmdlets'
        'RNDIS'
        'SecureBootCmdlets'
        'StorageWMI'
        'WDS-Tools'
    )
    #=================================================
    #   Install Default en-us Language
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Adding default en-US ADK Packages"
    Write-Host -ForegroundColor Yellow "Dism Function: Add-WindowsPackage"
    $Lang = 'en-us'

    foreach ($Package in $OCPackages) {
        $SourceFile = "$WinPEOCs\WinPE-$Package.cab"
        if (Test-Path $SourceFile) {
            Write-Host -ForegroundColor DarkGray "$SourceFile"
            $PackageName = "Add-WindowsPackage-WinPE-$Package"
            $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$PackageName.log"
            
            Try {Add-WindowsPackage -Path $MountPath -PackagePath $SourceFile -LogPath "$CurrentLog" | Out-Null}
            Catch {Write-Host -ForegroundColor Red $CurrentLog}
        }
    }

    $SourceFile = "$WinPEOCs\$Lang\lp.cab"
    if (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray "$SourceFile"
        $PackageName = "Add-WindowsPackage-WinPE-lp_$Lang"
        $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$PackageName.log"

        Try {Add-WindowsPackage -Path $MountPath -PackagePath $SourceFile -LogPath "$CurrentLog" | Out-Null}
        Catch {Write-Host -ForegroundColor Red $CurrentLog}
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }

    foreach ($Package in $OCPackages) {
        $SourceFile = "$WinPEOCs\$Lang\WinPE-$Package`_$Lang.cab"
        if (Test-Path $SourceFile) {
            Write-Host -ForegroundColor DarkGray "$SourceFile"
            $PackageName = "Add-WindowsPackage-WinPE-$Package`_$Lang"
            $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$PackageName.log"
            
            Try {Add-WindowsPackage -Path $MountPath -PackagePath $SourceFile -LogPath "$CurrentLog" | Out-Null}
            Catch {Write-Host -ForegroundColor Red $CurrentLog}
        }
    }
    #=================================================
    #   Save-WindowsImage
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save Windows Image"
    Write-Host -ForegroundColor Yellow "Dism Function: Save-WindowsImage"

    $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Save-WindowsImage.log"
    Save-WindowsImage -Path $MountPath -LogPath $CurrentLog | Out-Null
    #=================================================
    #   Install Selected Language
    #=================================================
    if ($Language -contains '*') {
        $Language = Get-ChildItem $WinPEOCs -Directory | Where-Object {$_.Name -ne 'en-us'} | Select-Object -ExpandProperty Name
    }

    foreach ($Lang in $Language) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Adding $Lang ADK Packages"
        Write-Host -ForegroundColor Yellow "Dism Function: Add-WindowsPackage"

        $SourceFile = "$WinPEOCs\$Lang\lp.cab"
        if (Test-Path $SourceFile) {
            Write-Host -ForegroundColor DarkGray "$SourceFile"
            $PackageName = "Add-WindowsPackage-WinPE-lp_$Lang"
            $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$PackageName.log"
    
            Try {Add-WindowsPackage -Path $MountPath -PackagePath $SourceFile -LogPath "$CurrentLog" | Out-Null}
            Catch {Write-Host -ForegroundColor Red $CurrentLog}
        }
        else {
            Write-Warning "Could not find $SourceFile"
        }

        foreach ($Package in $OCPackages) {
            $SourceFile = "$WinPEOCs\$Lang\WinPE-$Package`_$Lang.cab"
            if (Test-Path $SourceFile) {
                Write-Host -ForegroundColor DarkGray "$SourceFile"
                $PackageName = "Add-WindowsPackage-WinPE-$Package`_$Lang"
                $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$PackageName.log"
                
                Try {Add-WindowsPackage -Path $MountPath -PackagePath $SourceFile -LogPath "$CurrentLog" | Out-Null}
                Catch {Write-Host -ForegroundColor Red $CurrentLog}
            }
        }
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save Windows Image"
        Write-Host -ForegroundColor Yellow "Dism Function: Save-WindowsImage"
        $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Save-WindowsImage.log"
        Save-WindowsImage -Path $MountPath -LogPath $CurrentLog | Out-Null
    }
    #=================================================
    #   International Settings
    #=================================================
    if ($SetAllIntl -or $SetInputLocale) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Current Get-Intl Settings"
        Dism /image:"$MountPath" /Get-Intl
    }

    if ($SetAllIntl) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Applying Set-AllIntl"
        Dism /image:"$MountPath" /Set-AllIntl:$SetAllIntl
    }

    if ($SetInputLocale) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Applying Set-InputLocale"
        Dism /image:"$MountPath" /Set-InputLocale:$SetInputLocale
    }

    if ($SetAllIntl -or $SetInputLocale) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Updated Get-Intl Settings"
        Dism /image:"$MountPath" /Get-Intl
    }
    #=================================================
    #	Additional Files
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) WinPE Additional Files"
    #=================================================
    #	curl.exe
    #=================================================
    Write-Host -ForegroundColor Yellow "cURL is required for downloading files in WinPE"
    $SourceFile = "$env:SystemRoot\System32\curl.exe"
    Write-Host -ForegroundColor DarkGray $SourceFile
    if (Test-Path $SourceFile) {
        $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" curl.exe /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }
    #=================================================
    #	setx.exe
    #=================================================
    Write-Host -ForegroundColor Yellow "Setx is required for setting System Variables"
    $SourceFile = "$env:SystemRoot\System32\setx.exe"
    if (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray $SourceFile
        $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" setx.exe /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }
    #=================================================
    #	msinfo32.exe
    #=================================================
    Write-Host -ForegroundColor Yellow "MSInfo32 is helpful for verifying Hardware in WinPE"
    $SourceFile = "$env:SystemRoot\System32\msinfo32.exe"
    if (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray $SourceFile
        Write-Host -ForegroundColor DarkGray "$env:SystemRoot\System32\*\msinfo32.exe.mui"
        $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" msinfo32.exe /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
        $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" msinfo32.exe.mui /s /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }
    #=================================================
    #	osk.exe
    #=================================================
    Write-Host -ForegroundColor Yellow "OSK adds WinPE On Screen Keyboard"
    $SourceFile = "$env:SystemRoot\System32\osk.exe"
    if (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray $SourceFile
        $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" osk.exe /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
        $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" osksupport.dll /s /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }
    $SourceFile = "$env:SystemRoot\System32\osksupport.dll"
    if (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray $SourceFile
        $null = robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" osksupport.dll /b /ndl /np /r:0 /w:0 /xj /LOG+:$TemplateLogs\Robocopy.log
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }
    #=================================================
    #   Adding Microsoft DartConfig from MDT
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Microsoft DaRT Config from MDT"
    $SourceFile = "$env:ProgramFiles\Microsoft Deployment Toolkit\Templates\DartConfig8.dat"
    if (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray $SourceFile
        Copy-Item -Path $SourceFile -Destination "$MountPath\Windows\System32\DartConfig.dat" -Force
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }
    #=================================================
    #   Adding Microsoft DaRT
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Microsoft DaRT"
    $SourceFile = "$env:ProgramFiles\Microsoft DaRT\v10\Toolsx64.cab"
    if ($Name -match 'public') {
        Write-Host -ForegroundColor DarkGray 'Skipping Microsoft DaRT for Public Template'
    }
    elseif (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray $SourceFile
        expand.exe "$SourceFile" -F:*.* "$MountPath" | Out-Null
        if (!(Test-Path "$MountPath\Windows\System32\DartConfig.dat")) {
            Write-Warning "Microsoft DaRT requires MDT to be installed so DartConfig.dat can be copied"
        }
    }
    else {
        Write-Warning "Could not find $SourceFile"
    }
    #=================================================
    #	Save-WindowsImage
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Save Windows Image"
    Write-Host -ForegroundColor Yellow "Dism Function: Save-WindowsImage"

    $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Save-WindowsImage.log"
    Save-WindowsImage -Path $MountPath -LogPath $CurrentLog | Out-Null
    #=================================================
    #	PowerShell Execution Policy
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set WinPE PowerShell ExecutionPolicy to Bypass"
    Write-Host -ForegroundColor Yellow "OSD Function: Set-WindowsImageExecutionPolicy"
    Set-WindowsImageExecutionPolicy -Path $MountPath -ExecutionPolicy Bypass | Out-Null
    #=================================================
    #   Enable PowerShell Gallery
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Enable WinPE PowerShell Gallery"
    Write-Host -ForegroundColor Yellow "OSD Function: Enable-PEWindowsImagePSGallery"
    Enable-PEWindowsImagePSGallery -Path $MountPath | Out-Null
    #=================================================
    #   Remove winpeshl
    #=================================================
    $SourceFile = "$MountPath\Windows\System32\winpeshl.ini"
    if (Test-Path $SourceFile) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Removing WinRE $SourceFile"
        Write-Host -ForegroundColor Yellow "This file is present when using WinRE.wim and needs to be removed for WinPE compatibility"
        Remove-Item -Path $SourceFile -Force
    }
    #=================================================
    #   Registry Fixes
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Modifying WinPE CMD and PowerShell Console settings"
    Write-Host -ForegroundColor Yellow "This increases the buffer and sets the window metrics and default fonts"
    $RegistryConsole | Out-File -FilePath "$env:TEMP\RegistryConsole.reg" -Encoding ascii -Width 2000 -Force

    #Mount Registry
    Invoke-Exe reg load HKLM\Default "$MountPath\Windows\System32\Config\DEFAULT"
    Invoke-Exe reg import "$env:TEMP\RegistryConsole.reg"

    #Scaling
<#     reg add "HKLM\Default\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /t REG_SZ /v "X:\Windows\System32\WirelessConnect.exe" /d "~ HIGHDPIAWARE" /f
    reg add "HKLM\Default\Control Panel\Desktop" /t REG_DWORD /v LogPixels /d 96 /f
    reg add "HKLM\Default\Control Panel\Desktop" /v Win8DpiScaling /t REG_DWORD /d 0x00000001 /f
    reg add "HKLM\Default\Control Panel\Desktop" /v DpiScalingVer /t REG_DWORD /d 0x00001018 /f #>

    #Unload Registry
    Invoke-Exe reg unload HKLM\Default | Out-Null
    #=================================================
    #   Apply Packages
    #=================================================
    if (Test-Path "$env:ProgramData\OSDCloud\Packages\LCU") {
        $PackagesLCU = Get-ChildItem -Path "$env:ProgramData\OSDCloud\Packages\LCU" *.msu -Recurse

        if ($PackagesLCU) {
            Write-Host -ForegroundColor DarkGray "========================================================================="
            foreach ($Package in $PackagesLCU) {
                Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Applying Package $($Package.FullName)"
                Add-WindowsPackage -Path $MountPath -PackagePath $Package.FullName -ErrorAction SilentlyContinue
            }
            DISM /Image:"$MountPath" /Cleanup-Image /StartComponentCleanup | Out-Null
            # Save serviced boot manager files later copy to the root media.
            Copy-Item -Path "$MountPath\Windows\boot\efi\bootmgfw.efi" -Destination "$DestinationMedia\bootmgfw.efi" -Force -ErrorAction stop | Out-Null
            Copy-Item -Path "$MountPath\Windows\boot\efi\bootmgr.efi" -Destination "$DestinationMedia\bootmgr.efi" -Force -ErrorAction stop | Out-Null
        }
        Get-WindowsPackage -Path $MountPath | Sort-Object -Property InstallTime -Descending | Format-Table -AutoSize
    }
    #=================================================
    #   Save WIM
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Dismounting and Saving Windows Image"
    Write-Host -ForegroundColor Yellow "OSD Function: Dismount-MyWindowsImage"
    $MountMyWindowsImage | Dismount-MyWindowsImage -Save
    #=================================================
    #   Save WIM
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Exporting Boot.wim"
    if ($PSBoundParameters.ContainsKey('WinRE')) {
        $BootWim = Join-Path $DestinationSources 'boot.wim'
        $WinREWim = Join-Path $DestinationSources 'winre.wim'

        if (Test-Path $BootWim) {
            Remove-Item -Path $BootWim -Force -ErrorAction Stop | Out-Null
        }
        Write-Host -ForegroundColor Yellow "Dism Function: Export-WindowsImage"
        $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Export-WindowsImage.log"
        Export-WindowsImage -SourceImagePath $WinREWim -SourceIndex 1 -DestinationImagePath $BootWim -DestinationName 'Microsoft Windows PE (x64)' -LogPath $CurrentLog | Out-Null
        Remove-Item -Path $WinREWim -Force -ErrorAction Stop | Out-Null
    }
    else {
        $SourceImage = Join-Path $DestinationSources 'boot.wim'
        $DestinationImage = Join-Path $DestinationSources 'export.wim'

        if (Test-Path $DestinationImage) {
            Remove-Item -Path $DestinationImage -Force -ErrorAction Stop | Out-Null
        }
        Write-Host -ForegroundColor Yellow "Dism Function: Export-WindowsImage"
        $CurrentLog = "$TemplateLogs\$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Export-WindowsImage.log"
        Export-WindowsImage -SourceImagePath $SourceImage -SourceIndex 1 -DestinationImagePath $DestinationImage -LogPath $CurrentLog | Out-Null
        Remove-Item -Path $SourceImage -Force -ErrorAction Stop | Out-Null
        Rename-Item -Path $DestinationImage -NewName 'boot.wim' -Force -ErrorAction Stop | Out-Null
    }
    #=================================================
    #   Directories
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Create Config Directories"

    $CreateDirectories = @(
        'Config\AutopilotJSON',
        'Config\AutopilotOOBE',
        'Config\OOBEDeploy',
        'Config\Scripts\Shutdown',
        'Config\Scripts\Startup',
        'Config\Scripts\StartNet'
    )
    
    if ($Name -match 'public') {
        Write-Host -ForegroundColor DarkGray 'Skipping Config Directories for Public Template'
    }
    else {
        foreach ($Item in $CreateDirectories) {
            $SourcePath = "$OSDCloudTemplate\$Item"
            if (-NOT (Test-Path $SourcePath)) {
                Write-Host -ForegroundColor DarkGray $SourcePath
                New-Item -Path $SourcePath -ItemType Directory -Force | Out-Null
            }
        }
    }
    #=================================================
    #   New-OSDCloudISO
    #=================================================
    $isoFileName = 'OSDCloud.iso'
    $isoLabel = 'OSDCloud'
    $NewADKiso = New-AdkISO -MediaPath "$OSDCloudTemplate\Media" -isoFileName $isoFileName -isoLabel $isoLabel
    #=================================================
    #	OSDCloud Template Version
    #=================================================
    $WinPE = [PSCustomObject]@{
        BuildDate = (Get-Date).ToString('yyyy.MM.dd.HHmmss')
        Version = [Version](Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
    }

    $WinPE | ConvertTo-Json | Out-File "$OSDCloudTemplate\winpe.json" -Encoding ascii -Width 2000 -Force
    #=================================================
    #	Set-OSDCloudTemplate
    #=================================================
    Set-OSDCloudTemplate -Name $Name
    #=================================================
    #	Complete
    #=================================================
    $TemplateEndTime = Get-Date
    $TemplateTimeSpan = New-TimeSpan -Start $TemplateStartTime -End $TemplateEndTime
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($TemplateTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    Write-Host -ForegroundColor Cyan        "OSDCloud Template created at $OSDCloudTemplate"
    Write-Host -ForegroundColor DarkGray    "================================================"
    Stop-Transcript
    #=================================================
}
function New-OSDCloudUSB {
    <#
    .SYNOPSIS
    Creates an OSDCloud USB Drive and copies the contents of the OSDCloud Workspace Media directory
    Clear, Initialize, Partition (WinPE and OSDCloudUSB), and Format a USB Disk
    Requires Admin Rights

    .DESCRIPTION
    Creates an OSDCloud USB Drive and copies the contents of the OSDCloud Workspace Media directory
    Clear, Initialize, Partition (WinPE and OSDCloud), and Format a USB Disk
    Requires Admin Rights

    .EXAMPLE
    New-OSDCloudUSB -WorkspacePath C:\OSDCloud

    .EXAMPLE
    New-OSDCloudUSB -fromIsoFile D:\osdcloud.iso

    .EXAMPLE
    New-OSDCloudUSB -fromIsoUrl https://contoso.blob.core.windows.net/public/osdcloud.iso

    .LINK
    https://www.osdcloud.com/setup/osdcloud-usb
    #>

    [CmdletBinding(DefaultParameterSetName='Workspace')]
    param (
        #Path to the OSDCloud Workspace containing the Media directory
        #This parameter is not necessary if Get-OSDCloudWorkspace can get a return
        [Parameter(ParameterSetName='Workspace',ValueFromPipelineByPropertyName)]
        [System.String]$WorkspacePath,
        
        #Path to an OSDCloud ISO
        #This file will be mounted and the contents will be copied to the OSDCloud USB
        [Parameter(ParameterSetName='fromIsoFile',Mandatory)]
        [System.IO.FileInfo]$fromIsoFile,
        
        #Path to an OSDCloud ISO saved on the internet
        #This file will be downloaded and mounted and the contents will be copied to the OSDCloud USB
        [Parameter(ParameterSetName='fromIsoUrl',Mandatory)]
        [System.String]$fromIsoUrl
    )
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    Block-WindowsReleaseIdLt1703
    Block-WinPE
    #=================================================
    #	Initialize
    #=================================================
    $BootLabel = 'WinPE'
    $DataLabel = 'OSDCloudUSB'
    $ErrorActionPreference = 'Stop'
    $WinpeSourcePath = $null
    #=================================================
    #	Resolve Workspace
    #=================================================
    if ($PSCmdlet.ParameterSetName -eq 'Workspace') {
        if ($PSBoundParameters.ContainsKey('WorkspacePath')) {
            Set-OSDCloudWorkspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
        }
        $WorkspacePath = Get-OSDCloudWorkspace -ErrorAction Stop
    
        if (-NOT ($WorkspacePath)) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Workspace"
            Break
        }
    
        if (-NOT (Test-Path $WorkspacePath)) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud Workspace at $WorkspacePath"
            Break
        }
    
        if (-NOT (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud WinPE at $WorkspacePath\Media\sources\boot.wim"
            Break
        }
        
        $WinpeSourcePath = "$WorkspacePath\Media"
    }
    #=================================================
    #	Resolve fromIsoFile
    #=================================================
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
    #=================================================
    #	Resolve CloudISO
    #=================================================
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
    #=================================================
    #	New-BootableUSBDrive
    #=================================================
    $BootableUSBDrive = New-BootableUSBDrive -BootLabel $BootLabel -DataLabel $DataLabel
    #=================================================
    #	Test USB Volumes
    #=================================================
    $WinPEPartition = Get-USBPartition | Where-Object {($_.DiskNumber -eq $BootableUSBDrive.DiskNumber) -and ($_.PartitionNumber -eq 2)}
    if (-NOT ($WinPEPartition)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to create OSDCloud WinPE Partition"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
        Break
    }
    $OSDCloudPartition = Get-USBPartition | Where-Object {($_.DiskNumber -eq $BootableUSBDrive.DiskNumber) -and ($_.PartitionNumber -eq 1)}
    if (-NOT ($OSDCloudPartition)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to create OSDCloud Data Partition"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Something went very very wrong in this process"
        Break
    }
    #=================================================
    #	WinpeDestinationPath
    #=================================================
    $WinpeDestinationPath = "$($WinPEPartition.DriveLetter):\"
    if (-NOT ($WinpeDestinationPath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find Destination Path at $WinpeDestinationPath"
        Break
    }
    #=================================================
    #	Update WinPE Volume
    #=================================================
    if ((Test-Path -Path "$WinpeSourcePath") -and (Test-Path -Path "$WinpeDestinationPath")) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Copying $WinpeSourcePath to OSDCloud WinPE partition at $WinpeDestinationPath"
        robocopy "$WinpeSourcePath" "$WinpeDestinationPath" *.* /e /ndl /njh /njs /np /r:0 /w:0 /b /zb
    }
    #=================================================
    #	Remove Read-Only Attribute
    #=================================================
    Get-ChildItem -Path $WinpeDestinationPath -File -Recurse -Force | foreach {
        Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $false -Force -ErrorAction Ignore
    }
    #=================================================
    #   Dismount OSDCloudISO
    #=================================================
    if ($MountDiskImage) {
        Start-Sleep -Seconds 3
        Write-Verbose "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Dismounting $($MountDiskImage.ImagePath)"
        $null = Dismount-DiskImage -ImagePath $MountDiskImage.ImagePath
    }
    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-OSDCloudUSB is complete"
    #=================================================
}
function New-OSDCloudWorkspace {
    <#
    .SYNOPSIS
    Creates or updates an OSDCloud Workspace

    .DESCRIPTION
    Creates or updates an OSDCloud Workspace

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
    #=================================================
    #	Blocks
    #=================================================
    Block-NoCurl
    Block-PowerShellVersionLt5
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-WinPE
    #=================================================
    #	Initialize
    #=================================================
    $ErrorActionPreference = 'Stop'
    $WinpeSourcePath = $null
    #=================================================
    #	Initialize Workspace
    #=================================================
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
    #=================================================
    #	Initialize fromIsoFile
    #=================================================
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
    #=================================================
    #	Initialize CloudISO
    #=================================================
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
    #=================================================
    #	Initialize fromUsbDrive
    #=================================================
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
    #=================================================
    #	Workspace
    #================================================
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
    #=================================================
    #   Logs
    #=================================================
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
    #=================================================
    #	Mirror Content
    #=================================================
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
    #=================================================
    #	Remove Read-Only Attribute
    #=================================================
    if ($WinpeDestinationPath) {
        Get-ChildItem -Path $WinpeDestinationPath -File -Recurse -Force | foreach {
            Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $false -Force -ErrorAction Ignore
        }
    }
    #=================================================
    #   Dismount OSDCloudISO
    #=================================================
    if ($MountDiskImage) {
        Start-Sleep -Seconds 3
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Dismounting $($MountDiskImage.ImagePath)"
        $null = Dismount-DiskImage -ImagePath $MountDiskImage.ImagePath
    }
    #=================================================
    #	Set WorkspacePath
    #=================================================
    Set-OSDCloudWorkspace -WorkspacePath $WorkspacePath -ErrorAction Stop | Out-Null
    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Yellow "Find your current OSDCloud Workspace:   " -NoNewline
    Write-Host -ForegroundColor Gray "Get-OSDCloudWorkspace"
    Write-Host -ForegroundColor Yellow "Set a default OSDCloud Workspace:       " -NoNewline
    Write-Host -ForegroundColor Gray "Set-OSDCloudWorkspace C:\OSDCloud2"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) New-OSDCloudWorkspace created at $WorkspacePath"
    $null = Stop-Transcript -ErrorAction Ignore
    #=================================================
}
function Set-OSDCloudTemplate {
    <#
    .SYNOPSIS
    Changes the path to the OSDCloud Template to $env:ProgramData\OSDCloud

    .DESCRIPTION
    Changes the path to the OSDCloud Template to $env:ProgramData\OSDCloud

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [System.String]
        #Name of the OSDCloud Template
        $Name = 'default'
    )
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-PowerShellVersionLt5
    Block-WinPE
    #=================================================
    #	Set Template Path
    #=================================================
    if ($Name -ne 'default') {
        $OSDCloudTemplate = "$env:ProgramData\OSDCloud\Templates\$Name"

        if (-NOT (Test-Path "$OSDCloudTemplate\Media\sources\boot.wim")) {
            $Name = 'default'
        }
    }

    if ($Name -eq 'default') {
        $OSDCloudTemplate = "$env:ProgramData\OSDCloud"
        if (Test-Path "$env:ProgramData\OSDCloud\template.json") {
            $null = Remove-Item -Path "$env:ProgramData\OSDCloud\template.json" -Force
        }
    }
    else {
        $TemplateSettings = [PSCustomObject]@{
            TemplatePath = $OSDCloudTemplate
        }
    
        $TemplateSettings | ConvertTo-Json | Out-File "$env:ProgramData\OSDCloud\template.json" -Encoding ascii -Width 2000 -Force
    }

    $OSDCloudTemplate

<#     if ((Test-Path "$env:ProgramData\OSDCloud\Config") -or (Test-Path "$env:ProgramData\OSDCloud\Logs") -or (Test-Path "$env:ProgramData\OSDCloud\Media")) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Migrating existing OSDCloud Template to $OSDCloudTemplate"
        $null = robocopy "$env:ProgramData\OSDCloud\Config" "$OSDCloudTemplate\Config" *.* /move /e /np /njh /njs /r:0 /w:0
        $null = robocopy "$env:ProgramData\OSDCloud\Autopilot\Profiles" "$OSDCloudTemplate\Config\AutopilotJSON" *.* /move /e /np /njh /njs /r:0 /w:0
        $null = robocopy "$env:ProgramData\OSDCloud\Logs" "$OSDCloudTemplate\Logs" *.* /move /e /np /njh /njs /r:0 /w:0
        $null = robocopy "$env:ProgramData\OSDCloud\Media" "$OSDCloudTemplate\Media" *.* /move /e /np /njh /njs /r:0 /w:0
        $null = robocopy "$env:ProgramData\OSDCloud" "$OSDCloudTemplate" winpe.json /move /np /njh /njs /r:0 /w:0
        $null = robocopy "$env:ProgramData\OSDCloud" "$OSDCloudTemplate" *.iso /move /np /njh /njs /r:0 /w:0
    } #>
}
Register-ArgumentCompleter -CommandName Set-OSDCloudTemplate -ParameterName Name -ScriptBlock {Get-OSDCloudTemplateNames}
<#
.SYNOPSIS
Changes the path to the OSDCloud Workspace

.DESCRIPTION
Changes the path to the OSDCloud Workspace from an OSDCloud Template

.PARAMETER WorkspacePath
Directory for the OSDCloud Workspace to set.  Default is $env:SystemDrive\OSDCloud

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs
#>
function Set-OSDCloudWorkspace {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [System.String]$WorkspacePath = "$env:SystemDrive\OSDCloud"
    )
    #=================================================
    #	Block
    #=================================================
    Block-StandardUser
    Block-PowerShellVersionLt5
    Block-WinPE
    #=================================================
    #	Set-OSDCloudWorkspace
    #=================================================
    $WorkspaceSettings = [PSCustomObject]@{
        WorkspacePath = $WorkspacePath
    }

    if (-not (Test-Path "$env:ProgramData\OSDCloud")) {
        $null = New-Item -Path "$env:ProgramData\OSDCloud" -ItemType Directory -Force -ErrorAction Stop
    }

    $WorkspaceSettings | ConvertTo-Json | Out-File "$env:ProgramData\OSDCloud\workspace.json" -Encoding ascii -Width 2000 -Force

    $WorkspacePath
    #=================================================
}
function Update-OSDCloudUSB {
    <#
    .SYNOPSIS
    Updates an OSDCloud USB by downloading OS and Driver Packs from the internet

    .DESCRIPTION
    Updates an OSDCloud USB by downloading OS and Driver Packs from the internet

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>

    [CmdletBinding()]
    param (
        #Optional. Select one or more of the following Driver Packs to download
        #'*','ThisPC','Dell','HP','Lenovo','Microsoft'
        [ValidateSet('*','ThisPC','Dell','HP','Lenovo','Microsoft')]
        [System.String[]]$DriverPack,

        #Updates the required OSDCloud PowerShell Modules
        [System.Management.Automation.SwitchParameter]$PSUpdate,

        #Optional. Allows the selection of an Operating System to add to the USB
        [System.Management.Automation.SwitchParameter]$OS,

        #Optional. Allows the selection of Driver Packs to download
        #If this parameter is not used, any language can be downloaded downloaded
        [ValidateSet (
            'ar-sa','bg-bg','cs-cz','da-dk','de-de','el-gr',
            'en-gb','en-us','es-es','es-mx','et-ee','fi-fi',
            'fr-ca','fr-fr','he-il','hr-hr','hu-hu','it-it',
            'ja-jp','ko-kr','lt-lt','lv-lv','nb-no','nl-nl',
            'pl-pl','pt-br','pt-pt','ro-ro','ru-ru','sk-sk',
            'sl-si','sr-latn-rs','sv-se','th-th','tr-tr',
            'uk-ua','zh-cn','zh-tw'
        )]
        [System.String]$OSLanguage,

        #Optional. Selects the proper OS License
        #If this parameter is not used, Operating Systems with the specified License can be downloaded
        #'Retail','Volume'
        [Alias('Activation','License','OSLicense')]
        [ValidateSet('Retail','Volume')]
        [System.String]$OSActivation,

        #Optional. Selects an Operating System to download
        #If this parameter is not used, any Operating Systems can be downloaded
        #'Windows 11 22H2','Windows 11 21H2','Windows 10 22H2','Windows 10 21H2','Windows 10 21H1','Windows 10 20H2','Windows 10 2004','Windows 10 1909','Windows 10 1903','Windows 10 1809'
        [ValidateSet(
            'Windows 11 22H2','Windows 11 21H2',
            'Windows 10 22H2','Windows 10 21H2','Windows 10 21H1','Windows 10 20H2','Windows 10 2004',
            'Windows 10 1909H','Windows 10 1903',
            'Windows 10 1809'
            )]
        [System.String]$OSName
    )
    #=================================================
    #	Block
    #=================================================
    Block-WinPE
    Block-PowerShellVersionLt5
    #=================================================
    #	Initialize
    #=================================================
    $UsbVolumes = Get-USBVolume
    $WorkspacePath = Get-OSDCloudWorkspace
    $IsAdmin = Get-OSDGather -Property IsAdmin
    #=================================================
    #	Test USB Volumes
    #   Absolutely need to have USB volumes for this
    #   function to work
    #=================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    if ($UsbVolumes) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) USB volumes found"
        Write-Host -ForegroundColor DarkGray "========================================================================="
    }
    else {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find any USB volumes"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Plug in a USB drive first"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Break
    }
    #=================================================
    #	Test OSDCloud Workspace
    #   Not a big deal, but can't robocopy against it
    #=================================================
    if (! $WorkspacePath) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Workspace is not present on this system"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You will not be able to update the WinPE volume"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        $RobocopyWorkspace = $false
    }
    elseif (! (Test-Path $WorkspacePath)) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud Workspace is not at the path $WorkspacePath"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You will not be able to update the WinPE volume"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        $RobocopyWorkspace = $false
    }
    elseif (! (Test-Path "$WorkspacePath\Media\sources\boot.wim")) {
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) OSDCloud WinPE does not exist at $WorkspacePath\Media\sources\boot.wim"
        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You will not be able to update the WinPE volume"
        Write-Host -ForegroundColor DarkGray "========================================================================="
        $RobocopyWorkspace = $false
    }
    else {
        $RobocopyWorkspace = $true
    }
    #=================================================
    #	Set WinPE USB Volume Label
    #=================================================
    $WinpeVolumes = Get-USBVolume | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT')}
    if ($WinpeVolumes) {
        if ($IsAdmin) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Setting OSDCloud USB WinPE volume labels to WinPE"
            foreach ($volume in $WinpeVolumes) {
                Set-Volume -DriveLetter $volume.DriveLetter -NewFileSystemLabel 'WinPE' -ErrorAction Ignore
            }
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to set OSDCloud USB WinPE volume label"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Run this function again elevated with Admin rights"
        }
    }
    #=================================================
    #	Update all WinPE volumes with Workspace
    #=================================================
    $WinpeVolumes = Get-USBVolume | Where-Object {($_.FileSystemLabel -eq 'USBBOOT') -or ($_.FileSystemLabel -eq 'OSDBOOT') -or ($_.FileSystemLabel -eq 'USB BOOT') -or ($_.FileSystemLabel -eq 'WinPE')}
    if ($WinpeVolumes -and $RobocopyWorkspace) {
        foreach ($volume in $WinpeVolumes) {
            if (Test-Path -Path "$($volume.DriveLetter):\") {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) ROBOCOPY $WorkspacePath\Media $($volume.DriveLetter):\"
                robocopy "$WorkspacePath\Media" "$($volume.DriveLetter):\" *.* /e /ndl /njh /njs /np /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                Write-Host -ForegroundColor DarkGray "========================================================================="
            }
        }
    }
    #=================================================
    #   Update OSDCloud Workspace PowerShell
    #=================================================
    if ($RobocopyWorkspace) {
        if ($PSUpdate -or $DriverPack -or $OS -or $OSName -or $OSActivation -or $OSLanguage) {
            $PowerShellPath = "$WorkspacePath\PowerShell"
        
            if (! (Test-Path "$PowerShellPath")) {
                Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Creating OSDCloud Workspace PowerShell at $WorkspacePath\PowerShell"
                $null = New-Item -Path "$PowerShellPath" -ItemType Directory -Force -ErrorAction Ignore
                $UpdateModules = $true
            }
            if (! (Test-Path "$PowerShellPath\Offline\Modules")) {
                $null = New-Item -Path "$PowerShellPath\Offline\Modules" -ItemType Directory -Force -ErrorAction Ignore
                $UpdateModules = $true
            }
            if (! (Test-Path "$PowerShellPath\Offline\Scripts")) {
                $null = New-Item -Path "$PowerShellPath\Offline\Scripts" -ItemType Directory -Force -ErrorAction Ignore
                $UpdateModules = $true
            }
            if (! (Test-Path "$PowerShellPath\Required\Modules")) {
                $null = New-Item -Path "$PowerShellPath\Required\Modules" -ItemType Directory -Force -ErrorAction Ignore
            }
            if (! (Test-Path "$PowerShellPath\Required\Scripts")) {
                $null = New-Item -Path "$PowerShellPath\Required\Scripts" -ItemType Directory -Force -ErrorAction Ignore
            }
        }
    }
    #=================================================
    #   Update OSDCloud Workspace PowerShell
    #=================================================
    if ($RobocopyWorkspace) {
        if ($UpdateModules -or $PSUpdate) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Updating OSDCloud Workspace PowerShell Modules and Scripts at $PowerShellPath"
        
            try {
                Save-Module OSD -Path "$PowerShellPath\Offline\Modules" -ErrorAction Stop
            }
            catch {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the OSD PowerShell Module at $PowerShellPath\Offline\Modules"
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
            }
        
            try {
                Save-Module WindowsAutoPilotIntune -Path "$PowerShellPath\Offline\Modules" -ErrorAction Stop
            }
            catch {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the WindowsAutoPilotIntune PowerShell Module at $PowerShellPath\Offline\Modules"
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
            }
        
            try {
                Save-Script -Name Get-WindowsAutopilotInfo -Path "$PowerShellPath\Offline\Scripts" -ErrorAction Stop
            }
            catch {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the Get-WindowsAutopilotInfo PowerShell Script at $PowerShellPath\Offline\Scripts"
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
            }
        }
    }
    #=================================================
    #   OSDCloudVolumes
    #=================================================
    $OSDCloudVolumes = Get-USBVolume | Where-Object {$_.FileSystemLabel -eq 'OSDCloud'} | Where-Object {$_.SizeGB -ge 8} | Sort-Object DriveLetter -Descending
    if ($OSDCloudVolumes) {
        if ($IsAdmin) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Setting OSDCloud USB volume labels to OSDCloudUSB"
            foreach ($volume in $OSDCloudVolumes) {
                Set-Volume -DriveLetter $volume.DriveLetter -NewFileSystemLabel 'OSDCloudUSB' -ErrorAction Ignore
            }
        }
        else {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to set OSDCloud USB volume label"
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Run this function again elevated with Admin rights"
        }
    }
    #=================================================
    #   IsOfflineReady
    #=================================================
    $OSDCloudVolumes = Get-USBVolume | Where-Object {($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE')} | Where-Object {$_.SizeGB -ge 8} | Sort-Object DriveLetter -Descending
    $IsOfflineReady = $false
    if ($RobocopyWorkspace -and $OSDCloudVolumes) {
        foreach ($volume in $OSDCloudVolumes) {
            if (Test-Path "$($volume.DriveLetter):\OSDCloud") {
                $IsOfflineReady = $true
            }
        }
    }
    #=================================================
    #   Update OSDCloud Offline
    #=================================================
    if ($RobocopyWorkspace -and $OSDCloudVolumes) {
        foreach ($volume in $OSDCloudVolumes) {
            if ($IsOfflineReady -or $UpdateModules -or $PSUpdate -or $DriverPack -or $OS -or $OSName -or $OSActivation -or $OSLanguage) {
                if (Test-Path "$WorkspacePath\Config") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) ROBOCOPY $WorkspacePath\Config $($volume.DriveLetter):\OSDCloud\Config"
                    robocopy "$WorkspacePath\Config" "$($volume.DriveLetter):\OSDCloud\Config" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    Write-Host -ForegroundColor DarkGray "========================================================================="
                }
    
                if (Test-Path "$WorkspacePath\DriverPacks") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) ROBOCOPY $WorkspacePath\DriverPacks $($volume.DriveLetter):\OSDCloud\DriverPacks"
                    robocopy "$WorkspacePath\DriverPacks" "$($volume.DriveLetter):\OSDCloud\DriverPacks" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    Write-Host -ForegroundColor DarkGray "========================================================================="
                }
    
                if (Test-Path "$WorkspacePath\OS") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) ROBOCOPY $WorkspacePath\OS $($volume.DriveLetter):\OSDCloud\OS"
                    robocopy "$WorkspacePath\OS" "$($volume.DriveLetter):\OSDCloud\OS" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    Write-Host -ForegroundColor DarkGray "========================================================================="
                }
    
                if (Test-Path "$WorkspacePath\PowerShell") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) ROBOCOPY $WorkspacePath\PowerShell $($volume.DriveLetter):\OSDCloud\PowerShell"
                    robocopy "$WorkspacePath\PowerShell" "$($volume.DriveLetter):\OSDCloud\PowerShell" *.* /e /mt /ndl /njh /njs /r:0 /w:0 /xd "$RECYCLE.BIN" "System Volume Information"
                    Write-Host -ForegroundColor DarkGray "========================================================================="
                }
            }
        }
    }
    #=================================================
    #   Single OSDCloudVolume
    #=================================================
    if ($OSDCloudVolumes) {
        if ($DriverPack -or $OS -or $OSName -or $OSActivation -or $OSLanguage) {
            if (! ($OSDCloudVolumes)) {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to find an OSDCloud USB volume"
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) The USB volume must be labeled OSDCloud and be at least 8GB in size"
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Break
            }
        
            if (($OSDCloudVolumes | Measure-Object).Count -gt 1) {
                Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select a single OSDCloud USB volume in PowerShell GridView and press OK"
                $OSDCloudVolumes = $OSDCloudVolumes | Out-GridView -Title 'Select an OSDCloud USB volume and press OK' -OutputMode Single
            }
        
            if (! ($OSDCloudVolumes)) {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) You must select one OSDCloud USB volume"
                Write-Host -ForegroundColor DarkGray "========================================================================="
                Break
            }
        }
    }
    #=================================================
    #   OSDCloud OSName
    #=================================================
    if (($OSDCloudVolumes | Measure-Object).Count -eq 1) {
        if ($OS -or $OSName -or $OSActivation -or $OSLanguage) {
            $OSDownloadPath = "$($OSDCloudVolumes.DriveLetter):\OSDCloud\OS"
    
            $OSDCloudSavedOS = $null
            if (Test-Path $OSDownloadPath) {
                $OSDCloudSavedOS = Get-ChildItem -Path $OSDownloadPath *.esd -Recurse -File | Select-Object -ExpandProperty Name
            }
            $OperatingSystems = Get-WSUSXML -Catalog FeatureUpdate -UpdateArch 'x64' -Silent
        
            if ($OSName) {
                $OperatingSystems = $OperatingSystems | Where-Object {$_.Catalog -cmatch $OSName}
            }
            if ($OSActivation -eq 'Retail') {
                $OperatingSystems = $OperatingSystems | Where-Object {$_.Title -match 'consumer'}
            }
            if ($OSActivation -eq 'Volume') {
                $OperatingSystems = $OperatingSystems | Where-Object {$_.Title -match 'business'}
            }
            if ($OSLanguage){
                $OperatingSystems = $OperatingSystems | Where-Object {$_.Title -match $OSLanguage}
            }
        
            if ($OperatingSystems) {
                $OperatingSystems = $OperatingSystems | Sort-Object Title
    
                foreach ($Item in $OperatingSystems) {
                    $Item.Catalog = $Item.Catalog -replace 'FeatureUpdate ',''
                    if ($OSDCloudSavedOS) {
                        if ($Item.FileName -in $OSDCloudSavedOS) {
                            $Item.OSDStatus = 'Downloaded'
                        }
                    }
                }
    
                $OperatingSystems = $OperatingSystems | Select-Object -Property OSDVersion,OSDStatus,@{Name='OperatingSystem';Expression={($_.Catalog)}},Title,CreationDate,FileUri,FileName
        
                Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Select one or more Operating Systems to download in PowerShell GridView"
                $OperatingSystems = $OperatingSystems | Sort-Object -Property @{Expression='OSDStatus';Descending=$true}, OperatingSystem -Descending | Out-GridView -Title 'Select one or more Operating Systems to download and press OK' -PassThru
        
                foreach ($OperatingSystem in $OperatingSystems) {
                    if ($OperatingSystem.OSDStatus -eq 'Downloaded') {
                        Get-ChildItem -Path $OSDownloadPath -Recurse -Include $OperatingSystem.FileName | Select-Object -ExpandProperty FullName
                    }
                    elseif (Test-WebConnection -Uri "$($OperatingSystem.FileUri)") {
                        #$OSDownloadChildPath = Join-Path $OSDownloadPath (($OperatingSystem.Catalog) -replace 'FeatureUpdate ','')
                        $OSDownloadChildPath = Join-Path $OSDownloadPath $($OperatingSystem.OperatingSystem)
                        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Downloading OSDCloud Operating System to $OSDownloadChildPath"
                        $SaveWebFile = Save-WebFile -SourceUrl $OperatingSystem.FileUri -DestinationDirectory "$OSDownloadChildPath" -DestinationName $OperatingSystem.FileName
                        
                        if (Test-Path $SaveWebFile.FullName) {
                            Get-Item $SaveWebFile.FullName
                        }
                        else {
                            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not download the Operating System"
                        }
                    }
                    else {
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Could not verify an Internet connection for the Operating System"
                    }
                }
            }
            else {
                Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to determine a suitable Operating System"
            }
            Write-Host -ForegroundColor DarkGray "========================================================================="
        }
        else {
        }
    }
    #=================================================
    #   OSDCloud DriverPack
    #=================================================
    if (($OSDCloudVolumes | Measure-Object).Count -eq 1) {
        if ($DriverPack) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) DriverPacks will require up to 2GB each"
            $DriverPackDownloadPath = "$($OSDCloudVolumes.DriveLetter):\OSDCloud\DriverPacks"
    
            $OSDCloudSavedDriverPacks = $null
            if (Test-Path $DriverPackDownloadPath) {
                $OSDCloudSavedDriverPacks = Get-ChildItem -Path $DriverPackDownloadPath *.* -Recurse -File | Select-Object -ExpandProperty Name
            }
    
            if ($DriverPack -contains '*') {
                $DriverPack = 'ThisPC','Dell','HP','Lenovo','Microsoft'
            }
    
            if ($DriverPack -contains 'ThisPC') {
                $Manufacturer = Get-MyComputerManufacturer -Brief
                Save-MyDriverPack -DownloadPath "$DriverPackDownloadPath\$Manufacturer"
            }
        
            if ($DriverPack -contains 'Dell') {
                Get-DellDriverPack -DownloadPath "$DriverPackDownloadPath\Dell"
            }
            if ($DriverPack -contains 'HP') {
                Get-HPDriverPack -DownloadPath "$DriverPackDownloadPath\HP"
            }
            if ($DriverPack -contains 'Lenovo') {
                Get-LenovoDriverPack -DownloadPath "$DriverPackDownloadPath\Lenovo"
            }
            if ($DriverPack -contains 'Microsoft') {
                Get-MicrosoftDriverPack -DownloadPath "$DriverPackDownloadPath\Microsoft"
            }
            Write-Host -ForegroundColor DarkGray "========================================================================="
        }
        else {
        }
    }
    #=================================================
    #   PowerShell
    #=================================================
    if (($OSDCloudVolumes | Measure-Object).Count -eq 1) {
        if (Test-Path "$($OSDCloudVolumes.DriveLetter):\OSDCloud") {
            $PowerShellPath = "$($OSDCloudVolumes.DriveLetter):\OSDCloud\PowerShell"
            if (-not (Test-Path "$PowerShellPath")) {
                $null = New-Item -Path "$PowerShellPath" -ItemType Directory -Force -ErrorAction Ignore
                $UpdateModules = $true
            }
            if (-not (Test-Path "$PowerShellPath\Offline\Modules")) {
                $null = New-Item -Path "$PowerShellPath\Offline\Modules" -ItemType Directory -Force -ErrorAction Ignore
                $UpdateModules = $true
            }
            if (-not (Test-Path "$PowerShellPath\Offline\Scripts")) {
                $null = New-Item -Path "$PowerShellPath\Offline\Scripts" -ItemType Directory -Force -ErrorAction Ignore
                $UpdateModules = $true
            }
            if (-not (Test-Path "$PowerShellPath\Required\Modules")) {
                $null = New-Item -Path "$PowerShellPath\Required\Modules" -ItemType Directory -Force -ErrorAction Ignore
            }
            if (-not (Test-Path "$PowerShellPath\Required\Scripts")) {
                $null = New-Item -Path "$PowerShellPath\Required\Scripts" -ItemType Directory -Force -ErrorAction Ignore
            }
        }
    }
    #=================================================
    #   Online
    #=================================================
    if ($OSDCloudVolumes -and $IsOfflineReady) {
        if ($UpdateModules -or $PSUpdate) {
            if (($OSDCloudVolumes | Measure-Object).Count -eq 1) {
                if (Test-Path "$($OSDCloudVolumes.DriveLetter):\OSDCloud") {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Updating OSD and WindowsAutoPilotIntune PowerShell Modules at $PowerShellPath"
        
                    try {
                        Save-Module OSD -Path "$PowerShellPath\Offline\Modules" -ErrorAction Stop
                    }
                    catch {
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the OSD PowerShell Module at $PowerShellPath\Offline\Modules"
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
                    }
        
                    try {
                        Save-Module WindowsAutoPilotIntune -Path "$PowerShellPath\Offline\Modules" -ErrorAction Stop
                    }
                    catch {
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the WindowsAutoPilotIntune PowerShell Module at $PowerShellPath\Offline\Modules"
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
                    }
        
                    try {
                        Save-Script -Name Get-WindowsAutopilotInfo -Path "$PowerShellPath\Offline\Scripts" -ErrorAction Stop
                    }
                    catch {
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) There were some issues updating the Get-WindowsAutopilotInfo PowerShell Script at $PowerShellPath\Offline\Scripts"
                        Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Make sure you have an Internet connection and can access powershellgallery.com"
                    }
                    Write-Host -ForegroundColor DarkGray "========================================================================="
                }
            }
        }
        else {
        }
    }
    #=================================================
    #   Complete
    #=================================================
    Write-Host -ForegroundColor Yellow "Download a Driver Pack to OSDCloud USB:"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -DriverPack *"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -DriverPack ThisPC"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -DriverPack Dell"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -DriverPack Dell,HP,Lenovo,Microsoft"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Yellow "Download an Operating System to OSDCloud USB:"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OS"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OSName 'Windows 11 22H2'"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OSLanguage en-us"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OSActivation Volume"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OSName 'Windows 10 21H2' -OSLanguage en-us"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -OSName 'Windows 10 20H2' -OSLanguage de-de -OSActivation Volume"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Yellow "Update Offline PowerShell Modules and Scripts:"
    Write-Host -ForegroundColor Gray "Update-OSDCloudUSB -PSUpdate"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Update-OSDCloudUSB is complete"
    #=================================================
}
