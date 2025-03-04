<#
.SYNOPSIS
Adds PowerShell and PowerShell Gallery support to ADK's x64 winpe.wim

.DESCRIPTION
Adds PowerShell and PowerShell Gallery support to ADK's x64 winpe.wim.  This will speed things up with MDT and MEM CM going forward

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
21.3.15.2   Initial Release
#>
function Edit-AdkWinPEWIM {
    [CmdletBinding()]
    param ()

    #=================================================
    #	Start the Clock
    #=================================================
    $StartTime = Get-Date
    #=================================================
    #	Blocks
    #=================================================
    Block-WinPE
    Block-StandardUser
    Block-NoCurl
    #=================================================
    #	Set VerbosePreference
    #=================================================
    $CurrentVerbosePreference = $VerbosePreference
    $VerbosePreference = 'Continue'
    #=================================================
    #   Get ADK
    #=================================================
    $WinPEArch = 'amd64'
    $WindowsAdkPaths = Get-WindowsAdkPaths -Architecture $WinPEArch

    if ($null -eq $WindowsAdkPaths) {
        Write-Warning "Could not get ADK going, sorry"
        Break
    }
    #=================================================
    #   Get WinPE.wim
    #=================================================
    $WimSourcePath = $WindowsAdkPaths.WimSourcePath
    if (-NOT (Test-Path $WimSourcePath)) {
        Write-Warning "Could not find $WimSourcePath, sorry"
        Break
    }
    $WimSourceItem = Get-Item $WimSourcePath
    #=================================================
    #   Create Backup
    #=================================================
    if (-NOT (Test-Path "$($WimSourceItem.Directory)\winpe.bak")) {
        $WimSourceItem | Copy-Item -Destination "$($WimSourceItem.Directory)\winpe.bak" -Force -ErrorAction Stop
    }
    #=================================================
    #   Mount-MyWindowsImage
    #=================================================
    $MountMyWindowsImage = Mount-MyWindowsImage $WimSourceItem
    $MountPath = $MountMyWindowsImage.Path
    #=================================================
    #   Add Packages
    #=================================================
    $ErrorActionPreference = 'Ignore'
    $WinPEOCs = $WindowsAdkPaths.WinPEOCs

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
    #=================================================
    #	cURL
    #=================================================
    Write-Verbose "Adding curl.exe to $MountPath"
    if (Test-Path "$env:SystemRoot\System32\curl.exe") {
        robocopy "$env:SystemRoot\System32" "$MountPath\Windows\System32" curl.exe /ndl /nfl /njh /njs /b
    } else {
        Write-Warning "Could not find $env:SystemRoot\System32\curl.exe"
        Write-Warning "You must be using an old version of Windows"
    }
    #=================================================
    #	PowerShell Execution Policy
    #=================================================
    Write-Verbose "Setting PowerShell ExecutionPolicy to Bypass in $MountPath"
    Set-WindowsImageExecutionPolicy -Path $MountPath -ExecutionPolicy Bypass
    #=================================================
    #   Enable PowerShell Gallery
    #=================================================
    Write-Verbose "Enabling PowerShell Gallery support in $MountPath"
    Enable-PEWindowsImagePSGallery -Path $MountPath

    #Write-Verbose "Saving OSD to $MountPath\Program Files\WindowsPowerShell\Modules"
    #Save-Module -Name OSD -Path "$MountPath\Program Files\WindowsPowerShell\Modules" -Force
    #=================================================
    #   Startnet
    #=================================================
    #Write-Verbose "Adding PowerShell.exe to Startnet.cmd"
    #Add-Content -Path "$MountPath\Windows\System32\Startnet.cmd" -Value 'start powershell.exe' -Force
    #=================================================
    #   DriverPath
    #=================================================
<#     foreach ($Driver in $DriverPath) {
        Add-WindowsDriver -Path "$($MountMyWindowsImage.Path)" -Driver "$Driver" -Recurse -ForceUnsigned
    } #>
    #=================================================
    #   Save WIM
    #=================================================
    $MountMyWindowsImage | Dismount-MyWindowsImage -Save
    #=================================================
    #   Restore VerbosePreference
    #=================================================
    $VerbosePreference = $CurrentVerbosePreference
    #=================================================
    #	Complete
    #=================================================
    $EndTime = Get-Date
    $TimeSpan = New-TimeSpan -Start $StartTime -End $EndTime
    Write-Host -ForegroundColor DarkGray    "================================================"
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($TimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #=================================================
}
function Get-WindowsAdkInstallPath {
    <#
    .SYNOPSIS
    Retrieves the installation path of the Windows Assessment and Deployment Kit (Windows ADK) from the registry.

    .DESCRIPTION
    Retrieves the installation path of the Windows Assessment and Deployment Kit (Windows ADK) from the registry.

    .NOTES
    Author: David Segura
    #>
    [CmdletBinding()]
    param ()

    $WindowsKitsInstallPath = Get-WindowsKitsInstallPath

    if ($WindowsKitsInstallPath) {
        $WindowsAdkInstallPath = Join-Path $WindowsKitsInstallPath 'Assessment and Deployment Kit'

        if (Test-Path "$WindowsAdkInstallPath") {
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))] Windows Assessment and Deployment Kit install path is $WindowsAdkInstallPath"
            return $WindowsAdkInstallPath
        }
        else {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))] Windows Assessment and Deployment Kit is not installed"
            return $null
        }

    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))] Windows Assessment and Deployment Kit is not installed"
        return $null
    }
}
function Get-WindowsAdkInstallVersion {
    <#
    .SYNOPSIS
    Retrieves the installed version of the Windows Assessment and Deployment Kit (Windows ADK) from the registry.

    .DESCRIPTION
    Retrieves the installed version of the Windows Assessment and Deployment Kit (Windows ADK) from the registry.

    .NOTES
    Author: David Segura
    #>
    [CmdletBinding()]
    param ()

    $Result = Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue | `
    Where-Object { $_.DisplayName -eq 'Windows Assessment and Deployment Kit' } | Select-Object -ExpandProperty DisplayVersion -First 1

    return $Result
}
function Get-WindowsAdkPaths {
    <#
    .SYNOPSIS
    Retrieves the command paths of the Windows Assessment and Deployment Kit (ADK).

    .DESCRIPTION
    Retrieves the command paths of the Windows Assessment and Deployment Kit (ADK).

    .NOTES
    Author: David Segura
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        # Windows ADK architecture to get. Valid values are 'amd64', 'x86', and 'arm64'.
        [ValidateSet('amd64', 'x86', 'arm64')]
        [Alias('Arch')]
        [string]$Architecture = $Env:PROCESSOR_ARCHITECTURE,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        # Path to the Windows ADK root directory. Typically 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit'
        [ValidateScript({
            if (!($_ | Test-Path)) {
                throw 'Path does not exist'
            }
            if (!($_ | Test-Path -PathType Container)) {
                throw 'Path must be a directory'
            }
            if (!(Test-Path "$($_.FullName)\Deployment Tools")) {
                throw 'Path does not contain a Deployment Tools directory'
            }
            if (!(Test-Path "$($_.FullName)\Windows Preinstallation Environment")) {
                throw 'Path does not contain a Windows Preinstallation Environment directory'
            }
            return $true
        })]
        [System.IO.FileInfo]
        [Alias('AdkRoot')]
        $WindowsAdkRoot
    )
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
    $Error.Clear()
    #=================================================
    # region Get Windows ADK information from the Registry
    if (-not $WindowsAdkRoot) {
        $InstalledRoots32 = 'HKLM:\SOFTWARE\Microsoft\Windows Kits\Installed Roots'
        $InstalledRoots64 = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots'
        $RegistryValue = 'KitsRoot10'
        $KitsRoot10 = $null
 
        if (Test-Path -Path $InstalledRoots64) {
            $RegistryKey = Get-Item -Path $InstalledRoots64
            if ($null -ne $RegistryKey.GetValue($RegistryValue)) {
                $KitsRoot10 = Get-ItemPropertyValue -Path $InstalledRoots64 -Name $RegistryValue -ErrorAction SilentlyContinue
            }
        }

        if (-NOT ($KitsRoot10)) {
            if (Test-Path -Path $InstalledRoots32) {
                $RegistryKey = Get-Item -Path $InstalledRoots32
                if ($null -ne $RegistryKey.GetValue($RegistryValue)) {
                    $KitsRoot10 = Get-ItemPropertyValue -Path $InstalledRoots32 -Name $RegistryValue -ErrorAction SilentlyContinue
                }
            }
        }

        if ($KitsRoot10) {
            $WindowsAdkRoot = Join-Path $KitsRoot10 'Assessment and Deployment Kit'
        }
        else {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Unable to determine ADK Path"
            return
        }
    }
    #endregion
    #=================================================
    # region Validate Windows ADK Path
    $WinPERoot = Join-Path $WindowsAdkRoot 'Windows Preinstallation Environment'
    if (-NOT (Test-Path $WinPERoot -PathType Container)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))] WinPERoot is not a valid path $WinPERoot"
        $WinPERoot = $null
        return
    }
    #endregion
    #=================================================
    # region Set ADK Paths
    $PathDeploymentTools = Join-Path $WindowsAdkRoot (Join-Path 'Deployment Tools' $Architecture)
    $PathWinPE = Join-Path $WinPERoot $Architecture
    #endregion
    #=================================================
    # region Build Results
    $Results = [PSCustomObject] @{
        #KitsRoot           = $KitsRoot10
        AdkRoot             = $WindowsAdkRoot
        PathBCDBoot         = Join-Path $PathDeploymentTools 'BCDBoot'
        PathDeploymentTools = $PathDeploymentTools
        PathDISM            = Join-Path $PathDeploymentTools 'DISM'
        PathOscdimg         = Join-Path $PathDeploymentTools 'Oscdimg'
        PathUsmt            = Join-Path $WindowsAdkRoot (Join-Path 'User State Migration Tool' $Architecture)
        PathWinPE           = Join-Path $WinPERoot $Architecture
        PathWinPEMedia      = Join-Path $PathWinPE 'Media'
        PathWinSetup        = Join-Path $WindowsAdkRoot (Join-Path 'Windows Setup' $Architecture)
        WinPEOCs            = Join-Path $PathWinPE 'WinPE_OCs'
        WinPERoot           = $WinPERoot
        WimSourcePath       = Join-Path $PathWinPE 'en-us\winpe.wim'

        bcdbootexe          = Join-Path $PathDeploymentTools (Join-Path 'BCDBoot' 'bcdboot.exe')
        bcdeditexe          = Join-Path $PathDeploymentTools (Join-Path 'BCDBoot' 'bcdedit.exe')
        bootsectexe         = Join-Path $PathDeploymentTools (Join-Path 'BCDBoot' 'bootsect.exe')
        dismexe             = Join-Path $PathDeploymentTools (Join-Path 'DISM' 'dism.exe')
        efisysbin           = Join-Path $PathDeploymentTools (Join-Path 'Oscdimg' 'efisys.bin')
        efisysnopromptbin   = Join-Path $PathDeploymentTools (Join-Path 'Oscdimg' 'efisys_noprompt.bin')
        etfsbootcom         = if ($Architecture -eq 'arm64') {
            # ARM64 does not have a etfsboot.com | Redirect to amd64 folder
            Join-Path (Join-Path $WindowsAdkRoot (Join-Path 'Deployment Tools' 'amd64')) (Join-Path 'Oscdimg' 'etfsboot.com')
        }
        else {
            Join-Path $PathDeploymentTools (Join-Path 'Oscdimg' 'etfsboot.com')
        }
        imagexexe           = Join-Path $PathDeploymentTools (Join-Path 'DISM' 'imagex.exe')
        oa3toolexe          = Join-Path $PathDeploymentTools (Join-Path 'Licensing\OA30' 'oa3tool.exe')
        oscdimgexe          = Join-Path $PathDeploymentTools (Join-Path 'Oscdimg' 'oscdimg.exe')
        pkgmgrexe           = Join-Path $PathDeploymentTools (Join-Path 'DISM' 'pkgmgr.exe')
    }
    Return $Results
    #endregion
    #=================================================
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] End"
    #=================================================
}
function Get-WindowsKitsInstallPath {
    <#
    .SYNOPSIS
    Retrieves the installation path of the Windows Kit directory.

    .DESCRIPTION
    Retrieves the installation path of the Windows Kit directory.

    .NOTES
    Author: David Segura
    #>
    [CmdletBinding()]
    param ()

    # 32-bit Registry
    $InstalledRoots32 = 'HKLM:\SOFTWARE\Microsoft\Windows Kits\Installed Roots'
    # 64-bit Registry
    $InstalledRoots64 = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots'
    
    $RegistryValue = 'KitsRoot10'
    $KitsRoot10 = $null

    # Test for 64-bit Registry
    if (Test-Path -Path $InstalledRoots64) {
        $RegistryKey = Get-Item -Path $InstalledRoots64
        if ($null -ne $RegistryKey.GetValue($RegistryValue)) {
            $KitsRoot10 = Get-ItemPropertyValue -Path $InstalledRoots64 -Name $RegistryValue -ErrorAction SilentlyContinue
        }
    }

    if (-not ($KitsRoot10)) {
        if (Test-Path -Path $InstalledRoots32) {
            $RegistryKey = Get-Item -Path $InstalledRoots32
            if ($null -ne $RegistryKey.GetValue($RegistryValue)) {
                $KitsRoot10 = Get-ItemPropertyValue -Path $InstalledRoots32 -Name $RegistryValue -ErrorAction SilentlyContinue
            }
        }
    }


    if ($KitsRoot10) {
        if (Test-Path "$KitsRoot10") {
            Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))] Windows Kits install path is $KitsRoot10"
            return $KitsRoot10
        }
        else {
            Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))] Windows Kits install path from the registry does not exist at $KitsRoot10"
            return $null
        }
    }
    else {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))] Windows Kits is not installed"
        return $null
    }
}
<#
.SYNOPSIS
Creates an ADK CopyPE Working Directory

.DESCRIPTION
Creates an ADK CopyPE Working Directory

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
21.5.27.2   Resolved issue with paths
21.3.15.2   Renamed to make it easier to understand what it does
21.3.10     Initial Release
#>
function New-AdkCopyPE {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Path,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('amd64','x86','arm64')]
        [string]$WinPEArch = 'amd64'
    )

    #=================================================
    #   Require Admin Rights
    #=================================================
    if ((Get-OSDGather -Property IsAdmin) -eq $false) {
        Write-Warning "$($MyInvocation.MyCommand) requires Admin Rights ELEVATED"
        Break
    }
    #=================================================
    #   Get Adk Paths
    #=================================================
    $WindowsAdkPaths = Get-WindowsAdkPaths -Architecture $WinPEArch
    #=================================================
    $Destination = $Path

    $AdkWimSourcePath = $WindowsAdkPaths.WimSourcePath
    $AdkPathOscdimg = $WindowsAdkPaths.PathOscdimg
    $AdkPathWinPEMedia = $WindowsAdkPaths.PathWinPEMedia

    $DestinationMedia = Join-Path $Destination 'media'
    if (-NOT (Test-Path $DestinationMedia)) {
        New-Item -Path $DestinationMedia -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    $DestinationMount = Join-Path $Destination 'mount'
    if (-NOT (Test-Path $DestinationMount)) {
        New-Item -Path $DestinationMount -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    $DestinationFirmwareFiles = Join-Path $Destination 'fwfiles'
    if (-NOT (Test-Path $DestinationFirmwareFiles)) {
        New-Item -Path $DestinationFirmwareFiles -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    $DestinationSources = Join-Path $DestinationMedia 'sources'
    if (-NOT (Test-Path $DestinationSources)) {
        New-Item -Path $DestinationSources -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    xcopy /herky "$AdkPathWinPEMedia" "$DestinationMedia\"

    Copy-Item "$AdkWimSourcePath" "$DestinationSources\boot.wim"
    Copy-Item "$AdkPathOscdimg\efisys.bin" "$DestinationFirmwareFiles"
    Copy-Item "$AdkPathOscdimg\etfsboot.com" "$DestinationFirmwareFiles"
    #=================================================
}
<#
.SYNOPSIS
Creates an .iso file from a bootable media directory.  ADK is required

.DESCRIPTION
Creates a .iso file from a bootable media directory.  ADK is required

.PARAMETER MediaPath
Directory containing the bootable media

.PARAMETER isoFileName
File Name of the ISO

.PARAMETER isoLabel
Label of the ISO.  Limited to 16 characters

.PARAMETER OpenExplorer
Opens Windows Explorer to the parent directory of the ISO File

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
21.3.16     Initial Release
#>
function New-AdkISO {
    [CmdletBinding()]
    param (
        [Alias('AdkRoot')]
        [System.String]
        $WindowsAdkRoot,

        [Parameter(Mandatory = $true)]
        [string]$MediaPath,

        [Parameter(Mandatory = $true)]
        [string]$isoFileName,

        [Parameter(Mandatory = $true)]
        [ValidateLength(1,16)]
        [string]$isoLabel,

        #[System.Management.Automation.SwitchParameter]$NoPrompt,
        #[System.Management.Automation.SwitchParameter]$Mount,
        [System.Management.Automation.SwitchParameter]$OpenExplorer
    )
    Write-Warning "New-AdkISO has been replaced by New-WindowsAdkISO. Please update your scripts"
    Start-Sleep -Seconds 10
	#=================================================
	#	Blocks
	#=================================================
	Block-WinPE
	Block-StandardUser
    Block-PowerShellVersionLt5
    #=================================================
    #   Get Adk Paths
    #=================================================
    if ($WindowsAdkRoot) {
        $AdkPaths = Get-WindowsAdkPaths -WindowsAdkRoot $WindowsAdkRoot
    } else {
        $AdkPaths = Get-WindowsAdkPaths
    }
    if ($null -eq $AdkPaths) {
        Write-Warning "Could not get ADK going, sorry"
        Break
    }
    $WorkspacePath = (Get-Item -Path $MediaPath -ErrorAction Stop).Parent.FullName
    $IsoFullName = Join-Path $WorkspacePath $isoFileName
    $PathOscdimg = $AdkPaths.PathOscdimg
    $oscdimgexe = $AdkPaths.oscdimgexe

    Write-Verbose "WorkspacePath: $WorkspacePath"
    Write-Verbose "IsoFullName: $IsoFullName"
    Write-Verbose "PathOscdimg: $PathOscdimg"
    Write-Verbose "oscdimgexe: $oscdimgexe"
    #=================================================
    #   Test Paths
    #=================================================
    $DestinationBoot = Join-Path $MediaPath 'boot'
    if (-NOT (Test-Path $DestinationBoot)) {
        Write-Warning "Cannot locate $DestinationBoot"
        Write-Warning "This does not appear to be a valid bootable ISO"
        Break
    }
    $DestinationEfiBoot = Join-Path $MediaPath 'efi\microsoft\boot'
    if (-NOT (Test-Path $DestinationEfiBoot)) {
        Write-Warning "Cannot locate $DestinationEfiBoot"
        Write-Warning "This does not appear to be a valid bootable ISO"
        Break
    }
    #=================================================
    #   etfsboot.com
    #=================================================
    $etfsbootcom = $AdkPaths.etfsbootcom
    Copy-Item -Path $etfsbootcom -Destination $DestinationBoot -Force -ErrorAction Stop
    $Destinationetfsbootcom = Join-Path $DestinationBoot 'etfsboot.com'
    #=================================================
    #   efisys.bin and efisys_noprompt.bin
    #=================================================
    $efisysbin = $AdkPaths.efisysbin
    Copy-Item -Path $efisysbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
    $Destinationefisysbin = Join-Path $DestinationEfiBoot 'efisys.bin'

    $efisysnopromptbin = $AdkPaths.efisysnopromptbin
    Copy-Item -Path $efisysnopromptbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
    $Destinationefisysnopromptbin = Join-Path $DestinationEfiBoot 'efisys_noprompt.bin'

<#     if ($PSBoundParameters.ContainsKey('NoPrompt')) {
        $efisysbin = $AdkPaths.efisysnopromptbin
        Copy-Item -Path $efisysbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
        $Destinationefisysbin = Join-Path $DestinationEfiBoot 'efisys_noprompt.bin'
    } else {
        $efisysbin = $AdkPaths.efisysbin
        Copy-Item -Path $efisysbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
        $Destinationefisysbin = Join-Path $DestinationEfiBoot 'efisys.bin'
    } #>

    Write-Verbose  "DestinationBoot: $DestinationBoot"
    Write-Verbose  "etfsbootcom: $etfsbootcom"
    Write-Verbose  "Destinationetfsbootcom: $Destinationetfsbootcom"

    Write-Verbose  "DestinationEfiBoot: $DestinationEfiBoot"
    Write-Verbose  "efisysbin: $efisysbin"
    Write-Verbose  "Destinationefisysbin: $Destinationefisysbin"
    Write-Verbose  "efisysnopromptbin: $efisysnopromptbin"
    Write-Verbose  "Destinationefisysnopromptbin: $Destinationefisysnopromptbin"
    #=================================================
    #   Strings
    #=================================================
    $isoLabelString = '-l"{0}"' -f "$isoLabel"
    Write-Verbose  "isoLabelString: $isoLabelString"
    #=================================================
    #   Create Prompt ISO
    #=================================================
    $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$Destinationetfsbootcom", "$Destinationefisysbin"
    Write-Verbose  "BootDataString: $BootDataString"

    $Process = Start-Process $oscdimgexe -args @("-m","-o","-u2","-bootdata:$BootDataString",'-u2','-udfver102',$isoLabelString,"`"$MediaPath`"", "`"$IsoFullName`"") -PassThru -Wait -NoNewWindow

    if (-NOT (Test-Path $IsoFullName)) {
        Write-Error "Something didn't work"
        Break
    }
    $PromptIso = Get-Item -Path $IsoFullName
    #Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) ISO created at $PromptIso"
    #=================================================
    #   Create NoPrompt ISO
    #=================================================
    $IsoFullName = "$($PromptIso.Directory)\$($PromptIso.BaseName)_NoPrompt.iso"
    $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$Destinationetfsbootcom", "$Destinationefisysnopromptbin"
    Write-Verbose  "BootDataString: $BootDataString"

    $Process = Start-Process $oscdimgexe -args @("-m","-o","-u2","-bootdata:$BootDataString",'-u2','-udfver102',$isoLabelString,"`"$MediaPath`"", "`"$IsoFullName`"") -PassThru -Wait -NoNewWindow

    if (-NOT (Test-Path $IsoFullName)) {
        Write-Error "Something didn't work"
        Break
    }
    $NoPromptIso = Get-Item -Path $IsoFullName
    #Write-Host -ForegroundColor Yellow "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) ISO created at $NoPromptIso"
    #=================================================
    #   OpenExplorer
    #=================================================
    if ($PSBoundParameters.ContainsKey('OpenExplorer')) {
        explorer $WorkspacePath
    }
    #=================================================
    #   Return Get-Item
    #=================================================
    Return $PromptIso

<#     $Results += [pscustomobject]@{
        FullName            = $IsoFullName
        Name                = $isoFileName
        Label               = $isoLabel
        isoDirectory     = $MediaPath
    }
    Return $Results #>
    #=================================================
}
function New-WindowsAdkISO {
    <#
        .SYNOPSIS
        Creates an .iso file from a bootable media directory.  ADK is required

        .DESCRIPTION
        Creates a .iso file from a bootable media directory.  ADK is required

        .NOTES
        David Segura
        25.02.26     Initial Release replacing New-AdkISO
        25.03.01     Updated to use Get-WindowsAdkPaths
    #>
    [CmdletBinding()]
    param (
        # Directory containing the bootable media
        [Parameter(Mandatory = $true)]
        [ValidateScript({
                if (-NOT ($_ | Test-Path)) { throw "Path does not exist: $_" }
                if (-NOT ($_ | Test-Path -PathType Container)) { throw "Path must be a directory: $_" }
                return $true
            })]
        [System.IO.FileInfo]
        $MediaPath,

        # File Name of the ISO
        [Parameter(Mandatory = $true)]
        [System.String]
        $isoFileName,

        # Label of the ISO.  Limited to 16 characters
        [Parameter(Mandatory = $true)]
        [ValidateLength(1,16)]
        [System.String]
        $isoLabel,

        [Parameter(Mandatory = $false)]
        [ValidateScript({
                if (-NOT ($_ | Test-Path)) { throw "Path does not exist: $_" }
                if (-NOT ($_ | Test-Path -PathType Container)) { throw "Path must be a directory: $_" }
                return $true
            })]
        [System.IO.FileInfo]
        $IsoDirectory = $((Get-Item -Path $MediaPath -ErrorAction Stop).Parent.FullName),

        # Path to the Windows ADK root directory. Typically 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit'
        [ValidateScript({
                if (-NOT ($_ | Test-Path)) { throw "Path does not exist: $_" }
                if (-NOT ($_ | Test-Path -PathType Container)) { throw "Path must be a directory: $_" }
                if (-NOT (Test-Path "$($_.FullName)\Deployment Tools")) { throw "Path does not contain a Deployment Tools subfolder: $_" }
                # if (-NOT (Test-Path "$($_.FullName)\Windows Preinstallation Environment")) { throw "Path does not contain a Windows Preinstallation Environment directory: $_"}
                return $true
            })]
        [System.IO.FileInfo]
        $WindowsAdkRoot,

        #[System.Management.Automation.SwitchParameter]$NoPrompt,
        #[System.Management.Automation.SwitchParameter]$Mount,

        # Opens Windows Explorer to the parent directory of the ISO File
        [System.Management.Automation.SwitchParameter]
        $OpenExplorer
    )
    #=================================================
    $Error.Clear()
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Start"
	#=================================================
	Block-WinPE
	Block-StandardUser
    Block-PowerShellVersionLt5
    #=================================================
    # Get Adk Paths
    if ($WindowsAdkRoot) {
        $WindowsAdkPaths = Get-WindowsAdkPaths -WindowsAdkRoot $WindowsAdkRoot
    } else {
        $WindowsAdkPaths = Get-WindowsAdkPaths
    }
    if ($null -eq $WindowsAdkPaths) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Could not get ADK going, sorry"
        Break
    }
    $IsoFullName = Join-Path $IsoDirectory $isoFileName
    $PathOscdimg = $WindowsAdkPaths.PathOscdimg
    $oscdimgexe = $WindowsAdkPaths.oscdimgexe

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] IsoDirectory: $IsoDirectory"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] IsoFullName: $IsoFullName"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] PathOscdimg: $PathOscdimg"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] oscdimgexe: $oscdimgexe"
    #=================================================
    # Test Paths
    $DestinationBoot = Join-Path $MediaPath 'boot'
    if (-NOT (Test-Path $DestinationBoot)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Cannot locate $DestinationBoot"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This does not appear to be a valid bootable ISO"
        Break
    }
    $DestinationEfiBoot = Join-Path $MediaPath 'efi\microsoft\boot'
    if (-NOT (Test-Path $DestinationEfiBoot)) {
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Cannot locate $DestinationEfiBoot"
        Write-Warning "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] This does not appear to be a valid bootable ISO"
        Break
    }
    #=================================================
    # etfsboot.com
    $etfsbootcom = $WindowsAdkPaths.etfsbootcom
    $Destinationetfsbootcom = Join-Path $DestinationBoot 'etfsboot.com'
    if (Test-Path $Destinationetfsbootcom) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Using existing $Destinationetfsbootcom"
    }
    else {
        Copy-Item -Path $etfsbootcom -Destination $DestinationBoot -Force -ErrorAction Stop
    }
    #=================================================
    # efisys.bin and efisys_noprompt.bin
    $efisysbin = $WindowsAdkPaths.efisysbin
    $Destinationefisysbin = Join-Path $DestinationEfiBoot 'efisys.bin'
    if (Test-Path $Destinationefisysbin) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Using existing $Destinationefisysbin"
    }
    else {
        Copy-Item -Path $efisysbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
    }

    $efisysnopromptbin = $WindowsAdkPaths.efisysnopromptbin
    $Destinationefisysnopromptbin = Join-Path $DestinationEfiBoot 'efisys_noprompt.bin'
    if (Test-Path $Destinationefisysnopromptbin) {
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Using existing $Destinationefisysnopromptbin"
    }
    else {
        Copy-Item -Path $efisysnopromptbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
    }

<#     if ($PSBoundParameters.ContainsKey('NoPrompt')) {
        $efisysbin = $WindowsAdkPaths.efisysnopromptbin
        Copy-Item -Path $efisysbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
        $Destinationefisysbin = Join-Path $DestinationEfiBoot 'efisys_noprompt.bin'
    } else {
        $efisysbin = $WindowsAdkPaths.efisysbin
        Copy-Item -Path $efisysbin -Destination $DestinationEfiBoot -Force -ErrorAction Stop
        $Destinationefisysbin = Join-Path $DestinationEfiBoot 'efisys.bin'
    } #>

    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DestinationBoot: $DestinationBoot"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] etfsbootcom: $etfsbootcom"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destinationetfsbootcom: $Destinationetfsbootcom"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] DestinationEfiBoot: $DestinationEfiBoot"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] efisysbin: $efisysbin"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destinationefisysbin: $Destinationefisysbin"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] efisysnopromptbin: $efisysnopromptbin"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Destinationefisysnopromptbin: $Destinationefisysnopromptbin"
    #=================================================
    # Strings
    $isoLabelString = '-l"{0}"' -f "$isoLabel"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] isoLabelString: $isoLabelString"
    #=================================================
    # Create Prompt ISO
    $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$Destinationetfsbootcom", "$Destinationefisysbin"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] BootDataString: $BootDataString"

    $Process = Start-Process $oscdimgexe -args @('-m', '-o', '-u2', "-bootdata:$BootDataString", '-u2', '-udfver102', $isoLabelString, "`"$MediaPath`"", "`"$IsoFullName`"") -PassThru -Wait -WindowStyle Hidden

    if (-NOT (Test-Path $IsoFullName)) {
        Write-Error "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Something didn't work"
        Break
    }
    $PromptIso = Get-Item -Path $IsoFullName
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ISO created at $PromptIso"
    #=================================================
    # Create NoPrompt ISO
    $IsoFullName = "$($PromptIso.Directory)\$($PromptIso.BaseName)_NoPrompt.iso"
    $BootDataString = '2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$Destinationetfsbootcom", "$Destinationefisysnopromptbin"
    Write-Verbose "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] BootDataString: $BootDataString"

    $Process = Start-Process $oscdimgexe -args @('-m', '-o', '-u2', "-bootdata:$BootDataString", '-u2', '-udfver102', $isoLabelString, "`"$MediaPath`"", "`"$IsoFullName`"") -PassThru -Wait -WindowStyle Hidden

    if (-NOT (Test-Path $IsoFullName)) {
        Write-Error "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] Something didn't work"
        Break
    }
    $NoPromptIso = Get-Item -Path $IsoFullName
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand)] ISO created at $NoPromptIso"
    #=================================================
    # Open Windows Explorer
    if ($PSBoundParameters.ContainsKey('OpenExplorer')) {
        explorer $IsoDirectory
    }
    #=================================================
    # Return Get-Item
    Return $PromptIso

    <#  $Results += [pscustomobject]@{
        FullName            = $IsoFullName
        Name                = $isoFileName
        Label               = $isoLabel
        isoDirectory     = $MediaPath
    }
    Return $Results #>
    #=================================================
}
