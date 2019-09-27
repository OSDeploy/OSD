function Set-OSDPower {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0)]
        [ValidateSet('Balanced','High')]
        [string]$Property = 'High'
    )

    if ($Property -eq 'Balanced') {
        Write-Verbose 'Set-OSDPower: Enable Balanced Power Plan'
        Start-Process -WindowStyle Hidden -FilePath powercfg.exe -ArgumentList ('-SetActive','381b4222-f694-41f0-9685-ff5bb260df2e') -Wait
    }
    if ($Property -eq 'High') {
        Write-Verbose 'Set-OSDPower: Enable High Performance Power Plan'
        Start-Process -WindowStyle Hidden -FilePath powercfg.exe -ArgumentList ('-SetActive','8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c') -Wait
    }
}