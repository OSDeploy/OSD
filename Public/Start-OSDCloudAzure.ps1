function Start-OSDCloudAzure {
    <#
    .SYNOPSIS
    Installs the OSDCloudAzure Module and starts OS Deployment from Azure Storage

    .DESCRIPTION
    Installs the OSDCloudAzure Module and starts OS Deployment from Azure Storage

    .EXAMPLE
    Start-OSDCloudAzure

    .EXAMPLE
    Start-OSDCloudAzure -Force

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/Docs
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

        $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OSDCloud.log"
        $null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
        Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
        osdcloud-StartWinPE -OSDCloud -Azure
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