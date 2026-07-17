function step-finalize-osdcloudlogs {
    [CmdletBinding()]
    param ()
    #=================================================
    $Message = "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    Write-Debug -Message $Message; Write-Verbose -Message $Message
    $Step = $global:OSDCloudCurrentStep
    #=================================================
    #region Main
    $LogsPath = "C:\Windows\Temp\osdcloud-logs"

    $Params = @{
        Path        = $LogsPath
        ItemType    = 'Directory'
        Force       = $true
        ErrorAction = 'SilentlyContinue'
    }

    if (-not (Test-Path $Params.Path)) {
        New-Item @Params | Out-Null
    }

    # Copy the DISM log to C:\Windows\Temp\osdcloud-logs
    if (Test-Path "$env:SystemRoot\logs\dism\dism.log") {
        Copy-Item -Path "$env:SystemRoot\logs\dism\dism.log" -Destination 'C:\Windows\Temp\osdcloud-logs\dism.log' -Force | Out-Null
    }

    $null = Stop-Transcript -ErrorAction SilentlyContinue

    # Copy existing WinPE Logs to C:\Windows\Temp\osdcloud-logs
    if ($env:SystemDrive -eq 'X:') {
        $null = robocopy "X:\Windows\Temp\osdcloud-logs" "C:\Windows\Temp\osdcloud-logs" *.* /e /ndl /r:0 /w:0
    }
    #endregion
    #=================================================
    $Message = "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    Write-Verbose -Message $Message; Write-Debug -Message $Message
    #=================================================
}