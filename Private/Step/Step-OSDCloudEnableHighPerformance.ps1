function Step-OSDCloudEnableHighPerformance {
    <#
    .SYNOPSIS
    Enables the High Performance power plan when OSDCloud is running in WinPE on AC power.

    .DESCRIPTION
    Verifies that the current environment is WinPE and the device is not on battery before enabling the
    High Performance power plan. If requirements are not met, the function logs why activation is skipped.

    .EXAMPLE
    Step-OSDCloudEnableHighPerformance
    Runs the validation checks and enables the High Performance power plan when supported.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-14 - Improved reliability checks and added comment-based help
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    $HighPerformancePlanGuid = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'

    # Display remaining battery percentage if device is on battery
    if (($global:OSDCoreDevice.IsOnBattery -eq $true) -or ($global:OSDCloudDevice.IsOnBattery -eq $true)) {
        $classWin32Battery = (Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue | Select-Object -Property *)
        if ($classWin32Battery.BatteryStatus -eq 1) {
            Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Device has $($classWin32Battery.EstimatedChargeRemaining)% battery remaining"
        }
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] High Performance will not be enabled while on battery"
        return
    }

    # Device is not in WinPE
    if ($env:SystemDrive -ne 'X:') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] High Performance will not be enabled outside of WinPE"
        return
    }

    $powerSchemes = (powercfg.exe /L) 2>$null
    if (-not $powerSchemes) {
        Write-Warning "[$(Get-Date -format s)] Unable to enumerate power schemes with powercfg.exe"
        return
    }

    if ($powerSchemes -notmatch [regex]::Escape($HighPerformancePlanGuid)) {
        Write-Warning "[$(Get-Date -format s)] High Performance power plan $HighPerformancePlanGuid was not found"
        return
    }

    # Debug Mode: Skip High Performance activation when debugging OSDCloud
    if ($global:OSDCloud.Debug -eq $true) {
        Write-DarkGrayHost 'Device is running in debug mode. Performance will not be adjusted'
        return
    }

    # Enable High Performance power plan
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] powercfg.exe -SetActive $HighPerformancePlanGuid"
    powercfg.exe -SetActive $HighPerformancePlanGuid | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "[$(Get-Date -format s)] powercfg.exe returned exit code $LASTEXITCODE while enabling High Performance"
        return
    }

    Write-Verbose -Message "[$(Get-Date -format s)] High Performance power plan enabled"
    #=================================================
    Write-Verbose -Message "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
