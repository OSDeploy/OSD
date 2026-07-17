function Step-OSDCloudDriverPackAdd {
    [CmdletBinding()]
    param ()
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    if ($env:SystemDrive -ne 'X:') {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] This step will only run in WinPE (X:)"
        return
    }
    #=================================================
    $LogPath = "C:\Windows\Temp\osdcloud-logs"
    $DriverPath = "C:\Windows\Temp\osdcloud-driverpack-expand"

    if (Test-Path -Path $DriverPath) {
        if (-not (Test-Path -Path $LogPath)) {
            New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
        }
        Add-WindowsDriver -Path "C:\" -Driver "$DriverPath" -Recurse -ForceUnsigned -LogPath "$LogPath\Step-OSDCloudDriverPackAdd.log" -ErrorAction SilentlyContinue | Out-Null
    }
    #=================================================
    Write-Verbose "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
