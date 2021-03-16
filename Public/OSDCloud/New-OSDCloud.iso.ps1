<#
.SYNOPSIS
Creates an .iso file from a bootable media directory.  ADK is required

.Description
Creates a .iso file from a bootable media directory.  ADK is required

.PARAMETER WorkspacePath
Directory for the Workspace.  This will contain the Media directory and the .iso file
If not given, one will be created in $env:TEMP

.PARAMETER isoFileName
File Name of the ISO

.PARAMETER isoLabel
Lable of the ISO.  Limited to 16 characters

.PARAMETER CloudDriver
Download and install in WinPE drivers from Dell,Nutanix,VMware

.PARAMETER NoPrompt
Removes the 'Press any key to boot from CD or DVD......' prompt

.LINK
https://osdcloud.osdeploy.com

.NOTES
21.3.16     Initial Release
#>
function New-OSDCloud.iso {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$WorkspacePath = (Join-Path $env:TEMP (Get-Random)),

        [string]$isoFileName = 'OSDCloud.iso',

        [ValidateLength(1,16)]
        [string]$isoLabel = 'OSDCloud',

        [string[]]$DriverPath,

        [ValidateSet('Dell','Nutanix','VMware')]
        [string[]]$CloudDriver,
        [switch]$NoPrompt
    )

    #===================================================================================================
    #	Start the Clock
    #===================================================================================================
    $StartTime = Get-Date
    #======================================================================================================
    #	Require WinOS
    #======================================================================================================
    if ((Get-OSDGather -Property IsWinPE)) {
        Write-Warning "$($MyInvocation.MyCommand) cannot be run from WinPE"
        Break
    }
    #===================================================================================================
    #   Require Admin Rights
    #===================================================================================================
    if ((Get-OSDGather -Property IsAdmin) -eq $false) {
        Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
        Break
    }
    #===================================================================================================
    #   Require cURL
    #===================================================================================================
    if (-NOT (Test-Path "$env:SystemRoot\System32\curl.exe")) {
        Write-Warning "$($MyInvocation.MyCommand) could not find $env:SystemRoot\System32\curl.exe"
        Write-Warning "Get a newer Windows version!"
        Break
    }
    #===================================================================================================
    #	Set VerbosePreference
    #===================================================================================================
    $CurrentVerbosePreference = $VerbosePreference
    $VerbosePreference = 'Continue'
    #===================================================================================================
    #   Get Adk Paths
    #===================================================================================================
    $AdkPaths = Get-AdkPaths

    if ($null -eq $AdkPaths) {
        Write-Warning "Could not get ADK going, sorry"
        Break
    }
    #===================================================================================================
    #   Get WinPE.wim
    #===================================================================================================
    $WimSourcePath = $AdkPaths.WimSourcePath
    if (-NOT (Test-Path $WimSourcePath)) {
        Write-Warning "Could not find $WimSourcePath, sorry"
        Break
    }
    $PathWinPEMedia = $AdkPaths.PathWinPEMedia
    $DestinationMedia = Join-Path $WorkspacePath 'Media'
    Write-Verbose "Copying ADK Media to $DestinationMedia"
    robocopy "$PathWinPEMedia" "$DestinationMedia" *.* /e /ndl /xj /ndl /np /nfl /njh /njs

    $DestinationSources = Join-Path $DestinationMedia 'sources'
    if (-NOT (Test-Path "$DestinationSources")) {
        New-Item -Path "$DestinationSources" -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    $BootWim = Join-Path $DestinationSources 'boot.wim'
    Write-Verbose "Copying ADK Boot.wim to $BootWim"
    Copy-Item -Path $WimSourcePath -Destination $BootWim -Force
    #===================================================================================================
    #   Mount-MyWindowsImage
    #===================================================================================================
    $MountMyWindowsImage = Mount-MyWindowsImage $BootWim
    $MountPath = $MountMyWindowsImage.Path
    #===================================================================================================
    #   Add Packages
    #===================================================================================================
    $ErrorActionPreference = 'Ignore'
    $WinPEOCs = $AdkPaths.WinPEOCs

    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-WMI.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-WMI_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-HTA.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-HTA_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-NetFx.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-NetFx_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-Scripting.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-Scripting_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-PowerShell.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-PowerShell_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-SecureStartup.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-SecureStartup_en-us.cab"

    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-DismCmdlets.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-DismCmdlets_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-Dot3Svc.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-Dot3Svc_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-EnhancedStorage.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-EnhancedStorage_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-FMAPI.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-GamingPeripherals.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-PPPoE.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-PPPoE_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-PlatformId.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-PmemCmdlets.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-PmemCmdlets_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-RNDIS.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-RNDIS_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-SecureBootCmdlets.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-StorageWMI.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-StorageWMI_en-us.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\WinPE-WDS-Tools.cab"
    Add-WindowsPackage -Path $MountPath -PackagePath "$WinPEOCs\en-us\WinPE-WDS-Tools_en-us.cab"
    #===================================================================================================
    #	cURL
    #===================================================================================================
    Write-Verbose "Adding curl.exe to $MountPath"
    if (Test-Path "$env:SystemRoot\System32\curl.exe") {
        robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" curl.exe /ndl /nfl /njh /njs /b
    } else {
        Write-Warning "Could not find $env:SystemRoot\System32\curl.exe"
        Write-Warning "You must be using an old version of Windows"
    }
    #===================================================================================================
    #	PowerShell Execution Policy
    #===================================================================================================
    Write-Verbose "Setting PowerShell ExecutionPolicy to Bypass in $MountPath"
    Set-WindowsImageExecutionPolicy -Path $MountPath -ExecutionPolicy Bypass
    #===================================================================================================
    #   Enable PowerShell Gallery
    #===================================================================================================
    Write-Verbose "Enabling PowerShell Gallery support in $MountPath"
    Enable-PEWindowsImagePSGallery -Path $MountPath

    Write-Verbose "Saving OSD to $MountPath\Program Files\WindowsPowerShell\Modules"
    Save-Module -Name OSD -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
    #===================================================================================================
    #   Startnet
    #===================================================================================================
    Write-Verbose "Adding PowerShell.exe to Startnet.cmd"
    Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'start powershell.exe' -Force
    #===============================================================================================
    #   DriverPath
    #===============================================================================================
    foreach ($Driver in $DriverPath) {
        Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$Driver" -Recurse -ForceUnsigned
    }
    foreach ($Driver in $CloudDriver) {
        if ($Driver -eq 'Dell'){
            Write-Verbose "Adding $Driver CloudDriver"
            if (Test-WebConnection -Uri 'http://downloads.dell.com/FOLDER07062618M/1/WINPE10.0-DRIVERS-A23-PR4K0.CAB') {
                $SaveWebFile = Save-WebFile -SourceUrl 'http://downloads.dell.com/FOLDER07062618M/1/WINPE10.0-DRIVERS-A23-PR4K0.CAB'
                if (Test-Path $SaveWebFile.FullName) {
                    $DriverCab = Get-Item -Path $SaveWebFile.FullName
                    $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
            
                    if (-NOT (Test-Path $ExpandPath)) {
                        New-Item -Path $ExpandPath -ItemType Directory -Force | Out-Null
                    }
                    Expand -R "$($DriverCab.FullName)" -F:* "$ExpandPath" | Out-Null
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned
                }
            }
        }
        if ($Driver -eq 'Nutanix'){
            Write-Verbose "Adding $Driver CloudDriver"
            if (Test-WebConnection -Uri 'https://github.com/OSDeploy/OSDCloud/raw/main/Drivers/WinPE/Nutanix.cab') {
                $SaveWebFile = Save-WebFile -SourceUrl 'https://github.com/OSDeploy/OSDCloud/raw/main/Drivers/WinPE/Nutanix.cab'
                if (Test-Path $SaveWebFile.FullName) {
                    $DriverCab = Get-Item -Path $SaveWebFile.FullName
                    $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
            
                    if (-NOT (Test-Path $ExpandPath)) {
                        New-Item -Path $ExpandPath -ItemType Directory -Force | Out-Null
                    }
                    Expand -R "$($DriverCab.FullName)" -F:* "$ExpandPath" | Out-Null
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned
                }
            }
        }
        if ($Driver -eq 'VMware'){
            Write-Verbose "Adding $Driver CloudDriver"
            if (Test-WebConnection -Uri 'https://github.com/OSDeploy/OSDCloud/raw/main/Drivers/WinPE/VMware.cab') {
                $SaveWebFile = Save-WebFile -SourceUrl 'https://github.com/OSDeploy/OSDCloud/raw/main/Drivers/WinPE/VMware.cab'
                if (Test-Path $SaveWebFile.FullName) {
                    $DriverCab = Get-Item -Path $SaveWebFile.FullName
                    $ExpandPath = Join-Path $DriverCab.Directory $DriverCab.BaseName
            
                    if (-NOT (Test-Path $ExpandPath)) {
                        New-Item -Path $ExpandPath -ItemType Directory -Force | Out-Null
                    }
                    Expand -R "$($DriverCab.FullName)" -F:* "$ExpandPath" | Out-Null
                    Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$ExpandPath" -Recurse -ForceUnsigned
                }
            }
        }
    }
    #===============================================================================================
    #   Save WIM
    #===============================================================================================
    $MountMyWindowsImage | Dismount-MyWindowsImage -Save
    #===============================================================================================
    #   Create ISO
    #===============================================================================================
    if ($PSBoundParameters.ContainsKey('NoPrompt')) {
        $NewADKiso = New-ADK.iso -MediaPath $DestinationMedia -isoFileName $isoFileName -isoLabel $isoLabel -OpenExplorer -NoPrompt
    }
    else {
        $NewADKiso = New-ADK.iso -MediaPath $DestinationMedia -isoFileName $isoFileName -isoLabel $isoLabel -OpenExplorer
    }
    #===============================================================================================
    #   Restore VerbosePreference
    #===============================================================================================
    $VerbosePreference = $CurrentVerbosePreference
    #===================================================================================================
    #	Complete
    #===================================================================================================
    $EndTime = Get-Date
    $TimeSpan = New-TimeSpan -Start $StartTime -End $EndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($TimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    
    Return $NewADKiso
    #===================================================================================================
}