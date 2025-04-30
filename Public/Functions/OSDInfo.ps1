function Invoke-OSDInfo {
    <#
    .SYNOPSIS
    Displays OSD information, useful in an OS Deployment

    .DESCRIPTION
    Displays OSD information, useful in an OS Deployment

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
    #>
    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]$Battery,
        [System.Management.Automation.SwitchParameter]$TPM
    )
    #================================================
    #   Battery
    #================================================
    $Win32Battery = (Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue | Select-Object -Property *)

    if ($Win32Battery.BatteryStatus -eq 1) {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] Battery: Device has $($Win32Battery.EstimatedChargeRemaining)% battery remaining"
    }
    #================================================
    #   TPM
    #================================================
    if ($TPM -or $TPMDetails) {
        try {
            $Win32Tpm = Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_Tpm

            if ($null -eq $Win32Tpm) {
                Write-Host -ForegroundColor Red "[$(Get-Date -format G)] TPM: Not Supported"
                Write-Host -ForegroundColor Red "[$(Get-Date -format G)] Autopilot: Not Supported"
            }
            elseif ($Win32Tpm.SpecVersion) {
                if ($null -eq $Win32Tpm.SpecVersion) {
                    Write-Host -ForegroundColor Red "[$(Get-Date -format G)] Unable to detect the TPM SpecVersion"
                    Write-Host -ForegroundColor Red "[$(Get-Date -format G)] Autopilot: Not Supported"
                }

                $majorVersion = $Win32Tpm.SpecVersion.Split(",")[0] -as [int]
                if ($majorVersion -lt 2) {
                    Write-Host -ForegroundColor Red "[$(Get-Date -format G)] TPM version is less than 2.0"
                    Write-Host -ForegroundColor Red "[$(Get-Date -format G)] Autopilot: Not Supported"
                }
                else {
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM IsActivated: $($Win32Tpm.IsActivated_InitialValue)"
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM IsEnabled: $($Win32Tpm.IsEnabled_InitialValue)"
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM IsOwned: $($Win32Tpm.IsOwned_InitialValue)"
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM Manufacturer: $($Win32Tpm.ManufacturerIdTxt)"
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM Manufacturer Version: $($Win32Tpm.ManufacturerVersion)"
                    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] TPM SpecVersion: $($Win32Tpm.SpecVersion)"
                    Write-Host -ForegroundColor Green "[$(Get-Date -format G)] TPM 2.0: Supported"
                    Write-Host -ForegroundColor Green "[$(Get-Date -format G)] Autopilot: Supported"
                }
            }
            else {
                Write-Host -ForegroundColor Red "[$(Get-Date -format G)] TPM: Not Supported"
                Write-Host -ForegroundColor Red "[$(Get-Date -format G)] Autopilot: Not Supported"
            }
        }
        catch {
        }
    }
}