#requires -RunAsAdministrator

<#
Install winget on Windows Sandbox
Windows Sandbox provides a lightweight desktop environment to safely run applications in isolation. Software installed inside the Windows Sandbox environment remains "sandboxed" and runs separately from the host machine. Windows Sandbox does not include winget, nor the Microsoft Store app, so you will need to download the latest winget package from the winget releases page on GitHub.

To install the stable release of winget on Windows Sandbox, follow these steps from a Windows PowerShell command prompt:
#>

$progressPreference = 'silentlyContinue'
$latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object {$_.EndsWith(".msixbundle")}
$latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
Write-Information "Downloading winget to artifacts directory..."
Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage $latestWingetMsixBundle

<#
If you would like a preview or different version of the Package Manager, go to https://github.com/microsoft/winget-cli/releases. Copy the URL of the version you would prefer and update the above Uri.

For more information on Windows Sandbox, including how to install a sandbox and what to expect from it's usage, see the Windows Sandbox docs.
#>