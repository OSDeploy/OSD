function Get-OSDWinEvent {
    [CmdletBinding()]
    param (

        [int32]$DayCount = 1,
        [string[]]$LogName = @('System','Application'),

        [ValidateSet('Autopilot','BlueScreen')]
        [string]$Quick
    )

    $Events = @()

    $StartTime = (Get-Date).AddDays(-$DayCount)

    if ($Quick -eq 'Autopilot') {
        $Events += Get-WinEvent -FilterHashtable @{StartTime = $StartTime; LogName = 'Microsoft-Windows-AAD/Operational'} -ErrorAction Ignore
        #$Events += Get-WinEvent -FilterHashtable @{StartTime = $StartTime; LogName = 'Microsoft-Windows-AppXDeployment-Server/Operational'} -ErrorAction Ignore
        $Events += Get-WinEvent -FilterHashtable @{StartTime = $StartTime; LogName = 'Microsoft-Windows-AssignedAccess/Admin'} -ErrorAction Ignore
        $Events += Get-WinEvent -FilterHashtable @{StartTime = $StartTime; LogName = 'Microsoft-Windows-AssignedAccess/Operational'} -ErrorAction Ignore
        $Events += Get-WinEvent -FilterHashtable @{StartTime = $StartTime; LogName = 'Microsoft-Windows-AssignedAccessBroker/Admin'} -ErrorAction Ignore
        $Events += Get-WinEvent -FilterHashtable @{StartTime = $StartTime; LogName = 'Microsoft-Windows-AssignedAccessBroker/Operational'} -ErrorAction Ignore
        $Events += Get-WinEvent -FilterHashtable @{StartTime = $StartTime; LogName = 'Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin'} -ErrorAction Ignore
        $Events += Get-WinEvent -FilterHashtable @{StartTime = $StartTime; LogName = 'Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Operational'} -ErrorAction Ignore
        $Events += Get-WinEvent -FilterHashtable @{StartTime = $StartTime; LogName = 'Microsoft-Windows-ModernDeployment-Diagnostics-Provider/Autopilot'} -ErrorAction Ignore
        $Events += Get-WinEvent -FilterHashtable @{StartTime = $StartTime; LogName = 'Microsoft-Windows-ModernDeployment-Diagnostics-Provider/ManagementService'} -ErrorAction Ignore
        $Events += Get-WinEvent -FilterHashtable @{StartTime = $StartTime; LogName = 'Microsoft-Windows-Provisioning-Diagnostics-Provider/Admin'} -ErrorAction Ignore
        $Events += Get-WinEvent -FilterHashtable @{StartTime = $StartTime; LogName = 'Microsoft-Windows-Shell-Core/Operational'} -ErrorAction Ignore
        $Events += Get-WinEvent -FilterHashtable @{StartTime = $StartTime; LogName = 'Microsoft-Windows-User Device Registration/Admin'} -ErrorAction Ignore
    }
    elseif ($Quick -eq 'BlueScreen') {
        $Events = Get-WinEvent -FilterHashtable @{
            Id = 1001
            ProviderName = 'Microsoft-Windows-WER-SystemErrorReporting'
            #StartTime = $StartTime
        }
    }
    else {
        $Events = Get-WinEvent -FilterHashtable @{
            LogName = $LogName
            StartTime = $StartTime
        } -ErrorAction Ignore
    }

    $Events | Sort-Object TimeCreated | Select-Object TimeCreated,LevelDisplayName,LogName,Id,Message,ProviderName
}