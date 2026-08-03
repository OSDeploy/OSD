function Step-OSDCloudRestartLogs {
    <#
    .SYNOPSIS
    Moves OSDCloud transcript logs to the target OS and starts a new transcript.

    .DESCRIPTION
    Ensures C:\Windows\Temp\osdcloud-logs exists, moves existing transcript logs
    from X:\Windows\Temp\osdcloud-logs to the target logs path, and starts a new
    timestamped transcript file in the target path.

    .EXAMPLE
    Step-OSDCloudRestartLogs
    Moves current WinPE transcript logs to C:\Windows\Temp\osdcloud-logs and
    starts a new transcript in the same folder.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-17 - Added comment-based help block
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)]"
    #=================================================
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

    $null = robocopy "X:\Windows\Temp\osdcloud-logs" "$LogsPath" transcript.log /e /move /ndl /nfl /r:0 /w:0
    $TranscriptFullName = Join-Path $LogsPath "transcript-$((Get-Date).ToString('yyyy-MM-dd-HHmmss')).log"

    $null = Start-Transcript -Path $TranscriptFullName -ErrorAction SilentlyContinue
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
