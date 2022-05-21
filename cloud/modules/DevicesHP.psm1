<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module is designed to work in WinPE or Full
    This module is for HP Devices and leveraged HP Tools
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/DevicesHP.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/DevicesHP.psm1')
#>
#=================================================
#region Functions

function osdcloud-InstallModuleHPCMSL {
    [CmdletBinding()]
    param ()
    $InstallModule = $false
    $PSModuleName = 'HPCMSL'
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
            Install-Module $PSModuleName -SkipPublisherCheck -Scope AllUsers -Force -AcceptLicense
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -SkipPublisherCheck -AcceptLicense -Scope AllUsers -Force
        }
    }
    Import-Module -Name $PSModuleName -Force -Global -ErrorAction SilentlyContinue
}
function osdcloud-DetermineHPTPM{
    $SP87753 = Get-CimInstance  -Namespace "root\cimv2\security\MicrosoftTPM" -query "select * from win32_tpm where IsEnabled_InitialValue = 'True' and ((ManufacturerVersion like '7.%' and ManufacturerVersion < '7.63.3353') or (ManufacturerVersion like '5.1%') or (ManufacturerVersion like '5.60%') or (ManufacturerVersion like '5.61%') or (ManufacturerVersion like '4.4%') or (ManufacturerVersion like '6.40%') or (ManufacturerVersion like '6.41%') or (ManufacturerVersion like '6.43.243.0') or (ManufacturerVersion like '6.43.244.0'))"
    $SP94937 = Get-CimInstance  -Namespace "root\cimv2\security\MicrosoftTPM" -query "select * from win32_tpm where IsEnabled_InitialValue = 'True' and ((ManufacturerVersion like '7.62%') or (ManufacturerVersion like '7.63%') or (ManufacturerVersion like '7.83%') or (ManufacturerVersion like '6.43%') )"
    if ($SP87753){Return SP87753}
    elseif ($SP94937){Return SP94937}
    else{Return "NA"}
}
function osdcloud-DownloadHPTPM {
    [CmdletBinding()]
    param ($WorkingFolder)
    $ImportModule = Import-Module -Name HPCMSL -Global -Force -ErrorAction SilentlyContinue
    $Module = Get-Module -Name HPCMSL -ErrorAction SilentlyContinue
    if ($Module){
        $TPMUpdate = osdcloud-DetermineHPTPM
        if ($TPMUpdate -ne "NA")
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
                Return $UpdatePath
                }
            }
        }
    else {throw "Unable to load HPCMSL"}
    
}
function osdcloud-StartHPTPMUpdate {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        $path,
        [Parameter(Mandatory=$false)]
        $filename,
        [Parameter(Mandatory=$false)]
        $spec,
        [Parameter(Mandatory=$false)]
        $logsuffix
        )
    
    $Process = "$path\TPMConfig64.exe"
    #Create Argument List
    if ($filename -and $spec){$TPMArg = "-s -f$filename -a$spec -l$($env:temp)\TPMConfig_$($logsuffix).log"}
    elseif ($filename -and !($spec)) { $TPMArg = "-s -f$filename -l$($env:temp)\TPMConfig_$($logsuffix).log"}
    elseif (!($filename) -and $spec) { $TPMArg = "-s -a$spec -l$($env:temp)\TPMConfig_$($logsuffix).log"}
    elseif (!($filename) -and !($spec)) { $TPMArg = "-s -l$($env:temp)\TPMConfig_$($logsuffix).log"}
    
    Write-Output "Running Command: Start-Process -FilePath $Process -ArgumentList $TPMArg -PassThru -Wait"
    
    $TPMUpdate = Start-Process -FilePath $Process -ArgumentList $TPMArg -PassThru -Wait
    write-output "TPMUpdate Exit Code: $($TPMUpdate.exitcode)"
    }
function osdcloud-UpdateHPTPM {
    [CmdletBinding()]
    param ($WorkingFolder)
    $UpdatePath = osdcloud-DownloadHPTPM -WorkingFolder $WorkingFolder
    if (!(Test-Path -Path $UpdatePath)){Throw "Failed to Locate Update Path"}
    osdcloud-StartHPTPMUpdate -path $extractPath

}


#endregion
#=================================================