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
function osdcloud-InstallPackageManagement {
    [CmdletBinding()]
    param ()
    if ($WindowsPhase -eq 'WinPE') {
        $InstalledModule = Import-Module PackageManagement -PassThru -ErrorAction Ignore
        if (-not $InstalledModule) {
            Write-Host -ForegroundColor DarkGray 'Install PackageManagement'
            $PackageManagementURL = "https://psg-prod-eastus.azureedge.net/packages/packagemanagement.1.4.7.nupkg"
            Invoke-WebRequest -UseBasicParsing -Uri $PackageManagementURL -OutFile "$env:TEMP\packagemanagement.1.4.7.zip"
            $null = New-Item -Path "$env:TEMP\1.4.7" -ItemType Directory -Force
            Expand-Archive -Path "$env:TEMP\packagemanagement.1.4.7.zip" -DestinationPath "$env:TEMP\1.4.7"
            $null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement" -ItemType Directory -ErrorAction SilentlyContinue
            Move-Item -Path "$env:TEMP\1.4.7" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement\1.4.7"
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
function osdcloud-InstallModuleAutopilot {
    [CmdletBinding()]
    param ()
    $InstalledModule = Import-Module WindowsAutopilotIntune -PassThru -ErrorAction Ignore
    if (-not $InstalledModule) {
        Write-Host -ForegroundColor DarkGray 'Install-Module AzureAD,Microsoft.Graph.Intune,WindowsAutopilotIntune [CurrentUser]'
        Install-Module WindowsAutopilotIntune -Force -Scope CurrentUser
    }
}


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
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Start-EjectCD.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Start-EjectCD.ps1"
    Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Invoke-OSDAuditMode.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Invoke-OSDAuditMode.ps1"
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
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Start-EjectCD.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Start-EjectCD.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/$OSDCloudFunctionsPath/Invoke-OSDAuditMode.ps1" -OutFile "$ModulePath/$OSDCloudFunctionsPath/Invoke-OSDAuditMode.ps1"
            Invoke-WebRequest -UseBasicParsing -uri "$GitHubURI/OSD.psd1" -OutFile "$ModulePath/OSD.psd1"
        }
    }
    if (Test-HPIASupport -eq $true){Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')}
}


function osdcloud-InstallModuleAzAccounts {
    [CmdletBinding()]
    param ()
    $PSModuleName = 'Az.Accounts'
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
            Install-Module $PSModuleName -Scope AllUsers
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser
        }
    }
    Import-Module $PSModuleName -Force
}
function osdcloud-InstallModuleAzKeyVault {
    [CmdletBinding()]
    param ()
    $PSModuleName = 'Az.KeyVault'
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
            Install-Module $PSModuleName -Scope AllUsers
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser
        }
    }
    Import-Module $PSModuleName -Force
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
            Install-Module $PSModuleName -Scope AllUsers
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser
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
            Install-Module $PSModuleName -Scope AllUsers
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser
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
            Install-Module $PSModuleName -Scope AllUsers
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser
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
            Install-Module $PSModuleName -Scope AllUsers
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser
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
            Install-Module $PSModuleName -Scope AllUsers
        }
        else {
            Write-Host -ForegroundColor DarkGray "Install-Module $PSModuleName $($GalleryPSModule.Version) [CurrentUser]"
            Install-Module $PSModuleName -Scope CurrentUser
        }
    }
    Import-Module $PSModuleName -Force
}
function osdcloud-InstallModuleOSD {
    [CmdletBinding()]
    param ()
    $InstallModule = $false
    $PSModuleName = 'OSD'
    $InstalledModule = Get-Module -Name $PSModuleName -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
    $GalleryPSModule = Find-Module -Name $PSModuleName -ErrorAction Ignore -WarningAction Ignore

    if ($GalleryPSModule) {
        if (($GalleryPSModule.Version -as [version]) -gt ($InstalledModule.Version -as [version])) {
            Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $PSModuleName $($GalleryPSModule.Version) [AllUsers]"
            Install-Module $PSModuleName -Scope AllUsers -Force
            Import-Module $PSModuleName -Force
        }
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
function osdcloud-SetExecutionPolicy {
    [CmdletBinding()]
    param ()
    if ($WindowsPhase -eq 'WinPE') {
        if ((Get-ExecutionPolicy) -ne 'Bypass') {
            Write-Host -ForegroundColor DarkGray 'Set-ExecutionPolicy Bypass'
            Set-ExecutionPolicy Bypass -Force
        }
    }
    else {
        if ((Get-ExecutionPolicy -Scope CurrentUser) -ne 'RemoteSigned') {
            Write-Host -ForegroundColor DarkGray 'Set-ExecutionPolicy RemoteSigned [CurrentUser]'
            Set-ExecutionPolicy RemoteSigned -Force -Scope CurrentUser
        }
    }
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
