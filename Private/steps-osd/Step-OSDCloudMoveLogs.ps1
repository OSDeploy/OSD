function Step-OSDCloudMoveLogs {
    <#
    .SYNOPSIS
    Initializes transcript and debug log capture before image deployment.

    .DESCRIPTION
    Creates the OSDCloud log directory, starts a PowerShell transcript, and when DebugMode is enabled,
    writes diagnostic details to OSDCloud debug log files.

    .EXAMPLE
    Step-OSDCloudMoveLogs
    Starts transcript logging and captures debug diagnostics when enabled.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Extracted pre-image transcript and debug logging from Invoke-RecastOSDCloud
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        # Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Skip. Not running in WinPE (X:)"
        return
    }
    #=================================================
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Saving PowerShell Transcript to C:\Windows\TEMP\osdcloud-logs"
    Write-Verbose -Message 'https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.host/start-transcript'
    if (-NOT (Test-Path 'C:\Windows\TEMP\osdcloud-logs')) {
        New-Item -Path 'C:\Windows\TEMP\osdcloud-logs' -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    $Global:OSDCloud.Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Deploy-OSDCloud.log"
    Start-Transcript -Path (Join-Path 'C:\Windows\TEMP\osdcloud-logs' $Global:OSDCloud.Transcript) -ErrorAction Ignore

    if ($Global:OSDCloud.DebugMode -eq $true) {
        Write-SectionHeader 'DebugMode: Capture Data to Logs'
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] OSD Module: $((Get-Module -Name OSD -ListAvailable | Select-Object -First 1).Version)"
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Manufacurer | Model | Product : $(Get-MyComputerManufacturer) | $(Get-MyComputerModel) | $(Get-MyComputerProduct)"
        Write-DarkGrayHost 'Writing Information to C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log'

        Write-DarkGrayHost ' OSDCloud Variables'
        '=========================================================================' | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log'
        'OSD Cloud Variables' | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log' -Append
        '=========================================================================' | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log' -Append
        $OSDCloud | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log' -Append

        Write-DarkGrayHost ' Windows 11 Readiness'
        '=========================================================================' | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log' -Append
        'Windows 11 Readiness' | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log' -Append
        '=========================================================================' | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log' -Append
        Get-Win11Readiness | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log' -Append

        Write-DarkGrayHost ' TPM Information'
        '=========================================================================' | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log' -Append
        'TPM Information' | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log' -Append
        '=========================================================================' | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log' -Append
        Get-CimInstance -Namespace root/CIMV2/Security/MicrosoftTpm -ClassName Win32_Tpm | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log' -Append

        Write-DarkGrayHost ' My Computer Info'
        '=========================================================================' | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log' -Append
        'My Computer Info' | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log' -Append
        '=========================================================================' | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log' -Append
        Get-ComputerInfo | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDebug.log' -Append

        $OSDISKPre | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDiskPartPre.log'
        $OSDISKPost | Out-File 'C:\Windows\TEMP\osdcloud-logs\OSDCloudDiskPartPost.log'
    }
    #=================================================
}
