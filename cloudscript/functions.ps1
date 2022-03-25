<#PSScriptInfo
.VERSION 22.3.23.1
.GUID 302752c7-8567-45db-91ba-55c40fb9caee
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
powershell iex(irm functions.osdcloud.com)
#>
<#
.SYNOPSIS
    PSCloudScript at functions.osdcloud.com
.DESCRIPTION
    PSCloudScript at functions.osdcloud.com
.NOTES
    Version 22.3.23.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloudscript/functions.ps1
.EXAMPLE
    powershell iex(irm functions.osdcloud.com)
#>
#----------------------------------------------------------[Initialize]----------------------------------------------------------
Write-Host -ForegroundColor DarkGray "functions.osdcloud.com 22.3.23.1"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#----------------------------------------------------------[Declarations]--------------------------------------------------------
$oobePowerShellProfile = @'
[System.Environment]::SetEnvironmentVariable('Path',$Env:Path + ";$Env:ProgramFiles\WindowsPowerShell\Scripts",'Process')
'@
$winpePowerShellProfile = @'
[System.Environment]::SetEnvironmentVariable('APPDATA',"$Env:UserProfile\AppData\Roaming",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('HOMEDRIVE',"$Env:SystemDrive",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('HOMEPATH',"$Env:UserProfile",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$Env:UserProfile\AppData\Local",[System.EnvironmentVariableTarget]::Process)
'@
#----------------------------------------------------------[Prompt]--------------------------------------------------------------
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
#----------------------------------------------------------[OOBE Functions]------------------------------------------------------
<#
OOBE Functions are only exposed in OOBE
#>
if ($env:UserName -eq 'defaultuser0') {
    function Step-oobeSetDisplay {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            Write-Host -ForegroundColor Yellow 'Verify the Display Resolution and Scale is set properly'
            Start-Process 'ms-settings:display' | Out-Null
            $ProcessId = (Get-Process -Name 'SystemSettings').Id
            if ($ProcessId) {
                Wait-Process $ProcessId
            }
        }
    }
    function Step-oobeSetLanguage {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            Write-Host -ForegroundColor Yellow 'Verify the Language, Region, and Keyboard are set properly'
            Start-Process 'ms-settings:regionlanguage' | Out-Null
            $ProcessId = (Get-Process -Name 'SystemSettings').Id
            if ($ProcessId) {
                Wait-Process $ProcessId
            }
        }
    }
    function Step-oobeSetDateTime {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            Write-Host -ForegroundColor Yellow 'Verify the Date and Time is set properly including the Time Zone'
            Write-Host -ForegroundColor Yellow 'If this is not configured properly, Certificates and Domain Join may fail'
            Start-Process 'ms-settings:dateandtime' | Out-Null
            $ProcessId = (Get-Process -Name 'SystemSettings').Id
            if ($ProcessId) {
                Wait-Process $ProcessId
            }
        }
    }
    function Step-oobeExecutionPolicy {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            if ((Get-ExecutionPolicy -Scope CurrentUser) -ne 'RemoteSigned') {
                Write-Host -ForegroundColor DarkGray 'Set-ExecutionPolicy RemoteSigned [CurrentUser]'
                Set-ExecutionPolicy RemoteSigned -Force -Scope CurrentUser
            }
        }
    }
    function Step-oobePowerShellProfile {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
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
    function Step-oobePackageManagement {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            if (-not (Get-Module -Name PowerShellGet -ListAvailable | Where-Object {$_.Version -ge '2.2.5'})) {
                Write-Host -ForegroundColor DarkGray 'Install-Package PackageManagement,PowerShellGet [AllUsers]'
                Install-Package -Name PowerShellGet -MinimumVersion 2.2.5 -Force -Confirm:$false -Source PSGallery | Out-Null
        
                Write-Host -ForegroundColor DarkGray 'Import-Module PackageManagement,PowerShellGet [Global]'
                Import-Module PackageManagement,PowerShellGet -Force -Scope Global
            }
        }
    }
    function Step-oobeTrustPSGallery {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            $PSRepository = Get-PSRepository -Name PSGallery
            if ($PSRepository) {
                if ($PSRepository.InstallationPolicy -ne 'Trusted') {
                    Write-Host -ForegroundColor DarkGray 'Set-PSRepository PSGallery Trusted [CurrentUser]'
                    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
                }
            }
        }
    }
    function Step-oobeInstallModuleAutopilot {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            $InstalledModule = Import-Module WindowsAutopilotIntune -PassThru -ErrorAction Ignore
            if (-not $InstalledModule) {
                Write-Host -ForegroundColor DarkGray 'Install-Module AzureAD,Microsoft.Graph.Intune,WindowsAutopilotIntune [CurrentUser]'
                Install-Module WindowsAutopilotIntune -Force -Scope CurrentUser
            }
        }
    }
    function Step-oobeInstallModuleAzureAd {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            $InstalledModule = Import-Module AzureAD -PassThru -ErrorAction Ignore
            if (-not $InstalledModule) {
                Write-Host -ForegroundColor DarkGray 'Install-Module AzureAD [CurrentUser]'
                Install-Module AzureAD -Force -Scope CurrentUser
            }
        }
    }
    function Step-oobeInstallScriptAutopilot {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            $InstalledScript = Get-InstalledScript -Name Get-WindowsAutoPilotInfo -ErrorAction SilentlyContinue
            if (-not $InstalledScript) {
                Write-Host -ForegroundColor DarkGray 'Install-Script Get-WindowsAutoPilotInfo [AllUsers]'
                Install-Script -Name Get-WindowsAutoPilotInfo -Force -Scope AllUsers
            }
        }
    }
    function Step-oobeInstallModuleKeyVault {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            $InstalledModule = Import-Module Az.KeyVault -PassThru -ErrorAction Ignore
            if (-not $InstalledModule) {
                Write-Host -ForegroundColor DarkGray 'Install-Module Az.KeyVault,Az.Accounts [CurrentUser]'
                Install-Module Az.KeyVault -Force -Scope CurrentUser
            }
        }
    }
    function Step-oobeRegisterAutopilot {
        [CmdletBinding()]
        param (
            [System.String]
            $Command = 'Get-WindowsAutopilotInfo -Online -GroupTag Enterprise -Assign'
        )
        if ($env:UserName -eq 'defaultuser0') {
            Write-Host -ForegroundColor Cyan 'Registering Device in Autopilot in new PowerShell window ' -NoNewline
            $AutopilotProcess = Start-Process PowerShell.exe -ArgumentList "-Command $Command" -PassThru
            Write-Host -ForegroundColor Green "(Process Id $($AutopilotProcess.Id))"
            Return $AutopilotProcess
        }
    }
    function Step-oobeRemoveAppxPackage {
        [CmdletBinding()]
        param (
            [System.String[]]
            $Name
        )
        if ($env:UserName -eq 'defaultuser0') {
            Write-Host -ForegroundColor Cyan 'Removing Appx Packages'
            foreach ($Item in $Name) {
                if (Get-Command Get-AppxProvisionedPackage) {
                    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -Match $Item} | ForEach-Object {
                        Write-Host -ForegroundColor DarkGray $_.DisplayName
                        if ((Get-Command Remove-AppxProvisionedPackage).Parameters.ContainsKey('AllUsers')) {
                            try {
                                $null = Remove-AppxProvisionedPackage -Online -AllUsers -PackageName $_.PackageName
                            }
                            catch {
                                Write-Warning "AllUsers Appx Provisioned Package $($_.PackageName) did not remove successfully"
                            }
                        }
                        else {
                            try {
                                $null = Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName
                            }
                            catch {
                                Write-Warning "Appx Provisioned Package $($_.PackageName) did not remove successfully"
                            }
                        }
                    }
                }
            }
        }
    }
    function Step-oobeAddCapability {
        [CmdletBinding()]
        param (
            [System.String[]]
            $Name
        )
        if ($env:UserName -eq 'defaultuser0') {
            if ($Name) {Write-Host -ForegroundColor Cyan "Add-WindowsCapability"}
            foreach ($Item in $Name) {
                $WindowsCapability = Get-WindowsCapability -Online -Name "*$Item*" -ErrorAction SilentlyContinue | Where-Object {$_.State -ne 'Installed'}
                if ($WindowsCapability) {
                    foreach ($Capability in $WindowsCapability) {
                        Write-Host -ForegroundColor DarkGray $Capability.DisplayName
                        $Capability | Add-WindowsCapability -Online | Out-Null
                    }
                }
            }
        }
    }
    function Step-oobeUpdateDrivers {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            Write-Host -ForegroundColor Cyan 'Updating Windows Drivers in minimized window'
            if (!(Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore)) {
                try {
                    Install-Module PSWindowsUpdate -Force -Scope CurrentUser
                    Import-Module PSWindowsUpdate -Force -Scope Global
                }
                catch {
                    Write-Warning 'Unable to install PSWindowsUpdate Driver Updates'
                }
            }
            if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore) {
                Start-Process -WindowStyle Minimized PowerShell.exe -ArgumentList "-Command Install-WindowsUpdate -UpdateType Driver -AcceptAll -IgnoreReboot" -Wait
            }
        }
    }
    function Step-oobeUpdateWindows {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            Write-Host -ForegroundColor Cyan 'Updating Windows in minimized window'
            if (!(Get-Module PSWindowsUpdate -ListAvailable)) {
                try {
                    Install-Module PSWindowsUpdate -Force -Scope CurrentUser
                    Import-Module PSWindowsUpdate -Force -Scope Global
                }
                catch {
                    Write-Warning 'Unable to install PSWindowsUpdate Windows Updates'
                }
            }
            if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore) {
                #Write-Host -ForegroundColor DarkCyan 'Add-WUServiceManager -MicrosoftUpdate -Confirm:$false'
                Add-WUServiceManager -MicrosoftUpdate -Confirm:$false | Out-Null
                #Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot'
                #Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot -NotTitle 'Malicious'
                #Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot'
                Start-Process -WindowStyle Minimized PowerShell.exe -ArgumentList "-Command Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -NotTitle 'Preview' -NotKBArticleID 'KB890830','KB5005463','KB4481252'" -Wait
            }
        }
    }
    function Step-oobeRestartComputer {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            Write-Host -ForegroundColor Green 'Complete!'
            Write-Warning 'Device will restart in 30 seconds.  Press Ctrl + C to cancel'
            Stop-Transcript
            Start-Sleep -Seconds 30
            Restart-Computer
        }
    }
    function Step-oobeStopComputer {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            Write-Host -ForegroundColor Green 'Complete!'
            Write-Warning 'Device will shutdown in 30 seconds.  Press Ctrl + C to cancel'
            Stop-Transcript
            Start-Sleep -Seconds 30
            Stop-Computer
        }
    }
}
#----------------------------------------------------------[WinPE Functions]-----------------------------------------------------
<#
WinPE Functions are only exposed in WinPE
#>
if ($env:SystemDrive -eq 'X:') {
    function Step-winpeExecutionPolicy {
        [CmdletBinding()]
        param ()
        if ($env:SystemDrive -eq 'X:') {
            if ((Get-ExecutionPolicy) -ne 'Bypass') {
                Write-Host -ForegroundColor DarkGray 'Set-ExecutionPolicy Bypass'
                Set-ExecutionPolicy Bypass -Force
            }
        }
    }
    function Step-winpeEnvironment {
        [CmdletBinding()]
        param ()
        if ($env:SystemDrive -eq 'X:') {
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
    }
    function Step-winpePowerShellProfile {
        [CmdletBinding()]
        param ()
        if ($env:SystemDrive -eq 'X:') {
            if (-not (Test-Path "$env:UserProfile\Documents\WindowsPowerShell")) {
                $null = New-Item -Path "$env:UserProfile\Documents\WindowsPowerShell" -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            }
            Write-Host -ForegroundColor DarkGray 'Set LocalAppData in PowerShell Profile'
            $winpePowerShellProfile | Set-Content -Path "$env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force -Encoding Unicode
        }
    }
    function Step-winpeInstallNuget {
        [CmdletBinding()]
        param ()
        if ($env:SystemDrive -eq 'X:') {
            Write-Host -ForegroundColor DarkGray 'Install Nuget'
            $NuGetClientSourceURL = 'https://nuget.org/nuget.exe'
            $NuGetExeName = 'NuGet.exe'
        
            $PSGetProgramDataPath = Join-Path -Path $env:ProgramData -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
            $nugetExeBasePath = $PSGetProgramDataPath
            if (-not (Test-Path -Path $nugetExeBasePath))
            {
                $null = New-Item -Path $nugetExeBasePath -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            }
            $nugetExeFilePath = Join-Path -Path $nugetExeBasePath -ChildPath $NuGetExeName
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $null = Invoke-WebRequest -UseBasicParsing -Uri $NuGetClientSourceURL -OutFile $nugetExeFilePath
        
            $PSGetAppLocalPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
            $nugetExeBasePath = $PSGetAppLocalPath
        
            if (-not (Test-Path -Path $nugetExeBasePath))
            {
                $null = New-Item -Path $nugetExeBasePath -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            }
            $nugetExeFilePath = Join-Path -Path $nugetExeBasePath -ChildPath $NuGetExeName
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $null = Invoke-WebRequest -UseBasicParsing -Uri $NuGetClientSourceURL -OutFile $nugetExeFilePath
        }
    }
    function Step-winpeInstallPackageManagement {
        [CmdletBinding()]
        param ()
        if ($env:SystemDrive -eq 'X:') {
            $InstalledModule = Import-Module PackageManagement -PassThru -ErrorAction Ignore
            if (-not $InstalledModule) {
                Write-Host -ForegroundColor DarkGray 'Install PackageManagement'
                $PackageManagementURL = "https://psg-prod-eastus.azureedge.net/packages/packagemanagement.1.4.7.nupkg"
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Invoke-WebRequest -UseBasicParsing -Uri $PackageManagementURL -OutFile "$env:TEMP\packagemanagement.1.4.7.zip"
                $null = New-Item -Path "$env:TEMP\1.4.7" -ItemType Directory -Force
                Expand-Archive -Path "$env:TEMP\packagemanagement.1.4.7.zip" -DestinationPath "$env:TEMP\1.4.7"
                $null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement" -ItemType Directory -ErrorAction SilentlyContinue
                Move-Item -Path "$env:TEMP\1.4.7" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement\1.4.7"
                Import-Module PackageManagement -Force -Scope Global
            }
        }
    }
    function Step-winpeInstallPowerShellGet {
        [CmdletBinding()]
        param ()
        if ($env:SystemDrive -eq 'X:') {
            $InstalledModule = Import-Module PowerShellGet -PassThru -ErrorAction Ignore
            if (-not $InstalledModule) {
                Write-Host -ForegroundColor DarkGray 'Install PowerShellGet'
                $PowerShellGetURL = "https://psg-prod-eastus.azureedge.net/packages/powershellget.2.2.5.nupkg"
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Invoke-WebRequest -UseBasicParsing -Uri $PowerShellGetURL -OutFile "$env:TEMP\powershellget.2.2.5.zip"
                $null = New-Item -Path "$env:TEMP\2.2.5" -ItemType Directory -Force
                Expand-Archive -Path "$env:TEMP\powershellget.2.2.5.zip" -DestinationPath "$env:TEMP\2.2.5"
                $null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet" -ItemType Directory -ErrorAction SilentlyContinue
                Move-Item -Path "$env:TEMP\2.2.5" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet\2.2.5"
                Import-Module PowerShellGet -Force -Scope Global
            }
        }
    }
    function Step-winpeTrustPSGallery {
        [CmdletBinding()]
        param ()
        if ($env:SystemDrive -eq 'X:') {
            $PSRepository = Get-PSRepository -Name PSGallery
            if ($PSRepository) {
                if ($PSRepository.InstallationPolicy -ne 'Trusted') {
                    Write-Host -ForegroundColor DarkGray 'Set-PSRepository PSGallery Trusted'
                    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
                }
            }
        }
    }
    function Step-winpeInstallCurl {
        [CmdletBinding()]
        param ()
        if ($env:SystemDrive -eq 'X:') {
            if (-not (Get-Command 'curl.exe' -ErrorAction SilentlyContinue)) {
                Write-Host -ForegroundColor DarkGray 'Install Curl'
                $Uri = 'https://curl.se/windows/dl-7.81.0/curl-7.81.0-win64-mingw.zip'
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile "$env:TEMP\curl.zip"
        
                $null = New-Item -Path "$env:TEMP\Curl" -ItemType Directory -Force
                Expand-Archive -Path "$env:TEMP\curl.zip" -DestinationPath "$env:TEMP\curl"
        
                Get-ChildItem "$env:TEMP\curl" -Include 'curl.exe' -Recurse | foreach {Copy-Item $_ -Destination "$env:SystemRoot\System32\curl.exe"}
            }
        }
    }
    function Step-winpeInstallModuleOSD {
        [CmdletBinding()]
        param ()
        if ($env:SystemDrive -eq 'X:') {
            Write-Host -ForegroundColor DarkGray 'Install-Module OSD'
            Install-Module OSD -Force
        }
    }
}
#----------------------------------------------------------[Universal Functions]-------------------------------------------------
<#
Universal Functions are exposed in WinPE or OOBE
#>
if (($env:UserName -eq 'defaultuser0') -or ($env:SystemDrive -eq 'X:')) {
    function KeyVault {
        [CmdletBinding()]
        param ()
        $InstalledModule = Import-Module Az.KeyVault -PassThru -ErrorAction Ignore
        if (-not $InstalledModule) {
            if ($env:SystemDrive -eq 'X:') {
                Write-Host -ForegroundColor DarkGray 'Install-Module Az.KeyVault,Az.Accounts [AllUsers]'
                Install-Module Az.KeyVault -Force -Scope AllUsers
            }
            else {
                Write-Host -ForegroundColor DarkGray 'Install-Module Az.KeyVault,Az.Accounts [CurrentUser]'
                Install-Module Az.KeyVault -Force -Scope CurrentUser
            }
        }
    }
    function TestAutopilot {
        [CmdletBinding()]
        param ()

        $Global:RegAutopilot = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics\Autopilot'

        #Oter Keys
        #Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\AutopilotPolicyCache'
        #Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics\Autopilot\EstablishedCorrelations'
        
        if ($Global:RegAutoPilot.CloudAssignedForcedEnrollment -eq 1) {
            Write-Host -ForegroundColor Cyan "This device has an Autopilot Profile"
            Write-Host -ForegroundColor DarkGray "  TenantDomain: $($Global:RegAutoPilot.CloudAssignedTenantDomain)"
            Write-Host -ForegroundColor DarkGray "  TenantId: $($Global:RegAutoPilot.TenantId)"
            Write-Host -ForegroundColor DarkGray "  CloudAssignedLanguage: $($Global:RegAutoPilot.CloudAssignedLanguage)"
            Write-Host -ForegroundColor DarkGray "  CloudAssignedMdmId: $($Global:RegAutoPilot.CloudAssignedMdmId)"
            Write-Host -ForegroundColor DarkGray "  CloudAssignedOobeConfig: $($Global:RegAutoPilot.CloudAssignedOobeConfig)"
            Write-Host -ForegroundColor DarkGray "  CloudAssignedRegion: $($Global:RegAutoPilot.CloudAssignedRegion)"
            Write-Host -ForegroundColor DarkGray "  CloudAssignedTelemetryLevel: $($Global:RegAutoPilot.CloudAssignedTelemetryLevel)"
            Write-Host -ForegroundColor DarkGray "  AutopilotServiceCorrelationId: $($Global:RegAutoPilot.AutopilotServiceCorrelationId)"
            Write-Host -ForegroundColor DarkGray "  IsAutoPilotDisabled: $($Global:RegAutoPilot.IsAutoPilotDisabled)"
            Write-Host -ForegroundColor DarkGray "  IsDevicePersonalized: $($Global:RegAutoPilot.IsDevicePersonalized)"
            Write-Host -ForegroundColor DarkGray "  IsForcedEnrollmentEnabled: $($Global:RegAutoPilot.IsForcedEnrollmentEnabled)"
            Write-Host -ForegroundColor DarkGray "  SetTelemetryLevel_Succeeded_With_Level: $($Global:RegAutoPilot.SetTelemetryLevel_Succeeded_With_Level)"
        }
        else {
            Write-Warning 'Could not find an Autopilot Profile on this device.  If this device is registered, restart the device while connected to the internet'
        }
    }
}
#----------------------------------------------------------[OOBE User Functions]-------------------------------------------------
if ($env:UserName -eq 'defaultuser0') {
    function AddCapability {
        [CmdletBinding(DefaultParameterSetName='Default')]
        param (
            [Parameter(Mandatory,ParameterSetName='ByName',Position=0)]
            [System.String[]]$Name
        )
        if ($env:UserName -eq 'defaultuser0') {
            if ($Name) {
                #Do Nothing
            }
            else {
                $Name = Get-WindowsCapability -Online -ErrorAction SilentlyContinue | Where-Object {$_.State -ne 'Installed'} | Select-Object Name | Out-GridView -PassThru -Title 'Select one or more Capabilities' | Select-Object -ExpandProperty Name
            }
            if ($Name) {
                Write-Host -ForegroundColor Cyan "Add-WindowsCapability -Online"
                foreach ($Item in $Name) {
                    $WindowsCapability = Get-WindowsCapability -Online -Name "*$Item*" -ErrorAction SilentlyContinue | Where-Object {$_.State -ne 'Installed'}
                    if ($WindowsCapability) {
                        foreach ($Capability in $WindowsCapability) {
                            Write-Host -ForegroundColor DarkGray $Capability.DisplayName
                            $Capability | Add-WindowsCapability -Online | Out-Null
                        }
                    }
                }
            }
        }
    }
    function NetFX {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            $WindowsCapability = Get-WindowsCapability -Online -Name "*NetFX*" -ErrorAction SilentlyContinue | Where-Object {$_.State -ne 'Installed'}
            if ($WindowsCapability) {
                Write-Host -ForegroundColor Cyan "Add-WindowsCapability NetFX"
                foreach ($Capability in $WindowsCapability) {
                    Write-Host -ForegroundColor DarkGray $Capability.DisplayName
                    $Capability | Add-WindowsCapability -Online | Out-Null
                }
            }
        }
    }
    function Rsat {
        [CmdletBinding(DefaultParameterSetName='Default')]
        param (
            [Parameter(Mandatory,ParameterSetName='Basic')]
            [Switch]$Basic,
    
            [Parameter(Mandatory,ParameterSetName='Full')]
            [Switch]$Full,
    
            [Parameter(Mandatory,ParameterSetName='ByName',Position=0)]
            [System.String[]]$Name
        )
        if ($env:UserName -eq 'defaultuser0') {
            if ($Basic) {
                $Name = @('ActiveDirectory','BitLocker','GroupPolicy','RemoteDesktop','VolumeActivation')
            }
            elseif ($Full) {
                $Name = 'Rsat'
            }
            elseif ($Name) {
                #Do Nothing
            }
            else {
                $Name = Get-WindowsCapability -Online -Name "*Rsat*" -ErrorAction SilentlyContinue | `
                Where-Object {$_.State -ne 'Installed'} | `
                Select-Object Name, DisplayName, Description | `
                Out-GridView -PassThru -Title 'Select one or more Rsat Capabilities to install' | `
                Select-Object -ExpandProperty Name
            }
            if ($Name) {
                Write-Host -ForegroundColor Cyan "Add-WindowsCapability -Online Rsat"
                foreach ($Item in $Name) {
                    $WindowsCapability = Get-WindowsCapability -Online -Name "*$Item*" -ErrorAction SilentlyContinue | Where-Object {$_.State -ne 'Installed'}
                    if ($WindowsCapability) {
                        foreach ($Capability in $WindowsCapability) {
                            Write-Host -ForegroundColor DarkGray $Capability.DisplayName
                            $Capability | Add-WindowsCapability -Online | Out-Null
                        }
                    }
                }
            }
        }
    }
    function RemoveAppx {
        [CmdletBinding(DefaultParameterSetName='Default')]
        param (
            [Parameter(Mandatory,ParameterSetName='Basic')]
            [Switch]$Basic,
    
            [Parameter(Mandatory,ParameterSetName='ByName',Position=0)]
            [System.String[]]$Name
        )
        if ($env:UserName -eq 'defaultuser0') {
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
                                Try
                                {
                                    $null = Remove-AppxProvisionedPackage -Online -AllUsers -PackageName $_.PackageName
                                }
                                Catch
                                {
                                    Write-Warning "AllUsers Appx Provisioned Package $($_.PackageName) did not remove successfully"
                                }
                            }
                            else {
                                Try
                                {
                                    $null = Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName
                                }
                                Catch
                                {
                                    Write-Warning "Appx Provisioned Package $($_.PackageName) did not remove successfully"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    function UpdateDrivers {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            Write-Host -ForegroundColor Cyan 'Updating Windows Drivers in a minimized window'
            if (!(Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore)) {
                try {
                    Install-Module PSWindowsUpdate -Force -Scope CurrentUser
                    Import-Module PSWindowsUpdate -Force -Scope Global
                }
                catch {
                    Write-Warning 'Unable to install PSWindowsUpdate Driver Updates'
                }
            }
            if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore) {
                Start-Process -WindowStyle Minimized PowerShell.exe -ArgumentList "-Command Install-WindowsUpdate -UpdateType Driver -AcceptAll -IgnoreReboot" -Wait
            }
        }
    }
    function UpdateWindows {
        [CmdletBinding()]
        param ()
        if ($env:UserName -eq 'defaultuser0') {
            Write-Host -ForegroundColor Cyan 'Updating Windows in a minimized window'
            if (!(Get-Module PSWindowsUpdate -ListAvailable)) {
                try {
                    Install-Module PSWindowsUpdate -Force -Scope CurrentUser
                    Import-Module PSWindowsUpdate -Force -Scope Global
                }
                catch {
                    Write-Warning 'Unable to install PSWindowsUpdate Windows Updates'
                }
            }
            if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore) {
                #Write-Host -ForegroundColor DarkCyan 'Add-WUServiceManager -MicrosoftUpdate -Confirm:$false'
                Add-WUServiceManager -MicrosoftUpdate -Confirm:$false | Out-Null
                #Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot'
                #Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot -NotTitle 'Malicious'
                #Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot'
                Start-Process -WindowStyle Minimized PowerShell.exe -ArgumentList "-Command Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -NotTitle 'Preview' -NotKBArticleID 'KB890830','KB5005463','KB4481252'" -Wait
            }
        }
    }
}
#----------------------------------------------------------[WinPE User Functions]------------------------------------------------
#----------------------------------------------------------[User Functions]------------------------------------------------------
#----------------------------------------------------------[Update]--------------------------------------------------------------
#----------------------------------------------------------[Start Functions]-----------------------------------------------------
if ($env:SystemDrive -eq 'X:') {
    function Start-WinPE {
        [CmdletBinding()]
        param (
            [Parameter()]
            [Switch]$KeyVault,
            [Parameter()]
            [Switch]$OSDCloud
        )
        if ($env:SystemDrive -eq 'X:') {
            Step-winpeExecutionPolicy
            Step-winpeEnvironment
            Step-winpePowerShellProfile
            #Step-winpeInstallNuget
            Step-winpeInstallPackageManagement
            Step-winpeInstallPowerShellGet
            Step-winpeTrustPSGallery
            if ($OSDCloud) {
                Step-winpeInstallCurl
                Step-winpeInstallModuleOSD
                if (-not (Get-Command 'curl.exe' -ErrorAction SilentlyContinue)) {
                    Write-Warning 'curl.exe is missing from WinPE. This is required for OSDCloud to function'
                    Start-Sleep -Seconds 5
                    Break
                }
            }
            if ($KeyVault) {
                KeyVault
            }
        }
    }
}

if ($env:UserName -eq 'defaultuser0') {
    function Start-OOBE {
        [CmdletBinding()]
        param (
            [Parameter()]
            [Switch]$Autopilot,
            [Parameter()]
            [Switch]$Display,
            [Parameter()]
            [Switch]$Language,
            [Parameter()]
            [Switch]$DateTime,
            [Parameter()]
            [Switch]$KeyVault
        )
        if ($env:UserName -eq 'defaultuser0') {
            if ($Display) {
                Step-oobeSetDisplay
            }
            if ($Language) {
                Step-oobeSetLanguage
            }
            if ($DateTime) {
                Step-oobeSetDateTime
            }
            Step-oobeExecutionPolicy
            Step-oobePowerShellProfile
            Step-oobePackageManagement
            Step-oobeTrustPSGallery
            if ($Autopilot) {
                Step-oobeInstallModuleAutopilot
                Step-oobeInstallModuleAzureAd
                Step-oobeInstallScriptAutopilot
                $Global:RegAutopilotPolicyCache = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\AutopilotPolicyCache'
                $Global:RegAutopilot = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics\Autopilot'
                $Global:RegEstablishedCorrelations = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics\Autopilot\EstablishedCorrelations'
                
                if ($Global:RegAutoPilot.CloudAssignedForcedEnrollment -eq 1) {
                    Write-Host -ForegroundColor Cyan "This device has an Autopilot Profile"
                    Write-Host -ForegroundColor DarkGray "  TenantDomain: $($Global:RegAutoPilot.CloudAssignedTenantDomain)"
                    Write-Host -ForegroundColor DarkGray "  TenantId: $($Global:RegAutoPilot.TenantId)"
                    Write-Host -ForegroundColor DarkGray "  CloudAssignedLanguage: $($Global:RegAutoPilot.CloudAssignedLanguage)"
                    Write-Host -ForegroundColor DarkGray "  CloudAssignedMdmId: $($Global:RegAutoPilot.CloudAssignedMdmId)"
                    Write-Host -ForegroundColor DarkGray "  CloudAssignedOobeConfig: $($Global:RegAutoPilot.CloudAssignedOobeConfig)"
                    Write-Host -ForegroundColor DarkGray "  CloudAssignedRegion: $($Global:RegAutoPilot.CloudAssignedRegion)"
                    Write-Host -ForegroundColor DarkGray "  CloudAssignedTelemetryLevel: $($Global:RegAutoPilot.CloudAssignedTelemetryLevel)"
                    Write-Host -ForegroundColor DarkGray "  AutopilotServiceCorrelationId: $($Global:RegAutoPilot.AutopilotServiceCorrelationId)"
                    Write-Host -ForegroundColor DarkGray "  IsAutoPilotDisabled: $($Global:RegAutoPilot.IsAutoPilotDisabled)"
                    Write-Host -ForegroundColor DarkGray "  IsDevicePersonalized: $($Global:RegAutoPilot.IsDevicePersonalized)"
                    Write-Host -ForegroundColor DarkGray "  IsForcedEnrollmentEnabled: $($Global:RegAutoPilot.IsForcedEnrollmentEnabled)"
                    Write-Host -ForegroundColor DarkGray "  SetTelemetryLevel_Succeeded_With_Level: $($Global:RegAutoPilot.SetTelemetryLevel_Succeeded_With_Level)"
                }
            }
            if ($KeyVault) {
                KeyVault
            }
        }
    }
}
#----------------------------------------------------------[End]-----------------------------------------------------------------
#----------------------------------------------------------[End]-----------------------------------------------------------------