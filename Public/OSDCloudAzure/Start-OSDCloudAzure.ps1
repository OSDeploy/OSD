function Start-OSDCloudAzure {
    <#
    .SYNOPSIS
    Start an OSDCloud deployment from Azure Storage.

    .DESCRIPTION
    Installs the OSDCloudAzure module, runs from WinPE, connects to Azure, discovers available
    OSDCloud resources, and starts the deployment workflow when an image is available.

    .PARAMETER Force
    Reset OSDCloudAzure state before continuing.

    .EXAMPLE
    Start-OSDCloudAzure
    Starts an Azure-backed OSDCloud deployment using the current selection.

    .EXAMPLE
    Start-OSDCloudAzure -Force
    Resets the current Azure image selection and restarts the deployment flow.

    .NOTES
    Author: David Segura - Recast Software
    Copyright: Recast Software
    PowerShell Compatibility: 5.1 and 7
    2026-07-10 - Updated help to repo standard

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs

    .LINK
    https://github.com/OSDeploy/OSD/blob/master/Docs/Start-OSDCloudAzure.md
    #>

    [CmdletBinding()]
    param (
        [System.Management.Automation.SwitchParameter]
        #Resets everything to initial settings
        $Force
    )
    if ($env:SystemDrive -eq 'X:') {
        if ($Force) {
            $Force = $false
            $Global:AzOSDCloudBlobImage = $null
        }

        $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Start-OSDCloudAzure.log"
        $null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
        Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
        osdcloud-StartWinPE -OSDCloud
        Connect-OSDCloudAzure
        Get-OSDCloudAzureResources
        $null = Stop-Transcript -ErrorAction Ignore

        if ($Global:AzOSDCloudBlobImage) {
            Write-Host -ForegroundColor DarkGray '========================================================================='
            Write-Host -ForegroundColor Green 'Start-OSDCloudAzure'
            & "$($MyInvocation.MyCommand.Module.ModuleBase)\Projects\OSDCloudAzure\MainWindow.ps1"
            Start-Sleep -Seconds 2
    
            if ($Global:StartOSDCloud.AzOSDCloudImage) {
                Write-Host -ForegroundColor DarkGray '========================================================================='
                Write-Host -ForegroundColor Green "Invoke-OSDCloud ... Starting in 5 seconds..."
                Start-Sleep -Seconds 5
                Invoke-OSDCloud
            }
            else {
                Write-Warning "Unable to get a Windows Image from OSDCloudAzure to handoff to Invoke-OSDCloud"
            }
        }
        else {
            Write-Warning 'Unable to find resources to OSDCloudAzure'
        }
    }
    else {
        Write-Warning "OSDCloudAzure must be run from WinPE"
    }
}
