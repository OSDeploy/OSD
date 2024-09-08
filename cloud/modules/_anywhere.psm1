<#
.SYNOPSIS
    OSDCloud Cloud Module for functions.osdcloud.com
.DESCRIPTION
    OSDCloud Cloud Module for functions.osdcloud.com
.NOTES
    This module can be loaded in all Windows phases
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1
.EXAMPLE
    Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/_anywhere.psm1')
#>
#=================================================
#region Functions
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
function osdcloud-SetPowerShellProfile {
    [CmdletBinding()]
    param ()
$winpePowerShellProfile = @'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
[System.Environment]::SetEnvironmentVariable('APPDATA',"$Env:UserProfile\AppData\Roaming",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('HOMEDRIVE',"$Env:SystemDrive",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('HOMEPATH',"$Env:UserProfile",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$Env:UserProfile\AppData\Local",[System.EnvironmentVariableTarget]::Process)
'@
$oobePowerShellProfile = @'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
[System.Environment]::SetEnvironmentVariable('Path',$Env:Path + ";$Env:ProgramFiles\WindowsPowerShell\Scripts",'Process')
'@

    if ($WindowsPhase -eq 'WinPE') {
        if (-not (Test-Path "$env:UserProfile\Documents\WindowsPowerShell")) {
            $null = New-Item -Path "$env:UserProfile\Documents\WindowsPowerShell" -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
        Write-Host -ForegroundColor Green "[+] Set LocalAppData in PowerShell Profile"
        $winpePowerShellProfile | Set-Content -Path "$env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force -Encoding Unicode
    }
    if ($WindowsPhase -eq 'OOBE') {
        if (-not (Test-Path $Profile.CurrentUserAllHosts)) {
            Write-Host -ForegroundColor Green "[+] Set LocalAppData in PowerShell Profile [CurrentUserAllHosts]"
            $null = New-Item $Profile.CurrentUserAllHosts -ItemType File -Force
            #[System.Environment]::SetEnvironmentVariable('Path',"$Env:LocalAppData\Microsoft\WindowsApps;$Env:ProgramFiles\WindowsPowerShell\Scripts;",'User')
            #[System.Environment]::SetEnvironmentVariable('Path',$Env:Path + ";$Env:ProgramFiles\WindowsPowerShell\Scripts")
            #[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
            $oobePowerShellProfile | Set-Content -Path $Profile.CurrentUserAllHosts -Force -Encoding Unicode
        }
    }
}
function osdcloud-TrustPSGallery {
    [CmdletBinding()]
    param ()
    $PowerShellGallery = Get-PSRepository -Name PSGallery -ErrorAction Ignore
    if ($PowerShellGallery.InstallationPolicy -ne 'Trusted') {
        Write-Host -ForegroundColor Yellow "[-] Set-PSRepository PSGallery Trusted"
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
    if ($PowerShellGallery.InstallationPolicy -eq 'Trusted') {
        Write-Host -ForegroundColor Green "[+] PSRepository PSGallery Trusted"
    }
}
function osdcloud-SetExecutionPolicy {
    [CmdletBinding()]
    param ()
    if ($WindowsPhase -eq 'WinPE') {
        if ((Get-ExecutionPolicy) -ne 'Bypass') {
            Write-Host -ForegroundColor Yellow "[-] Set-ExecutionPolicy Bypass -Force"
            Set-ExecutionPolicy Bypass -Force
        }
        else {
            Write-Host -ForegroundColor Green "[+] Get-ExecutionPolicy Bypass"
        }
    }
    if ($WindowsPhase -eq 'OOBE') {
        if ((Get-ExecutionPolicy -Scope CurrentUser) -ne 'RemoteSigned') {
            Write-Host -ForegroundColor Yellow "[-] Set-ExecutionPolicy -Scope CurrentUser RemoteSigned"
            Set-ExecutionPolicy RemoteSigned -Force -Scope CurrentUser
        }
        else {
            Write-Host -ForegroundColor Green "[+] Get-ExecutionPolicy RemoteSigned [CurrentUser]"
        }
    }
    if ($WindowsPhase -eq 'Windows') {
        # We should not be messing with ExecutionPolicy in Windows Phase so set for Process
        Set-ExecutionPolicy RemoteSigned -Force -Scope Process
        Write-Host -ForegroundColor Gray "[i] Get-ExecutionPolicy $(Get-ExecutionPolicy -Scope Process) [Process]"
        Write-Host -ForegroundColor Gray "[i] Get-ExecutionPolicy $(Get-ExecutionPolicy -Scope CurrentUser) [CurrentUser]"
        Write-Host -ForegroundColor Gray "[i] Get-ExecutionPolicy $(Get-ExecutionPolicy -Scope LocalMachine) [LocalMachine]"
    }
}
function osdcloud-InstallNuget {
    [CmdletBinding()]
    param ()
    if ($WindowsPhase -eq 'WinPE') {
        $NuGetClientSourceURL = 'https://nuget.org/nuget.exe'
        $NuGetExeName = 'NuGet.exe'
        $PSGetProgramDataPath = Join-Path -Path $env:ProgramData -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
        $nugetExeBasePath = $PSGetProgramDataPath
        $nugetExeFilePath = Join-Path -Path $nugetExeBasePath -ChildPath $NuGetExeName
    
        if (-not (Test-Path -Path $nugetExeFilePath)) {
            if (-not (Test-Path -Path $nugetExeBasePath)) {
                $null = New-Item -Path $nugetExeBasePath -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            }
            Write-Host -ForegroundColor Yellow "[-] Downloading NuGet to $nugetExeFilePath"
            $null = Invoke-WebRequest -UseBasicParsing -Uri $NuGetClientSourceURL -OutFile $nugetExeFilePath
        }
    
        $PSGetAppLocalPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
        $nugetExeBasePath = $PSGetAppLocalPath
        $nugetExeFilePath = Join-Path -Path $nugetExeBasePath -ChildPath $NuGetExeName
        if (-not (Test-Path -Path $nugetExeFilePath)) {
            if (-not (Test-Path -Path $nugetExeBasePath)) {
                $null = New-Item -Path $nugetExeBasePath -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            }
            Write-Host -ForegroundColor Yellow "[-] Downloading NuGet to $nugetExeFilePath"
            $null = Invoke-WebRequest -UseBasicParsing -Uri $NuGetClientSourceURL -OutFile $nugetExeFilePath
        }
        if (Test-Path "$env:ProgramFiles\PackageManagement\ProviderAssemblies\nuget\2.8.5.208\Microsoft.PackageManagement.NuGetProvider.dll") {
            Write-Host -ForegroundColor Green "[+] Nuget 2.8.5.208+"
        }
        else {
            Write-Host -ForegroundColor Yellow "[-] Install-PackageProvider NuGet -MinimumVersion 2.8.5.201"
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope AllUsers | Out-Null
        }
    }
    else {
        if (Test-Path "$env:ProgramFiles\PackageManagement\ProviderAssemblies\nuget\2.8.5.208\Microsoft.PackageManagement.NuGetProvider.dll") {
            #Write-Host -ForegroundColor Green "[+] Nuget 2.8.5.208+"
        }
        else {
            Write-Host -ForegroundColor Yellow "[-] Install-PackageProvider NuGet -MinimumVersion 2.8.5.201"
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope AllUsers | Out-Null
        }
        $InstalledModule = Get-PackageProvider -Name NuGet | Where-Object {$_.Version -ge '2.8.5.201'} | Sort-Object Version -Descending | Select-Object -First 1
        if ($InstalledModule) {
            Write-Host -ForegroundColor Green "[+] NuGet $([string]$InstalledModule.Version)"
        }
    }
}
function osdcloud-InstallPackageManagement {
    [CmdletBinding()]
    param ()
    if ($WindowsPhase -eq 'WinPE') {
        $InstalledModule = Import-Module PackageManagement -PassThru -ErrorAction Ignore
        if (-not $InstalledModule) {
            Write-Host -ForegroundColor Yellow "[-] Install PackageManagement 1.4.8.1"
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
        $InstalledModule = Get-PackageProvider -Name PowerShellGet | Where-Object {$_.Version -ge '2.2.5'} | Sort-Object Version -Descending | Select-Object -First 1
        if (-not ($InstalledModule)) {
            Write-Host -ForegroundColor Yellow "[-] Install-PackageProvider PowerShellGet -MinimumVersion 2.2.5"
            Install-PackageProvider -Name PowerShellGet -MinimumVersion 2.2.5 -Force -Scope AllUsers | Out-Null
            Import-Module PowerShellGet -Force -Scope Global -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 5
        }
    
        $InstalledModule = Get-Module -Name PackageManagement -ListAvailable | Where-Object {$_.Version -ge '1.4.8.1'} | Sort-Object Version -Descending | Select-Object -First 1
        if (-not ($InstalledModule)) {
            Write-Host -ForegroundColor Yellow "[-] Install-Module PackageManagement -MinimumVersion 1.4.8.1"
            Install-Module -Name PackageManagement -MinimumVersion 1.4.8.1 -Force -Confirm:$false -Source PSGallery -Scope AllUsers
            Import-Module PackageManagement -Force -Scope Global -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 5
        }
    
        Import-Module PackageManagement -Force -Scope Global -ErrorAction SilentlyContinue
        $InstalledModule = Get-Module -Name PackageManagement -ListAvailable | Where-Object {$_.Version -ge '1.4.8.1'} | Sort-Object Version -Descending | Select-Object -First 1
        if ($InstalledModule) {
            Write-Host -ForegroundColor Green "[+] PackageManagement $([string]$InstalledModule.Version)"
        }
        Import-Module PowerShellGet -Force -Scope Global -ErrorAction SilentlyContinue
        $InstalledModule = Get-PackageProvider -Name PowerShellGet | Where-Object {$_.Version -ge '2.2.5'} | Sort-Object Version -Descending | Select-Object -First 1
        if ($InstalledModule) {
            Write-Host -ForegroundColor Green "[+] PowerShellGet $([string]$InstalledModule.Version)"
        }
    }
}
function osdcloud-InstallModuleAutopilot {
    [CmdletBinding()]
    param ()
    $InstalledModule = Import-Module WindowsAutopilotIntune -PassThru -ErrorAction Ignore
    if (-not $InstalledModule) {
        Write-Host -ForegroundColor DarkGray 'Install-Module AzureAD,Microsoft.Graph.Intune,WindowsAutopilotIntune [CurrentUser]'
        Install-Module WindowsAutopilotIntune -Force -Scope CurrentUser -SkipPublisherCheck
    }
}
function osdcloud-InstallPowerShellModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.Management.Automation.SwitchParameter]
        $Force
    )
    # Do not install the Module by default
    $InstallModule = $false

    # Get the version from the local machine
    $InstalledModule = Get-Module -Name $Name -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
    
    # Get the version from PowerShell Gallery
    $GalleryPSModule = Find-Module -Name $Name -ErrorAction Ignore -WarningAction Ignore

    if ($InstalledModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            # The version in the gallery is newer than the installed version, so we need to install it
            $InstallModule = $true
        }
    }
    else {
        # Get-Module did not find the module, so we need to install it
        $InstallModule = $true
    }

    if ($InstallModule) {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor Yellow "[-] $Name $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $Name -Scope AllUsers -Force -SkipPublisherCheck -AllowClobber
        }
        elseif ($WindowsPhase -eq 'OOBE') {
            Write-Host -ForegroundColor Yellow "[-] $Name $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $Name -Scope AllUsers -Force -SkipPublisherCheck -AllowClobber
        }
        else {
            # Install the PowerShell Module in the OS
            Write-Host -ForegroundColor Yellow "[-] $Name $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $Name -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber
        }
    }
    else {
        # The module is already installed and up to date
        Import-Module -Name $Name -Force
        Write-Host -ForegroundColor Green "[+] $Name $($InstalledModule.Version)"
    }
}
function osdcloud-RestartComputer {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor Green 'Complete!'
    Write-Warning 'Device will restart in 30 seconds.  Press Ctrl + C to cancel'
    Start-Sleep -Seconds 30
    Restart-Computer
}
function osdcloud-StopComputer {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor Green 'Complete!'
    Write-Warning 'Device will shutdown in 30 seconds.  Press Ctrl + C to cancel'
    Start-Sleep -Seconds 30
    Stop-Computer
}
#endregion
#=================================================
#region Gary Blok
function osdcloud-UpdateModuleFilesManually {
    #Custom Testing - Overwrites files in module with updated ones in GitHub
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)]
        [ValidateSet($true, $false)]
        $DEVMode = $false
        ) 
    write-host "Manually Updating Several Module Files directly from GitHub" -ForegroundColor Cyan
    $ModulePath = (Get-ChildItem -Path "$($Env:ProgramFiles)\WindowsPowerShell\Modules\osd" | Where-Object {$_.Attributes -match "Directory"} | select -Last 1).fullname
    write-host "Updating Files in $ModulePath"
    $OSDCloudGUIDevProjectPath = "Projects\OSDCloudDev"
    $OSDCloudGUIProjectPath = "Projects\OSDCloudGUI"
    $OSDCloudFunctionsPath = "Public\Functions\OSDCloud"
    $GitHubURI = "https://raw.githubusercontent.com/OSDeploy/OSD/master"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudGUIDevProjectPath/MainWindow.ps1" -OutFile "$ModulePath/$OSDCloudGUIDevProjectPath/MainWindow.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudGUIDevProjectPath/MainWindow.xaml" -OutFile "$ModulePath/$OSDCloudGUIDevProjectPath/MainWindow.xaml"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudGUIProjectPath/MainWindow.ps1" -OutFile "$ModulePath/$OSDCloudGUIProjectPath/MainWindow.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudGUIProjectPath/MainWindow.xaml" -OutFile "$ModulePath/$OSDCloudGUIProjectPath/MainWindow.xaml"
    if ($DevMode -eq $true){Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Invoke-OSDSpecializeDev.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Invoke-OSDSpecializeDev.ps1"}
    else{Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Invoke-OSDSpecialize.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Invoke-OSDSpecialize.ps1"}
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Get-Win11Readiness.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Get-Win11Readiness.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Get-HyperVName.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Get-HyperVName.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-HyperVName.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-HyperVName.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteCreateFinish.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteCreateFinish.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteCreateStart.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteCreateStart.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteHyperVName.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteHyperVName.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteBitlocker.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteBitlocker.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteOEMActivation.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteOEMActivation.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteSetWiFi.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteSetWiFi.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Start-EjectCD.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Start-EjectCD.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Update-DefenderStack.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Update-DefenderStack.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Get-TimeZoneFromIP.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Get-TimeZoneFromIP.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-BitlockerRegValuesXTS256.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-BitlockerRegValuesXTS256.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteDefenderUpdate.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteDefenderUpdate.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteNetFX.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteNetFX.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteTimeZone.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteTimeZone.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-WindowsOEMActivation.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-WindowsOEMActivation.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Invoke-OSDAuditMode.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Invoke-OSDAuditMode.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-WiFi.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-WiFi.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Start-OSDDiskPart.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Start-OSDDiskPart.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/Public/OSDCloud.ps1" -OutFile "$ModulePath/Public/OSDCloud.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/OSD.psd1" -OutFile "$ModulePath/OSD.psd1"
    import-module "$ModulePath/OSD.psd1" -Force
    if ($WindowsPhase -eq 'WinPE') {
        if (Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\osd"){
            $ModulePath = (Get-ChildItem -Path "C:\Program Files\WindowsPowerShell\Modules\osd" | Where-Object {$_.Attributes -match "Directory"} | select -Last 1).fullname
            write-host "Updating Files in $ModulePath"
            if ($DevMode -eq $true){Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Invoke-OSDSpecializeDev.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Invoke-OSDSpecializeDev.ps1"}
            else{Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Invoke-OSDSpecialize.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Invoke-OSDSpecialize.ps1"}
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Get-Win11Readiness.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Get-Win11Readiness.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Get-HyperVName.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Get-HyperVName.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-HyperVName.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-HyperVName.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteCreateFinish.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteCreateFinish.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteCreateStart.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteCreateStart.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteHyperVName.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteHyperVName.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteBitlocker.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteBitlocker.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteOEMActivation.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteOEMActivation.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteSetWiFi.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteSetWiFi.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Start-EjectCD.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Start-EjectCD.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Update-DefenderStack.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Update-DefenderStack.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Get-TimeZoneFromIP.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Get-TimeZoneFromIP.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-BitlockerRegValuesXTS256.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-BitlockerRegValuesXTS256.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteDefenderUpdate.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteDefenderUpdate.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteNetFX.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteNetFX.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-SetupCompleteTimeZone.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-SetupCompleteTimeZone.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-WindowsOEMActivation.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-WindowsOEMActivation.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Invoke-OSDAuditMode.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Invoke-OSDAuditMode.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Set-WiFi.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Set-WiFi.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/OSD.psd1" -OutFile "$ModulePath/OSD.psd1"
        }
    }
    if (Test-HPIASupport -eq $true){Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')}
}
#endregion
#=================================================
#region Retired Functions
# The following Functions are planned to be removed in a future release
function osdcloud-InstallModuleAzAccounts {
    [CmdletBinding()]
    param ()
    $InstallModule = $false
    $PSModuleName = 'Az.Accounts'
    $InstalledModule = Get-Module -Name $PSModuleName -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore -WarningAction Ignore

    if ($GalleryPSModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            if ($WindowsPhase -eq 'WinPE') {
                Write-Host -ForegroundColor Yellow "[-] Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Install-Module $PSModuleName -Scope AllUsers -Force -SkipPublisherCheck
            }
            else {
                Write-Host -ForegroundColor Yellow "[-] Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
                Install-Module $PSModuleName -Scope CurrentUser -Force -SkipPublisherCheck
            }
        }
    }

    $InstalledModule = Get-Module -Name $PSModuleName -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
    if ($GalleryPSModule) {
        if (($InstalledModule.Version -as [version]) -ge ($GalleryPSModule.Version -as [version])) {
            Write-Host -ForegroundColor Green "[+] $PSModuleName $($GalleryPSModule.Version)"
        }
    }
}
function osdcloud-InstallModuleAzKeyVault {
    [CmdletBinding()]
    param ()
    $InstallModule = $false
    $PSModuleName = 'Az.KeyVault'
    $InstalledModule = Get-Module -Name $PSModuleName -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore -WarningAction Ignore

    if ($GalleryPSModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            if ($WindowsPhase -eq 'WinPE') {
                Write-Host -ForegroundColor Yellow "[-] Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Install-Module $PSModuleName -Scope AllUsers -Force -SkipPublisherCheck
            }
            else {
                Write-Host -ForegroundColor Yellow "[-] Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
                Install-Module $PSModuleName -Scope CurrentUser -Force -SkipPublisherCheck
            }
        }
    }

    $InstalledModule = Get-Module -Name $PSModuleName -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
    if ($GalleryPSModule) {
        if (($InstalledModule.Version -as [version]) -ge ($GalleryPSModule.Version -as [version])) {
            Write-Host -ForegroundColor Green "[+] $PSModuleName $($GalleryPSModule.Version)"
        }
    }
}
function osdcloud-InstallModuleAzResources {
    [CmdletBinding()]
    param ()
    $PSModuleName = 'Az.Resources'
    $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore

    if ($InstalledModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            if ($WindowsPhase -eq 'WinPE') {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Update-Module -Name $PSModuleName -Scope AllUsers -Force
                Import-Module $PSModuleName -Force
            }
            else {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
                Update-Module -Name $PSModuleName -Scope CurrentUser -Force
                Import-Module $PSModuleName -Force
            } 
        }
    }
    else {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers -SkipPublisherCheck
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser -SkipPublisherCheck
        }
    }
    Import-Module $PSModuleName -Force
}
function osdcloud-InstallModuleAzStorage {
    [CmdletBinding()]
    param ()
    $PSModuleName = 'Az.Storage'
    $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore

    if ($InstalledModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            if ($WindowsPhase -eq 'WinPE') {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Update-Module -Name $PSModuleName -Scope AllUsers -Force
                Import-Module $PSModuleName -Force
            }
            else {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
                Update-Module -Name $PSModuleName -Scope CurrentUser -Force
                Import-Module $PSModuleName -Force
            } 
        }
    }
    else {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers -SkipPublisherCheck
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser -SkipPublisherCheck
        }
    }
    Import-Module $PSModuleName -Force
}
function osdcloud-InstallModuleAzureAD {
    [CmdletBinding()]
    param ()
    $PSModuleName = 'AzureAD'
    $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore

    if ($InstalledModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            if ($WindowsPhase -eq 'WinPE') {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Update-Module -Name $PSModuleName -Scope AllUsers -Force
                Import-Module $PSModuleName -Force
            }
            else {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
                Update-Module -Name $PSModuleName -Scope CurrentUser -Force
                Import-Module $PSModuleName -Force
            } 
        }
    }
    else {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers -SkipPublisherCheck
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser -SkipPublisherCheck
        }
    }
    Import-Module $PSModuleName -Force
}
function osdcloud-InstallModuleMSGraphAuthentication {
    [CmdletBinding()]
    param ()
    $PSModuleName = 'Microsoft.Graph.Authentication'
    $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore

    if ($InstalledModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            if ($WindowsPhase -eq 'WinPE') {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Update-Module -Name $PSModuleName -Scope AllUsers -Force
                Import-Module $PSModuleName -Force
            }
            else {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
                Update-Module -Name $PSModuleName -Scope CurrentUser -Force
                Import-Module $PSModuleName -Force
            } 
        }
    }
    else {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers -SkipPublisherCheck
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser -SkipPublisherCheck
        }
    }
    Import-Module $PSModuleName -Force
}
function osdcloud-InstallModuleMSGraphDeviceManagement {
    [CmdletBinding()]
    param ()
    $PSModuleName = 'Microsoft.Graph.DeviceManagement'
    $InstalledModule = Get-InstalledModule $PSModuleName -ErrorAction Ignore | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore

    if ($InstalledModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            if ($WindowsPhase -eq 'WinPE') {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
                Update-Module -Name $PSModuleName -Scope AllUsers -Force
                Import-Module $PSModuleName -Force
            }
            else {
                Write-Host -ForegroundColor DarkGray "Update-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
                Update-Module -Name $PSModuleName -Scope CurrentUser -Force
                Import-Module $PSModuleName -Force
            } 
        }
    }
    else {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers -SkipPublisherCheck
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser -SkipPublisherCheck
        }
    }
    Import-Module $PSModuleName -Force
}
function osdcloud-InstallModuleOSD {
    [CmdletBinding()]
    param ()
    $PSModuleName = 'OSD'
    $InstalledModule = Get-Module -Name $PSModuleName -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore -WarningAction Ignore

    if ($GalleryPSModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            Write-Host -ForegroundColor Yellow "[-] Install-Module $PSModuleName $($GalleryPSModule.Version)"
            Install-Module $PSModuleName -Scope AllUsers -Force -SkipPublisherCheck
            Import-Module $PSModuleName -Force
        }
    }
    $InstalledModule = Get-Module -Name $PSModuleName -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
    if ($GalleryPSModule) {
        if (($InstalledModule.Version -as [version]) -ge ($GalleryPSModule.Version -as [version])) {
            Write-Host -ForegroundColor Green "[+] $PSModuleName $($GalleryPSModule.Version)"
        }
    }
}
#endregion