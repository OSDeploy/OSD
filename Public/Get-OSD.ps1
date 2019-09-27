function Get-OSD {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0)]
        [ValidateSet('BalancedPower','HighPower')]
        [string]$Action
    )

    if (!($Action)) {
        $OSDModuleVersion = $($MyInvocation.MyCommand.Module.Version)
        Write-Host "OSD PowerShell Module $OSDModuleVersion" -ForegroundColor Green
        Write-Host "http://osd.osdeploy.com/release" -ForegroundColor Cyan
        Write-Host "OSD is a shared collection of OS Deployment related PowerShell Functions"
        Write-Host ""
        Write-Host "Follow the #OSD Contributors:" -ForegroundColor Green
        Write-Host "Andrew Jimenez | " -NoNewline
        Write-Host "@AndrewJimenez_" -ForegroundColor Cyan
    
        Write-Host "Ben Whitmore | " -NoNewline
        Write-Host "@byteben" -ForegroundColor Cyan
    
        Write-Host "Jerome Bezet-Torres | " -NoNewline
        Write-Host "@JM2K69" -ForegroundColor Cyan
    
        Write-Host "Manel Rodero | " -NoNewline
        Write-Host "@manelrodero" -ForegroundColor Cyan
    
        Write-Host "Nathan Bridges | " -NoNewline
        Write-Host "@nathanjbridges" -ForegroundColor Cyan
    
        Write-Host "Sune Thomsen | " -NoNewline
        Write-Host "@SuneThomsenDK" -ForegroundColor Cyan
        Write-Host ""
        Write-Host 'Update OSD Module to the latest version:    ' -NoNewline
        Write-Host 'Update-Module OSD -Force' -ForegroundColor Green
    }

    if ($Action -eq 'BalancedPower') {
        Write-Verbose 'Set-OSDPower: Enable Balanced Power Plan'
        Start-Process -WindowStyle Hidden -FilePath powercfg.exe -ArgumentList ('-SetActive','381b4222-f694-41f0-9685-ff5bb260df2e') -Wait
    }
    if ($Action -eq 'HighPower') {
        Write-Verbose 'Set-OSDPower: Enable High Performance Power Plan'
        Start-Process -WindowStyle Hidden -FilePath powercfg.exe -ArgumentList ('-SetActive','8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c') -Wait
    }
}