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
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Battery: Device has $($Win32Battery.EstimatedChargeRemaining)% battery remaining"
    }
    #================================================
    #   TPM
    #================================================
    if ($TPM -or $TPMDetails) {
        try {
            $Win32Tpm = Get-CimInstance -Namespace "ROOT\cimv2\Security\MicrosoftTpm" -ClassName Win32_Tpm

            if ($null -eq $Win32Tpm) {
                Write-Host -ForegroundColor Red "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM: Not Supported"
                Write-Host -ForegroundColor Red "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Autopilot: Not Supported"
            }
            elseif ($Win32Tpm.SpecVersion) {
                if ($null -eq $Win32Tpm.SpecVersion) {
                    Write-Host -ForegroundColor Red "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Unable to detect the TPM SpecVersion"
                    Write-Host -ForegroundColor Red "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Autopilot: Not Supported"
                }

                $majorVersion = $Win32Tpm.SpecVersion.Split(",")[0] -as [int]
                if ($majorVersion -lt 2) {
                    Write-Host -ForegroundColor Red "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM version is less than 2.0"
                    Write-Host -ForegroundColor Red "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Autopilot: Not Supported"
                }
                else {
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM IsActivated: $($Win32Tpm.IsActivated_InitialValue)"
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM IsEnabled: $($Win32Tpm.IsEnabled_InitialValue)"
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM IsOwned: $($Win32Tpm.IsOwned_InitialValue)"
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM Manufacturer: $($Win32Tpm.ManufacturerIdTxt)"
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM Manufacturer Version: $($Win32Tpm.ManufacturerVersion)"
                    Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM SpecVersion: $($Win32Tpm.SpecVersion)"
                    Write-Host -ForegroundColor Green "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM 2.0: Supported"
                    Write-Host -ForegroundColor Green "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Autopilot: Supported"
                }
            }
            else {
                Write-Host -ForegroundColor Red "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) TPM: Not Supported"
                Write-Host -ForegroundColor Red "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Autopilot: Not Supported"
            }
        }
        catch {
        }
    }
}