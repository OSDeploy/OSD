function Install-ModuleHPCMSL {
    <#
.SYNOPSIS
    Installs or updates the HP Client Management Script Library (HPCMSL) PowerShell module.

.DESCRIPTION
    Ensures the HPCMSL module (version 1.8.5) is installed and up to date from the PowerShell Gallery.
    If PowerShellGet 2.2.5 or later is not present, it is installed first.
    Compares the installed HPCMSL version against the Gallery version and installs if missing or outdated.
    Supports both WinPE and full Windows environments.
    After installation, the module is imported into the global scope.

.EXAMPLE
    Install-ModuleHPCMSL
    Installs or updates HPCMSL 1.8.5 for all users and imports it into the current session.

.NOTES
    Requires internet access to reach the PowerShell Gallery.
    Must be run with administrator privileges.
    Uses the $WindowsPhase variable to detect WinPE vs. full OS context.
#>
    [CmdletBinding()]
    param ()
    if ((Get-ExecutionPolicy) -ne 'Bypass') {
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Force -ErrorAction SilentlyContinue
    }
    $InstallModule = $false
    $PSModuleName = 'HPCMSL'
    if (-not (Get-Module -Name PowerShellGet -ListAvailable | Where-Object { $_.Version -ge '2.2.5' })) {
        Write-Host -ForegroundColor DarkGray 'Install-Package PackageManagement,PowerShellGet [AllUsers]'
        Install-Package -Name PowerShellGet -MinimumVersion 2.2.5 -Force -Confirm:$false -Source PSGallery | Out-Null

        Write-Host -ForegroundColor DarkGray 'Import-Module PackageManagement,PowerShellGet [Global]'
        Import-Module PackageManagement, PowerShellGet -Force -Scope Global -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    }
    $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore
    if ($InstalledModule.count -gt 1) { $InstalledModule = $InstalledModule | Select-Object -First 1 }
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore

    if ($InstalledModule) {
        write-host "$PSModuleName in Gallery: $($GalleryPSModule.Version) vs Installed: $($InstalledModule.Version)"
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            $InstallModule = $true
        }
    }
    else {
        Write-Host "$PSModuleName is not Installed"
        $InstallModule = $true
    }

    if ($InstallModule) {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName 1.8.5 [AllUsers]"
            Install-Module $PSModuleName -RequiredVersion 1.8.5 -SkipPublisherCheck -Scope AllUsers -Force -AcceptLicense -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName 1.8.5 [AllUsers]"
            Install-Module $PSModuleName -RequiredVersion 1.8.5 -SkipPublisherCheck -AcceptLicense -Scope AllUsers -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
    }

    Import-Module -Name $PSModuleName -Force -Global -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
}

Function Test-HPTPMFromOSDCloudUSB {
    <#
.SYNOPSIS
    Tests whether HP TPM firmware packages exist on an OSDCloud USB drive.

.DESCRIPTION
    Searches for HP TPM firmware softpaq files (SP87753 and/or SP94937) on a connected
    OSDCloud USB volume. If found, optionally copies them to C:\OSDCloud\HP for local use.
    Returns $true if the requested package(s) are found, otherwise $false.

.PARAMETER PackageID
    The HP softpaq package ID to check for. Valid values are 'SP87753' or 'SP94937'.
    If not specified, both packages are checked.

.PARAMETER TryToCopy
    Switch to indicate that found firmware files should be copied to C:\OSDCloud\HP.
    Note: this parameter is currently unreachable due to early return statements when
    a PackageID is specified.

.EXAMPLE
    Test-HPTPMFromOSDCloudUSB -PackageID SP94937
    Returns $true if SP94937.exe exists on the OSDCloud USB and copies it to C:\OSDCloud\HP.

.EXAMPLE
    Test-HPTPMFromOSDCloudUSB
    Returns $true only if both SP87753.exe and SP94937.exe exist on the OSDCloud USB.

.OUTPUTS
    System.Boolean
#>
    [CmdletBinding()]
    param (

        [Parameter()]
        [System.String]
        $PackageID,
        [switch]
        $TryToCopy
    )
    $ComputerManufacturer = (Get-MyComputerManufacturer -Brief)
    $OSDCloudUSB = Get-Volume.usb | Where-Object { ($_.FileSystemLabel -match 'OSDCloud') -or ($_.FileSystemLabel -match 'BHIMAGE') } | Select-Object -First 1
    if (!(Test-Path -Path "C:\OSDCloud")) {
        Write-Host -ForegroundColor Yellow "C:\OSDCloud does not exist, will be unable to copy TPM files local"
    }
    else {
        if (!(Test-Path -Path "C:\OSDCloud\HP")) {
            New-Item -Path "C:\OSDCloud\HP" -ItemType Directory -Force | Out-Null
        }
    }
    $HPTPMSP87753 = "$($OSDCloudUSB.DriveLetter):\OSDCloud\Firmware\$ComputerManufacturer\TPM\SP87753.exe"
    $HPTPMSP94937 = "$($OSDCloudUSB.DriveLetter):\OSDCloud\Firmware\$ComputerManufacturer\TPM\SP94937.exe"
    if ($PackageID) {
        if ($PackageID -eq 'SP87753') {
            if (Test-Path -Path $HPTPMSP87753) {
                if (Test-Path -Path "C:\OSDCloud") { Copy-Item -Path $HPTPMSP87753 -Destination "C:\OSDCloud\HP\SP87753.exe" -Force }
                return $true
            }
            else {
                return $false
            }
        }
        if ($PackageID -eq 'SP94937') {
            if (Test-Path -Path $HPTPMSP94937) {
                if (Test-Path -Path "C:\OSDCloud") { Copy-Item -Path $HPTPMSP94937 -Destination "C:\OSDCloud\HP\SP94937.exe" -Force }

                return $true
            }
            else {
                return $false
            }
        }
    }
    else {
        if ((Test-Path -Path $HPTPMSP94937) -and (Test-Path -Path $HPTPMSP87753)) {
            if (Test-Path -Path "C:\OSDCloud") { Copy-Item -Path $HPTPMSP94937 -Destination "C:\OSDCloud\HP\SP94937.exe" -Force }
            if (Test-Path -Path "C:\OSDCloud") { Copy-Item -Path $HPTPMSP87753 -Destination "C:\OSDCloud\HP\SP87753.exe" -Force }
            return $true
        }
        else {
            return $false
        }
    }
    if ($TryToCopy) {
        if (Test-Path -Path $HPTPMSP94937) {
            if (Test-Path -Path "C:\OSDCloud") {
                Write-Host "Copy-Item -Path $HPTPMSP94937 -Destination 'C:\OSDCloud\HP\SP94937.exe' -Force"
                Copy-Item -Path $HPTPMSP94937 -Destination "C:\OSDCloud\HP\SP94937.exe" -Force
            }
        }
        if (Test-Path -Path $HPTPMSP87753) {
            if (Test-Path -Path "C:\OSDCloud") {
                Write-Host "Copy-Item -Path $HPTPMSP87753 -Destination 'C:\OSDCloud\HP\SP87753.exe' -Force"
                Copy-Item -Path $HPTPMSP87753 -Destination "C:\OSDCloud\HP\SP87753.exe" -Force
            }
        }
    }

}


function Get-HPTPMDetermine {
    <#
.SYNOPSIS
    Determines which HP TPM firmware update package is required for the current device.

.DESCRIPTION
    Queries the TPM via WMI (win32_tpm) to identify the manufacturer and firmware version.
    For Infineon (IFX) TPMs, compares the firmware version against known vulnerable version
    ranges and returns the appropriate HP softpaq package ID.
    Returns 'SP87753' for firmware requiring an older update package, 'SP94937' for firmware
    requiring the newer package, or $false if no update is needed or the TPM is not Infineon.

.EXAMPLE
    $Package = Get-HPTPMDetermine
    Returns 'SP87753', 'SP94937', or $false.

.OUTPUTS
    System.String
    Returns 'SP87753', 'SP94937', or $false.

.NOTES
    Requires access to the root\cimv2\security\MicrosoftTPM WMI namespace.
    Must be run with administrator privileges.
#>
    [CmdletBinding()]
    param ()
    $TPM = Get-CimInstance -Namespace "root\cimv2\security\MicrosoftTPM" -ClassName win32_tpm
    if ($TPM.ManufacturerIdTxt -match "IFX") {
        $SP87753 = Get-CimInstance  -Namespace "root\cimv2\security\MicrosoftTPM" -query "select * from win32_tpm where IsEnabled_InitialValue = 'True' and ((ManufacturerVersion like '7.%' and ManufacturerVersion < '7.63.3353') or (ManufacturerVersion like '5.1%') or (ManufacturerVersion like '5.60%') or (ManufacturerVersion like '5.61%') or (ManufacturerVersion like '4.4%') or (ManufacturerVersion like '6.40%') or (ManufacturerVersion like '6.41%') or (ManufacturerVersion like '6.43.243.0') or (ManufacturerVersion like '6.43.244.0'))"
        $SP94937 = Get-CimInstance  -Namespace "root\cimv2\security\MicrosoftTPM" -query "select * from win32_tpm where IsEnabled_InitialValue = 'True' and ((ManufacturerVersion like '7.62%') or (ManufacturerVersion like '7.63%') or (ManufacturerVersion like '7.83%') or (ManufacturerVersion like '6.43%') )"
        if (!($SP87753)) {
            $TPM = Get-CimInstance -Namespace "root\cimv2\security\MicrosoftTPM" -ClassName win32_tpm
            #Testing change below, from -eq to -lt.  If you manually downgrade using 94937 from 2.0 to 1.2, it sets the version to 6.43.X
            if ($TPM.SpecVersion -match "1.2" -and $TPM.ManufacturerVersion -lt "6.43") {
                $SP87753 = 'SP87753'
            }
        }
        if ($SP87753) { Return "SP87753" }
        elseif ($SP94937) { Return "SP94937" }
        else { Return $false }
    }
    else { Return $false }
}

function Invoke-HPTPMDownload {
    <#
.SYNOPSIS
    Downloads and extracts the required HP TPM firmware update softpaq using HPCMSL.

.DESCRIPTION
    Calls Get-HPTPMDetermine to identify the required softpaq, then uses the HPCMSL
    Get-Softpaq cmdlet to download it to the specified working folder. The downloaded
    EXE is silently extracted to a subfolder. Returns the path to the extracted folder.
    Intended for manual download and testing scenarios.

.PARAMETER WorkingFolder
    The folder path where the softpaq EXE will be downloaded and extracted.
    Defaults to $env:TEMP\TPM if not specified.

.EXAMPLE
    Invoke-HPTPMDownload
    Downloads and extracts the required TPM firmware softpaq to $env:TEMP\TPM.

.EXAMPLE
    Invoke-HPTPMDownload -WorkingFolder 'C:\Temp\TPMWork'
    Downloads and extracts the required TPM firmware softpaq to C:\Temp\TPMWork.

.OUTPUTS
    System.String
    Returns the path to the extracted firmware folder.

.NOTES
    Requires internet access and the HPCMSL PowerShell module.
    Must be run with administrator privileges.
#>
    [CmdletBinding()]
    param ($WorkingFolder)
    Install-ModuleHPCMSL
    Import-Module -Name HPCMSL -Force
    $TPMUpdate = Get-HPTPMDetermine
    if (!(($TPMUpdate -eq $false) -or ($TPMUpdate -eq "False"))) {
        if ((!($WorkingFolder)) -or ($null -eq $WorkingFolder)) { $WorkingFolder = "$env:TEMP\TPM" }
        if (!(Test-Path -Path $WorkingFolder)) { New-Item -Path $WorkingFolder -ItemType Directory -Force | Out-Null }
        $UpdatePath = "$WorkingFolder\$TPMUpdate.exe"
        $extractPath = "$WorkingFolder\$TPMUpdate"
        Write-Host "Starting downlaod & Install of TPM Update $TPMUpdate"
        Get-Softpaq -Number $TPMUpdate -SaveAs $UpdatePath -Overwrite yes
        if (!(Test-Path -Path $UpdatePath)) { Throw "Failed to Download TPM Update" }
        Start-Process -FilePath $UpdatePath -ArgumentList "/s /e /f $extractPath" -Wait
        if (!(Test-Path -Path $extractPath)) { Throw "Failed to Extract TPM Update" }
        else {
            Return $extractPath
        }
    }
    else { Write-Host "No TPM Softpaq to Download" }
}

function Invoke-HPTPMDowngrade {
    <#
.SYNOPSIS
    Downloads and applies the HP SP94937 softpaq to downgrade a TPM from 2.0 to 1.2.

.DESCRIPTION
    Downloads softpaq SP94937 using HPCMSL, extracts it, and runs TPMConfig64.exe with
    the '-a 1.2' argument to downgrade an Infineon TPM from firmware version 2.0 to 1.2.
    Disables Virtualization Technology (VTx) in the BIOS via Set-HPBIOSSetting before
    applying the firmware change.

.PARAMETER WorkingFolder
    The folder path where the softpaq EXE will be downloaded and extracted.
    Defaults to $env:TEMP\TPM if not specified.

.EXAMPLE
    Invoke-HPTPMDowngrade
    Downloads SP94937 to $env:TEMP\TPM and downgrades the Infineon TPM to spec 1.2.

.NOTES
    Requires HPCMSL and the HP BIOS WMI interface (Set-HPBIOSSetting).
    Must be run with administrator privileges.
    A system reboot is typically required after the firmware change takes effect.
#>
    [CmdletBinding()]
    param ($WorkingFolder)
    Install-ModuleHPCMSL
    Import-Module -Name HPCMSL -Force
    $TPMUpdate = 'SP94937'
    if (!(($TPMUpdate -eq $false) -or ($TPMUpdate -eq "False"))) {
        if ((!($WorkingFolder)) -or ($null -eq $WorkingFolder)) { $WorkingFolder = "$env:TEMP\TPM" }
        if (!(Test-Path -Path $WorkingFolder)) { New-Item -Path $WorkingFolder -ItemType Directory -Force | Out-Null }
        $UpdatePath = "$WorkingFolder\$TPMUpdate.exe"
        $extractPath = "$WorkingFolder\$TPMUpdate"
        Write-Host "Starting downlaod & Install of TPM Update $TPMUpdate"
        Get-Softpaq -Number $TPMUpdate -SaveAs $UpdatePath -Overwrite yes
        if (!(Test-Path -Path $UpdatePath)) { Throw "Failed to Download TPM Update" }
        Start-Process -FilePath $UpdatePath -ArgumentList "/s /e /f $extractPath" -Wait
        if (!(Test-Path -Path $extractPath)) { Throw "Failed to Extract TPM Update" }
        else {
            Write-Host "TPM Downloaded to $extractPath"
        }
    }
    else { Write-Host "No TPM Softpaq to Download" }
    if ($extractPath) {
        Set-HPBIOSSetting -SettingName 'Virtualization Technology (VTx)' -Value 'Disable'
        $spec = '1.2'
        $Process = "$extractPath\TPMConfig64.exe"
        $TPMArg = "-s -a$spec -l$($LogFolder)\TPMConfig.log"
        Write-Host -ForegroundColor Green "Running Command: Start-Process -FilePath $Process -ArgumentList $TPMArg -PassThru -Wait"
        $TPMUpdate = Start-Process -FilePath $Process -ArgumentList $TPMArg -PassThru -Wait
        write-output "Exit Code: $($TPMUpdate.exitcode)"
    }
}
function Invoke-HPTPMEXEDownload {
    <#
.SYNOPSIS
    Downloads the required HP TPM firmware EXE to C:\OSDCloud\HP\TPM.

.DESCRIPTION
    Calls Get-HPTPMDetermine to identify the required softpaq, then downloads the firmware
    EXE to C:\OSDCloud\HP\TPM. If the file is already present on a connected OSDCloud USB
    drive it is copied locally instead of being downloaded from the internet. The destination
    folder is cleared before each run. Also disables Virtualization Technology (VTx) in the
    BIOS via Set-HPBIOSSetting.

.EXAMPLE
    Invoke-HPTPMEXEDownload
    Determines the required TPM softpaq and downloads (or copies) it to C:\OSDCloud\HP\TPM.

.NOTES
    Requires HPCMSL if the firmware file is not already available on an OSDCloud USB drive.
    Must be run with administrator privileges.
#>
    [CmdletBinding()]
    param ()
    Set-HPBIOSSetting -SettingName 'Virtualization Technology (VTx)' -Value 'Disable'
    $TPMUpdate = Get-HPTPMDetermine
    if (!(($TPMUpdate -eq $false) -or ($TPMUpdate -eq "False"))) {
        $DownloadFolder = "C:\OSDCloud\HP\TPM"
        if (Test-Path -Path $DownloadFolder) {
            Remove-Item -Path $DownloadFolder -Force -Recurse
            New-Item -Path $DownloadFolder -ItemType Directory -Force | Out-Null
        }
        $UpdatePath = "$DownloadFolder\$TPMUpdate.exe"
        if ((Test-HPTPMFromOSDCloudUSB -PackageID $TPMUpdate) -eq $true) {
            if (Test-Path -Path "C:\OSDCloud\HP\$TPMUpdate.exe") {
                "Found Local Copy of TPM Update $TPMUpdate, Copying to Staging Area"
                Copy-Item -Path "C:\OSDCloud\HP\$TPMUpdate.exe" -Destination $UpdatePath -Force -Verbose
            }
        }
        if (!(Test-Path -Path $UpdatePath)) {
            Write-Host "Starting download of TPM Update $TPMUpdate"
            Install-ModuleHPCMSL
            Import-Module -Name HPCMSL -Force
            Get-Softpaq -Number $TPMUpdate -SaveAs $UpdatePath -Overwrite yes
        }
        if (!(Test-Path -Path $UpdatePath)) { Throw "Failed to Download TPM Update" }
    }
}
function Invoke-HPTPMEXEInstall {
    <#
.SYNOPSIS
    Extracts and installs the HP TPM firmware update from C:\OSDCloud\HP\TPM.

.DESCRIPTION
    Locates the firmware EXE in C:\OSDCloud\HP\TPM, silently extracts it, then runs
    TPMConfig64.exe with the specified arguments to apply the TPM firmware update.
    Logs activity to C:\OSDCloud\Logs\TPMConfig.log. Outputs the exit code from
    TPMConfig64 along with a human-readable description for all documented exit codes.

.PARAMETER path
    Reserved parameter. Not currently used.

.PARAMETER filename
    Optional firmware binary filename passed to TPMConfig64 via the -f argument.

.PARAMETER spec
    Optional TPM specification version to target (e.g., '1.2' or '2.0').
    Passed to TPMConfig64 via the -a argument.

.PARAMETER logsuffix
    Reserved parameter. Not currently used.

.PARAMETER WorkingFolder
    Reserved parameter. Not currently used.

.EXAMPLE
    Invoke-HPTPMEXEInstall
    Installs the TPM firmware using default TPMConfig64 arguments.

.EXAMPLE
    Invoke-HPTPMEXEInstall -spec '1.2'
    Installs the TPM firmware targeting the 1.2 specification.

.NOTES
    Run Invoke-HPTPMEXEDownload first to stage the firmware file.
    Must be run with administrator privileges.
    Exit code 3010 indicates success with a required reboot.
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        $path,
        [Parameter(Mandatory = $false)]
        $filename,
        [Parameter(Mandatory = $false)]
        $spec,
        [Parameter(Mandatory = $false)]
        $logsuffix,
        [Parameter(Mandatory = $false)]
        $WorkingFolder
    )

    $TPM = Get-HPTPMDetermine
    if ($TPM) {
        $DownloadFolder = "C:\OSDCloud\HP\TPM"
        $LogFolder = "C:\OSDCloud\Logs"
        $TPMUpdate = (Get-ChildItem -Path $DownloadFolder -Filter *.exe).FullName
        if (Test-Path $TPMUpdate) {
            Start-Process -FilePath $TPMUpdate -ArgumentList "/s /e /f $DownloadFolder" -Wait
            if (!(Test-Path -Path "$DownloadFolder\TPMConfig64.exe")) { Throw "Failed to Extract TPM Update" }
            $Process = "$DownloadFolder\TPMConfig64.exe"
            #Create Argument List
            if ($filename -and $spec) { $TPMArg = "-s -f$filename -a$spec -l$($LogFolder)\TPMConfig.log" }
            elseif ($filename -and !($spec)) { $TPMArg = "-s -f$filename -l$($LogFolder)\TPMConfig.log" }
            elseif (!($filename) -and $spec) { $TPMArg = "-s -a$spec -l$($LogFolder)\TPMConfig.log" }
            elseif (!($filename) -and !($spec)) { $TPMArg = "-s -l$($LogFolder)\TPMConfig.log" }

            Write-Output "Running Command: Start-Process -FilePath $Process -ArgumentList $TPMArg -PassThru -Wait"
            $TPMUpdate = Start-Process -FilePath $Process -ArgumentList $TPMArg -PassThru -Wait
            write-output "TPMUpdate Exit Code: $($TPMUpdate.exitcode)"
            If ($TPMUpdate.ExitCode -eq 3010) {
                write-output "$($TPMUpdate.exitcode): Success, Reboot Required"
            }
            else {
                Switch ($TPMUpdate.ExitCode) {
                    0 { $ErrorDescription = "Success" }
                    128 { $ErrorDescription = " Invalid command line option" }
                    256 { $ErrorDescription = "No BIOS support" }
                    257 { $ErrorDescription = "No TPM firmware bin file" }
                    258 { $ErrorDescription = " Failed to create HP_TOOLS partition" }
                    259 { $ErrorDescription = "Failed to flash the firmware" }
                    260 { $ErrorDescription = "No EFI partition (for GPT)" }
                    261 { $ErrorDescription = "Bad EFI partition" }
                    262 { $ErrorDescription = "Cannot create HP_TOOLS partition (because the maximum number of partitions has been reached)" }
                    263 { $ErrorDescription = "Not enough space partition (when the size of the firmware binary file is greater than the free space of EFI or HP_TOOLS partition)" }
                    264 { $ErrorDescription = " Unsupported operating system" }
                    265 { $ErrorDescription = "Elevated (administrator) privileges are required" }
                    273 { $ErrorDescription = "Not supported chipset" }
                    274 { $ErrorDescription = "No more firmware upgrade is allowed" }
                    275 { $ErrorDescription = "Invalid firmware binary file " }
                    290 { $ErrorDescription = "BitLocker is currently enabled." }
                    291 { $ErrorDescription = "Unknown BitLocker status" }
                    292 { $ErrorDescription = "WinMagic encryption is currently enabled" }
                    293 { $ErrorDescription = "WinMagic SecureDoc is currently enabled" }
                    296 { $ErrorDescription = "No system information" }
                    305 { $ErrorDescription = "Intel TXT is currently enabled." }
                    306 { $ErrorDescription = "VTx is currently enabled." }
                    307 { $ErrorDescription = "SGX is currently enabled." }
                    1602 { $ErrorDescription = "User cancelled the operation" }
                    3010 { $ErrorDescription = "Success reboot required" }
                    3011 { $ErrorDescription = "Success rollback" }
                    3012 { $ErrorDescription = "Failed rollback" }

                }
                write-output "$($TPMUpdate.exitcode): $ErrorDescription"
            }
        }
        else { Throw "Failed to Locate Update Path" }
    }
}
