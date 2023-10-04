<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module should be loaded in OOBE and Windows
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/ne-winpe.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/ne-winpe.psm1')
#>

#region Functions
function osdcloud-InstallModulePester {
    [CmdletBinding()]
    param ()
    $InstallModule = $false
    $PSModuleName = 'Pester'
    $InstalledModule = Get-Module -Name $PSModuleName -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore -WarningAction Ignore
    
    if ($GalleryPSModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            Write-Host -ForegroundColor Yellow "[-] Install-Module $PSModuleName $($GalleryPSModule.Version)"
            Install-Module $PSModuleName -Scope AllUsers -Force -SkipPublisherCheck -AllowClobber
            #Import-Module $PSModuleName -Force
        }
    }
    $InstalledModule = Get-Module -Name $PSModuleName -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
    if ($GalleryPSModule) {
        if (($InstalledModule.Version -as [version]) -ge ($GalleryPSModule.Version -as [version])) {
            Write-Host -ForegroundColor Green "[+] $PSModuleName $($GalleryPSModule.Version)"
        }
    }
}
function osdcloud-InstallPwsh {
    [CmdletBinding()]
    param ()
    $PowerShellSeven = Get-ChildItem -Path "$env:ProgramFiles" pwsh.exe -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($PowerShellSeven) {
        Write-Host -ForegroundColor Green "[+] PowerShell $($PowerShellSeven.VersionInfo.FileVersion)"
    }
    else {
        if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
            Write-Host -ForegroundColor Yellow "[-] winget install --id Microsoft.PowerShell --exact --scope machine --override '/quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ADD_PATH=1' --accept-source-agreements --accept-package-agreements"
            winget install --id Microsoft.PowerShell --exact --scope machine --override '/quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ADD_PATH=1' --accept-source-agreements --accept-package-agreements
        }
        else {
            Write-Host -ForegroundColor Yellow "[-] Invoke-Expression (Invoke-RestMethod https://aka.ms/install-powershell.ps1)"
            Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI"
        }
        $PowerShellSeven = Get-ChildItem -Path "$env:ProgramFiles" pwsh.exe -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($PowerShellSeven) {
            Write-Host -ForegroundColor Green "[+] PowerShell $($PowerShellSeven.VersionInfo.FileVersion)"
        }
    }
}
function osdcloud-InstallScriptAutopilot {
    [CmdletBinding()]
    param ()
    $InstalledScript = Get-InstalledScript -Name Get-WindowsAutoPilotInfo -ErrorAction SilentlyContinue
    if (-not $InstalledScript) {
        Write-Host -ForegroundColor DarkGray 'Install-Script Get-WindowsAutoPilotInfo [AllUsers]'
        Install-Script -Name Get-WindowsAutoPilotInfo -Force -Scope AllUsers
    }
}
function osdcloud-InstallWinGet {
    [CmdletBinding()]
    param ()

    if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
        Write-Host -ForegroundColor Green '[+] WinGet is installed'
    }
    else {
        if (Get-AppxPackage -Name 'Microsoft.DesktopAppInstaller' -ErrorAction SilentlyContinue) {
            Write-Host -ForegroundColor Yellow '[-] Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe'
            try {
                Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction Stop
            }
            catch {
                Write-Host -ForegroundColor Red '[!] Could not install Microsoft.DesktopAppInstaller AppxPackage'
                Break
            }
        }
    }

    if (Get-AppxPackage -Name 'Microsoft.DesktopAppInstaller' -ErrorAction SilentlyContinue | Where-Object { $_.Version -ge '1.21.2701.0' }) {
        Write-Host -ForegroundColor Green '[+] WinGet is current'
    }
    else {
        if (Get-Command 'WinGet' -ErrorAction SilentlyContinue) {
            $WingetVersion = & winget.exe --version
            [string]$WingetVersion = $WingetVersion -replace '[a-zA-Z\-]'

            Write-Host -ForegroundColor Yellow "[-] WinGet $WingetVersion requires an update"
        }
        else {
            Write-Host -ForegroundColor Yellow '[-] Installing WinGet'
        }

        $progressPreference = 'silentlyContinue'
        Write-Host -ForegroundColor Yellow '[-] Downloading Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
        Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

        Write-Host -ForegroundColor Yellow '[-] Downloading Microsoft.VCLibs.x64.14.00.Desktop.appx'
        Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
    
        Write-Host -ForegroundColor Yellow '[-] Downloading Microsoft.UI.Xaml.2.7.x64.appx'
        Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile Microsoft.UI.Xaml.2.7.x64.appx

        Write-Host -ForegroundColor Yellow '[-] Installing WinGet and its dependencies'
        Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
        Add-AppxPackage Microsoft.UI.Xaml.2.7.x64.appx
        Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
    }
}
#endregion

#region Gary Blok
function osdcloud-RenamePC {
    [CmdletBinding()]
    param ()
    <# Gary Blok @gwblok Recast Software
    Generate Generic Computer Name based on Model Name... doesn't work well in Production as it names the machine after the model, so if you have more than one model.. it will get the same name.
    This is used in my lab to name the PCs after the model, which makes life easier for me.

    It creates randomly generated names for VMs following the the pattern "VM-CompanyName-Random 5 digit Number" - You would need to change how many digits this is if you have a longer company name.

    NOTES.. Computer name can NOT be longer than 15 charaters.  There is no checking to ensure the name is under that limit.


    #>


    $Manufacturer = (Get-WmiObject -Class:Win32_ComputerSystem).Manufacturer
    $Model = (Get-WmiObject -Class:Win32_ComputerSystem).Model
    $CompanyName = "GARYTOWN"

    if ($Manufacturer -match "Lenovo")
        {
        $Model = ((Get-CimInstance -ClassName Win32_ComputerSystemProduct).Version).split(" ")[1]
        $ComputerName = "$($Manufacturer)-$($Model)"
        }
    elseif (($Manufacturer -match "HP") -or ($Manufacturer -match "Hew")){
        $Manufacturer = "HP"
        
        if ($Model-match "EliteDesk"){$Model = $Model.replace("EliteDesk","ED")}
        elseif($Model-match "EliteBook"){$Model = $Model.replace("EliteBook","EB")}
        elseif($Model-match "ProDesk"){$Model = $Model.replace("ProDesk","PD")}
        elseif($Model-match "ProBook"){$Model = $Model.replace("ProBook","PB")}
        $Model = $model.replace(" ","-")
        $ComputerName = $Model.Substring(0,12)
        }
    elseif($Manufacturer -match "Dell"){
        $Manufacturer = "Dell"
        $Model = (Get-WmiObject -Class:Win32_ComputerSystem).Model
        if ($Model-match "Latitude"){$Model = $Model.replace("Latitude","L")}
        elseif($Model-match "OptiPlex"){$Model = $Model.replace("OptiPlex","O")}
        elseif($Model-match "Precision"){$Model = $Model.replace("Precision","P")}
        $Model = $model.replace(" ","-")
        if($Model-match "Tower"){
            $Model = $Model.replace("Tower","T")
            $Keep = $Model.Split("-") | select -First 3
            $ComputerName = "$($Manufacturer)-$($Keep[0])-$($Keep[1])-$($Keep[2])"
            }
        else
            {
            $Keep = $Model.Split("-") | select -First 2
            $ComputerName = "$($Manufacturer)-$($Keep[0])-$($Keep[1])"
            }
        
        }
    elseif ($Manufacturer -match "Microsoft")
        {
        if ($Model -match "Virtual")
            {
            $Random = Get-Random -Maximum 99999
            $ComputerName = "VM-$($CompanyName)-$($Random )"
            if ($ComputerName.Length -gt 15){
                $ComputerName = $ComputerName.Substring(0,15)
                }
            }
        }
    else {
        $Serial = (Get-WmiObject -class:win32_bios).SerialNumber
        if ($Serial.Length -ge 15)
            {
            $ComputerName = $Serial.substring(0,15)
            }
        else
            {
            $ComputerName = $Serial 
            }
        }
    Write-Output "Renaming Computer to $ComputerName"
    Rename-Computer -NewName $ComputerName
    Write-Output "====================================================="
}
#endregion