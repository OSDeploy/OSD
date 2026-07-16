function Step-OSDCloudPreinstallLogs {
    <#
    .SYNOPSIS
    Initializes OSDCloud log storage before preinstall processing.

    .DESCRIPTION
    Creates the OSDCloud logs directory when running in WinPE so subsequent preinstall and deployment
    steps have a consistent logging location.

    .EXAMPLE
    Step-OSDCloudPreinstallLogs
    Ensures the OSDCloud log folder exists before continuing preinstall steps.

    .LINK
    https://github.com/OSDeploy/OSD/tree/master/docs

    .NOTES
    Author: David Segura - Recast Software
    2026-07-15 - Extracted Initialize OSDCloud Logs block from Invoke-RecastOSDCloud
    #>
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] Initialize OSDCloud Logs"
    $ParamNewItem = @{
        Path = $Global:OSDCloud.Logs
        ItemType = 'Directory'
        Force = $true
        ErrorAction = 'Stop'
    }

    if ($Global:OSDCloud.IsWinPE) {
        if (-not (Test-Path $Global:OSDCloud.Logs)) {
            $null = New-Item @ParamNewItem
        }
    }
    #=================================================
}
