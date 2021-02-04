#======================================================================================
#   Require Elevation
#======================================================================================
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Checking User Account Control settings" -ForegroundColor Green
    if ((Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System).EnableLUA -eq 0) {
        #UAC Disabled
        Write-Host "User Account Control is Disabled ... " -ForegroundColor Green
        Write-Host "You will need to correct your UAC Settings" -ForegroundColor Green
        Write-Host "Try running this script in an Elevated PowerShell session ... Exiting" -ForegroundColor Green
        Start-Sleep -s 10
        Exit 0
    } else {
        #UAC Enabled
        Write-Host "UAC is Enabled" -ForegroundColor Green
        Start-Sleep -s 3
        if ($Silent) {
            Write-Host "This script will relaunch with Elevated Permissions (Silent)" -ForegroundColor Green
            Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Silent" -Verb RunAs -Wait
        } elseif($Restart) {
            Write-Host "This script will relaunch with Elevated Permissions (Restart)" -ForegroundColor Green
            Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Restart" -Verb RunAs -Wait
        } else {
            Write-Host "This script will relaunch with Elevated Permissions" -ForegroundColor Green
            Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -Wait
        }
        Exit 0
    }
} else {
    Write-Host "Running with Elevated Permissions" -ForegroundColor Green
    Write-Host ""
}
#======================================================================================
#   Logs
#======================================================================================
$OSDAppName = $MyInvocation.MyCommand.Name
$OSDLogs = "$env:SystemRoot\Logs\LXP"
if (!(Test-Path $OSDLogs)) {New-Item $OSDLogs -ItemType Directory -Force | Out-Null}
$OSDLogName = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$OSDAppName.log"
Start-Transcript -Path (Join-Path $OSDLogs $OSDLogName)
#======================================================================================
#   Operating System
#======================================================================================
$OSCaption = $((Get-WmiObject -Class Win32_OperatingSystem).Caption).Trim()
$OSArchitecture = $((Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture).Trim()
$OSVersion = $((Get-WmiObject -Class Win32_OperatingSystem).Version).Trim()
$OSBuildNumber = $((Get-WmiObject -Class Win32_OperatingSystem).BuildNumber).Trim()
#======================================================================================
#   Variables
#======================================================================================
Write-Host "PSScriptRoot: $PSScriptRoot" -ForegroundColor Cyan
Write-Host "OSCaption: $OSCaption" -ForegroundColor Cyan
Write-Host "OSArchitecture: $OSArchitecture" -ForegroundColor Cyan
Write-Host "OSVersion: $OSVersion" -ForegroundColor Cyan
Write-Host "OSBuildNumber: $OSBuildNumber" -ForegroundColor Cyan
#======================================================================================
#   Verify OSBuild
#======================================================================================
if (($OSBuildNumber -eq 18362) -or ($OSBuildNumber -eq 18363)) {
    #======================================================================================
    #   Installed Languages
    #======================================================================================
    Write-Host "======================================================================================"
    $OSMUILanguages = $((Get-WmiObject -Class Win32_OperatingSystem).MUILanguages)
    
    $InstalledLanguagePacks = foreach ($Item in $OSMUILanguages) {
        [PSCustomObject] @{
            LanguagePack    = $Item
            Language        = ($Item -split "-")[0]
            Localization    = ($Item -split "-")[1]
        }
    }
    
    Write-Host "Installed Language Packs:" -ForegroundColor Cyan
    foreach ($item in $InstalledLanguagePacks) {
        Write-Host "$($Item.LanguagePack)"
    }
    Write-Host "Installed Languages:" -ForegroundColor Cyan
    foreach ($item in $InstalledLanguagePacks) {
        Write-Host "$($Item.Language)"
    }
    Write-Host "Installed Localizations:" -ForegroundColor Cyan
    foreach ($item in $InstalledLanguagePacks) {
        Write-Host "$($Item.Localization)"
    }
    #======================================================================================
    #   Gather LP Files
    #======================================================================================
    Write-Host "======================================================================================"
    Write-Host "Available Language Packs to Install:" -ForegroundColor Cyan

    if ($OSArchitecture -match '64') {
        $AllLanguagePackFiles = Get-ChildItem "$PSScriptRoot\1903 LP x64" *.cab -Recurse | Select-Object -Property *
    } else {
        $AllLanguagePackFiles = Get-ChildItem "$PSScriptRoot\1903 LP x86" *.cab -Recurse | Select-Object -Property *
    }
    $LanguagePackFiles = foreach ($Item in $AllLanguagePackFiles) {
        [PSCustomObject] @{
            Language    = $Item.Name -replace 'Microsoft-Windows-Client-Language-Pack_x64_' -replace '.cab'
            Package     = $Item.FullName
        }
    }

    #Remove installed languages from the list of available to install
    $AvailableLanguagePacks = $LanguagePackFiles | Where-Object {$_.Language -NotIn $InstalledLanguagePacks.LanguagePack}

    foreach ($Item in $AvailableLanguagePacks) {
        Write-Host "$($Item.Language)"
    }
    #======================================================================================
    #   Select Language Packs for Install
    #======================================================================================
    Write-Host "======================================================================================"
    $InstallLanguagePacks = $AvailableLanguagePacks  | Out-GridView -PassThru -Title 'Windows 10 1903-1909 LP: Select one or more Language Packs to install'

    foreach ($Item in $InstallLanguagePacks) {
        Write-Host -ForegroundColor Yellow "Installing $($Item.Language) Language Pack ... This may take several minutes"
        Add-WindowsPackage -Online -PackagePath $Item.Package -NoRestart
    }
    #======================================================================================
    #   Installed Languages
    #======================================================================================
    Write-Host "======================================================================================"
    $OSMUILanguages = $((Get-WmiObject -Class Win32_OperatingSystem).MUILanguages)
    
    $InstalledLanguagePacks = foreach ($Item in $OSMUILanguages) {
        [PSCustomObject] @{
            LanguagePack    = $Item
            Language        = ($Item -split "-")[0]
            Localization    = ($Item -split "-")[1]
        }
    }
    
    Write-Host "Installed Language Packs:" -ForegroundColor Cyan
    foreach ($item in $InstalledLanguagePacks) {
        Write-Host "$($Item.LanguagePack)"
    }
    Write-Host "Installed Languages:" -ForegroundColor Cyan
    foreach ($item in $InstalledLanguagePacks) {
        Write-Host "$($Item.Language)"
    }
    Write-Host "Installed Localizations:" -ForegroundColor Cyan
    foreach ($item in $InstalledLanguagePacks) {
        Write-Host "$($Item.Localization)"
    }
    #======================================================================================
    #   Gather LXP Files
    #======================================================================================
    $AllLocalExperiencePackFiles = Get-ChildItem "$PSScriptRoot\1903 LXP" *.appx -Recurse | Select-Object -Property *
    $LocalExperiencePackFiles = foreach ($Item in $AllLocalExperiencePackFiles) {
        [PSCustomObject] @{
            Language    = ($Item.Directory).Name
            Directory   = $Item.Directory
            Package     = $Item.FullName
            License     = Join-Path $Item.Directory 'License.xml'
        }
    }
    #Remove installed languages from the list of available to install
    $AvailableLocalExperiencePacks = $LocalExperiencePackFiles
    #$AvailableLocalExperiencePacks = $LocalExperiencePackFiles | Where-Object {$_.Language -In $InstalledLanguagePacks.LanguagePack}
    #$AvailableLocalExperiencePacks = $LocalExperiencePacks | Where-Object {$_.Language -NotIn $WinUserLanguageList.LanguageTag}
    #======================================================================================
    #   Available Local Experience Packs
    #======================================================================================
    Write-Host "======================================================================================"
    Write-Host "Available Local Experience Packs:" -ForegroundColor Cyan
    
<#     foreach ($Item in $AvailableLocalExperiencePacks) {
        Write-Host "$($Item.Language)"
    } #>
    Write-Host "======================================================================================"
    $InstallLocalExperiencePacks = $AvailableLocalExperiencePacks | Out-GridView -PassThru -Title 'Windows 10 1903-1909 LXP: Select one or more Local Experience Packs to install'
    #======================================================================================
    #   Install Local Experience Packs
    #======================================================================================
    if ($null -eq $InstallLocalExperiencePacks) {
        Write-Warning "No Languages were selected for installation"
    }
    foreach ($Item in $InstallLocalExperiencePacks) {
        Write-Warning "Installing LXP.  This process may take a few minutes ..."
        $Item | Format-List
        Add-AppxProvisionedPackage -Online -PackagePath $Item.Package -LicensePath $Item.License
        Write-Warning "A restart may be required to complete the installation of the Language LXP"
    }
    #======================================================================================
    #   Get-WindowsCapability -Online
    #======================================================================================
    Write-Host "======================================================================================"
    Write-Host "Installing Capabilities:" -ForegroundColor Cyan
    $GetWindowsCapability = Get-WindowsCapability -Online | Where-Object {($_.Name -match 'Language') -and ($_.State -eq 'NotPresent')} | Sort-Object -Property Name


    foreach ($InstalledLanguage in $InstalledLanguagePacks) {
        foreach ($Item in $GetWindowsCapability | Where-Object {$_.Name -match $InstalledLanguage.LanguagePack}) {
            Write-Host "Installing $($Item.Name)"
            if ($OSArchitecture -match '64') {
                $Item | Add-WindowsCapability -Online -Source "$PSScriptRoot\1903 FOD x64" -LimitAccess
            } else {
                $Item | Add-WindowsCapability -Online -Source "$PSScriptRoot\1903 FOD x86" -LimitAccess
            }
        }
    }
} else {
    Write-Warning "Windows 10 1903-1909 LXP: Operating System is not compatible with the Language files"
}
#======================================================================================
#   Complete
#======================================================================================
Write-Host ""
Write-Host "Complete ... $(Join-Path $PSScriptRoot $MyInvocation.MyCommand.Name)" -ForegroundColor Green
Stop-Transcript
Write-Host "Script will exit in 20 seconds" -ForegroundColor Green
Start-Sleep 20
#======================================================================================
#   Exit
#======================================================================================
Exit 0