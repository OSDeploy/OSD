function Start-OOBE.autopilot {
    [CmdletBinding()]
    param ()
    #=======================================================================
    #	Block
    #=======================================================================
    Block-StandardUser
    Block-PowerShellVersionLt5
    Block-WinPE
    #=======================================================================
    #	Set Environment
    #=======================================================================
    $env:APPDATA = "$SystemRoot\System32\Config\SystemProfile\AppData\Roaming"
    $env:LOCALAPPDATA = "$SystemRoot\System32\Config\SystemProfile\AppData\Local"
    #=======================================================================
    #	Start-OOBE.autopilot
    #=======================================================================
    Write-Host "Starting OSDCloud OOBE" -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

    Write-Host "Testing connection to PowerShell Gallery" -ForegroundColor Cyan
    Wait-WebConnection -Uri powershellgallery.com -Verbose
    $Error.Clear()
    
<#     Write-Host "Install-Module PackageManagement" -ForegroundColor Cyan
    Install-Module -Name PackageManagement -Force
    $Error.Clear() #>
    
    Write-Host "Install-Module PowerShellGet" -ForegroundColor Cyan
    Install-Module -Name PowerShellGet -Force
    $Error.Clear()
    
    Write-Host "Install-Module WindowsAutoPilotIntune" -ForegroundColor Cyan
    Install-Module -Name WindowsAutoPilotIntune -Force
    $Error.Clear()

    Write-Host "Install Get-WindowsAutoPilotInfo.ps1" -ForegroundColor Cyan
    Install-Script -Name Get-WindowsAutoPilotInfo -Force
    $Error.Clear()

<#     Write-Host "Testing Get-WindowsAutoPilotInfo.ps1" -ForegroundColor Cyan
    & "C:\Program Files\WindowsPowerShell\Scripts\Get-WindowsAutoPilotInfo.ps1"
    $Error.Clear() #>

<#     Write-Host "Connect-MSGraph" -ForegroundColor Cyan
    Connect-MSGraph -Verbose
    $Error.Clear() #>

    Write-Host "Run Get-WindowsAutoPilotInfo -Online in the new PowerShell session" -ForegroundColor Cyan
    Start-Sleep -Seconds 5
    Start-Process PowerShell.exe -Wait
    $Error.Clear()

    Write-Host 'Press Enter to Sysprep /oobe /reboot or CTRL+C to Break'
    pause
    Set-ExecutionPolicy RemoteSigned -Force
    Start-Process Sysprep.exe -WorkingDirectory "$env:SystemRoot\System32\Sysprep" -ArgumentList "/oobe /reboot"
    $Error.Clear()
}