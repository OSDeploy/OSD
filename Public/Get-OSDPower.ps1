function Get-OSDPower {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0)]
        [ValidateSet('Low','Balanced','High','LIST','QUERY')]
        [string]$Property = 'LIST'
    )
    if ($Property -eq 'High') {
        Write-Verbose 'Set-OSDPower: Enable High Performance Power Plan'
        Start-Process -WindowStyle Hidden -FilePath powercfg.exe -ArgumentList ('-SetActive','8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c') -Wait
    }
    if ($Property -eq 'Balanced') {
        Write-Verbose 'Set-OSDPower: Enable Balanced Power Plan'
        Start-Process -WindowStyle Hidden -FilePath powercfg.exe -ArgumentList ('-SetActive','381b4222-f694-41f0-9685-ff5bb260df2e') -Wait
    }
    if ($Property -eq 'Low') {
        Write-Verbose 'Set-OSDPower: Enable Power Saver Power Plan'
        Start-Process -WindowStyle Hidden -FilePath powercfg.exe -ArgumentList ('-SetActive','a1841308-3541-4fab-bc81-f71556f20b4a') -Wait
    }
    if ($Property -eq 'LIST') {
        Write-Verbose 'Set-OSDPower: Enable Power Saver Power Plan'
        powercfg.exe /LIST
    }
    if ($Property -eq 'QUERY') {
        Write-Verbose 'Set-OSDPower: Enable Power Saver Power Plan'
        powercfg.exe /QUERY
    }
}