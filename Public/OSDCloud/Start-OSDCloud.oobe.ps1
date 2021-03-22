function Start-OSDCloud.oobe {
    [CmdletBinding()]
    param ()

    $env:APPDATA = "$SystemRoot\System32\Config\SystemProfile\AppData\Roaming"
    $env:LOCALAPPDATA = "$SystemRoot\System32\Config\SystemProfile\AppData\Local"

    Write-Host "Starting OSDCloud OOBE" -ForegroundColor Cyan
    Start-Sleep -Seconds 5

    Write-Host "Testing connection to PowerShell Gallery" -ForegroundColor Cyan
    Start-Sleep -Seconds 5
    Wait-WebConnection -Uri powershellgallery.com -Verbose
    $Error.Clear()
    Start-Sleep -Seconds 5
    
    Write-Host "Install Get-WindowsAutoPilotInfo.ps1" -ForegroundColor Cyan
    Start-Sleep -Seconds 5
    Install-Script -Name Get-WindowsAutoPilotInfo
    $Error.Clear()
    Start-Sleep -Seconds 5

    Write-Host "Testing Get-WindowsAutoPilotInfo.ps1" -ForegroundColor Cyan
    Start-Sleep -Seconds 5
    Get-WindowsAutoPilotInfo.ps1 -Verbose
    $Error.Clear()
    Start-Sleep -Seconds 5

    Write-Host "Connect-MSGraph" -ForegroundColor Cyan
    Start-Sleep -Seconds 5
    Connect-MSGraph -Verbose
    $Error.Clear()
    Start-Sleep -Seconds 5

    [void]('Press Enter to start OOBE')

    Write-Host "Starting OOBE" -ForegroundColor Cyan
    Start-Sleep -Seconds 5
    Start-Process -WorkingDirectory $env:SystemRoot\System32\OOBE -FilePath WinDeploy.exe
    $Error.Clear()
    Start-Sleep -Seconds 5

    Set-ItemProperty -Path "HKLM:\System\Setup" -Name CmdLine -Value 'oobe\windeploy.exe'
    $Error.Clear()
    Start-Sleep -Seconds 5
    Set-ItemProperty -Path "HKLM:\System\Setup" -Name CmdLine -Value 'oobe\windeploy.exe'
    $Error.Clear()
    Start-Sleep -Seconds 5
}