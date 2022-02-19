function Invoke-oobeUpdateDrivers {
    [CmdletBinding()]
    param ()
    #================================================
    #   Initialize
    #================================================
    $Title = 'Invoke-oobeUpdateDrivers'
    $host.ui.RawUI.WindowTitle = "Running $Title"
    $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.size(2000,2000)
    #================================================
    #   Temp
    #================================================
    if (!(Test-Path "$env:SystemRoot\Temp")) {
        New-Item -Path "$env:SystemRoot\Temp" -ItemType Directory -Force
    }
    #================================================
    #   Transcript
    #================================================
    $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$Title.log"
    Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
    $host.ui.RawUI.WindowTitle = "Running $Title $env:SystemRoot\Temp\$Transcript"
    #================================================
    #   Main
    #================================================
    if ($env:UserName -eq 'defaultuser0') {
        if (!(Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore)) {
            try {
                Install-Module PSWindowsUpdate -Force
                Import-Module PSWindowsUpdate -Force
            }
            catch {
                Write-Warning 'Unable to install PSWindowsUpdate Driver Updates'
            }
        }
        if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore) {
            Install-WindowsUpdate -UpdateType Driver -AcceptAll -IgnoreReboot
        }
    }
    else {
        Write-Warning "OOBE defaultuser0 is required to run $Title"
        Start-Sleep -Seconds 5
    }

    #================================================
    #   Complete
    #================================================
    if ($Global:OOBEDeployWindowTitle) {
        $host.ui.RawUI.WindowTitle = $Global:OOBEDeployWindowTitle
    }
    else {
        $host.ui.RawUI.WindowTitle = "$Title $env:SystemRoot\Temp\$Transcript"
    }
    Stop-Transcript
    #================================================
}