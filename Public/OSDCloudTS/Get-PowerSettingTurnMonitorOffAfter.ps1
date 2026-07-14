Function Get-PowerSettingTurnMonitorOffAfter {
    <#
    .SYNOPSIS
    Gets the active power plan monitor-off timeout in minutes.

    .DESCRIPTION
    Returns the "Turn off display after" timeout for the active power plan.
    The function reads both AC (plugged in) and DC (battery) values from
    power policy data in root\cimv2\power.

    .EXAMPLE
    Get-PowerSettingTurnMonitorOffAfter

    Returns a PSCustomObject with AC and DC monitor-off timeout values
    in minutes.

    .OUTPUTS
    PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param ()

    $powerNamespace = 'root\cimv2\power'

    # Use Get-WmiObject first for compatibility with existing WinPE/OSD usage.
    $currentPlan = Get-WmiObject -Namespace $powerNamespace -Class Win32_PowerPlan -ErrorAction SilentlyContinue |
        Where-Object { $_.IsActive } |
        Select-Object -First 1

    if (-not $currentPlan) {
        $currentPlan = Get-CimInstance -Namespace $powerNamespace -ClassName Win32_PowerPlan -ErrorAction SilentlyContinue |
            Where-Object { $_.IsActive } |
            Select-Object -First 1
    }

    if (-not $currentPlan) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to determine the active power plan."
    }

    $displayOffSetting = Get-CimInstance -Namespace $powerNamespace -ClassName Win32_PowerSetting |
        Where-Object { $_.ElementName -eq 'Turn off display after' } |
        Select-Object -First 1

    if (-not $displayOffSetting) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to locate the 'Turn off display after' power setting."
    }

    $guidPattern = '\{[0-9a-fA-F\-]{36}\}'
    $currentPlanGuid = [regex]::Match($currentPlan.InstanceId, $guidPattern).Value
    $displayOffGuid = [regex]::Match($displayOffSetting.InstanceId, $guidPattern).Value

    if ([string]::IsNullOrWhiteSpace($currentPlanGuid) -or [string]::IsNullOrWhiteSpace($displayOffGuid)) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to parse power setting GUID values."
    }

    $instancePrefix = "Microsoft:PowerSettingDataIndex\$currentPlanGuid"

    $dc = Get-CimInstance -Namespace $powerNamespace -ClassName Win32_PowerSettingDataIndex |
        Where-Object { $_.InstanceId -eq "$instancePrefix\DC\$displayOffGuid" } |
        Select-Object -First 1

    $ac = Get-CimInstance -Namespace $powerNamespace -ClassName Win32_PowerSettingDataIndex |
        Where-Object { $_.InstanceId -eq "$instancePrefix\AC\$displayOffGuid" } |
        Select-Object -First 1

    if (-not $ac -or -not $dc) {
        throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Unable to retrieve AC and DC values for the display timeout setting."
    }

    [pscustomobject]@{
        AC = [int]($ac.SettingIndexValue / 60)
        DC = [int]($dc.SettingIndexValue / 60)
    }
}
