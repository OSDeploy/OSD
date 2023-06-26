#Requires -RunAsAdministrator

[CmdletBinding()]
param()

#region YamlFile
$Configuration = @'
# yaml-language-server: $schema=https://aka.ms/configuration-dsc-schema/0.2
# Reference: https://github.com/microsoft/winget-cli-restsource#building-the-client
properties:
  resources:
    - resource: Microsoft.Windows.Developer/DeveloperMode
      directives:
        description: Enable Developer Mode
        allowPrerelease: true
      settings:
        Ensure: Present
    - resource: Microsoft.WinGet.DSC/WinGetPackage
      id: vsPackage
      directives:
        description: Install Visual Studio 2022 (any edition is OK)
        allowPrerelease: true
      settings:
        id: Microsoft.VisualStudio.2022.Community
        source: winget
    - resource: Microsoft.VisualStudio.DSC/VSComponents
      dependsOn:
        - vsPackage
      directives:
        description: Install required VS workloads from project .vsconfig file
        allowPrerelease: true
      settings:
        productId: Microsoft.VisualStudio.Product.Community
        channelId: VisualStudio.17.Release
        vsConfigFile: '${WinGetConfigRoot}\..\.vsconfig'
  configurationVersion: 0.2.0
'@
#endregion

#region Check for Admin Elevated
$whoiam = [system.security.principal.windowsidentity]::getcurrent().name
$isElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if ($isElevated) {
    Write-Output "Running as $whoiam and IS Elevated"
}
else {
    Write-Warning "Running as $whoiam and is NOT Elevated"
    Break
}
#endregion

#region TLS 1.2 Connection
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#endregion

#region Disable Progress Bar
# Disable the progress bar in Invoke-WebRequest which speeds things up https://github.com/PowerShell/PowerShell/issues/2138
$ProgressPreference = 'SilentlyContinue'
#endregion

#region Functions
function Get-InstalledVersion {
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('DesktopAppInstaller', 'NuGet', 'QuickAssistApp', 'UIXaml', 'VCLibs140', 'WebView2', 'WinGet')]
        [string]$AppName
    )

    switch ($AppName) {
        'DesktopAppInstaller' {
            $AppxPkg = Get-AppxPackage -Name 'Microsoft.DesktopAppInstaller' -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($AppxPkg.Version) {
                return [string]$AppxPkg.Version
            }
            else {
                # AppxPkg is not installed
                return [string]''
            }
        }
        'QuickAssistApp' {
            $AppxPkg = Get-AppxPackage -Name 'MicrosoftCorporationII.QuickAssist' -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($AppxPkg.Version) {
                return [string]$AppxPkg.Version
            }
            else {
                # AppxPkg is not installed
                return [string]''
            }
        }
        'UIXaml' {
            $AppxPkg = Get-AppxPackage -Name 'Microsoft.UI.Xaml.2.7' -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($AppxPkg.Version) {
                return [string]$AppxPkg.Version
            }
            else {
                # AppxPkg is not installed
                return [string]''
            }
        }
        'VCLibs140' {
            $AppxPkg = Get-AppxPackage -Name 'Microsoft.VCLibs.140.00.UWPDesktop' -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($AppxPkg.Version) {
                return [string]$AppxPkg.Version
            }
            else {
                # AppxPkg is not installed
                return [string]''
            }
        }
        'NuGet' {
            # NOTE: using -ForceBootstrap will automatically install the package provider if it's not present
            $NuGetProvider = Find-PackageProvider -Name 'NuGet' -ForceBootstrap -IncludeDependencies -WarningAction SilentlyContinue
            if ($NuGetProvider.Version) {
                return [string]$NuGetProvider.Version
            }
            else {
                # NuGet is not installed (this would be weird)
                return [string]''
            }
        }
        'WebView2' {
            # https://docs.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution#detect-if-a-suitable-webview2-runtime-is-already-installed
            if ([System.Environment]::Is64BitOperatingSystem) {
                $KeyPath = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
            }
            else {
                # UNTESTED!
                $KeyPath = 'HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
            }
            $WebViewRegKey = Get-ItemProperty -Path $KeyPath -ErrorAction SilentlyContinue
            if ($WebViewRegKey.pv) {
                return [string]$WebViewRegKey.pv
            }
            else {
                # WebView2 is not installed per-machine
                return [string]''
            }
        }
        'WinGet' {
            $WinGetEXE = Get-Command -Type Application -Name 'winget.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($WinGetEXE) {
                $WinGetVer = & winget.exe --version
                #[version]$WinGetVer = $WinGetVer -replace '[a-zA-Z\-]'
                return [string]$WinGetVer
            }
            else {
                # WinGet.exe is not installed
                return [string]''
            }
        }
    }
}
function Confirm-NuGet {
    $AppName = "NuGet"

    if ($installedVersion = Get-InstalledVersion -AppName NuGet) {
        Write-Host "$AppName $installedVersion is installed"
    }
    else {
        Write-Error "$AppName is NOT installed or Failed to install automatically!"
        return $false
    }

    # https://docs.microsoft.com/en-us/powershell/module/packagemanagement/register-packagesource
    $NuGetSrcURI = 'https://www.nuget.org/api/v2'
    $NuGetSource = Get-PackageSource -ProviderName NuGet

    if ($NuGetSource.Location -EQ $NuGetSrcURI) {
        Write-Host "$AppName Package Source is already set to $NuGetSrcURI"
        return $true
    }
    else {
        #Write-Warning "NuGet Package Source is not set as expected, attempting to set it"
        Register-PackageSource -Name NuGet -Location $NuGetSrcURI -ProviderName NuGet
        #check our work
        $NuGetSource = Get-PackageSource -ProviderName NuGet
        if ($NuGetSource.Location -EQ $NuGetSrcURI) {
            Write-Host "$AppName Package Source is now set to $NuGetSrcURI"
            return $true
        }
        else {
            Write-Error "Failed to set $AppName Package Source to $NuGetSrcURI"
            return $false
        }
    }
}
function Confirm-WinGet {
    $AppName = "WinGet.exe"
    $MinVer = '1.3.1251'

    if ($installedVersion = Get-InstalledVersion -AppName WinGet) {
        # WinGet is on the system, is it old?
        # have to remove letters and dashes to convert it to a comparable [version] type
        $installedVersion = $installedVersion -replace '[a-zA-Z\-]'
    }
    else {
        Write-Warning "$AppName is not installed. DesktopInstaller must be updated."
    }

    if (Confirm-DesktopAppInstaller) {
        if ($installedVersion = Get-InstalledVersion -AppName WinGet) {
            Write-Host "$AppName $installedVersion has been installed"
            return $true
        }
        else {
            Write-Error "$AppName could NOT be installed!"
            return $false
        }
    }
    else {
        Write-Error "DesktopAppInstaller could NOT be updated to install WinGet!"
        return $false
    }

}
function Confirm-UIXaml {
    $AppName = "UI.Xaml 2.7"
    $PkgName = 'Microsoft.UI.Xaml' # The Appx Package Name on https://www.nuget.org/packages/Microsoft.UI.Xaml/
    $MinVer = '2.7.0' # WinGet/DesktopAppInstaller requires 2.7.x, 2.8.0 causes a failure
    $MaxVer = '2.7.999' # Keeps it under 2.8

    if (-not $isElevated) {
        Write-Error "$AppName cannot be installed without admin elevation!"
        return $false
    }

    if (-not (Confirm-NuGet)) {
        Write-Error "$AppName cannot be installed without NuGet"
        return $false
    }

    # Check for / get the NuGet package
    $UIXamlPackage = Get-Package -Name $PkgName -MinimumVersion $MinVer -MaximumVersion $MaxVer -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($installedVersion = $UIXamlPackage.Version) {
        if ([version]$installedVersion -ge [version]$MinVer -and [version]$installedVersion -le [version]$MaxVer) {
            Write-Host "$AppName NuGet Package $installedVersion is already installed but needs to be registered for $whoiam"
        }
        else {
            Write-Host "$AppName NuGet Package $installedVersion is already installed but is not within versions $MinVer to $maxVer"
            $installedVersion = $null
        }
    }

    if (-not $installedVersion) {
        #Find-Package -Name $PkgName
        Write-Host "Installing $AppName NuGet Package ..."
        #Install-Package -Name $PkgName -RequiredVersion $MaxVer -Force | Out-Null
        Install-Package -Name $PkgName -MinimumVersion $MinVer -MaximumVersion $MaxVer -Force -Source Nuget | Out-Null

        # check our work
        $UIXamlPackage = Get-Package -Name $PkgName -MinimumVersion $MinVer -MaximumVersion $MaxVer -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($UIXamlPackage.Version) {
            Write-Host "$AppName NuGet Package $($UIXamlPackage.Version) has been installed"
        }
        else {
            Write-Error "Failed to install $AppName NuGet Package!"
            return $false
        }
    }

    # Once the Package is installed, register the appx for the user
    $UIXamlPath = Split-Path $(Get-Package -Name $PkgName -MinimumVersion $MinVer -MaximumVersion $MaxVer).Source -Parent
    if ([System.Environment]::Is64BitOperatingSystem) {
        $UIXamlPath = "$UIXamlPath\tools\AppX\x64\Release\"
    }
    else {
        # UNTESTED!
        $UIXamlPath = "$UIXamlPath\tools\AppX\x86\Release\"
    }
    $UIXamlAppX = $(Get-ChildItem -Path "$UIXamlPath\*.appx").Name
    Add-AppxPackage -Path "$UIXamlPath\$UIXamlAppX"

    # check our work...
    if ($installedVersion = Get-InstalledVersion -AppName UIXaml) {
        Write-Host "$AppName has been registered using $installedVersion"
        return $true
    }
    else {
        Write-Error "$AppName was NOT registered!"
        return $false
    }
}
function Confirm-VCLibs140 {
    $AppName = "VCLibs"
    # NOTE: The DesktopAppInstaller package has changed its minimum required version which caused this to incorrectly
    # accept older versions of VCLibs and fail to install. I may need to come up with a way of determining the
    # dependacies from that app manifest rather than statically defining the version here.
    $MinVer = '14.0.30704.0'

    if ($installedVersion = Get-InstalledVersion -AppName VCLibs140) {
        Write-Host "$AppName $installedVersion is already installed"
        if ([version]$installedVersion -ge [version]$MinVer) {
            Write-Host "$AppName $installedVersion meets the mnimum required $MinVer"
            return $true
        }
        else {
            Write-Warning "$AppName $installedVersion is already installed, but does not meet the minimum $MinVer"
        }
    }
    else {
        Write-Warning "$AppName is not installed, attempting to download and install..."
    }

    if (-not $isElevated) {
        Write-Error "$whoiam is NOT Elevated, cannot update or install $AppName..."
        return $false
    }

    # Download the VCLibs dependancy
    # https://docs.microsoft.com/en-us/troubleshoot/developer/visualstudio/cpp/libraries/c-runtime-packages-desktop-bridge
    if ([System.Environment]::Is64BitOperatingSystem) {
        $InstallerURI = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
    }
    else {
        # UNTESTED!
        $InstallerURI = 'https://aka.ms/Microsoft.VCLibs.x86.14.00.Desktop.appx'
    }
    $InstallerAPPX = "$($env:TEMP)\VCLibs140.appx"

    try {
        Invoke-WebRequest -UseBasicParsing -Uri $InstallerURI -OutFile $InstallerAPPX
    }
    catch {
        Write-Error "Download failed : $_"
        return $false
    }
    Add-AppxPackage -Path $InstallerAPPX

    # check our work...
    if ($installedVersion = Get-InstalledVersion -AppName VCLibs140) {
        Write-Host "$AppName $installedVersion has been installed"
        return $true
    }
    else {
        Write-Error "$AppName is NOT installed!"
        return $false
    }
}
function Confirm-DesktopAppInstaller {
    $AppName = "DesktopAppInstaller"
    $MinVer = '1.18.1251.0'
    $installedVersion = Get-InstalledVersion -AppName DesktopAppInstaller

    # WinGet or the "Windows Package Manager" is part of to the DesktopInstaller
    # https://docs.microsoft.com/en-us/windows/package-manager/

    # The DesktopInstaller can be installed manually from the store, or use the release from GitHub
    # https://github.com/microsoft/winget-cli

    # Once installed we can use WinGet to install other store apps (like Quick Assist)
    # However, v1.3.1251-preview was the first to be able to install free store apps without an account
    # https://github.com/microsoft/winget-cli/releases/tag/v1.3.1251-preview

    # v1.4 should GA with this capability, but 1.3.1251-preview would be the minimum, for now
    # https://github.com/microsoft/winget-cli/releases

    # The DesktopInstaller package is versioned differntly from winget itself (of course)
    # DesktopInstaller v1.18.1251.0 was the first to include Winget 1.3.1251
    # so that's our minimum DesktopAppInstaller version - at least the build revisons match (1251).

    if (-not (Confirm-VCLibs140)) {
        Write-Error "Cannot update $AppName without first updating VCLibs"
        return $false
    }

    if (-not (Confirm-UIXaml)) {
        Write-Error "Cannot update $AppName without first updating UI.Xaml"
        return $false
    }

    Write-Host "Attempting to download and install the latest $AppName from GitHub"

    # Download latest winget-cli (DesktopAppInstaller) from github https://github.com/microsoft/winget-cli/releases/latest
    $GitRepo = "microsoft/winget-cli"
    $ReleasesJSON = "https://api.github.com/repos/$GitRepo/releases"
    #$ReleaseFile = 'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
    $ReleaseMinVer = '1.3.1251'

    # See the full list of releases
    #Invoke-WebRequest $ReleasesJSON | ConvertFrom-Json | Format-Table -Property name,tag_name,prerelease,target_commitish

    try {
        $Releases = Invoke-WebRequest -UseBasicParsing -Uri $ReleasesJSON | ConvertFrom-Json
    }
    catch {
        Write-Error "Download failed : $_"
        return $false
    }

    $Release = $Releases | Where-Object { $_.prerelease -eq "true" } | Select-Object -First 1
    Write-Host "Latest Release of DesktopAppInstaller from GitHub is $($Release.tag_name)"
    # remove any leading non-numeric characters, then any letters or hyphens
    $ReleaseVer = (($Release.tag_name) -replace '^[^0-9]*') -replace '[a-zA-Z\-]'

    Write-Host "Downloading and Installing $AppName $($Release.tag_name)"

    try {
        $ThisJSON = Invoke-WebRequest -UseBasicParsing -Uri "https://api.github.com/repos/$GitRepo/releases/$($Release.id)" | ConvertFrom-Json
    } catch {
        Write-Error "Download failed : $_"
        return $false
    }

    $InstallerLicense = ''
    $InstallerFile = ''
    $InstallerSHA265 = ''
    foreach ($asset in $ThisJSON.assets) {
        switch -Wildcard ($asset.name) {
            '*_License1.xml' {
                #Write-Host "Downloading License: $($asset.browser_download_url)"
                $InstallerLicense = "$($env:TEMP)\$($asset.name)"
                try {
                    Invoke-WebRequest -UseBasicParsing -Uri $asset.browser_download_url -OutFile $InstallerLicense
                } catch {
                    Write-Error "Download failed : $_"
                    return $false
                }
            }

            'Microsoft.DesktopAppInstaller_*.msixbundle' {
                #Write-Host "Downloading App: $($asset.browser_download_url)"
                $InstallerFile = "$($env:TEMP)\$($asset.name)"
                try {
                    Invoke-WebRequest -UseBasicParsing -Uri $asset.browser_download_url -OutFile $InstallerFile
                } catch {
                    Write-Error "Download failed : $_"
                    return $false
                }
            }

            'Microsoft.DesktopAppInstaller_*.txt' {
                #Write-Host "Reading Hash File: $($asset.browser_download_url)"
                try {
                    [string]$InstallerSHA265 = Invoke-RestMethod -Uri $asset.browser_download_url
                } catch {
                    Write-Warning "Download failed : $_"
                }
            }

        }
    }

    if (-not (Test-Path -Path $InstallerLicense) -or -not (Test-Path -Path $InstallerFile) ) {
        Write-Error "Installtion files not found"
        return $false
    }

    if (-not $InstallerSHA265) {
        Write-Warning "Cannot validate installer (checksum unknown) but will continue anyway."
    } else {
        if ($InstallerSHA265.Length -ne 64) {
            Write-Warning "Cannot validate installer (checksum not SHA265) but will continue anyway."
        } else {
            $InstallerSHA265 = $InstallerSHA265.ToUpper()
            $InstalerFileHash = (Get-FileHash -Algorithm SHA256 -Path $InstallerFile).Hash
            $InstalerFileHash = $InstalerFileHash.ToUpper()
            if ($InstallerSHA265 -eq $InstalerFileHash) {
                Write-Host "Installer File Integrity was confirmed with SHA256 Hash"
            } else {
                Write-Error "Installer File Integrity FAILED! File hash ($InstalerFileHash) does not match published hash ($InstallerSHA265)"
                return $false
            }
        }
    }

    #Write-Host "Installing DesktopAppInstaller"
    Add-AppxProvisionedPackage -Online -PackagePath $InstallerFile -LicensePath $InstallerLicense
    Start-Sleep -Seconds 1
    Add-AppxPackage -Path $InstallerFile -ForceUpdateFromAnyVersion -ForceApplicationShutdown
    Start-Sleep -Seconds 1

    $installedVersion = Get-InstalledVersion -AppName DesktopAppInstaller
    if ('' -ne $installedVersion -and ([version]$installedVersion -ge [version]$MinVer)) {
        Write-Host "$AppName has been updated to $installedVersion"
        return $true
    }
    elseif ('' -eq $installedVersion) {
        Write-Error "$AppName was NOT installed!"
        return $false
    }
    else {
        Write-Error "$AppName $installedVersion is still too old!"
        return $false
    }
}
#endregion

#region WinGet
if (Confirm-WinGet) {
    # Disable UAC Secure Desktop
    $PolicyKeys = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\' -ErrorAction SilentlyContinue
    if (-not $PolicyKeys.PromptOnSecureDesktop) {
        Write-Host "UAC Secure Desktop is already disabled"
    }
    elseif ($PolicyKeys.PromptOnSecureDesktop -and -not($isElevated)) {
        Write-Warning "Cannot disable UAC Secure Desktop. Helper will not be able to see the screen if elevation is required"
    }
    elseif ($PolicyKeys.PromptOnSecureDesktop -and $isElevated) {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\' -Name PromptOnSecureDesktop -Value 0 -ErrorAction SilentlyContinue
        $PolicyKeys = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\' -ErrorAction SilentlyContinue
        if (-not $PolicyKeys.PromptOnSecureDesktop) {
        }
        else {
            Write-Warning "Failed to disable the UAC Secure Desktop. Helper will not be able to see the screen if elevation is required"
        }
    }

    # NOTE: The app seems to run in the context of whoever owns the already running explorer.exe process
    # Even when running this script as a different (admin) user, the spawned process will be the other user.
    # I'm not sure how this would behave on a multi-user host like Win10 multi-session...
    # Let's check so we can at least warn because it looks odd...
    # The GetOwner method sometimes fail in OOBE, so we'll 'try' but not break on it.
}
#endregion

$info = winget show
$Path = "C:\Users\$env:Username\AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState"
if ((test-path  -path $Path) -eq $true) {
    try {
        $originalsetting = "C:\Users\$ENV:USERNAME\AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"

      #  Write-Host -ForegroundColor DarkCyan  "search file $originalsetting"
      #  Write-Host -ForegroundColor DarkGray "Create Backup : settings.json to settingsbackup.json"

      #  Copy-Item  $originalsetting -Destination "$Path\Settingsbackup.json" 
    
    }
    catch {

    }

    Write-Host -ForegroundColor DarkCyan "Enable experimental features to Winget"

    $json =@'
{
    "$schema": "https://aka.ms/winget-settings.schema.json",

    "experimentalFeatures": {
        "pinning": true,
        "dependencies": true,
        "directMSI": true,
        "uninstallPreviousArgument": true,
        "configuration": true,
        "windowsFeature": true
      },
}
'@
    $json | Out-File "$Path\settings.json" -Encoding ascii -Force


    $Configuration | Out-File -FilePath .\configuration.dsc.yaml -Encoding ascii

    winget configure show .\configuration.dsc.yaml

    Start-Sleep -Seconds 2
    Write-Host ""
    Write-Host -ForegroundColor DarkCyan "Starting installation of Git, Visual Studio Code, ADK, ADKPE and MDT"
    Write-Host ""

    winget configure .\configuration.dsc.yaml ---disable-interactivity --accept-configuration-agreements
}