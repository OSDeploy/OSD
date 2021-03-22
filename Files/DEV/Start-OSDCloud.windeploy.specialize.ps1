function Start-OSDCloud.windeploy.specialize {
    [CmdletBinding()]
    param (
        [string]$ComputerName
    )

    Write-Host "Starting OSDCloud Specialize" -ForegroundColor Cyan
    Start-Sleep -Seconds 5
    
    Write-Host "Renaming Computer to SLACKER" -ForegroundColor Cyan
    (Get-WmiObject Win32_ComputerSystem).Rename('SLACKER')
    $Error.Clear()
    Start-Sleep -Seconds 5

    Write-Host "Setting Registry" -ForegroundColor Cyan
    Set-ItemProperty -Path "HKLM:\System\Setup" -Name CmdLine -Value 'PowerShell -ExecutionPolicy Bypass -Command Start-OSDCloud.windeploy.oobe'
    $Error.Clear()
    Start-Sleep -Seconds 5

    [void]('Press Enter to start Specialize')

    Write-Host "Starting Specialize" -ForegroundColor Cyan
    Start-Process -WorkingDirectory $env:SystemRoot\System32\OOBE -FilePath WinDeploy.exe
    $Error.Clear()
    Set-ItemProperty -Path "HKLM:\System\Setup" -Name CmdLine -Value 'PowerShell -ExecutionPolicy Bypass -Command Start-OSDCloud.windeploy.oobe'
    $Error.Clear()
    Start-Sleep -Seconds 5
    Set-ItemProperty -Path "HKLM:\System\Setup" -Name CmdLine -Value 'PowerShell -ExecutionPolicy Bypass -Command Start-OSDCloud.windeploy.oobe'
    $Error.Clear()
}