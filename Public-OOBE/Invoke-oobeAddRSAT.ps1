function Invoke-oobeAddRSAT {
    [CmdletBinding()]
    param ()
    #================================================
    #   Initialize
    #================================================
    $Title = 'Invoke-oobeAddRSAT'
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
        $AddWindowsCapability = Get-MyWindowsCapability -Category Rsat -Detail
        foreach ($Item in $AddWindowsCapability) {
            if ($Item.State -ne 'Installed') {
                Write-Host -ForegroundColor DarkCyan "$($Item.DisplayName)"
                $Item | Add-WindowsCapability -Online -ErrorAction Ignore | Out-Null
            }
            else {
                Write-Host -ForegroundColor DarkGray "$($Item.DisplayName)"
            }
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