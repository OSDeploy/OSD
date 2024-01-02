function Install-ModuleHPCMSL {
    [CmdletBinding()]
    param ()
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
    $InstallModule = $false
    $PSModuleName = 'HPCMSL'
    if (-not (Get-Module -Name PowerShellGet -ListAvailable | Where-Object {$_.Version -ge '2.2.5'})) {
        Write-Host -ForegroundColor DarkGray 'Install-Package PackageManagement,PowerShellGet [AllUsers]'
        Install-Package -Name PowerShellGet -MinimumVersion 2.2.5 -Force -Confirm:$false -Source PSGallery | Out-Null

        Write-Host -ForegroundColor DarkGray 'Import-Module PackageManagement,PowerShellGet [Global]'
        Import-Module PackageManagement,PowerShellGet -Force -Scope Global -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        }
    $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore | Select-Object -First 1
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
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -SkipPublisherCheck -Scope AllUsers -Force -AcceptLicense -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -SkipPublisherCheck -AcceptLicense -Scope AllUsers -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
    }
    Import-Module -Name $PSModuleName -Force -Global -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
}

function Get-HPTPMDetermine{
    $SP87753 = Get-CimInstance  -Namespace "root\cimv2\security\MicrosoftTPM" -query "select * from win32_tpm where IsEnabled_InitialValue = 'True' and ((ManufacturerVersion like '7.%' and ManufacturerVersion < '7.63.3353') or (ManufacturerVersion like '5.1%') or (ManufacturerVersion like '5.60%') or (ManufacturerVersion like '5.61%') or (ManufacturerVersion like '4.4%') or (ManufacturerVersion like '6.40%') or (ManufacturerVersion like '6.41%') or (ManufacturerVersion like '6.43.243.0') or (ManufacturerVersion like '6.43.244.0'))"
    $SP94937 = Get-CimInstance  -Namespace "root\cimv2\security\MicrosoftTPM" -query "select * from win32_tpm where IsEnabled_InitialValue = 'True' and ((ManufacturerVersion like '7.62%') or (ManufacturerVersion like '7.63%') or (ManufacturerVersion like '7.83%') or (ManufacturerVersion like '6.43%') )"
    if ($SP87753){Return "SP87753"}
    elseif ($SP94937){Return "SP94937"}
    else{Return $false}
}

function Invoke-HPTPMDownload { #Used when you want to manually download and test, as it will extract for you.
    [CmdletBinding()]
    param ($WorkingFolder)
    Install-ModuleHPCMSL
    Import-Module -Name HPCMSL -Force
    $TPMUpdate = Get-HPTPMDetermine    
    if (!(($TPMUpdate -eq $false) -or ($TPMUpdate -eq "False")))
        {
        if ((!($WorkingFolder))-or ($null -eq $WorkingFolder)){$WorkingFolder = "$env:TEMP\TPM"}
        if (!(Test-Path -Path $WorkingFolder)){New-Item -Path $WorkingFolder -ItemType Directory -Force |Out-Null}
        $UpdatePath = "$WorkingFolder\$TPMUpdate.exe"
        $extractPath = "$WorkingFolder\$TPMUpdate"
        Write-Host "Starting downlaod & Install of TPM Update $TPMUpdate"
        Get-Softpaq -Number $TPMUpdate -SaveAs $UpdatePath -Overwrite yes
        if (!(Test-Path -Path $UpdatePath)){Throw "Failed to Download TPM Update"}
        Start-Process -FilePath $UpdatePath -ArgumentList "/s /e /f $extractPath" -Wait
        if (!(Test-Path -Path $UpdatePath)){Throw "Failed to Extract TPM Update"}
        else {
            Return $extractPath
            }
        }
    else {Write-Host "No TPM Softpaq to Download"}
}
function Invoke-HPTPMEXEDownload { #This will download just the TPM Softpaq needed and place in C:\OSDCloud\HP\TPM
    Install-ModuleHPCMSL
    Set-HPBIOSSetting -SettingName 'Virtualization Technology (VTx)' -Value 'Disable'
    Import-Module -Name HPCMSL -Force
    $TPMUpdate = Get-HPTPMDetermine
    if (!(($TPMUpdate -eq $false) -or ($TPMUpdate -eq "False")))
        {
        $DownloadFolder = "C:\OSDCloud\HP\TPM"
        if (Test-Path -Path $DownloadFolder){
            Remove-Item -Path $DownloadFolder -Force -Recurse
            New-Item -Path $DownloadFolder -ItemType Directory -Force |Out-Null
        }
        $UpdatePath = "$DownloadFolder\$TPMUpdate.exe"
        Write-Host "Starting download of TPM Update $TPMUpdate"
        Get-Softpaq -Number $TPMUpdate -SaveAs $UpdatePath -Overwrite yes
        if (!(Test-Path -Path $UpdatePath)){Throw "Failed to Download TPM Update"}
    }    
}
function Invoke-HPTPMEXEInstall {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)]
        $path,
        [Parameter(Mandatory=$false)]
        $filename,
        [Parameter(Mandatory=$false)]
        $spec,
        [Parameter(Mandatory=$false)]
        $logsuffix,
        [Parameter(Mandatory=$false)]
        $WorkingFolder
        )

        $TPM = Get-HPTPMDetermine
    if ($TPM){
        $DownloadFolder = "C:\OSDCloud\HP\TPM"
        $LogFolder = "C:\OSDCloud\Logs"
        $TPMUpdate = (Get-ChildItem -Path $DownloadFolder -Filter *.exe).FullName
        if (Test-Path $TPMUpdate){
            Start-Process -FilePath $TPMUpdate -ArgumentList "/s /e /f $DownloadFolder" -Wait
            if (!(Test-Path -Path "$DownloadFolder\TPMConfig64.exe")){Throw "Failed to Extract TPM Update"}
            $Process = "$DownloadFolder\TPMConfig64.exe"
            #Create Argument List
            if ($filename -and $spec){$TPMArg = "-s -f$filename -a$spec -l$($LogFolder)\TPMConfig.log"}
            elseif ($filename -and !($spec)) { $TPMArg = "-s -f$filename -l$($LogFolder)\TPMConfig.log"}
            elseif (!($filename) -and $spec) { $TPMArg = "-s -a$spec -l$($LogFolder)\TPMConfig.log"}
            elseif (!($filename) -and !($spec)) { $TPMArg = "-s -l$($LogFolder)\TPMConfig.log"}
            
            Write-Output "Running Command: Start-Process -FilePath $Process -ArgumentList $TPMArg -PassThru -Wait"
            $TPMUpdate = Start-Process -FilePath $Process -ArgumentList $TPMArg -PassThru -Wait
            write-output "TPMUpdate Exit Code: $($TPMUpdate.exitcode)"
            If ($TPMUpdate.ExitCode -eq 3010){
                write-output "$($TPMUpdate.exitcode): Success, Reboot Required"
            }
            else {
                Switch ($TPMUpdate.ExitCode)
                {   
                    0 {$ErrorDescription = "Success"}
                    128 {$ErrorDescription = " Invalid command line option"}
                    256 {$ErrorDescription = "No BIOS support"}
                    257 {$ErrorDescription = "No TPM firmware bin file"}
                    258 {$ErrorDescription = " Failed to create HP_TOOLS partition"}
                    259 {$ErrorDescription = "Failed to flash the firmware"}
                    260 {$ErrorDescription = "No EFI partition (for GPT)"}
                    261 {$ErrorDescription = "Bad EFI partition"}
                    262 {$ErrorDescription = "Cannot create HP_TOOLS partition (because the maximum number of partitions has been reached)"}
                    263 {$ErrorDescription = "Not enough space partition (when the size of the firmware binary file is greater than the free space of EFI or HP_TOOLS partition)"}
                    264 {$ErrorDescription = " Unsupported operating system"}
                    265 {$ErrorDescription = "Elevated (administrator) privileges are required"}
                    273 {$ErrorDescription = "Not supported chipset"}
                    274 {$ErrorDescription = "No more firmware upgrade is allowed"}
                    275 {$ErrorDescription = "Invalid firmware binary file "}
                    290 {$ErrorDescription = "BitLocker is currently enabled."}
                    291 {$ErrorDescription = "Unknown BitLocker status"}
                    292 {$ErrorDescription = "WinMagic encryption is currently enabled"}
                    293 {$ErrorDescription = "WinMagic SecureDoc is currently enabled"}
                    296 {$ErrorDescription = "No system information"}
                    305 {$ErrorDescription = "Intel TXT is currently enabled."}
                    306 {$ErrorDescription = "VTx is currently enabled."}
                    307 {$ErrorDescription = "SGX is currently enabled."}
                    1602 {$ErrorDescription = "User cancelled the operation"}
                    3010 {$ErrorDescription = "Success reboot required"}
                    3011 {$ErrorDescription = "Success rollback"}
                    3012 {$ErrorDescription = "Failed rollback"}

                }
                write-output "$($TPMUpdate.exitcode): $ErrorDescription"
            }
        }
        else {Throw "Failed to Locate Update Path"}
    }
}