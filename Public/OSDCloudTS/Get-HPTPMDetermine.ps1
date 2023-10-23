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
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            $InstallModule = $true
        }
    }
    else {
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

function Invoke-HPTPMDownload {
    [CmdletBinding()]
    param ($WorkingFolder)
    Install-ModuleHPCMSL
    Import-Module -Name HPCMSL -Force
    $TPMUpdate = osdcloud-HPTPMDetermine    
    if ($TPMUpdate -ne $false)
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
}
function Invoke-HPTPMEXEDownload {
    Install-ModuleHPCMSL
    Set-HPBIOSSetting -SettingName 'Virtualization Technology (VTx)' -Value 'Disable'
    Import-Module -Name HPCMSL -Force
    $TPMUpdate = Set-HPTPMDetermine
    if ($TPMUpdate -ne $false)
        {
        $DownloadFolder = "C:\OSDCloud\HP\TPM"
        if (!(Test-Path -Path $DownloadFolder)){New-Item -Path $DownloadFolder -ItemType Directory -Force |Out-Null}
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
    $TPMUpdate = Set-HPTPMDetermine
    if ($TPMUpdate){
        $DownloadFolder = "C:\OSDCloud\HP\TPM"
        $TPMUpdate = (Get-ChildItem -Path $DownloadFolder -Filter *.exe).FullName
        if (Test-Path $TPMUpdate){
            Start-Process -FilePath $TPMUpdate -ArgumentList "/s /e /f $DownloadFolder" -Wait
            if (!(Test-Path -Path "$DownloadFolder\TPMConfig64.exe")){Throw "Failed to Extract TPM Update"}
            $Process = "$DownloadFolder\TPMConfig64.exe"
            #Create Argument List
            if ($filename -and $spec){$TPMArg = "-s -f$filename -a$spec -l$($env:temp)\TPMConfig.log"}
            elseif ($filename -and !($spec)) { $TPMArg = "-s -f$filename -l$($env:temp)\TPMConfig.log"}
            elseif (!($filename) -and $spec) { $TPMArg = "-s -a$spec -l$($env:temp)\TPMConfig.log"}
            elseif (!($filename) -and !($spec)) { $TPMArg = "-s -l$($env:temp)\TPMConfig.log"}
            
            Write-Output "Running Command: Start-Process -FilePath $Process -ArgumentList $TPMArg -PassThru -Wait"
            $TPMUpdate = Start-Process -FilePath $Process -ArgumentList $TPMArg -PassThru -Wait
            write-output "TPMUpdate Exit Code: $($TPMUpdate.exitcode)"
        }
        else {Throw "Failed to Locate Update Path"}
    }
}