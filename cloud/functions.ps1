<#PSScriptInfo
.VERSION 22.9.13.1
.GUID 7a3671f6-485b-443e-8e86-b60fdcea1419
.AUTHOR David Segura @SeguraOSD
.COMPANYNAME osdcloud.com
.COPYRIGHT (c) 2022 David Segura osdcloud.com. All rights reserved.
.TAGS OSDeploy OSDCloud WinPE OOBE Windows AutoPilot
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/OSD
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
Script should be executed in a Command Prompt using the following command
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
This is abbreviated as
powershell iex (irm functions.osdcloud.com)
#>
<#
.SYNOPSIS
    PSCloudScript at functions.osdcloud.com
.DESCRIPTION
    PSCloudScript at functions.osdcloud.com
.NOTES
    Version 22.9.13.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/functions.ps1
.EXAMPLE
    powershell iex (irm functions.osdcloud.com)
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/functions.ps1')
#>
[CmdletBinding()]
param()
$ScriptName = 'functions.osdcloud.com'
$ScriptVersion = '23.6.3.1'

#region Initialize
if ($env:SystemDrive -eq 'X:') {
    $WindowsPhase = 'WinPE'
}
else {
    $ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
    if ($env:UserName -eq 'defaultuser0') {$WindowsPhase = 'OOBE'}
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') {$WindowsPhase = 'Specialize'}
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_AUDIT') {$WindowsPhase = 'AuditMode'}
    else {$WindowsPhase = 'Windows'}
}

Write-Host -ForegroundColor Green "[+] $ScriptName $ScriptVersion ($WindowsPhase Phase)"
#endregion

#region Transport Layer Security (TLS) 1.2
#Write-Host -ForegroundColor Green "[+] Transport Layer Security (TLS) 1.2"
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
#endregion

#region PowerShell Profile
$oobePowerShellProfile = @'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
[System.Environment]::SetEnvironmentVariable('Path',$Env:Path + ";$Env:ProgramFiles\WindowsPowerShell\Scripts",'Process')
'@
$winpePowerShellProfile = @'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
[System.Environment]::SetEnvironmentVariable('APPDATA',"$Env:UserProfile\AppData\Roaming",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('HOMEDRIVE',"$Env:SystemDrive",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('HOMEPATH',"$Env:UserProfile",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$Env:UserProfile\AppData\Local",[System.EnvironmentVariableTarget]::Process)
'@
#endregion

#region Functions
function osdcloud-SetExecutionPolicy {
    [CmdletBinding()]
    param ()
    if ($WindowsPhase -eq 'WinPE') {
        if ((Get-ExecutionPolicy) -ne 'Bypass') {
            Write-Host -ForegroundColor Yellow "[-] Set-ExecutionPolicy Bypass -Force"
            Set-ExecutionPolicy Bypass -Force
        }
        if ((Get-ExecutionPolicy) -eq 'Bypass') {
            Write-Host -ForegroundColor Green "[+] Get-ExecutionPolicy Bypass"
        }
    }
    if ($WindowsPhase -eq 'OOBE') {
        if ((Get-ExecutionPolicy -Scope CurrentUser) -ne 'RemoteSigned') {
            Write-Host -ForegroundColor Yellow "[-] Set-ExecutionPolicy -Scope CurrentUser RemoteSigned"
            Set-ExecutionPolicy RemoteSigned -Force -Scope CurrentUser
        }
        if ((Get-ExecutionPolicy -Scope CurrentUser) -eq 'RemoteSigned') {
            Write-Host -ForegroundColor Green "[+] Get-ExecutionPolicy RemoteSigned [CurrentUser]"
        }
    }
    if ($WindowsPhase -eq 'Windows') {
        # We should not be messing with ExecutionPolicy in Windows Phase
        # Display information only
        Write-Host -ForegroundColor Gray "[i] Get-ExecutionPolicy $(Get-ExecutionPolicy -Scope Process) [Process]"
        Write-Host -ForegroundColor Gray "[i] Get-ExecutionPolicy $(Get-ExecutionPolicy -Scope CurrentUser) [CurrentUser]"
        Write-Host -ForegroundColor Gray "[i] Get-ExecutionPolicy $(Get-ExecutionPolicy -Scope LocalMachine) [LocalMachine]"
    }
}
function osdcloud-WinpeSetEnvironmentVariables {
    [CmdletBinding()]
    param ()
    if (Get-Item env:LocalAppData -ErrorAction Ignore) {
        Write-Verbose 'System Environment Variable LocalAppData is already present in this PowerShell session'
    }
    else {
        Write-Host -ForegroundColor DarkGray 'Set LocalAppData in System Environment'
        Write-Verbose 'WinPE does not have the LocalAppData System Environment Variable'
        Write-Verbose 'This can be enabled for this Power Session, but it will not persist'
        Write-Verbose 'Set System Environment Variable LocalAppData for this PowerShell session'
        #[System.Environment]::SetEnvironmentVariable('LocalAppData',"$env:UserProfile\AppData\Local")
        [System.Environment]::SetEnvironmentVariable('APPDATA',"$Env:UserProfile\AppData\Roaming",[System.EnvironmentVariableTarget]::Process)
        [System.Environment]::SetEnvironmentVariable('HOMEDRIVE',"$Env:SystemDrive",[System.EnvironmentVariableTarget]::Process)
        [System.Environment]::SetEnvironmentVariable('HOMEPATH',"$Env:UserProfile",[System.EnvironmentVariableTarget]::Process)
        [System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$Env:UserProfile\AppData\Local",[System.EnvironmentVariableTarget]::Process)
    }
}
function osdcloud-SetPowerShellProfile {
    [CmdletBinding()]
    param ()
    if ($WindowsPhase -eq 'WinPE') {
        if (-not (Test-Path "$env:UserProfile\Documents\WindowsPowerShell")) {
            $null = New-Item -Path "$env:UserProfile\Documents\WindowsPowerShell" -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
        Write-Host -ForegroundColor DarkGray 'Set LocalAppData in PowerShell Profile'
        $winpePowerShellProfile | Set-Content -Path "$env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force -Encoding Unicode
    }
    if ($WindowsPhase -eq 'OOBE') {
        if (-not (Test-Path $Profile.CurrentUserAllHosts)) {
            
            Write-Host -ForegroundColor DarkGray 'Set PowerShell Profile [CurrentUserAllHosts]'
            $null = New-Item $Profile.CurrentUserAllHosts -ItemType File -Force

            #[System.Environment]::SetEnvironmentVariable('Path',"$Env:LocalAppData\Microsoft\WindowsApps;$Env:ProgramFiles\WindowsPowerShell\Scripts;",'User')

            #[System.Environment]::SetEnvironmentVariable('Path',$Env:Path + ";$Env:ProgramFiles\WindowsPowerShell\Scripts")
            #[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)

            $oobePowerShellProfile | Set-Content -Path $Profile.CurrentUserAllHosts -Force -Encoding Unicode
        }
    }
}
function osdcloud-InstallPackageManagement {
    [CmdletBinding()]
    param ()
    if ($WindowsPhase -eq 'WinPE') {
        $InstalledModule = Import-Module PackageManagement -PassThru -ErrorAction Ignore
        if (-not $InstalledModule) {
            Write-Host -ForegroundColor DarkGray 'Install PackageManagement'
            $PackageManagementURL = "https://psg-prod-eastus.azureedge.net/packages/packagemanagement.1.4.8.1.nupkg"
            Invoke-WebRequest -UseBasicParsing -Uri $PackageManagementURL -OutFile "$env:TEMP\packagemanagement.1.4.8.1.zip"
            $null = New-Item -Path "$env:TEMP\1.4.8.1" -ItemType Directory -Force
            Expand-Archive -Path "$env:TEMP\packagemanagement.1.4.8.1.zip" -DestinationPath "$env:TEMP\1.4.8.1"
            $null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement" -ItemType Directory -ErrorAction SilentlyContinue
            Move-Item -Path "$env:TEMP\1.4.8.1" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement\1.4.8.1"
            Import-Module PackageManagement -Force -Scope Global
        }
    }
    else {
        if (-not (Get-Module -Name PowerShellGet -ListAvailable | Where-Object {$_.Version -ge '2.2.5'})) {
            Write-Host -ForegroundColor DarkGray 'Install-Package PackageManagement,PowerShellGet [AllUsers]'
            Install-Package -Name PowerShellGet -MinimumVersion 2.2.5 -Force -Confirm:$false -Source PSGallery | Out-Null
    
            Write-Host -ForegroundColor DarkGray 'Import-Module PackageManagement,PowerShellGet [Global]'
            Import-Module PackageManagement,PowerShellGet -Force -Scope Global
        }
    }
}
function osdcloud-WinpeInstallPowerShellGet {
    [CmdletBinding()]
    param ()
    $InstalledModule = Import-Module PowerShellGet -PassThru -ErrorAction Ignore
    if (-not (Get-Module -Name PowerShellGet -ListAvailable | Where-Object {$_.Version -ge '2.2.5'})) {
        Write-Host -ForegroundColor DarkGray 'Install PowerShellGet'
        $PowerShellGetURL = "https://psg-prod-eastus.azureedge.net/packages/powershellget.2.2.5.nupkg"
        Invoke-WebRequest -UseBasicParsing -Uri $PowerShellGetURL -OutFile "$env:TEMP\powershellget.2.2.5.zip"
        $null = New-Item -Path "$env:TEMP\2.2.5" -ItemType Directory -Force
        Expand-Archive -Path "$env:TEMP\powershellget.2.2.5.zip" -DestinationPath "$env:TEMP\2.2.5"
        $null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet" -ItemType Directory -ErrorAction SilentlyContinue
        Move-Item -Path "$env:TEMP\2.2.5" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet\2.2.5"
        Import-Module PowerShellGet -Force -Scope Global
    }
}
function osdcloud-RemoveAppx {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param (
        [Parameter(Mandatory,ParameterSetName='Basic')]
        [System.Management.Automation.SwitchParameter]$Basic,

        [Parameter(Mandatory,ParameterSetName='ByName',Position=0)]
        [System.String[]]$Name
    )
    if ($WindowsPhase -eq 'WinPE') {
        if (Get-Command Get-AppxProvisionedPackage) {
            if ($Basic) {
                $Name = @('CommunicationsApps','OfficeHub','People','Skype','Solitaire','Xbox','ZuneMusic','ZuneVideo')
            }
            elseif ($Name) {
                #Do Nothing
            }
            if ($Name) {
                Write-Host -ForegroundColor Cyan "Remove-AppxProvisionedPackage -Path 'C:\' -PackageName"
                foreach ($Item in $Name) {
                    Get-AppxProvisionedPackage -Path 'C:\' | Where-Object {$_.DisplayName -Match $Item} | ForEach-Object {
                        Write-Host -ForegroundColor DarkGray $_.DisplayName
                        Try {
                            $null = Remove-AppxProvisionedPackage -Path 'C:\' -PackageName $_.PackageName
                        }
                        Catch {
                            Write-Warning "Appx Provisioned Package $($_.PackageName) did not remove successfully"
                        }
                    }
                }
            }
        }
    }
    if ($WindowsPhase -eq 'OOBE') {
        if (Get-Command Get-AppxProvisionedPackage) {
            if ($Basic) {
                $Name = @('CommunicationsApps','OfficeHub','People','Skype','Solitaire','Xbox','ZuneMusic','ZuneVideo')
            }
            elseif ($Name) {
                #Do Nothing
            }
            else {
                $Name = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | `
                Select-Object -Property DisplayName, PackageName | `
                Out-GridView -PassThru -Title 'Select one or more Appx Provisioned Packages to remove' | `
                Select-Object -ExpandProperty DisplayName
            }
            if ($Name) {
                Write-Host -ForegroundColor Cyan 'Remove-AppxProvisionedPackage -Online -AllUsers -PackageName'
                foreach ($Item in $Name) {
                    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -Match $Item} | ForEach-Object {
                        Write-Host -ForegroundColor DarkGray $_.DisplayName
                        if ((Get-Command Remove-AppxProvisionedPackage).Parameters.ContainsKey('AllUsers')) {
                            Try {
                                $null = Remove-AppxProvisionedPackage -Online -AllUsers -PackageName $_.PackageName
                            }
                            Catch {
                                Write-Warning "AllUsers Appx Provisioned Package $($_.PackageName) did not remove successfully"
                            }
                        }
                        else {
                            Try {
                                $null = Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName
                            }
                            Catch {
                                Write-Warning "Appx Provisioned Package $($_.PackageName) did not remove successfully"
                            }
                        }
                    }
                }
            }
        }
    }
}
New-Alias -Name 'RemoveAppx' -Value 'osdcloud-RemoveAppx' -Description 'OSDCloud' -Force
function osdcloud-TrustPSGallery {
    [CmdletBinding()]
    param ()

    if ($WindowsPhase -eq 'WinPE') {
        $PowerShellGallery = Get-PSRepository -Name PSGallery -ErrorAction Ignore
        if ($PowerShellGallery.InstallationPolicy -ne 'Trusted') {
            Write-Host -ForegroundColor Yellow "[-] Set-PSRepository PSGallery Trusted"
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        }

        $PowerShellGallery = Get-PSRepository -Name PSGallery -ErrorAction Ignore
        if ($PowerShellGallery.InstallationPolicy -eq 'Trusted') {
            Write-Host -ForegroundColor Green "[+] PSRepository PSGallery Trusted"
        }
    }
    else {
        $PowerShellGallery = Get-PSRepository -Name PSGallery -Scope CurrentUser -ErrorAction Ignore
        if ($PowerShellGallery.InstallationPolicy -ne 'Trusted') {
            Write-Host -ForegroundColor Yellow "[-] Set-PSRepository PSGallery Trusted [CurrentUser]"
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -Scope CurrentUser
        }

        $PowerShellGallery = Get-PSRepository -Name PSGallery -Scope CurrentUser -ErrorAction Ignore
        if ($PowerShellGallery.InstallationPolicy -eq 'Trusted') {
            Write-Host -ForegroundColor Green "[+] PSRepository PSGallery Trusted Trusted [CurrentUser]"
        }
    }
}
#endregion

#region Gary Blok
function Test-HPIASupport {
    $CabPath = "$env:TEMP\platformList.cab"
    $XMLPath = "$env:TEMP\platformList.xml"
    $PlatformListCabURL = "https://hpia.hpcloud.hp.com/ref/platformList.cab"
    Invoke-WebRequest -Uri $PlatformListCabURL -OutFile $CabPath -UseBasicParsing
    $Expand = expand $CabPath $XMLPath
    [xml]$XML = Get-Content $XMLPath
    $Platforms = $XML.ImagePal.Platform.SystemID
    $MachinePlatform = (Get-CimInstance -Namespace root/cimv2 -ClassName Win32_BaseBoard).Product
    if ($MachinePlatform -in $Platforms){$HPIASupport = $true}
    else {$HPIASupport = $false}
    return $HPIASupport
    }

function Test-DCUSupport {
    $SystemSKUNumber = (Get-CimInstance -ClassName Win32_ComputerSystem).SystemSKUNumber
    $CabPathIndex = "$env:temp\DellCabDownloads\CatalogIndexPC.cab"
    $DellCabExtractPath = "$env:temp\DellCabDownloads\DellCabExtract"
    # Pull down Dell XML CAB used in Dell Command Update ,extract and Load
    if (!(Test-Path $DellCabExtractPath)){$newfolder = New-Item -Path $DellCabExtractPath -ItemType Directory -Force}
    Invoke-WebRequest -Uri "https://downloads.dell.com/catalog/CatalogIndexPC.cab" -OutFile $CabPathIndex -UseBasicParsing -ErrorAction SilentlyContinue
    New-Item -Path $DellCabExtractPath -ItemType Directory -Force | Out-Null
    $Expand = expand $CabPathIndex $DellCabExtractPath\CatalogIndexPC.xml
    [xml]$XMLIndex = Get-Content "$DellCabExtractPath\CatalogIndexPC.xml" -ErrorAction SilentlyContinue
    #Dig Through Dell XML to find Model of THIS Computer (Based on System SKU)
    $XMLModel = $XMLIndex.ManifestIndex.GroupManifest | Where-Object {$_.SupportedSystems.Brand.Model.systemID -match $SystemSKUNumber}
    if ($XMLModel){$DCUSupportedDevice = $true}
    else {$DCUSupportedDevice = $false}
    Return $DCUSupportedDevice
    }
    


$Manufacturer = (Get-CimInstance -Class:Win32_ComputerSystem).Manufacturer
$Model = (Get-CimInstance -Class:Win32_ComputerSystem).Model
if ($Manufacturer -match "HP" -or $Manufacturer -match "Hewlett-Packard"){
    $Manufacturer = "HP"
    $HPEnterprise = Test-HPIASupport
}
if ($Manufacturer -match "Dell"){
    $Manufacturer = "Dell"
    $DellEnterprise = Test-DCUSupport
}
#endregion

#region Finish Initialization
if ($WindowsPhase -eq 'WinPE') {
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_winpe.psm1')
    #Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_winpeoobe.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_winpestartup.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdcloudbeta.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdpad.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/osdcloudazure.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/secrets.psm1')
    if ($HPEnterprise -eq $true){Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')}
    if ($DellEnterprise -eq $true){Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/devicesdell.psm1')}
}
if ($WindowsPhase -eq 'OOBE') {
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_oobe.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_oobewin.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_oobestartup.psm1')
    #Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_winpeoobe.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/autopilot.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdpad.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/defender.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/secrets.psm1')
    if ($HPEnterprise -eq $true){Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')}
    if ($DellEnterprise -eq $true){Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/devicesdell.psm1')}

}
if ($WindowsPhase -eq 'Specialize') {
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')
    #Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_oobe.psm1')
    #Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_oobewin.psm1')
    #Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_oobestartup.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/defender.psm1')
    #Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/secrets.psm1')
    if ($HPEnterprise -eq $true){Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')}
    if ($DellEnterprise -eq $true){Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/devicesdell.psm1')}

}
if ($WindowsPhase -eq 'Windows') {
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_oobewin.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/autopilot.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdcloudbeta.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/azosdpad.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/defender.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/osdcloudazure.psm1')
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/secrets.psm1')
    if ($HPEnterprise -eq $true){Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')}
    if ($DellEnterprise -eq $true){Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/devicesdell.psm1')}

}
#endregion

#region PowerShell Prompt
<#
Since these functions are temporarily loaded, the PowerShell Prompt is changed to make it visual if the functions are loaded or not
[OSDCloud]: PS C:\>

You can read more about how to make the change here
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_prompts?view=powershell-5.1
#>
function Prompt {
    $(if (Test-Path variable:/PSDebugContext) { '[DBG]: ' }
    else { "[OSDCloud]: " }
    ) + 'PS ' + $(Get-Location) +
    $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
}
#endregion