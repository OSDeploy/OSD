<#PSScriptInfo
.VERSION 22.5.3.1
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
    Version 22.5.3.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloudscript/functions.osdcloud.com.ps1
.EXAMPLE
    powershell iex (irm functions.osdcloud.com)
#>
#=================================================
#Script Information
$ScriptName = 'functions.osdcloud.com'
$ScriptVersion = '22.5.8.4'
#=================================================
#region Initialize Functions
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

#Determine the proper Windows environment
if ($env:SystemDrive -eq 'X:') {$WindowsPhase = 'WinPE'}
else {
    $ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
    if ($env:UserName -eq 'defaultuser0') {$WindowsPhase = 'OOBE'}
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') {$WindowsPhase = 'Specialize'}
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_AUDIT') {$WindowsPhase = 'AuditMode'}
    else {$WindowsPhase = 'Windows'}
}

#Finish Initialization
Write-Host -ForegroundColor DarkGray "$ScriptName $ScriptVersion $WindowsPhase"

#endregion
#=================================================
#region Environment Variables
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
#=================================================
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
#=================================================
#region WinPE Functions
if ($WindowsPhase -eq 'WinPE') {
    function osdcloud-InstallCurl {
        [CmdletBinding()]
        param ()
        if (-not (Get-Command 'curl.exe' -ErrorAction SilentlyContinue)) {
            Write-Host -ForegroundColor DarkGray 'Install Curl'
            $Uri = 'https://curl.se/windows/dl-7.81.0/curl-7.81.0-win64-mingw.zip'
            Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile "$env:TEMP\curl.zip"
    
            $null = New-Item -Path "$env:TEMP\Curl" -ItemType Directory -Force
            Expand-Archive -Path "$env:TEMP\curl.zip" -DestinationPath "$env:TEMP\curl"
    
            Get-ChildItem "$env:TEMP\curl" -Include 'curl.exe' -Recurse | foreach {Copy-Item $_ -Destination "$env:SystemRoot\System32\curl.exe"}
        }
    }
    function osdcloud-InstallNuget {
        [CmdletBinding()]
        param ()
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
        $null = Invoke-WebRequest -UseBasicParsing -Uri $NuGetClientSourceURL -OutFile $nugetExeFilePath
    
        $PSGetAppLocalPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
        $nugetExeBasePath = $PSGetAppLocalPath
    
        if (-not (Test-Path -Path $nugetExeBasePath))
        {
            $null = New-Item -Path $nugetExeBasePath -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
        $nugetExeFilePath = Join-Path -Path $nugetExeBasePath -ChildPath $NuGetExeName
        $null = Invoke-WebRequest -UseBasicParsing -Uri $NuGetClientSourceURL -OutFile $nugetExeFilePath
    }
    function osdcloud-InstallPowerShellGet {
        [CmdletBinding()]
        param ()
        $InstalledModule = Import-Module PowerShellGet -PassThru -ErrorAction Ignore
        if (-not $InstalledModule) {
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
    function osdcloud-SetEnvironmentVariables {
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
}
#endregion
#=================================================
#region WinPE OOBE Functions
if (($WindowsPhase -eq 'WinPE') -or ($WindowsPhase -eq 'OOBE')) {
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
    function osdcloud-TrustPSGallery {
        [CmdletBinding()]
        param ()
        if ($WindowsPhase -eq 'WinPE') {
            $PSRepository = Get-PSRepository -Name PSGallery
            if ($PSRepository) {
                if ($PSRepository.InstallationPolicy -ne 'Trusted') {
                    Write-Host -ForegroundColor DarkGray 'Set-PSRepository PSGallery Trusted'
                    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
                }
            }
        }
        if ($WindowsPhase -eq 'OOBE') {
            $PSRepository = Get-PSRepository -Name PSGallery
            if ($PSRepository) {
                if ($PSRepository.InstallationPolicy -ne 'Trusted') {
                    Write-Host -ForegroundColor DarkGray 'Set-PSRepository PSGallery Trusted [CurrentUser]'
                    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
                }
            }
        }
    }
    function osdcloud-GetKeyVaultSecretList {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory=$true, Position=0)]
            [System.String]
            # Specifies the name of the key vault to which the secret belongs. This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.
            $VaultName
        )
        $Module = Import-Module Az.Accounts -PassThru -ErrorAction Ignore
        if (-not $Module) {
            Install-Module Az.Accounts -Force
        }
        
        $Module = Import-Module Az.KeyVault -PassThru -ErrorAction Ignore
        if (-not $Module) {
            Install-Module Az.KeyVault -Force
        }
    
        if (!(Get-AzContext -ErrorAction Ignore)) {
            Connect-AzAccount -DeviceCode
        }

        if (Get-AzContext -ErrorAction Ignore) {
            Get-AzKeyVaultSecret -VaultName "$VaultName" | Select-Object -ExpandProperty Name
        }
        else {
            Write-Error "Authenticate to Azure using 'Connect-AzAccount -DeviceCode'"
        }
    }
    New-Alias -Name 'ListSecrets' -Value 'osdcloud-GetKeyVaultSecretList' -Description 'OSDCloud' -Force
    function osdcloud-InvokeKeyVaultSecret {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory=$true, Position=0)]
            [System.String]
            # Specifies the name of the key vault to which the secret belongs. This cmdlet constructs the fully qualified domain name (FQDN) of a key vault based on the name that this parameter specifies and your current environment.
            $VaultName,

            [Parameter(Mandatory=$true, Position=1)]
            [System.String]
            # Specifies the name of the secret to get the content to use as a PSCloudScript
            $Name
        )
        $Module = Import-Module Az.Accounts -PassThru -ErrorAction Ignore
        if (-not $Module) {
            Install-Module Az.Accounts -Force
        }
        
        $Module = Import-Module Az.KeyVault -PassThru -ErrorAction Ignore
        if (-not $Module) {
            Install-Module Az.KeyVault -Force
        }
    
        if (!(Get-AzContext -ErrorAction Ignore)) {
            Connect-AzAccount -DeviceCode
        }

        if (Get-AzContext -ErrorAction Ignore) {
            $Result = Get-AzKeyVaultSecret -VaultName "$VaultName" -Name "$Name" -AsPlainText
            if ($Result) {
                Invoke-Expression -Command $Result
            }
        }
        else {
            Write-Error "Authenticate to Azure using 'Connect-AzAccount -DeviceCode'"
        }
    }
    New-Alias -Name 'InvokeSecret' -Value 'osdcloud-InvokeKeyVaultSecret' -Description 'OSDCloud' -Force
}
#endregion
#=================================================
#region OOBE Functions
if ($WindowsPhase -eq 'OOBE') {
    function osdcloud-SetWindowsDateTime {
        [CmdletBinding()]
        param ()
        Write-Host -ForegroundColor Yellow 'Verify the Date and Time is set properly including the Time Zone'
        Write-Host -ForegroundColor Yellow 'If this is not configured properly, Certificates and Domain Join may fail'
        Start-Process 'ms-settings:dateandtime' | Out-Null
        $ProcessId = (Get-Process -Name 'SystemSettings').Id
        if ($ProcessId) {
            Wait-Process $ProcessId
        }
    }
    function osdcloud-SetWindowsDisplay {
        [CmdletBinding()]
        param ()
        Write-Host -ForegroundColor Yellow 'Verify the Display Resolution and Scale is set properly'
        Start-Process 'ms-settings:display' | Out-Null
        $ProcessId = (Get-Process -Name 'SystemSettings').Id
        if ($ProcessId) {
            Wait-Process $ProcessId
        }
    }
    function osdcloud-SetWindowsLanguage {
        [CmdletBinding()]
        param ()
        Write-Host -ForegroundColor Yellow 'Verify the Language, Region, and Keyboard are set properly'
        Start-Process 'ms-settings:regionlanguage' | Out-Null
        $ProcessId = (Get-Process -Name 'SystemSettings').Id
        if ($ProcessId) {
            Wait-Process $ProcessId
        }
    }
    function osdcloud-AutopilotRegisterCommand {
        [CmdletBinding()]
        param (
            [System.String]
            $Command = 'Get-WindowsAutopilotInfo -Online -Assign'
        )
        Write-Host -ForegroundColor Cyan 'Registering Device in Autopilot in new PowerShell window ' -NoNewline
        $AutopilotProcess = Start-Process PowerShell.exe -ArgumentList "-Command $Command" -PassThru
        Write-Host -ForegroundColor Green "(Process Id $($AutopilotProcess.Id))"
        Return $AutopilotProcess
    }
    function osdcloud-AddCapability {
        [CmdletBinding(DefaultParameterSetName='Default')]
        param (
            [Parameter(Mandatory,ParameterSetName='ByName',Position=0)]
            [System.String[]]$Name
        )
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
    New-Alias -Name 'AddCapability' -Value 'osdcloud-AddCapability' -Description 'OSDCloud' -Force
    function osdcloud-NetFX {
        [CmdletBinding()]
        param ()
        $WindowsCapability = Get-WindowsCapability -Online -Name "*NetFX*" -ErrorAction SilentlyContinue | Where-Object {$_.State -ne 'Installed'}
        if ($WindowsCapability) {
            Write-Host -ForegroundColor Cyan "Add-WindowsCapability NetFX"
            foreach ($Capability in $WindowsCapability) {
                Write-Host -ForegroundColor DarkGray $Capability.DisplayName
                $Capability | Add-WindowsCapability -Online | Out-Null
            }
        }
    }
    New-Alias -Name 'NetFX' -Value 'osdcloud-NetFX' -Description 'OSDCloud' -Force
    function osdcloud-Rsat {
        [CmdletBinding(DefaultParameterSetName='Default')]
        param (
            [Parameter(Mandatory,ParameterSetName='Basic')]
            [System.Management.Automation.SwitchParameter]$Basic,
    
            [Parameter(Mandatory,ParameterSetName='Full')]
            [System.Management.Automation.SwitchParameter]$Full,
    
            [Parameter(Mandatory,ParameterSetName='ByName',Position=0)]
            [System.String[]]$Name
        )
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
    New-Alias -Name 'Rsat' -Value 'osdcloud-Rsat' -Description 'OSDCloud' -Force
    function osdcloud-UpdateDrivers {
        [CmdletBinding()]
        param ()
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
    New-Alias -Name 'UpdateDrivers' -Value 'osdcloud-UpdateDrivers' -Description 'OSDCloud' -Force
    function osdcloud-UpdateWindows {
        [CmdletBinding()]
        param ()
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
    New-Alias -Name 'UpdateWindows' -Value 'osdcloud-UpdateWindows' -Description 'OSDCloud' -Force
    function osdcloud-UpdateDefender {
        [CmdletBinding()]
        param ()
        if (Test-Path "$env:ProgramFiles\Windows Defender\MpCmdRun.exe") {
            Write-Host -ForegroundColor Cyan 'Updating Windows Defender'
            & "$env:ProgramFiles\Windows Defender\MpCmdRun.exe" -signatureupdate
        }
    }
    New-Alias -Name 'UpdateDefender' -Value 'osdcloud-UpdateDefender' -Description 'OSDCloud' -Force
}
#endregion
#=================================================
#region Anywhere Functions
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
function osdcloud-InstallModuleOSD {
    [CmdletBinding()]
    param ()
    if ($WindowsPhase -eq 'WinPE') {
        Write-Host -ForegroundColor DarkGray 'Install-Module OSD [AllUsers]'
        Install-Module OSD -Force -Scope AllUsers
        Import-Module OSD -Force
    }
    else {
        $InstalledModule = Import-Module OSD -PassThru -ErrorAction Ignore
        if (-not $InstalledModule) {
            Write-Host -ForegroundColor DarkGray 'Install-Module OSD [CurrentUser]'
            Install-Module OSD -Force -Scope CurrentUser
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
function osdcloud-InstallModuleAzKeyVault {
    [CmdletBinding()]
    param ()
    $InstalledModule = Import-Module Az.KeyVault -PassThru -ErrorAction Ignore
    
    if (-not $InstalledModule) {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray 'Install-Module Az.KeyVault [AllUsers]'
            Install-Module Az.KeyVault -Scope AllUsers
            Import-Module Az.KeyVault -Force
        }
        else {
            Write-Host -ForegroundColor DarkGray 'Install-Module Az.KeyVault [CurrentUser]'
            Install-Module Az.KeyVault -Force -Scope CurrentUser
        }
    }
}
function osdcloud-InstallModuleAzResources {
    [CmdletBinding()]
    param ()
    $InstalledModule = Import-Module Az.Resources -PassThru -ErrorAction Ignore

    if (-not $InstalledModule) {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray 'Install-Module Az.Resources [AllUsers]'
            Install-Module Az.Resources -Scope AllUsers -Force
            Import-Module Az.Resources -Force
        }
        else {
            Write-Host -ForegroundColor DarkGray 'Install-Module Az.Resources [CurrentUser]'
            Install-Module Az.Resources -Force -Scope CurrentUser
        }
    }
}
function osdcloud-InstallModuleAzStorage {
    [CmdletBinding()]
    param ()
    $InstalledModule = Import-Module Az.Storage -PassThru -ErrorAction Ignore

    if (-not $InstalledModule) {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray 'Install-Module Az.Storage [AllUsers]'
            Install-Module Az.Storage -Scope AllUsers
            Import-Module Az.Storage -Force
        }
        else {
            Write-Host -ForegroundColor DarkGray 'Install-Module Az.Storage [CurrentUser]'
            Install-Module Az.Storage -Force -Scope CurrentUser
        }
    }
}
function osdcloud-InstallModuleAzureAd {
    [CmdletBinding()]
    param ()
    $InstalledModule = Import-Module AzureAD -PassThru -ErrorAction Ignore

    if (-not $InstalledModule) {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray 'Install-Module AzureAD [AllUsers]'
            Install-Module AzureAD -Scope AllUsers
            Import-Module AzureAD -Force
        }
        else {
            $InstalledModule = Import-Module AzureAD -PassThru -ErrorAction Ignore
            if (-not $InstalledModule) {
                Write-Host -ForegroundColor DarkGray 'Install-Module AzureAD [CurrentUser]'
                Install-Module AzureAD -Force -Scope CurrentUser
            }
        }
    }
}
function osdcloud-InstallModuleMSGraphDeviceManagement {
    [CmdletBinding()]
    param ()
    $InstalledModule = Import-Module Microsoft.Graph.DeviceManagement -PassThru -ErrorAction Ignore

    if (-not $InstalledModule) {
        if ($WindowsPhase -eq 'WinPE') {
            Write-Host -ForegroundColor DarkGray 'Install-Module Microsoft.Graph.DeviceManagement [AllUsers]'
            Install-Module Microsoft.Graph.DeviceManagement -Scope AllUsers
            Import-Module Microsoft.Graph.DeviceManagement -Force
        }
        else {
            $InstalledModule = Import-Module Microsoft.Graph.DeviceManagement -PassThru -ErrorAction Ignore
            if (-not $InstalledModule) {
                Write-Host -ForegroundColor DarkGray 'Install-Module Microsoft.Graph.DeviceManagement [CurrentUser]'
                Install-Module Microsoft.Graph.DeviceManagement -Force -Scope CurrentUser
            }
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
function osdcloud-ShowAutopilotInfo {
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
function osdcloud-TestAutopilotProfile {
    [CmdletBinding()]
    param ()
    $Global:RegAutopilot = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics\Autopilot'

    #Oter Keys
    #Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\AutopilotPolicyCache'
    #Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics\Autopilot\EstablishedCorrelations'
    
    if ($Global:RegAutoPilot.CloudAssignedForcedEnrollment -eq 1) {
        $true
    }
    else {
        $false
    }
}
#endregion
#=================================================
#region WinPE Startup
if ($WindowsPhase -eq 'WinPE') {
    function osdcloud-StartWinPE {
        [CmdletBinding()]
        param (
            [Parameter()]
            [System.Management.Automation.SwitchParameter]
            $KeyVault,
            [Parameter()]
            [System.Management.Automation.SwitchParameter]
            $OSDCloud
        )
        if ($env:SystemDrive -eq 'X:') {
            osdcloud-SetExecutionPolicy
            osdcloud-SetEnvironmentVariables
            osdcloud-SetPowerShellProfile
            #osdcloud-InstallNuget
            osdcloud-InstallPackageManagement
            osdcloud-InstallPowerShellGet
            osdcloud-TrustPSGallery
            if ($OSDCloud) {
                osdcloud-InstallCurl
                osdcloud-InstallModuleOSD
                if (-not (Get-Command 'curl.exe' -ErrorAction SilentlyContinue)) {
                    Write-Warning 'curl.exe is missing from WinPE. This is required for OSDCloud to function'
                    Start-Sleep -Seconds 5
                    Break
                }
            }
            if ($KeyVault) {
                osdcloud-InstallModuleAzKeyVault
            }
        }
        else {
            Write-Warning 'Function is not supported in this Windows Phase'
        }
    }
    New-Alias -Name 'Start-WinPE' -Value 'osdcloud-StartWinPE' -Description 'OSDCloud' -Force
}
#endregion
#=================================================
#region OOBE Startup
if ($WindowsPhase -eq 'OOBE') {
    function osdcloud-StartOOBE {
        [CmdletBinding()]
        param (
            [System.Management.Automation.SwitchParameter]
            #Install Autopilot Support
            $Autopilot,

            [System.Management.Automation.SwitchParameter]
            #Show Windows Settings Display
            $Display,

            [System.Management.Automation.SwitchParameter]
            #Show Windows Settings Display
            $Language,

            [System.Management.Automation.SwitchParameter]
            #Show Windows Settings Display
            $DateTime,

            [System.Management.Automation.SwitchParameter]
            #Install Azure KeyVault support
            $KeyVault
        )
        if ($Display) {
            osdcloud-SetWindowsDisplay
        }
        if ($Language) {
            osdcloud-SetWindowsLanguage
        }
        if ($DateTime) {
            osdcloud-SetWindowsDateTime
        }
        osdcloud-SetExecutionPolicy
        osdcloud-SetPowerShellProfile
        osdcloud-InstallPackageManagement
        osdcloud-TrustPSGallery
        osdcloud-InstallModuleOSD

        #Add Azure KeuVault Support
        if ($KeyVault) {
            osdcloud-InstallModuleAzKeyVault
        }

        #Get Autopilot information from the device
        $TestAutopilotProfile = osdcloud-TestAutopilotProfile

        #If the device has an Autopilot Profile, show the information
        if ($TestAutopilotProfile -eq $true) {
            osdcloud-ShowAutopilotInfo
            $Autopilot = $false
        }
        
        #Install the required Autopilot Modules
        if ($Autopilot) {
            if ($TestAutopilotProfile -eq $false) {
                osdcloud-InstallModuleAutopilot
                osdcloud-InstallModuleAzureAd
                osdcloud-InstallScriptAutopilot
            }
        }
    }
    New-Alias -Name 'Start-OOBE' -Value 'osdcloud-StartOOBE' -Description 'OSDCloud' -Force
}
#endregion
#=================================================
function Connect-AzWinPE {
    [CmdletBinding()]
    param ()
    osdcloud-InstallModuleAzureAd
    osdcloud-InstallModuleAzKeyVault
    osdcloud-InstallModuleAzResources
    osdcloud-InstallModuleAzStorage
    osdcloud-InstallModuleMSGraphDeviceManagement

    Get-AzContext -ErrorAction Ignore | Disconnect-AzAccount -ErrorAction Ignore

    $Global:AzContext = Get-AzContext
    if (!($Global:AzContext)) {
        $null = Connect-AzAccount -Device -AuthScope Storage -ErrorAction Ignore
        $Global:AzContext = Get-AzContext
    }

    if ($Global:AzContext) {
        Write-Host -ForegroundColor Green 'Connected to Azure'
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan 'Azure Context ($Global:AzContext)'
        $Global:AzContext | Select-Object Account, Environment, Subscription, Tenant | Format-list

        $Global:AzAccount = $Global:AzContext.Account
        $Global:AzEnvironment = $Global:AzContext.Environment
        $Global:AzSubscription = $Global:AzContext.Subscription
        $Global:AzTenantId = $Global:AzContext.Tenant
        Write-Host -ForegroundColor Cyan 'Building $Global:Az*AccessToken'
        Write-Host -ForegroundColor Cyan 'Building $Global:Az*Headers'
        #=================================================
        #	AAD Graph
        #=================================================
        #Write-Host -ForegroundColor Cyan 'Building $Global:AzAadGraphAccessToken'
        $Global:AzAadGraphAccessToken = Get-AzAccessToken -ResourceTypeName AadGraph
        #Write-Host -ForegroundColor Cyan 'Building $Global:AzAadGraphHeaders'
        $Global:AzAadGraphHeaders = @{
            'Authorization' = 'Bearer ' + $Global:AzAadGraphAccessToken.Token
            'Content-Type'  = 'application/json'
            'ExpiresOn'     = $Global:AzAadGraphAccessToken.ExpiresOn
        }
        #$Global:AzAadGraphHeaders
        #=================================================
        #	Azure KeyVault
        #=================================================
        #Write-Host -ForegroundColor Cyan 'Building $Global:AzKeyVaultAccessToken'
        $Global:AzKeyVaultAccessToken = Get-AzAccessToken -ResourceTypeName KeyVault
        #Write-Host -ForegroundColor Cyan 'Building $Global:AzKeyVaultHeaders'
        $Global:AzKeyVaultHeaders = @{
            'Authorization' = 'Bearer ' + $Global:AzKeyVaultAccessToken.Token
            'Content-Type'  = 'application/json'
            'ExpiresOn'     = $Global:AzKeyVaultAccessToken.ExpiresOn
        }
        #$Global:AzKeyVaultHeaders
        #=================================================
        #	Azure MSGraph
        #=================================================
        #Write-Host -ForegroundColor Cyan 'Building $Global:AzMSGraphAccessToken'
        $Global:AzMSGraphAccessToken = Get-AzAccessToken -ResourceTypeName MSGraph
        #Write-Host -ForegroundColor Cyan 'Building $Global:AzMSGraphHeaders'
        $Global:AzMSGraphHeaders = @{
            'Authorization' = 'Bearer ' + $Global:AzMSGraphAccessToken.Token
            'Content-Type'  = 'application/json'
            'ExpiresOn'     = $Global:AzMSGraphHeaders.ExpiresOn
        }
        #$Global:AzMSGraphHeaders
        #=================================================
        #	Azure Storage
        #=================================================
        #Write-Host -ForegroundColor Cyan 'Building $Global:AzStorageAccessToken'
        $Global:AzStorageAccessToken = Get-AzAccessToken -ResourceTypeName Storage
        #Write-Host -ForegroundColor Cyan 'Building $Global:AzStorageHeaders'
        $Global:AzStorageHeaders = @{
            'Authorization' = 'Bearer ' + $Global:AzStorageAccessToken.Token
            'Content-Type'  = 'application/json'
            'ExpiresOn'     = $Global:AzStorageHeaders.ExpiresOn
        }
        #$Global:AzStorageHeaders
        #=================================================
        #	AzureAD
        #=================================================
        #Write-Verbose -Verbose 'Azure Access Tokens have been saved to $Global:AccessToken*'
        #Write-Verbose -Verbose 'Azure Auth Headers have been saved to $Global:Headers*'
        #$Global:MgGraph = Connect-MgGraph -AccessToken $Global:AzMSGraphAccessToken.Token -Scopes DeviceManagementConfiguration.Read.All,DeviceManagementServiceConfig.Read.All,DeviceManagementServiceConfiguration.Read.All
        $Global:AzureAD = Connect-AzureAD -AadAccessToken $Global:AzAadGraphAccessToken.Token -AccountId $Global:AzContext.Account.Id

        Write-Host -ForegroundColor Cyan 'Saving Azure Storage Accounts to $Global:AzStorageAccounts'
        $Global:AzStorageAccounts = Get-AzStorageAccount

        Write-Host -ForegroundColor Cyan 'Saving OSDCloud Azure Storage Resources to $Global:AzOSDCloudStorageAccounts'
        $Global:AzOSDCloudStorageAccounts = Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts' | Where-Object {$_.Tags.Keys -contains 'osdcloud'}

        Write-Host -ForegroundColor Cyan 'Saving Azure Storage Contexts to $Global:AzStorageContext'
        $Global:AzStorageContext = @{}
        $Global:AzBlobImages = @()

        foreach ($Item in $Global:AzOSDCloudStorageAccounts) {
            $Global:LastStorageContext = New-AzStorageContext -StorageAccountName $Item.ResourceName
            $Global:AzStorageContext."$($Item.ResourceName)" = $Global:LastStorageContext
            #Get-AzStorageBlobByTag -TagFilterSqlExpression ""osdcloudimage""=""win10ltsc"" -Context $StorageContext
            #Get-AzStorageBlobByTag -Context $Global:LastStorageContext

            $StorageContainers = Get-AzStorageContainer -Context $Global:LastStorageContext
        
            foreach ($Container in $StorageContainers) {
                Write-Host -ForegroundColor Cyan "Scanning for Windows images on Storage Account $($Item.ResourceName) Container: $($Container.Name)"
                $Global:AzBlobImages += Get-AzStorageBlob -Context $Global:LastStorageContext -Container $Container.Name -Blob *.wim -ErrorAction Ignore
            }
        }

        if ($Global:AzBlobImages) {
            Write-Host -ForegroundColor Cyan 'Windows Images are stored in $Global:AzBlobImages'

            $i = $null
            $Results = foreach ($Item in $Global:AzBlobImages) {
                $i++

                $ObjectProperties = @{
                    Selection   = $i
                    Name        = $Item.Name
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }

            $Results | Select-Object -Property Selection, Name | Format-Table | Out-Host

            do {
                $SelectReadHost = Read-Host -Prompt "Select a Windows Image to apply by Selection [Number]"
            }
            until (((($SelectReadHost -ge 0) -and ($SelectReadHost -in $Results.Selection))))

            $Results = $Results | Where-Object {$_.Selection -eq $SelectReadHost}

            $Global:AzOSDCloudImage = $Global:AzOSDCloudImage | Where-Object {$_.Name -eq $Results.Name}

            $Global:AzOSDCloudImage | Select-Object * | Export-Clixml X:\AzOSDCloudImage.xml

            $Global:AzOSDCloudImage | Select-Object * | Out-Host
            #=================================================
            #   Invoke-OSDCloud.ps1
            #=================================================
            Write-Host -ForegroundColor DarkGray "========================================================================="
            Write-Host -ForegroundColor Green "Invoke-OSDCloud ... Starting in 5 seconds..."
            Start-Sleep -Seconds 5
            Invoke-OSDCloud
        }
        else {
            Write-Warning 'Unable to find any Windows Images on the storage accounts'
        }
    }
    else {
        Write-Warning 'Unable to connect to AzureAD'
    }
}